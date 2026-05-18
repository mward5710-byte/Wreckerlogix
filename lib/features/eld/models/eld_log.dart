/// ELD (Electronic Logging Device) / HOS (Hours of Service) data models.

/// FMCSA duty status categories for HOS compliance.
enum DutyStatus { offDuty, sleeperBerth, driving, onDutyNotDriving }

/// ELD event types per FMCSA specifications.
enum EldEventType {
  dutyStatusChange,
  intermediateLog,
  enginePowerUp,
  engineShutDown,
  loginLogout,
  malfunctionCleared,
}

/// A single ELD log entry recorded by the device or driver.
class EldLogEntry {
  final String id;
  final String driverId;
  final String driverName;
  final DutyStatus dutyStatus;
  final EldEventType eventType;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final double? odometerMiles;
  final String? vehicleId;
  final String? annotation;
  final bool certified;

  const EldLogEntry({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.dutyStatus,
    required this.eventType,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.odometerMiles,
    this.vehicleId,
    this.annotation,
    this.certified = false,
  });

  /// Copy with optional overrides for certification and annotation.
  EldLogEntry copyWith({bool? certified, String? annotation}) {
    return EldLogEntry(
      id: id,
      driverId: driverId,
      driverName: driverName,
      dutyStatus: dutyStatus,
      eventType: eventType,
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
      odometerMiles: odometerMiles,
      vehicleId: vehicleId,
      annotation: annotation ?? this.annotation,
      certified: certified ?? this.certified,
    );
  }

  /// Human-readable label for the current duty status.
  String get statusLabel {
    switch (dutyStatus) {
      case DutyStatus.offDuty:
        return 'Off Duty';
      case DutyStatus.sleeperBerth:
        return 'Sleeper Berth';
      case DutyStatus.driving:
        return 'Driving';
      case DutyStatus.onDutyNotDriving:
        return 'On Duty (Not Driving)';
    }
  }
}

/// Aggregated Hours of Service summary for compliance tracking.
class HosSummary {
  final double drivingHoursToday;
  final double onDutyHoursToday;
  final double drivingHoursThisWeek;
  final double onDutyHoursThisWeek;

  const HosSummary({
    required this.drivingHoursToday,
    required this.onDutyHoursToday,
    required this.drivingHoursThisWeek,
    required this.onDutyHoursThisWeek,
  });

  /// Remaining driving hours today (11-hour rule).
  double get remainingDrivingToday => 11.0 - drivingHoursToday;

  /// Remaining on-duty hours today (14-hour rule).
  double get remainingOnDutyToday => 14.0 - onDutyHoursToday;

  /// Remaining driving hours this week (60-hour rule).
  double get remainingDrivingThisWeek => 60.0 - drivingHoursThisWeek;

  /// True if any HOS limit has been exceeded.
  bool get isViolation =>
      remainingDrivingToday < 0 ||
      remainingOnDutyToday < 0 ||
      remainingDrivingThisWeek < 0;

  /// Overall compliance status label.
  String get complianceStatus {
    if (isViolation) return 'Violation';
    if (remainingDrivingToday < 1.0 ||
        remainingOnDutyToday < 1.0 ||
        remainingDrivingThisWeek < 5.0) {
      return 'Warning';
    }
    return 'Compliant';
  }
}
