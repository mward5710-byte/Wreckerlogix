import 'package:flutter/foundation.dart';
import '../models/eld_log.dart';

/// State management for ELD / HOS logging and compliance.
class EldProvider extends ChangeNotifier {
  List<EldLogEntry> _logs = [];
  HosSummary _hosSummary = const HosSummary(
    drivingHoursToday: 0,
    onDutyHoursToday: 0,
    drivingHoursThisWeek: 0,
    onDutyHoursThisWeek: 0,
  );
  DutyStatus _currentStatus = DutyStatus.offDuty;
  bool _eldConnected = false;
  String? _eldDeviceId;

  List<EldLogEntry> get logs => List.unmodifiable(_logs);
  HosSummary get hosSummary => _hosSummary;
  DutyStatus get currentStatus => _currentStatus;
  bool get eldConnected => _eldConnected;
  String? get eldDeviceId => _eldDeviceId;

  EldProvider() {
    _loadSampleData();
  }

  /// Simulate connecting to an ELD Bluetooth dongle.
  void connectDevice(String deviceId) {
    _eldDeviceId = deviceId;
    _eldConnected = true;
    notifyListeners();
  }

  /// Disconnect from the ELD device.
  void disconnectDevice() {
    _eldDeviceId = null;
    _eldConnected = false;
    notifyListeners();
  }

  /// Record a duty-status change and update the current status.
  void changeDutyStatus(DutyStatus newStatus, {String? annotation}) {
    final entry = EldLogEntry(
      id: 'eld-${DateTime.now().millisecondsSinceEpoch}',
      driverId: 'drv-001',
      driverName: 'Mike Torres',
      dutyStatus: newStatus,
      eventType: EldEventType.dutyStatusChange,
      timestamp: DateTime.now(),
      latitude: 39.7817,
      longitude: -89.6501,
      odometerMiles: _logs.isNotEmpty ? _logs.last.odometerMiles : 102345.0,
      vehicleId: 'truck-07',
      annotation: annotation,
    );
    _logs.add(entry);
    _currentStatus = newStatus;
    notifyListeners();
  }

  /// Add an intermediate position log (automatic every 60 min while driving).
  void addIntermediateLog({double? lat, double? lng, double? odometer}) {
    final entry = EldLogEntry(
      id: 'eld-int-${DateTime.now().millisecondsSinceEpoch}',
      driverId: 'drv-001',
      driverName: 'Mike Torres',
      dutyStatus: _currentStatus,
      eventType: EldEventType.intermediateLog,
      timestamp: DateTime.now(),
      latitude: lat ?? 39.7817,
      longitude: lng ?? -89.6501,
      odometerMiles: odometer,
      vehicleId: 'truck-07',
    );
    _logs.add(entry);
    notifyListeners();
  }

  /// Certify a log entry (driver acknowledges accuracy).
  void certifyLog(String logId) {
    final index = _logs.indexWhere((e) => e.id == logId);
    if (index != -1) {
      _logs[index] = _logs[index].copyWith(certified: true);
      notifyListeners();
    }
  }

  /// Get all log entries for a given date.
  List<EldLogEntry> getLogsForDate(DateTime date) {
    return _logs
        .where((e) =>
            e.timestamp.year == date.year &&
            e.timestamp.month == date.month &&
            e.timestamp.day == date.day)
        .toList();
  }

  /// Get all log entries for a specific driver.
  List<EldLogEntry> getLogsForDriver(String driverId) {
    return _logs.where((e) => e.driverId == driverId).toList();
  }

  /// Populate realistic sample data for demo purposes.
  void _loadSampleData() {
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);

