/// Represents a roadside assistance request.
enum AssistanceType { tow, jumpStart, tireChange, lockout, fuelDelivery, winchOut, other }

enum RequestStatus { requested, dispatched, enRoute, onScene, inProgress, completed, cancelled }

enum RequestPriority { low, normal, high, emergency }

class AssistanceRequest {
  final String id;
  final String customerName;
  final String customerPhone;
  final AssistanceType assistanceType;
  final RequestStatus status;
  final RequestPriority priority;
  final double latitude;
  final double longitude;
  final String address;
  final String? vehicleDescription;
  final String? notes;
  final String? assignedDriverId;
  final String? assignedDriverName;
  final DateTime requestedAt;
  final DateTime? estimatedArrival;
  final DateTime? completedAt;
  final double? estimatedCost;

  const AssistanceRequest({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.assistanceType,
    this.status = RequestStatus.requested,
    this.priority = RequestPriority.normal,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.vehicleDescription,
    this.notes,
    this.assignedDriverId,
    this.assignedDriverName,
    required this.requestedAt,
    this.estimatedArrival,
    this.completedAt,
    this.estimatedCost,
  });

  AssistanceRequest copyWith({
    RequestStatus? status,
    String? assignedDriverId,
    String? assignedDriverName,
    DateTime? estimatedArrival,
    DateTime? completedAt,
    String? notes,
    double? estimatedCost,
  }) {
    return AssistanceRequest(
      id: id,
      customerName: customerName,
      customerPhone: customerPhone,
      assistanceType: assistanceType,
      status: status ?? this.status,
      priority: priority,
      latitude: latitude,
      longitude: longitude,
      address: address,
      vehicleDescription: vehicleDescription,
      notes: notes ?? this.notes,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
      assignedDriverName: assignedDriverName ?? this.assignedDriverName,
      requestedAt: requestedAt,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      completedAt: completedAt ?? this.completedAt,
      estimatedCost: estimatedCost ?? this.estimatedCost,
    );
  }

  /// Human-readable assistance type label.
  String get assistanceTypeLabel {
    switch (assistanceType) {
      case AssistanceType.tow:
        return 'Tow';
      case AssistanceType.jumpStart:
        return 'Jump Start';
      case AssistanceType.tireChange:
        return 'Tire Change';
      case AssistanceType.lockout:
        return 'Lockout';
      case AssistanceType.fuelDelivery:
        return 'Fuel Delivery';
      case AssistanceType.winchOut:
        return 'Winch Out';
      case AssistanceType.other:
        return 'Other';
    }
  }

  /// Human-readable status label.
  String get statusLabel {
    switch (status) {
      case RequestStatus.requested:
        return 'Requested';
      case RequestStatus.dispatched:
        return 'Dispatched';
      case RequestStatus.enRoute:
        return 'En Route';
      case RequestStatus.onScene:
        return 'On Scene';
      case RequestStatus.inProgress:
        return 'In Progress';
      case RequestStatus.completed:
        return 'Completed';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Human-readable priority label.
  String get priorityLabel {
    switch (priority) {
      case RequestPriority.low:
        return 'Low';
      case RequestPriority.normal:
        return 'Normal';
      case RequestPriority.high:
        return 'High';
      case RequestPriority.emergency:
        return 'Emergency';
    }
  }

  /// ETA label: shows "X min" until arrival, or "Arrived" when on scene or later.
  String get etaLabel {
    if (status == RequestStatus.onScene ||
        status == RequestStatus.inProgress ||
        status == RequestStatus.completed) {
      return 'Arrived';
    }
    if (estimatedArrival == null) return 'N/A';
    final minutes = estimatedArrival!.difference(DateTime.now()).inMinutes;
    if (minutes <= 0) return 'Arrived';
    return '$minutes min';
  }
}
