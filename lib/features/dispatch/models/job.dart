/// Represents a tow/recovery job in the dispatch system.
enum JobStatus {
  pending,
  assigned,
  enRoute,
  onScene,
  inProgress,
  completed,
  cancelled
}

enum JobPriority { low, normal, high, emergency }

enum TowType {
  lightDuty,
  mediumDuty,
  heavyDuty,
  flatbed,
  motorcycle,
  winchOut,
  lockout,
  jumpStart,
  fuelDelivery,
  tireChange
}

class Job {
  final String id;
  final String customerName;
  final String customerPhone;
  final String pickupAddress;
  final String dropoffAddress;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final String vehicleYear;
  final String vehicleMake;
  final String vehicleModel;
  final String vehicleColor;
  final String? licensePlate;
  final TowType towType;
  final JobPriority priority;
  final JobStatus status;
  final String? assignedDriverId;
  final String? assignedDriverName;
  final String? notes;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? completedAt;
  final double? estimatedCost;
  final List<String> photoIds;

  const Job({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.pickupAddress,
    required this.dropoffAddress,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    required this.vehicleYear,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.vehicleColor,
    this.licensePlate,
    required this.towType,
    this.priority = JobPriority.normal,
    this.status = JobStatus.pending,
    this.assignedDriverId,
    this.assignedDriverName,
    this.notes,
    required this.createdAt,
    this.assignedAt,
    this.completedAt,
    this.estimatedCost,
    this.photoIds = const [],
  });

  Job copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? pickupAddress,
    String? dropoffAddress,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    String? vehicleYear,
    String? vehicleMake,
    String? vehicleModel,
    String? vehicleColor,
    String? licensePlate,
    TowType? towType,
    JobPriority? priority,
    JobStatus? status,
    String? assignedDriverId,
    String? assignedDriverName,
    String? notes,
    DateTime? createdAt,
    DateTime? assignedAt,
    DateTime? completedAt,
    double? estimatedCost,
    List<String>? photoIds,
  }) {
    return Job(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      licensePlate: licensePlate ?? this.licensePlate,
      towType: towType ?? this.towType,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
      assignedDriverName: assignedDriverName ?? this.assignedDriverName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      assignedAt: assignedAt ?? this.assignedAt,
      completedAt: completedAt ?? this.completedAt,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      photoIds: photoIds ?? this.photoIds,
    );
  }

  /// Human-readable status label.
  String get statusLabel {
    switch (status) {
      case JobStatus.pending:
        return 'Pending';
      case JobStatus.assigned:
        return 'Assigned';
      case JobStatus.enRoute:
        return 'En Route';
      case JobStatus.onScene:
        return 'On Scene';
      case JobStatus.inProgress:
        return 'In Progress';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Human-readable tow type.
  String get towTypeLabel {
    switch (towType) {
      case TowType.lightDuty:
        return 'Light Duty Tow';
      case TowType.mediumDuty:
        return 'Medium Duty Tow';
      case TowType.heavyDuty:
        return 'Heavy Duty Tow';
      case TowType.flatbed:
        return 'Flatbed';
      case TowType.motorcycle:
        return 'Motorcycle';
      case TowType.winchOut:
        return 'Winch Out';
      case TowType.lockout:
        return 'Lockout';
      case TowType.jumpStart:
        return 'Jump Start';
      case TowType.fuelDelivery:
        return 'Fuel Delivery';
      case TowType.tireChange:
        return 'Tire Change';
    }
  }

  String get vehicleDescription =>
      '$vehicleYear $vehicleMake $vehicleModel ($vehicleColor)';
}
