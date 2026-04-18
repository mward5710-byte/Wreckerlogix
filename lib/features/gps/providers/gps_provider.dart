import 'package:flutter/foundation.dart';
import '../models/fleet_vehicle.dart';

/// State management for GPS fleet tracking.
class GpsProvider extends ChangeNotifier {
  final List<FleetVehicle> _vehicles = [];
  bool _isTracking = false;
  FleetVehicle? _selectedVehicle;

  List<FleetVehicle> get vehicles => List.unmodifiable(_vehicles);
  List<FleetVehicle> get availableVehicles =>
      _vehicles.where((v) => v.status == DriverStatus.available).toList();
  List<FleetVehicle> get activeVehicles =>
      _vehicles.where((v) => v.status != DriverStatus.offline).toList();
  bool get isTracking => _isTracking;
  FleetVehicle? get selectedVehicle => _selectedVehicle;

  GpsProvider() {
    _loadSampleFleet();
  }

  void selectVehicle(FleetVehicle? vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  void startTracking() {
    _isTracking = true;
    notifyListeners();
  }

  void stopTracking() {
    _isTracking = false;
    notifyListeners();
  }

  void updateVehiclePosition(String vehicleId, double lat, double lng) {
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index == -1) return;

    _vehicles[index] = _vehicles[index].copyWith(
      latitude: lat,
      longitude: lng,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  void updateVehicleStatus(String vehicleId, DriverStatus status) {
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index == -1) return;

    _vehicles[index] = _vehicles[index].copyWith(
      status: status,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  void _loadSampleFleet() {
    _vehicles.addAll([
      FleetVehicle(
        id: 'truck-001',
        driverName: 'Mike Rodriguez',
        vehicleId: 'VH-001',
        vehicleLabel: 'Truck #1 — Flatbed',
        latitude: 39.7817,
        longitude: -89.6501,
        speed: 35.0,
        heading: 180.0,
        status: DriverStatus.enRoute,
        currentJobId: 'job-002',
        lastUpdated: DateTime.now(),
      ),
      FleetVehicle(
        id: 'truck-002',
        driverName: 'Jake Thompson',
        vehicleId: 'VH-002',
        vehicleLabel: 'Truck #2 — Wheel Lift',
        latitude: 39.7600,
        longitude: -89.6700,
        speed: 0.0,
        status: DriverStatus.available,
        lastUpdated: DateTime.now(),
      ),
      FleetVehicle(
        id: 'truck-003',
        driverName: 'Carlos Mendez',
        vehicleId: 'VH-003',
        vehicleLabel: 'Truck #3 — Heavy Duty',
        latitude: 39.8000,
        longitude: -89.6400,
        speed: 55.0,
        heading: 45.0,
        status: DriverStatus.enRoute,
        currentJobId: 'job-005',
        lastUpdated: DateTime.now(),
      ),
      FleetVehicle(
        id: 'truck-004',
        driverName: 'David Park',
        vehicleId: 'VH-004',
        vehicleLabel: 'Truck #4 — Light Duty',
        latitude: 39.7500,
        longitude: -89.6800,
        speed: 0.0,
        status: DriverStatus.offline,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ]);
  }
}
