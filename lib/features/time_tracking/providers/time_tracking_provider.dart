import 'package:flutter/foundation.dart';
import '../models/time_entry.dart';

/// State management for time tracking — shifts and hours.
class TimeTrackingProvider extends ChangeNotifier {
  final List<TimeEntry> _entries = [];
  TimeEntry? _activeShift;

  List<TimeEntry> get entries => List.unmodifiable(_entries);
  TimeEntry? get activeShift => _activeShift;
  bool get isClockedIn => _activeShift != null;

  TimeTrackingProvider() {
    _loadSampleData();
  }

  /// Clock in — start a new shift.
  void clockIn(String driverId, String driverName) {
    if (_activeShift != null) return; // Already clocked in

    final entry = TimeEntry(
      id: 'shift-${DateTime.now().millisecondsSinceEpoch}',
      driverId: driverId,
      driverName: driverName,
      clockIn: DateTime.now(),
    );

    _activeShift = entry;
    _entries.insert(0, entry);
    notifyListeners();
  }

  /// Clock out — end the active shift.
  void clockOut() {
    if (_activeShift == null) return;

    final index = _entries.indexWhere((e) => e.id == _activeShift!.id);
    if (index == -1) return;

    _entries[index] = _activeShift!.copyWith(
      clockOut: DateTime.now(),
      status: ShiftStatus.completed,
    );
    _activeShift = null;
    notifyListeners();
  }

  /// Start a break during active shift.
  void startBreak() {
    if (_activeShift == null) return;

    final index = _entries.indexWhere((e) => e.id == _activeShift!.id);
    if (index == -1) return;

    final breaks = List<BreakEntry>.from(_activeShift!.breaks);
    breaks.add(BreakEntry(start: DateTime.now()));

    _activeShift = _activeShift!.copyWith(
      breaks: breaks,
      status: ShiftStatus.paused,
    );
    _entries[index] = _activeShift!;
    notifyListeners();
  }

  /// End the current break.
  void endBreak() {
    if (_activeShift == null) return;

    final index = _entries.indexWhere((e) => e.id == _activeShift!.id);
    if (index == -1) return;

    final breaks = List<BreakEntry>.from(_activeShift!.breaks);
    if (breaks.isNotEmpty && breaks.last.end == null) {
      final lastBreak = breaks.removeLast();
      breaks.add(BreakEntry(start: lastBreak.start, end: DateTime.now()));
    }

    _activeShift = _activeShift!.copyWith(
      breaks: breaks,
      status: ShiftStatus.active,
    );
    _entries[index] = _activeShift!;
    notifyListeners();
  }

  /// Total hours for the current week.
  double get weeklyHours {
    final weekStart =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    final startOfWeek =
        DateTime(weekStart.year, weekStart.month, weekStart.day);
    return _entries
        .where((e) => e.clockIn.isAfter(startOfWeek))
        .fold(0.0, (sum, e) => sum + e.totalHours);
  }

  void _loadSampleData() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    _entries.addAll([
      TimeEntry(
        id: 'shift-sample-1',
        driverId: 'driver-001',
        driverName: 'Mike Rodriguez',
        clockIn: DateTime(yesterday.year, yesterday.month, yesterday.day, 7, 0),
        clockOut:
            DateTime(yesterday.year, yesterday.month, yesterday.day, 16, 30),
        status: ShiftStatus.completed,
        breaks: [
          BreakEntry(
            start:
                DateTime(yesterday.year, yesterday.month, yesterday.day, 12, 0),
            end: DateTime(
                yesterday.year, yesterday.month, yesterday.day, 12, 30),
          ),
        ],
      ),
      TimeEntry(
        id: 'shift-sample-2',
        driverId: 'driver-002',
        driverName: 'Jake Thompson',
        clockIn: DateTime(yesterday.year, yesterday.month, yesterday.day, 6, 0),
        clockOut:
            DateTime(yesterday.year, yesterday.month, yesterday.day, 15, 0),
        status: ShiftStatus.completed,
      ),
    ]);
  }
}
