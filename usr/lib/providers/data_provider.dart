import 'package:flutter/foundation.dart';
import '../models/models.dart';

class DataProvider extends ChangeNotifier {
  List<Machine> _machines = [];
  List<SparePart> _spareParts = [];
  List<Replacement> _replacements = [];

  // Mock data initialization
  DataProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Initialize 4 machines
    _machines = [
      Machine(
        id: '1',
        name: 'Gongoni',
        location: 'Main Workshop',
        installationDate: DateTime(2023, 1, 15),
        status: 'Active',
      ),
      Machine(
        id: '2',
        name: 'Mikoroshini',
        location: 'Secondary Workshop',
        installationDate: DateTime(2023, 3, 22),
        status: 'Active',
      ),
      Machine(
        id: '3',
        name: 'Lebanoni',
        location: 'Production Floor',
        installationDate: DateTime(2022, 11, 8),
        status: 'Maintenance',
      ),
      Machine(
        id: '4',
        name: 'Buyuni',
        location: 'Storage Area',
        installationDate: DateTime(2023, 5, 10),
        status: 'Inactive',
      ),
    ];

    // Initialize spare parts with various compatibilities
    _spareParts = [
      SparePart(
        id: '1',
        name: 'Bearing Assembly',
        specification: 'SKF-6205',
        compatibleMachines: ['1', '2', '3'],
        currentStock: 15,
        unitCost: 25000.0,
        currency: 'TZS',
        supplierInfo: 'SKF Tanzania Ltd',
        criticalLevel: 5,
      ),
      SparePart(
        id: '2',
        name: 'Conveyor Belt',
        specification: 'Type-A 5m',
        compatibleMachines: ['1', '4'],
        currentStock: 3,
        unitCost: 150.0,
        currency: 'USD',
        supplierInfo: 'Industrial Belts Inc',
        criticalLevel: 2,
      ),
      SparePart(
        id: '3',
        name: 'Motor Capacitor',
        specification: '400V 50uF',
        compatibleMachines: ['2', '3', '4'],
        currentStock: 8,
        unitCost: 12000.0,
        currency: 'TZS',
        supplierInfo: 'Electrical Components Ltd',
        criticalLevel: 3,
      ),
      SparePart(
        id: '4',
        name: 'Gear Set',
        specification: 'Ratio 2:1',
        compatibleMachines: ['1', '2'],
        currentStock: 12,
        unitCost: 45000.0,
        currency: 'TZS',
        supplierInfo: 'Precision Gears Ltd',
        criticalLevel: 4,
      ),
      SparePart(
        id: '5',
        name: 'Control Panel',
        specification: 'Siemens S7-1200',
        compatibleMachines: ['3', '4'],
        currentStock: 2,
        unitCost: 500.0,
        currency: 'USD',
        supplierInfo: 'Siemens Tanzania',
        criticalLevel: 1,
      ),
    ];

    // Initialize some replacement records
    _replacements = [
      Replacement(
        id: '1',
        machineId: '1',
        sparePartId: '1',
        dateReplaced: DateTime(2024, 1, 10),
        quantityUsed: 1,
        costIncurred: 25000.0,
        technicianName: 'John Doe',
        reason: 'Bearing failure due to wear',
        nextMaintenance: DateTime(2024, 4, 10),
      ),
      Replacement(
        id: '2',
        machineId: '3',
        sparePartId: '3',
        dateReplaced: DateTime(2024, 2, 5),
        quantityUsed: 2,
        costIncurred: 24000.0,
        technicianName: 'Jane Smith',
        reason: 'Capacitor burnout',
        nextMaintenance: DateTime(2024, 5, 5),
      ),
    ];

    notifyListeners();
  }

  // Getters
  List<Machine> get machines => _machines;
  List<SparePart> get spareParts => _spareParts;
  List<Replacement> get replacements => _replacements;

  // Get machine by ID
  Machine? getMachineById(String id) {
    return _machines.firstWhere((machine) => machine.id == id);
  }

  // Get spare part by ID
  SparePart? getSparePartById(String id) {
    return _spareParts.firstWhere((part) => part.id == id);
  }

  // Get replacements for a machine
  List<Replacement> getReplacementsForMachine(String machineId) {
    return _replacements.where((replacement) => replacement.machineId == machineId).toList();
  }

  // Get compatible spare parts for a machine
  List<SparePart> getCompatibleSpareParts(String machineId) {
    return _spareParts.where((part) => part.compatibleMachines.contains(machineId)).toList();
  }

  // Get low stock spare parts
  List<SparePart> getLowStockSpareParts() {
    return _spareParts.where((part) => part.isLowStock).toList();
  }

  // Add replacement
  void addReplacement(Replacement replacement) {
    _replacements.add(replacement);
    // Update stock if needed
    final sparePart = getSparePartById(replacement.sparePartId);
    if (sparePart != null) {
      updateSparePartStock(replacement.sparePartId, sparePart.currentStock - replacement.quantityUsed);
    }
    notifyListeners();
  }

  // Update spare part stock
  void updateSparePartStock(String partId, int newStock) {
    final index = _spareParts.indexWhere((part) => part.id == partId);
    if (index != -1) {
      _spareParts[index] = SparePart(
        id: _spareParts[index].id,
        name: _spareParts[index].name,
        specification: _spareParts[index].specification,
        compatibleMachines: _spareParts[index].compatibleMachines,
        currentStock: newStock,
        unitCost: _spareParts[index].unitCost,
        currency: _spareParts[index].currency,
        supplierInfo: _spareParts[index].supplierInfo,
        criticalLevel: _spareParts[index].criticalLevel,
      );
      notifyListeners();
    }
  }

  // TODO: Add methods for authentication when backend is connected
  // TODO: Add methods for syncing with Firebase/Supabase
}
