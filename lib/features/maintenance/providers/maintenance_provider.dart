import 'package:flutter/foundation.dart';
import '../models/maintenance_record.dart';

/// State management for vehicle maintenance tracking.
class MaintenanceProvider extends ChangeNotifier {
  final List<MaintenanceRecord> _records = [];

  List<MaintenanceRecord> get records => List.unmodifiable(_records);

  List<MaintenanceRecord> get scheduledRecords =>
      _records.where((r) => r.status == MaintenanceStatus.scheduled).toList();

  List<MaintenanceRecord> get overdueRecords =>
      _records.where((r) => r.isOverdue).toList();

  List<MaintenanceRecord> get completedRecords =>
      _records.where((r) => r.status == MaintenanceStatus.completed).toList();

  MaintenanceProvider() {
    _loadSampleData();
  }

  /// Add a new maintenance record.
  void addRecord(MaintenanceRecord record) {
    _records.insert(0, record);
    notifyListeners();
  }

  /// Update the status of an existing record.
  void updateStatus(String recordId, MaintenanceStatus status) {
    final index = _records.indexWhere((r) => r.id == recordId);
    if (index == -1) return;

    _records[index] = _records[index].copyWith(status: status);
    notifyListeners();
  }

  /// Mark a record as completed with optional cost and notes.
  void completeRecord(String recordId, {double? cost, String? notes}) {
    final index = _records.indexWhere((r) => r.id == recordId);
    if (index == -1) return;

    _records[index] = _records[index].copyWith(
      status: MaintenanceStatus.completed,
      completedDate: DateTime.now(),
      cost: cost,
      notes: notes,
    );
    notifyListeners();
  }

  /// Cancel a maintenance record.
  void cancelRecord(String recordId) {
    final index = _records.indexWhere((r) => r.id == recordId);
    if (index == -1) return;

    _records[index] = _records[index].copyWith(
      status: MaintenanceStatus.cancelled,
    );
    notifyListeners();
  }

  /// Delete a maintenance record.
  void deleteRecord(String recordId) {
    _records.removeWhere((r) => r.id == recordId);
    notifyListeners();
  }

  /// Get all records for a specific vehicle.
  List<MaintenanceRecord> getRecordsForVehicle(String vehicleId) {
    return _records.where((r) => r.vehicleId == vehicleId).toList();
  }

  /// Get records scheduled within the next 30 days.
  List<MaintenanceRecord> getUpcomingMaintenance() {
    final now = DateTime.now();
    final cutoff = now.add(const Duration(days: 30));
    return _records
        .where((r) =>
            r.status == MaintenanceStatus.scheduled &&
            r.scheduledDate.isAfter(now) &&
            r.scheduledDate.isBefore(cutoff))
        .toList();
  }

  void _loadSampleData() {
    final now = DateTime.now();
    _records.addAll([
      MaintenanceRecord(
        id: 'maint-001',
        vehicleId: 'VH-001',
        vehicleLabel: 'Truck #1 — Flatbed',
        type: MaintenanceType.oilChange,
        status: MaintenanceStatus.scheduled,
        priority: MaintenancePriority.normal,
        description: 'Regular oil change at 75,000 miles',
        scheduledDate: now.add(const Duration(days: 3)),
        odometerAtService: 74850.0,
        vendor: 'QuickLube Springfield',
        nextServiceMiles: 5000.0,
      ),
      MaintenanceRecord(
        id: 'maint-002',
        vehicleId: 'VH-002',
        vehicleLabel: 'Truck #2 — Wheel Lift',
        type: MaintenanceType.brakeService,
        status: MaintenanceStatus.inProgress,
        priority: MaintenancePriority.high,
        description: 'Front brake pad replacement and rotor resurfacing',
        scheduledDate: now.subtract(const Duration(days: 1)),
        odometerAtService: 62100.0,
        vendor: 'Springfield Fleet Repair',
        nextServiceMiles: 30000.0,
      ),
      MaintenanceRecord(
        id: 'maint-003',
        vehicleId: 'VH-003',
        vehicleLabel: 'Truck #3 — Heavy Duty',
        type: MaintenanceType.inspection,
        status: MaintenanceStatus.scheduled,
        priority: MaintenancePriority.urgent,
        description: 'Annual DOT safety inspection',
        scheduledDate: now.subtract(const Duration(days: 5)),
        odometerAtService: 91200.0,
        vendor: 'IL DOT Inspection Station',
      ),
      MaintenanceRecord(
        id: 'maint-004',
        vehicleId: 'VH-001',
        vehicleLabel: 'Truck #1 — Flatbed',
        type: MaintenanceType.tireRotation,
        status: MaintenanceStatus.completed,
        priority: MaintenancePriority.low,
        description: 'Rotate all six tires and check tread depth',
        scheduledDate: now.subtract(const Duration(days: 14)),
        completedDate: now.subtract(const Duration(days: 13)),
        cost: 89.99,
        odometerAtService: 74200.0,
        vendor: 'QuickLube Springfield',
        nextServiceMiles: 7500.0,
      ),
      MaintenanceRecord(
        id: 'maint-005',
        vehicleId: 'VH-004',
        vehicleLabel: 'Truck #4 — Light Duty',
        type: MaintenanceType.electricalRepair,
        status: MaintenanceStatus.scheduled,
        priority: MaintenancePriority.high,
        description: 'Winch motor intermittent failure — diagnose and repair',
        scheduledDate: now.add(const Duration(days: 2)),
        odometerAtService: 45600.0,
        vendor: 'Springfield Fleet Repair',
      ),
      MaintenanceRecord(
        id: 'maint-006',
        vehicleId: 'VH-002',
        vehicleLabel: 'Truck #2 — Wheel Lift',
        type: MaintenanceType.preventive,
        status: MaintenanceStatus.completed,
        priority: MaintenancePriority.normal,
        description: 'Full fluid check — coolant, transmission, power steering',
        scheduledDate: now.subtract(const Duration(days: 30)),
        completedDate: now.subtract(const Duration(days: 29)),
        cost: 149.50,
        odometerAtService: 61000.0,
        vendor: 'QuickLube Springfield',
        notes: 'Transmission fluid slightly dark — monitor at next service',
        nextServiceMiles: 10000.0,
      ),
      MaintenanceRecord(
        id: 'maint-007',
        vehicleId: 'VH-003',
        vehicleLabel: 'Truck #3 — Heavy Duty',
        type: MaintenanceType.engineRepair,
        status: MaintenanceStatus.cancelled,
        priority: MaintenancePriority.normal,
        description: 'Turbo boost leak — replaced intercooler hose',
        scheduledDate: now.subtract(const Duration(days: 20)),
        notes: 'Cancelled — issue resolved with hose clamp tightening',
      ),
    ]);
  }
}
