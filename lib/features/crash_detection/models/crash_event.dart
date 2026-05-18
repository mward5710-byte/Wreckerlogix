/// Represents a crash detection event and its lifecycle.
enum CrashSeverity { minor, moderate, severe, critical }

enum CrashAlertStatus {
  detected,
  alertSent,
  acknowledged,
  responderDispatched,
  resolved,
  falseAlarm,
}

class CrashEvent {
  final String id;
  final String vehicleId;
  final String driverName;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final CrashSeverity severity;
  final CrashAlertStatus status;
  final double impactForceG;
  final double speedAtImpact;
  final String? address;
  final String? notes;
  final bool autoAlertSent;
  final DateTime? respondedAt;

  const CrashEvent({
    required this.id,
    required this.vehicleId,
    required this.driverName,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.severity,
    this.status = CrashAlertStatus.detected,
    required this.impactForceG,
    required this.speedAtImpact,
    this.address,
    this.notes,
    this.autoAlertSent = false,
    this.respondedAt,
  });

  CrashEvent copyWith({
    CrashAlertStatus? status,
    String? notes,
    DateTime? respondedAt,
  }) {
    return CrashEvent(
      id: id,
      vehicleId: vehicleId,
      driverName: driverName,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      severity: severity,
      status: status ?? this.status,
      impactForceG: impactForceG,
      speedAtImpact: speedAtImpact,
      address: address,
      notes: notes ?? this.notes,
      autoAlertSent: autoAlertSent,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  /// Human-readable severity label.
  String get severityLabel {
    switch (severity) {
      case CrashSeverity.minor:
        return 'Minor';
      case CrashSeverity.moderate:
        return 'Moderate';
      case CrashSeverity.severe:
        return 'Severe';
      case CrashSeverity.critical:
        return 'Critical';
    }
  }

  /// Human-readable status label.
  String get statusLabel {
    switch (status) {
      case CrashAlertStatus.detected:
        return 'Detected';
      case CrashAlertStatus.alertSent:
        return 'Alert Sent';
      case CrashAlertStatus.acknowledged:
        return 'Acknowledged';
      case CrashAlertStatus.responderDispatched:
        return 'Responder Dispatched';
      case CrashAlertStatus.resolved:
        return 'Resolved';
      case CrashAlertStatus.falseAlarm:
        return 'False Alarm';
    }
  }
}

/// Configuration for crash detection behavior.
class CrashDetectionSettings {
  final bool isEnabled;
  final double sensitivityThreshold;
  final bool autoAlert911;
  final bool autoAlertDispatch;
  final int countdownSeconds;
  final List<String> emergencyContacts;

  const CrashDetectionSettings({
    this.isEnabled = true,
    this.sensitivityThreshold = 3.0,
    this.autoAlert911 = true,
    this.autoAlertDispatch = true,
    this.countdownSeconds = 30,
    this.emergencyContacts = const [],
  });
}
