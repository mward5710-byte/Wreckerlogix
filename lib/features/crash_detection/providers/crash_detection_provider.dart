import 'package:flutter/foundation.dart';
import '../models/crash_event.dart';

/// State management for crash detection and auto-alert.
class CrashDetectionProvider extends ChangeNotifier {
  final List<CrashEvent> _events = [];
  CrashDetectionSettings _settings = const CrashDetectionSettings(
    isEnabled: true,
    sensitivityThreshold: 3.0,
    autoAlert911: true,
    autoAlertDispatch: true,
    countdownSeconds: 30,
    emergencyContacts: [],
  );
  bool _isMonitoring = false;
  CrashEvent? _activeCrash;
  int? _countdownRemaining;

  List<CrashEvent> get events => List.unmodifiable(_events);
  CrashDetectionSettings get settings => _settings;
  bool get isMonitoring => _isMonitoring;
  CrashEvent? get activeCrash => _activeCrash;
  int? get countdownRemaining => _countdownRemaining;

  List<CrashEvent> get resolvedEvents => _events
      .where((e) =>
          e.status == CrashAlertStatus.resolved ||
          e.status == CrashAlertStatus.falseAlarm)
      .toList();

  List<CrashEvent> get activeEvents => _events
      .where((e) =>
          e.status != CrashAlertStatus.resolved &&
          e.status != CrashAlertStatus.falseAlarm)
      .toList();

  CrashDetectionProvider() {
    _loadSampleData();
  }

  void startMonitoring() {
    _isMonitoring = true;
    notifyListeners();
  }

  void stopMonitoring() {
    _isMonitoring = false;
    notifyListeners();
  }

  /// Report a new crash, set it as the active crash, and start countdown.
  void reportCrash({
    required String vehicleId,
    required String driverName,
    required double latitude,
    required double longitude,
    required double impactForceG,
    required double speedAtImpact,
    required CrashSeverity severity,
  }) {
    final event = CrashEvent(
      id: 'crash-${DateTime.now().millisecondsSinceEpoch}',
      vehicleId: vehicleId,
      driverName: driverName,
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      severity: severity,
      status: CrashAlertStatus.detected,
      impactForceG: impactForceG,
      speedAtImpact: speedAtImpact,
    );

    _events.insert(0, event);
    _activeCrash = event;
    _countdownRemaining = _settings.countdownSeconds;
    notifyListeners();
  }

  /// Driver cancels the alert — marks the active crash as a false alarm.
  void cancelAlert() {
    if (_activeCrash == null) return;

    final index = _events.indexWhere((e) => e.id == _activeCrash!.id);
    if (index == -1) return;

    _events[index] = _events[index].copyWith(
      status: CrashAlertStatus.falseAlarm,
    );
    _activeCrash = null;
    _countdownRemaining = null;
    notifyListeners();
  }

  /// Acknowledge a crash event.
  void acknowledgeAlert(String eventId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return;

    _events[index] = _events[index].copyWith(
      status: CrashAlertStatus.acknowledged,
      respondedAt: DateTime.now(),
    );

    if (_activeCrash?.id == eventId) {
      _activeCrash = _events[index];
      _countdownRemaining = null;
    }
    notifyListeners();
  }

  /// Mark that a responder has been dispatched.
  void dispatchResponder(String eventId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return;

    _events[index] = _events[index].copyWith(
      status: CrashAlertStatus.responderDispatched,
    );

    if (_activeCrash?.id == eventId) {
      _activeCrash = _events[index];
    }
    notifyListeners();
  }

  /// Resolve a crash event.
  void resolveEvent(String eventId, {String? notes}) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return;

    _events[index] = _events[index].copyWith(
      status: CrashAlertStatus.resolved,
      notes: notes,
    );

    if (_activeCrash?.id == eventId) {
      _activeCrash = null;
      _countdownRemaining = null;
    }
    notifyListeners();
  }

  /// Update crash detection settings.
  void updateSettings(CrashDetectionSettings settings) {
    _settings = settings;
    notifyListeners();
  }

  void _loadSampleData() {
    _events.addAll([
      CrashEvent(
        id: 'crash-001',
        vehicleId: 'VH-002',
        driverName: 'Jake Thompson',
        latitude: 39.7600,
        longitude: -89.6700,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        severity: CrashSeverity.moderate,
        status: CrashAlertStatus.resolved,
        impactForceG: 4.2,
        speedAtImpact: 25.0,
        address: '1400 S Grand Ave E, Springfield, IL',
        notes: 'Rear-ended at stoplight. Minor vehicle damage, no injuries.',
        autoAlertSent: true,
        respondedAt:
            DateTime.now().subtract(const Duration(days: 2, hours: 23, minutes: 52)),
      ),
      CrashEvent(
        id: 'crash-002',
        vehicleId: 'VH-001',
        driverName: 'Mike Rodriguez',
        latitude: 39.7817,
        longitude: -89.6501,
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        severity: CrashSeverity.minor,
        status: CrashAlertStatus.falseAlarm,
        impactForceG: 3.1,
        speedAtImpact: 5.0,
        address: 'Warehouse Loading Dock, Springfield, IL',
        notes: 'Hard bump over loading dock ramp triggered sensor.',
      ),
      CrashEvent(
        id: 'crash-003',
        vehicleId: 'VH-003',
        driverName: 'Carlos Mendez',
        latitude: 39.8000,
        longitude: -89.6400,
        timestamp: DateTime.now().subtract(const Duration(days: 14)),
        severity: CrashSeverity.severe,
        status: CrashAlertStatus.resolved,
        impactForceG: 7.8,
        speedAtImpact: 45.0,
        address: 'I-55 Mile Marker 98, Southbound',
        notes: 'Side collision on highway. Driver treated on scene.',
        autoAlertSent: true,
        respondedAt:
            DateTime.now().subtract(const Duration(days: 13, hours: 23, minutes: 55)),
      ),
      CrashEvent(
        id: 'crash-004',
        vehicleId: 'VH-004',
        driverName: 'David Park',
        latitude: 39.7500,
        longitude: -89.6800,
        timestamp: DateTime.now().subtract(const Duration(days: 30)),
        severity: CrashSeverity.critical,
        status: CrashAlertStatus.resolved,
        impactForceG: 12.5,
        speedAtImpact: 60.0,
        address: 'Route 66 & Veterans Pkwy, Springfield, IL',
        notes: 'Head-on collision. Driver hospitalized, full recovery.',
        autoAlertSent: true,
        respondedAt:
            DateTime.now().subtract(const Duration(days: 29, hours: 23, minutes: 57)),
      ),
    ]);
  }
}
