/// Represents a driver/vehicle in the fleet for GPS tracking.
enum DriverStatus { offline, available, enRoute, onScene, busy }

class FleetVehicle {
  final String id;
  final String driverName;
  final String vehicleId;
  final String vehicleLabel; // e.g., "Truck #4 — Flatbed"
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed; // mph
  final DriverStatus status;
  final String? currentJobId;
  final DateTime lastUpdated;

  const FleetVehicle({
    required this.id,
    required this.driverName,
    required this.vehicleId,
    required this.vehicleLabel,
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    this.status = DriverStatus.available,
    this.currentJobId,
    required this.lastUpdated,
  });

  FleetVehicle copyWith({
    double? latitude,
    double? longitude,
    double? heading,
    double? speed,
    DriverStatus? status,
    String? currentJobId,
    DateTime? lastUpdated,
  }) {
    return FleetVehicle(
      id: id,
      driverName: driverName,
      vehicleId: vehicleId,
      vehicleLabel: vehicleLabel,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      status: status ?? this.status,
      currentJobId: currentJobId ?? this.currentJobId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  String get statusLabel {
    switch (status) {
      case DriverStatus.offline:
        return 'Offline';
      case DriverStatus.available:
        return 'Available';
      case DriverStatus.enRoute:
        return 'En Route';
      case DriverStatus.onScene:
        return 'On Scene';
      case DriverStatus.busy:
        return 'Busy';
    }
  }
}
