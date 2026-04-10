import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/data_provider.dart';
import '../models/models.dart';

class AddReplacementScreen extends StatefulWidget {
  const AddReplacementScreen({super.key});

  @override
  State<AddReplacementScreen> createState() => _AddReplacementScreenState();
}

class _AddReplacementScreenState extends State<AddReplacementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _technicianController = TextEditingController();
  final _reasonController = TextEditingController();
  final _costController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  String? _selectedMachineId;
  String? _selectedSparePartId;
  DateTime _selectedDate = DateTime.now();
  DateTime? _nextMaintenanceDate;
  File? _photoFile;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _technicianController.dispose();
    _reasonController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isNextMaintenance) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isNextMaintenance ? (_nextMaintenanceDate ?? DateTime.now()) : _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isNextMaintenance) {
          _nextMaintenanceDate = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _photoFile = File(pickedFile.path);
      });
    }
  }

  void _calculateCost() {
    if (_selectedSparePartId != null) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final sparePart = dataProvider.getSparePartById(_selectedSparePartId!);
      if (sparePart != null && _quantityController.text.isNotEmpty) {
        final quantity = int.tryParse(_quantityController.text) ?? 1;
        final totalCost = sparePart.unitCost * quantity;
        _costController.text = totalCost.toStringAsFixed(2);
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final replacement = Replacement(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID generation
        machineId: _selectedMachineId!,
        sparePartId: _selectedSparePartId!,
        dateReplaced: _selectedDate,
        quantityUsed: int.parse(_quantityController.text),
        costIncurred: double.parse(_costController.text),
        technicianName: _technicianController.text,
        reason: _reasonController.text,
        nextMaintenance: _nextMaintenanceDate,
        photoPath: _photoFile?.path,
      );

      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      dataProvider.addReplacement(replacement);

      setState(() => _isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Replacement record added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final machines = dataProvider.machines;
    final spareParts = dataProvider.spareParts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Replacement'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Machine Dropdown
              DropdownButtonFormField<String>(
                value: _selectedMachineId,
                decoration: const InputDecoration(
                  labelText: 'Machine',
                  border: OutlineInputBorder(),
                ),
                items: machines.map((machine) {
                  return DropdownMenuItem(
                    value: machine.id,
                    child: Text(machine.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMachineId = value;
                    _selectedSparePartId = null; // Reset spare part when machine changes
                  });
                },
                validator: (value) => value == null ? 'Please select a machine' : null,
              ),
              const SizedBox(height: 16),

              // Spare Part Dropdown (filtered by selected machine)
              DropdownButtonFormField<String>(
                value: _selectedSparePartId,
                decoration: const InputDecoration(
                  labelText: 'Spare Part',
                  border: OutlineInputBorder(),
                ),
                items: spareParts
                    .where((part) => _selectedMachineId == null || part.compatibleMachines.contains(_selectedMachineId))
                    .map((part) {
                      return DropdownMenuItem(
                        value: part.id,
                        child: Text('${part.name} (${part.specification})'),
                      );
                    })
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSparePartId = value;
                  });
                  _calculateCost();
                },
                validator: (value) => value == null ? 'Please select a spare part' : null,
              ),
              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date Replaced',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quantity
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity Used',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter quantity';
                  if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Please enter valid quantity';
                  return null;
                },
                onChanged: (_) => _calculateCost(),
              ),
              const SizedBox(height: 16),

              // Cost (auto-filled)
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Cost Incurred',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Please enter cost' : null,
              ),
              const SizedBox(height: 16),

              // Technician Name
              TextFormField(
                controller: _technicianController,
                decoration: const InputDecoration(
                  labelText: 'Technician Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter technician name' : null,
              ),
              const SizedBox(height: 16),

              // Reason
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Replacement',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Please enter reason' : null,
              ),
              const SizedBox(height: 16),

              // Next Maintenance Date
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Next Scheduled Maintenance (Optional)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _nextMaintenanceDate != null
                        ? '${_nextMaintenanceDate!.day}/${_nextMaintenanceDate!.month}/${_nextMaintenanceDate!.year}'
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Photo Attachment
              const Text('Photo Attachment (Optional)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera),
                    label: const Text('Camera'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ],
              ),
              if (_photoFile != null) ...[
                const SizedBox(height: 8),
                Text('Photo selected: ${_photoFile!.path.split('/').last}'),
              ],
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Replacement', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
