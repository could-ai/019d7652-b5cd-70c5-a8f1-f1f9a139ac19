class Machine {
  final String id;
  final String name;
  final String location;
  final DateTime installationDate;
  final String status; // 'Active', 'Maintenance', 'Inactive'

  Machine({
    required this.id,
    required this.name,
    required this.location,
    required this.installationDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'installationDate': installationDate.toIso8601String(),
      'status': status,
    };
  }

  factory Machine.fromMap(Map<String, dynamic> map) {
    return Machine(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      installationDate: DateTime.parse(map['installationDate']),
      status: map['status'],
    );
  }
}

class SparePart {
  final String id;
  final String name;
  final String specification;
  final List<String> compatibleMachines;
  final int currentStock;
  final double unitCost;
  final String currency; // 'TZS' or 'USD'
  final String? supplierInfo;
  final int criticalLevel;

  SparePart({
    required this.id,
    required this.name,
    required this.specification,
    required this.compatibleMachines,
    required this.currentStock,
    required this.unitCost,
    required this.currency,
    this.supplierInfo,
    required this.criticalLevel,
  });

  bool get isLowStock => currentStock <= criticalLevel;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specification': specification,
      'compatibleMachines': compatibleMachines,
      'currentStock': currentStock,
      'unitCost': unitCost,
      'currency': currency,
      'supplierInfo': supplierInfo,
      'criticalLevel': criticalLevel,
    };
  }

  factory SparePart.fromMap(Map<String, dynamic> map) {
    return SparePart(
      id: map['id'],
      name: map['name'],
      specification: map['specification'],
      compatibleMachines: List<String>.from(map['compatibleMachines']),
      currentStock: map['currentStock'],
      unitCost: map['unitCost'],
      currency: map['currency'],
      supplierInfo: map['supplierInfo'],
      criticalLevel: map['criticalLevel'],
    );
  }
}

class Replacement {
  final String id;
  final String machineId;
  final String sparePartId;
  final DateTime dateReplaced;
  final int quantityUsed;
  final double costIncurred;
  final String technicianName;
  final String reason;
  final DateTime? nextMaintenance;
  final String? photoPath; // Local file path for photo

  Replacement({
    required this.id,
    required this.machineId,
    required this.sparePartId,
    required this.dateReplaced,
    required this.quantityUsed,
    required this.costIncurred,
    required this.technicianName,
    required this.reason,
    this.nextMaintenance,
    this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'machineId': machineId,
      'sparePartId': sparePartId,
      'dateReplaced': dateReplaced.toIso8601String(),
      'quantityUsed': quantityUsed,
      'costIncurred': costIncurred,
      'technicianName': technicianName,
      'reason': reason,
      'nextMaintenance': nextMaintenance?.toIso8601String(),
      'photoPath': photoPath,
    };
  }

  factory Replacement.fromMap(Map<String, dynamic> map) {
    return Replacement(
      id: map['id'],
      machineId: map['machineId'],
      sparePartId: map['sparePartId'],
      dateReplaced: DateTime.parse(map['dateReplaced']),
      quantityUsed: map['quantityUsed'],
      costIncurred: map['costIncurred'],
      technicianName: map['technicianName'],
      reason: map['reason'],
      nextMaintenance: map['nextMaintenance'] != null ? DateTime.parse(map['nextMaintenance']) : null,
      photoPath: map['photoPath'],
    );
  }
}