    _logs = [
      EldLogEntry(
        id: 'eld-sample-001',
        driverId: 'drv-001',
        driverName: 'Mike Torres',
        dutyStatus: DutyStatus.offDuty,
        eventType: EldEventType.enginePowerUp,
        timestamp: base.add(const Duration(hours: 5, minutes: 45)),
        latitude: 39.7817,
        longitude: -89.6501,
        odometerMiles: 102300.0,
        vehicleId: 'truck-07',
        annotation: 'Morning startup',
        certified: true,
      ),
      EldLogEntry(
        id: 'eld-sample-002',
        driverId: 'drv-001',
        driverName: 'Mike Torres',
        dutyStatus: DutyStatus.onDutyNotDriving,
        eventType: EldEventType.dutyStatusChange,
        timestamp: base.add(const Duration(hours: 6)),
        latitude: 39.7817,
        longitude: -89.6501,
        odometerMiles: 102300.0,
        vehicleId: 'truck-07',
        annotation: 'Pre-trip inspection',
        certified: true,
      ),
      EldLogEntry(
        id: 'eld-sample-003',
        driverId: 'drv-001',
        driverName: 'Mike Torres',
        dutyStatus: DutyStatus.driving,
        eventType: EldEventType.dutyStatusChange,
        timestamp: base.add(const Duration(hours: 6, minutes: 30)),
        latitude: 39.7900,
        longitude: -89.6400,
        odometerMiles: 102305.0,
        vehicleId: 'truck-07',
        certified: true,
      ),
      EldLogEntry(
        id: 'eld-sample-004',
        driverId: 'drv-001',
        driverName: 'Mike Torres',
        dutyStatus: DutyStatus.driving,
        eventType: EldEventType.intermediateLog,
        timestamp: base.add(const Duration(hours: 7, minutes: 30)),
        latitude: 39.9500,
        longitude: -89.3200,
        odometerMiles: 102365.0,
        vehicleId: 'truck-07',
      ),
      EldLogEntry(
        id: 'eld-sample-005',
        driverId: 'drv-001',
        driverName: 'Mike Torres',
        dutyStatus: DutyStatus.onDutyNotDriving,
        eventType: EldEventType.dutyStatusChange,
        timestamp: base.add(const Duration(hours: 10)),
        latitude: 40.1160,
        longitude: -88.2434,
        odometerMiles: 102410.0,
        vehicleId: 'truck-07',
        annotation: 'Drop-off at customer site',
        certified: true,
      ),
      EldLogEntry(
        id: 'eld-sample-006',
        driverId: 'drv-001',
        driverName: 'Mike Torres',
        dutyStatus: DutyStatus.sleeperBerth,
        eventType: EldEventType.dutyStatusChange,
        timestamp: base.add(const Duration(hours: 11)),
        latitude: 40.1160,
        longitude: -88.2434,
        odometerMiles: 102410.0,
        vehicleId: 'truck-07',
        annotation: 'Mandatory rest break',
        certified: true,
      ),
      EldLogEntry(
        id: 'eld-sample-007',
        driverId: 'drv-001',
        driverName: 'Mike Torres',
        dutyStatus: DutyStatus.driving,
        eventType: EldEventType.dutyStatusChange,
        timestamp: base.add(const Duration(hours: 13, minutes: 30)),
        latitude: 40.1200,
        longitude: -88.2500,
        odometerMiles: 102415.0,
        vehicleId: 'truck-07',
        annotation: 'Resuming after break',
      ),
      EldLogEntry(
        id: 'eld-sample-008',
        driverId: 'drv-001',
        driverName: 'Mike Torres',
        dutyStatus: DutyStatus.onDutyNotDriving,
        eventType: EldEventType.dutyStatusChange,
        timestamp: base.add(const Duration(hours: 15)),
        latitude: 39.7817,
        longitude: -89.6501,
        odometerMiles: 102520.0,
        vehicleId: 'truck-07',
        annotation: 'Back at yard — paperwork',
      ),
    ];

    _currentStatus = DutyStatus.onDutyNotDriving;
    _eldConnected = true;
    _eldDeviceId = 'ELD-BT-4073';

    _hosSummary = const HosSummary(
      drivingHoursToday: 6.5,
      onDutyHoursToday: 8.0,
      drivingHoursThisWeek: 32.0,
      onDutyHoursThisWeek: 42.0,
    );
  }
}
