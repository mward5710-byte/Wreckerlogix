import 'package:flutter/foundation.dart';
import '../models/job.dart';

/// State management for the Dispatch module.
class DispatchProvider extends ChangeNotifier {
  final List<Job> _jobs = [];
  bool _isLoading = false;
  String? _error;

  List<Job> get jobs => List.unmodifiable(_jobs);
  List<Job> get pendingJobs =>
      _jobs.where((j) => j.status == JobStatus.pending).toList();
  List<Job> get activeJobs => _jobs
      .where((j) =>
          j.status == JobStatus.assigned ||
          j.status == JobStatus.enRoute ||
          j.status == JobStatus.onScene ||
          j.status == JobStatus.inProgress)
      .toList();
  List<Job> get completedJobs =>
      _jobs.where((j) => j.status == JobStatus.completed).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  DispatchProvider() {
    _loadSampleData();
  }

  Job? getJobById(String id) {
    try {
      return _jobs.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Create a new job.
  void createJob(Job job) {
    _jobs.insert(0, job);
    notifyListeners();
  }

  /// Update job status.
  void updateJobStatus(String jobId, JobStatus status) {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return;

    final job = _jobs[index];
    _jobs[index] = job.copyWith(
      status: status,
      completedAt: status == JobStatus.completed ? DateTime.now() : null,
    );
    notifyListeners();
  }

  /// Assign a driver to a job.
  void assignDriver(String jobId, String driverId, String driverName) {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return;

    _jobs[index] = _jobs[index].copyWith(
      assignedDriverId: driverId,
      assignedDriverName: driverName,
      status: JobStatus.assigned,
      assignedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Delete a job.
  void deleteJob(String jobId) {
    _jobs.removeWhere((j) => j.id == jobId);
    notifyListeners();
  }

  void _loadSampleData() {
    _jobs.addAll([
      Job(
        id: 'job-001',
        customerName: 'Sarah Johnson',
        customerPhone: '(555) 123-4567',
        pickupAddress: '1234 Oak Street, Springfield, IL',
        dropoffAddress: 'Mike\'s Auto Shop, 567 Main St, Springfield, IL',
        vehicleYear: '2019',
        vehicleMake: 'Honda',
        vehicleModel: 'Civic',
        vehicleColor: 'Silver',
        licensePlate: 'IL-ABC1234',
        towType: TowType.flatbed,
        priority: JobPriority.high,
        status: JobStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        estimatedCost: 125.00,
      ),
      Job(
        id: 'job-002',
        customerName: 'Tom Williams',
        customerPhone: '(555) 987-6543',
        pickupAddress: 'I-55 Mile Marker 42, Southbound',
        dropoffAddress: 'Williams Residence, 890 Pine Ave, Springfield, IL',
        vehicleYear: '2022',
        vehicleMake: 'Ford',
        vehicleModel: 'F-150',
        vehicleColor: 'Black',
        licensePlate: 'IL-XYZ9876',
        towType: TowType.heavyDuty,
        priority: JobPriority.emergency,
        status: JobStatus.enRoute,
        assignedDriverId: 'driver-001',
        assignedDriverName: 'Mike Rodriguez',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        assignedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        estimatedCost: 250.00,
      ),
      Job(
        id: 'job-003',
        customerName: 'Lisa Chen',
        customerPhone: '(555) 456-7890',
        pickupAddress: 'Walmart Parking Lot, 2100 S MacArthur Blvd',
        dropoffAddress: 'AutoZone, 3400 Freedom Dr, Springfield, IL',
        vehicleYear: '2017',
        vehicleMake: 'Toyota',
        vehicleModel: 'Camry',
        vehicleColor: 'Blue',
        towType: TowType.lightDuty,
        priority: JobPriority.normal,
        status: JobStatus.completed,
        assignedDriverId: 'driver-002',
        assignedDriverName: 'Jake Thompson',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        assignedAt:
            DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
        completedAt: DateTime.now().subtract(const Duration(hours: 1)),
        estimatedCost: 95.00,
      ),
    ]);
  }
}
