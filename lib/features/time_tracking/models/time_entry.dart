/// Time tracking models for shift and per-job time management.
enum ShiftStatus { active, completed, paused }

class TimeEntry {
  final String id;
  final String driverId;
  final String driverName;
  final DateTime clockIn;
  final DateTime? clockOut;
  final ShiftStatus status;
  final List<BreakEntry> breaks;
  final String? notes;

  const TimeEntry({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.clockIn,
    this.clockOut,
    this.status = ShiftStatus.active,
    this.breaks = const [],
    this.notes,
  });

  TimeEntry copyWith({
    DateTime? clockOut,
    ShiftStatus? status,
    List<BreakEntry>? breaks,
    String? notes,
  }) {
    return TimeEntry(
      id: id,
      driverId: driverId,
      driverName: driverName,
      clockIn: clockIn,
      clockOut: clockOut ?? this.clockOut,
      status: status ?? this.status,
      breaks: breaks ?? this.breaks,
      notes: notes ?? this.notes,
    );
  }

  /// Total hours worked (excluding breaks).
  double get totalHours {
    final end = clockOut ?? DateTime.now();
    final totalMinutes = end.difference(clockIn).inMinutes;
    final breakMinutes =
        breaks.fold<int>(0, (sum, b) => sum + b.durationMinutes);
    return (totalMinutes - breakMinutes) / 60.0;
  }

  /// Overtime hours (anything over 8 hours).
  double get overtimeHours {
    final hours = totalHours;
    return hours > 8.0 ? hours - 8.0 : 0.0;
  }

  bool get isActive => status == ShiftStatus.active;
}

class BreakEntry {
  final DateTime start;
  final DateTime? end;

  const BreakEntry({required this.start, this.end});

  int get durationMinutes {
    final e = end ?? DateTime.now();
    return e.difference(start).inMinutes;
  }
}
