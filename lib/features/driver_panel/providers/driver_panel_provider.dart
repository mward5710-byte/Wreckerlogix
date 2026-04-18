import 'package:flutter/foundation.dart';

/// Driver's current operational state for the Quick Panel.
enum DriverMode { offDuty, available, onJob }

/// State management for the Driver Quick Panel — mobile-first quick actions.
class DriverPanelProvider extends ChangeNotifier {
  DriverMode _mode = DriverMode.offDuty;
  bool _isClockedIn = false;
  DateTime? _clockInTime;
  String? _currentJobId;
  String? _currentJobCustomer;
  String? _currentJobPickup;
  String? _currentJobDropoff;
  String? _currentJobVehicle;
  String? _currentJobStatus;
  int _todayJobsCompleted = 0;
  double _todayEarnings = 0.0;
  double _todayMiles = 0.0;

  DriverMode get mode => _mode;
  bool get isClockedIn => _isClockedIn;
  DateTime? get clockInTime => _clockInTime;
  String? get currentJobId => _currentJobId;
  String? get currentJobCustomer => _currentJobCustomer;
  String? get currentJobPickup => _currentJobPickup;
  String? get currentJobDropoff => _currentJobDropoff;
  String? get currentJobVehicle => _currentJobVehicle;
  String? get currentJobStatus => _currentJobStatus;
  int get todayJobsCompleted => _todayJobsCompleted;
  double get todayEarnings => _todayEarnings;
  double get todayMiles => _todayMiles;
  bool get hasActiveJob => _currentJobId != null;

  /// Hours worked today (since clock-in).
  String get hoursWorkedToday {
    if (_clockInTime == null) return '0:00';
    final diff = DateTime.now().difference(_clockInTime!);
    final hours = diff.inHours;
    final mins = diff.inMinutes % 60;
    return '$hours:${mins.toString().padLeft(2, '0')}';
  }

  DriverPanelProvider() {
    // Load sample "today" stats
    _todayJobsCompleted = 3;
    _todayEarnings = 320.00;
    _todayMiles = 47.2;
  }

  /// Clock in — start the day.
  void clockIn() {
    _isClockedIn = true;
    _clockInTime = DateTime.now();
    _mode = DriverMode.available;
    notifyListeners();
  }

  /// Clock out — end the day.
  void clockOut() {
    _isClockedIn = false;
    _clockInTime = null;
    _mode = DriverMode.offDuty;
    _currentJobId = null;
    _currentJobCustomer = null;
    _currentJobPickup = null;
    _currentJobDropoff = null;
    _currentJobVehicle = null;
    _currentJobStatus = null;
    notifyListeners();
  }

  /// Accept / load a job into the quick panel.
  void loadJob({
    required String jobId,
    required String customer,
    required String pickup,
    required String dropoff,
    required String vehicle,
  }) {
    _currentJobId = jobId;
    _currentJobCustomer = customer;
    _currentJobPickup = pickup;
    _currentJobDropoff = dropoff;
    _currentJobVehicle = vehicle;
    _currentJobStatus = 'Assigned';
    _mode = DriverMode.onJob;
    notifyListeners();
  }

  /// Quick status update — one tap.
  void updateStatus(String newStatus) {
    _currentJobStatus = newStatus;
    notifyListeners();
  }

  /// Mark en route with one tap.
  void goEnRoute() {
    _currentJobStatus = 'En Route';
    notifyListeners();
  }

  /// Mark arrived on scene.
  void arriveOnScene() {
    _currentJobStatus = 'On Scene';
    notifyListeners();
  }

  /// Mark tow in progress (hooked up, loading).
  void startTow() {
    _currentJobStatus = 'In Progress';
    notifyListeners();
  }

  /// Complete the job.
  void completeJob() {
    _todayJobsCompleted++;
    _currentJobStatus = 'Completed';
    _mode = DriverMode.available;
    // Keep job info for a moment so driver sees confirmation
    notifyListeners();
  }

  /// Clear the completed job card.
  void clearCompletedJob() {
    _currentJobId = null;
    _currentJobCustomer = null;
    _currentJobPickup = null;
    _currentJobDropoff = null;
    _currentJobVehicle = null;
    _currentJobStatus = null;
    notifyListeners();
  }

  /// Simulate accepting the next queued job (for demo).
  void acceptDemoJob() {
    loadJob(
      jobId: 'job-demo-${DateTime.now().millisecondsSinceEpoch}',
      customer: 'Sarah Johnson',
      pickup: '1234 Oak Street, Springfield, IL',
      dropoff: "Mike's Auto Shop, 567 Main St",
      vehicle: '2019 Honda Civic (Silver)',
    );
  }
}
