/// FuelCloud transaction data models.

class FuelTransaction {
  final String id;
  final DateTime transactionDate;
  final String? siteName;
  final String? tankName;
  final String? vehicleName;
  final String? vehicleId;
  final String? driverName;
  final double volume; // gallons
  final double pricePerUnit; // price per gallon
  final double totalCost;
  final String? fuelType;
  final bool isVoided;

  const FuelTransaction({
    required this.id,
    required this.transactionDate,
    this.siteName,
    this.tankName,
    this.vehicleName,
    this.vehicleId,
    this.driverName,
    required this.volume,
    required this.pricePerUnit,
    required this.totalCost,
    this.fuelType,
    this.isVoided = false,
  });

  factory FuelTransaction.fromJson(Map<String, dynamic> json) {
    return FuelTransaction(
      id: json['id']?.toString() ?? '',
      transactionDate: json['transaction_date'] != null
          ? DateTime.parse(json['transaction_date'] as String)
          : DateTime.now(),
      siteName: json['site']?['name'] as String?,
      tankName: json['tank']?['name'] as String?,
      vehicleName: json['vehicle']?['name'] as String?,
      vehicleId: json['vehicle']?['id']?.toString(),
      driverName: json['driver']?['name'] as String?,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
      pricePerUnit: (json['price_per_unit'] as num?)?.toDouble() ?? 0.0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0.0,
      fuelType: json['fuel_type'] as String?,
      isVoided: json['is_voided'] as bool? ?? false,
    );
  }

  String get formattedVolume => '${volume.toStringAsFixed(3)} gal';
  String get formattedCost => '\$${totalCost.toStringAsFixed(2)}';
  String get formattedPPU => '\$${pricePerUnit.toStringAsFixed(3)}/gal';
}
