/// Types of vehicle maintenance services.
enum MaintenanceType {
  oilChange,
  tireRotation,
  brakeService,
  engineRepair,
  transmissionService,
  electricalRepair,
  bodyWork,
  inspection,
  preventive,
  other,
}

/// Current status of a maintenance record.
enum MaintenanceStatus { scheduled, inProgress, completed, overdue, cancelled }

/// Priority level for a maintenance task.
enum MaintenancePriority { low, normal, high, urgent }

/// Represents a single vehicle maintenance record.
class MaintenanceRecord {
  final String id;
  final String vehicleId;
  final String vehicleLabel;
  final MaintenanceType type;
  final MaintenanceStatus status;
  final MaintenancePriority priority;
  final String description;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final double? cost;
  final double? odometerAtService;
  final String? vendor;
  final String? notes;
  final double? nextServiceMiles;

  const MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.vehicleLabel,
    required this.type,
    this.status = MaintenanceStatus.scheduled,
    this.priority = MaintenancePriority.normal,
    required this.description,
    required this.scheduledDate,
    this.completedDate,
    this.cost,
    this.odometerAtService,
    this.vendor,
    this.notes,
    this.nextServiceMiles,
  });

  MaintenanceRecord copyWith({
    MaintenanceStatus? status,
    DateTime? completedDate,
    double? cost,
    String? notes,
  }) {
    return MaintenanceRecord(
      id: id,
      vehicleId: vehicleId,
      vehicleLabel: vehicleLabel,
      type: type,
      status: status ?? this.status,
      priority: priority,
      description: description,
      scheduledDate: scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      cost: cost ?? this.cost,
      odometerAtService: odometerAtService,
      vendor: vendor,
      notes: notes ?? this.notes,
      nextServiceMiles: nextServiceMiles,
    );
  }

  /// Human-readable maintenance type label.
  String get typeLabel {
    switch (type) {
      case MaintenanceType.oilChange:
        return 'Oil Change';
      case MaintenanceType.tireRotation:
        return 'Tire Rotation';
      case MaintenanceType.brakeService:
        return 'Brake Service';
      case MaintenanceType.engineRepair:
        return 'Engine Repair';
      case MaintenanceType.transmissionService:
        return 'Transmission Service';
      case MaintenanceType.electricalRepair:
        return 'Electrical Repair';
      case MaintenanceType.bodyWork:
        return 'Body Work';
      case MaintenanceType.inspection:
        return 'Inspection';
      case MaintenanceType.preventive:
        return 'Preventive';
      case MaintenanceType.other:
        return 'Other';
    }
  }

  /// Human-readable status label.
  String get statusLabel {
    switch (status) {
      case MaintenanceStatus.scheduled:
        return 'Scheduled';
      case MaintenanceStatus.inProgress:
        return 'In Progress';
      case MaintenanceStatus.completed:
        return 'Completed';
      case MaintenanceStatus.overdue:
        return 'Overdue';
      case MaintenanceStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Human-readable priority label.
  String get priorityLabel {
    switch (priority) {
      case MaintenancePriority.low:
        return 'Low';
      case MaintenancePriority.normal:
        return 'Normal';
      case MaintenancePriority.high:
        return 'High';
      case MaintenancePriority.urgent:
        return 'Urgent';
    }
  }

  /// Whether this record is overdue (scheduled in the past and not completed).
  bool get isOverdue =>
      scheduledDate.isBefore(DateTime.now()) &&
      status != MaintenanceStatus.completed &&
      status != MaintenanceStatus.cancelled;
}
