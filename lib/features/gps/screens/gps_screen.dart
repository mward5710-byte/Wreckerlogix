import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fleet_vehicle.dart';
import '../providers/gps_provider.dart';

/// GPS fleet tracking screen — shows all vehicles and their status.
class GpsScreen extends StatelessWidget {
  const GpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Tracking'),
        actions: [
          Consumer<GpsProvider>(
            builder: (context, gps, _) => IconButton(
              icon:
                  Icon(gps.isTracking ? Icons.gps_fixed : Icons.gps_not_fixed),
              onPressed: () {
                if (gps.isTracking) {
                  gps.stopTracking();
                } else {
                  gps.startTracking();
                }
              },
              tooltip: gps.isTracking ? 'Stop Tracking' : 'Start Tracking',
            ),
          ),
        ],
      ),
      body: Consumer<GpsProvider>(
        builder: (context, gps, _) {
          return Column(
            children: [
              // Map placeholder
              Container(
                height: 300,
                width: double.infinity,
                color: Colors.grey[200],
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'Google Maps Integration',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${gps.activeVehicles.length} vehicles active',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    // Vehicle markers on mock map
                    ...gps.vehicles.map((v) => Positioned(
                          left: ((v.longitude + 90) % 360) * 0.8 + 50,
                          top: ((v.latitude + 40) % 180) * 1.2 + 20,
                          child: _MapPin(vehicle: v),
                        )),
                  ],
                ),
              ),

              // Fleet status summary
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _StatusCount(
                      label: 'Available',
                      count: gps.availableVehicles.length,
                      color: Colors.green,
                    ),
                    _StatusCount(
                      label: 'Active',
                      count: gps.activeVehicles.length,
                      color: Colors.blue,
                    ),
                    _StatusCount(
                      label: 'Total',
                      count: gps.vehicles.length,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Vehicle list
              Expanded(
                child: ListView.builder(
                  itemCount: gps.vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = gps.vehicles[index];
                    return _VehicleListTile(
                      vehicle: vehicle,
                      isSelected: gps.selectedVehicle?.id == vehicle.id,
                      onTap: () => gps.selectVehicle(vehicle),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final FleetVehicle vehicle;

  const _MapPin({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (vehicle.status) {
      case DriverStatus.available:
        color = Colors.green;
      case DriverStatus.enRoute:
        color = Colors.blue;
      case DriverStatus.onScene:
        color = Colors.purple;
      case DriverStatus.busy:
        color = Colors.orange;
      case DriverStatus.offline:
        color = Colors.grey;
    }

    return Tooltip(
      message: '${vehicle.driverName} — ${vehicle.statusLabel}',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [BoxShadow(color: color.withAlpha(100), blurRadius: 6)],
        ),
        child: const Icon(Icons.local_shipping, size: 16, color: Colors.white),
      ),
    );
  }
}

class _StatusCount extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusCount({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text('$count',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleListTile extends StatelessWidget {
  final FleetVehicle vehicle;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleListTile({
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      leading: CircleAvatar(
        backgroundColor: _statusColor.withAlpha(30),
        child: Icon(Icons.local_shipping, color: _statusColor),
      ),
      title: Text(vehicle.vehicleLabel),
      subtitle: Text('${vehicle.driverName} — ${vehicle.statusLabel}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (vehicle.speed != null && vehicle.speed! > 0)
            Text('${vehicle.speed!.toStringAsFixed(0)} mph',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            '${vehicle.latitude.toStringAsFixed(4)}, ${vehicle.longitude.toStringAsFixed(4)}',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Color get _statusColor {
    switch (vehicle.status) {
      case DriverStatus.available:
        return Colors.green;
      case DriverStatus.enRoute:
        return Colors.blue;
      case DriverStatus.onScene:
        return Colors.purple;
      case DriverStatus.busy:
        return Colors.orange;
      case DriverStatus.offline:
        return Colors.grey;
    }
  }
}
