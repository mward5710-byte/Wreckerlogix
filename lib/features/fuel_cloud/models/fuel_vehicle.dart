/// FuelCloud vehicle and site models.

class FuelVehicle {
  final String id;
  final String name;
  final String? vin;
  final String? licensePlate;
  final bool isActive;

  const FuelVehicle({
    required this.id,
    required this.name,
    this.vin,
    this.licensePlate,
    this.isActive = true,
  });

  factory FuelVehicle.fromJson(Map<String, dynamic> json) {
    return FuelVehicle(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unknown Vehicle',
      vin: json['vin'] as String?,
      licensePlate: json['license_plate'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class FuelSite {
  final String id;
  final String name;
  final String? address;

  const FuelSite({
    required this.id,
    required this.name,
    this.address,
  });

  factory FuelSite.fromJson(Map<String, dynamic> json) {
    return FuelSite(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unknown Site',
      address: json['address'] as String?,
    );
  }
}
