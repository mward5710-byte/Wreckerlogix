import 'package:flutter/foundation.dart';
import '../models/assistance_request.dart';

/// State management for the Roadside Assistance module.
class RoadsideAssistanceProvider extends ChangeNotifier {
  final List<AssistanceRequest> _requests = [];

  List<AssistanceRequest> get requests => List.unmodifiable(_requests);

  List<AssistanceRequest> get activeRequests => _requests
      .where((r) =>
          r.status != RequestStatus.completed &&
          r.status != RequestStatus.cancelled)
      .toList();

  List<AssistanceRequest> get completedRequests => _requests
      .where((r) =>
          r.status == RequestStatus.completed ||
          r.status == RequestStatus.cancelled)
      .toList();

  RoadsideAssistanceProvider() {
    _loadSampleData();
  }

  /// Find a request by its id.
  AssistanceRequest? getRequestById(String id) {
    try {
      return _requests.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Create a new assistance request.
  void createRequest({
    required String customerName,
    required String customerPhone,
    required AssistanceType assistanceType,
    RequestPriority priority = RequestPriority.normal,
    required double latitude,
    required double longitude,
    required String address,
    String? vehicleDescription,
    String? notes,
  }) {
    final request = AssistanceRequest(
      id: 'req-${DateTime.now().millisecondsSinceEpoch}',
      customerName: customerName,
      customerPhone: customerPhone,
      assistanceType: assistanceType,
      priority: priority,
      latitude: latitude,
      longitude: longitude,
      address: address,
      vehicleDescription: vehicleDescription,
      notes: notes,
      requestedAt: DateTime.now(),
    );
    _requests.insert(0, request);
    notifyListeners();
  }

  /// Assign a driver to a request.
  void assignDriver(String requestId, String driverId, String driverName,
      {DateTime? eta}) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    _requests[index] = _requests[index].copyWith(
      assignedDriverId: driverId,
      assignedDriverName: driverName,
      status: RequestStatus.dispatched,
      estimatedArrival: eta,
    );
    notifyListeners();
  }

  /// Update the status of a request.
  void updateStatus(String requestId, RequestStatus newStatus) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    _requests[index] = _requests[index].copyWith(status: newStatus);
    notifyListeners();
  }

  /// Mark a request as completed.
  void completeRequest(String requestId, {double? finalCost}) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    _requests[index] = _requests[index].copyWith(
      status: RequestStatus.completed,
      completedAt: DateTime.now(),
      estimatedCost: finalCost,
    );
    notifyListeners();
  }

  /// Cancel a request.
  void cancelRequest(String requestId) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    _requests[index] = _requests[index].copyWith(
      status: RequestStatus.cancelled,
      completedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void _loadSampleData() {
    _requests.addAll([
      AssistanceRequest(
        id: 'req-001',
        customerName: 'Maria Garcia',
        customerPhone: '(555) 234-5678',
        assistanceType: AssistanceType.tow,
        status: RequestStatus.requested,
        priority: RequestPriority.high,
        latitude: 39.7817,
        longitude: -89.6501,
        address: '1400 S Ninth St, Springfield, IL',
        vehicleDescription: '2020 Chevrolet Malibu (White)',
        notes: 'Vehicle won\'t start after minor fender bender.',
        requestedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        estimatedCost: 150.00,
      ),
      AssistanceRequest(
        id: 'req-002',
        customerName: 'James Carter',
        customerPhone: '(555) 345-6789',
        assistanceType: AssistanceType.jumpStart,
        status: RequestStatus.enRoute,
        priority: RequestPriority.normal,
        latitude: 39.7990,
        longitude: -89.6440,
        address: 'Walmart Parking Lot, 2760 N Dirksen Pkwy',
        vehicleDescription: '2018 Toyota RAV4 (Gray)',
        assignedDriverId: 'driver-003',
        assignedDriverName: 'Carlos Mendez',
        requestedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        estimatedArrival: DateTime.now().add(const Duration(minutes: 12)),
        estimatedCost: 75.00,
      ),
      AssistanceRequest(
        id: 'req-003',
        customerName: 'Priya Patel',
        customerPhone: '(555) 456-7890',
        assistanceType: AssistanceType.lockout,
        status: RequestStatus.onScene,
        priority: RequestPriority.emergency,
        latitude: 39.7700,
        longitude: -89.6680,
        address: 'I-55 Northbound, Mile Marker 98',
        vehicleDescription: '2021 BMW X3 (Black)',
        notes: 'Child locked inside vehicle.',
        assignedDriverId: 'driver-001',
        assignedDriverName: 'Mike Rodriguez',
        requestedAt: DateTime.now().subtract(const Duration(minutes: 40)),
        estimatedCost: 85.00,
      ),
      AssistanceRequest(
        id: 'req-004',
        customerName: 'David Kim',
        customerPhone: '(555) 567-8901',
        assistanceType: AssistanceType.tireChange,
        status: RequestStatus.completed,
        priority: RequestPriority.normal,
        latitude: 39.8010,
        longitude: -89.6370,
        address: '3100 Lindbergh Blvd, Springfield, IL',
        vehicleDescription: '2016 Honda Accord (Blue)',
        assignedDriverId: 'driver-002',
        assignedDriverName: 'Jake Thompson',
        requestedAt: DateTime.now().subtract(const Duration(hours: 2)),
        completedAt: DateTime.now().subtract(const Duration(minutes: 45)),
        estimatedCost: 60.00,
      ),
      AssistanceRequest(
        id: 'req-005',
        customerName: 'Emily Watson',
        customerPhone: '(555) 678-9012',
        assistanceType: AssistanceType.fuelDelivery,
        status: RequestStatus.dispatched,
        priority: RequestPriority.low,
        latitude: 39.7550,
        longitude: -89.6920,
        address: '4500 Wabash Ave, Springfield, IL',
        vehicleDescription: '2023 Hyundai Tucson (Red)',
        notes: 'Ran out of gas on the way to work.',
        assignedDriverId: 'driver-004',
        assignedDriverName: 'Anna Brooks',
        requestedAt: DateTime.now().subtract(const Duration(minutes: 18)),
        estimatedArrival: DateTime.now().add(const Duration(minutes: 22)),
        estimatedCost: 55.00,
      ),
    ]);
  }
}
