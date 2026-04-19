import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/maintenance_record.dart';
import '../providers/maintenance_provider.dart';

/// Maintenance Tracking screen — view and manage vehicle service records.
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance')),
      body: Consumer<MaintenanceProvider>(
        builder: (context, maint, _) {
          final sorted = List<MaintenanceRecord>.from(maint.records)
            ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

          return Column(
            children: [
              // Overdue alert banner
              if (maint.overdueRecords.isNotEmpty)
                _OverdueBanner(count: maint.overdueRecords.length),

              // Summary cards
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _SummaryCard(
                      label: 'Scheduled',
                      count: maint.scheduledRecords.length,
                      color: Colors.blue,
                    ),
                    _SummaryCard(
                      label: 'Overdue',
                      count: maint.overdueRecords.length,
                      color: Colors.red,
                    ),
                    _SummaryCard(
                      label: 'Done This Mo.',
                      count: _completedThisMonth(maint),
                      color: Colors.green,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Record list
              Expanded(
                child: sorted.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.build_circle_outlined,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No maintenance records',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16)),
                            SizedBox(height: 8),
                            Text('Tap + to schedule service',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: sorted.length,
                        itemBuilder: (context, index) {
                          final record = sorted[index];
                          return _MaintenanceTile(
                            record: record,
                            onDismiss: () => maint.deleteRecord(record.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  int _completedThisMonth(MaintenanceProvider maint) {
    final now = DateTime.now();
    return maint.completedRecords
        .where((r) =>
            r.completedDate != null &&
            r.completedDate!.month == now.month &&
            r.completedDate!.year == now.year)
        .length;
  }

  void _showAddDialog(BuildContext context) {
    final descController = TextEditingController();
    final vehicleController = TextEditingController();
    MaintenanceType selectedType = MaintenanceType.oilChange;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Schedule Maintenance'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: vehicleController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Label',
                    hintText: 'e.g. Truck #1 — Flatbed',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MaintenanceType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: MaintenanceType.values
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text(_typeLabelFor(t))))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedType = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration:
                      const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (descController.text.trim().isEmpty ||
                    vehicleController.text.trim().isEmpty) {
                  return;
                }
                final provider =
                    Provider.of<MaintenanceProvider>(context, listen: false);
                final ts = DateTime.now().millisecondsSinceEpoch;
                provider.addRecord(MaintenanceRecord(
                  id: 'maint-$ts',
                  vehicleId: 'VH-$ts',
                  vehicleLabel: vehicleController.text.trim(),
                  type: selectedType,
                  description: descController.text.trim(),
                  scheduledDate: DateTime.now().add(const Duration(days: 7)),
                ));
                Navigator.of(ctx).pop();
              },
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }

  static String _typeLabelFor(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.oilChange:
        return 'Oil Change';
      case MaintenanceType.tireRotation:
        return 'Tire Rotation';
      case MaintenanceType.brakeService:
        return 'Brake Service';
      case MaintenanceType.engineRepair:
        return 'Engine Repair';
      case MaintenanceType.transmissionService:
        return 'Transmission Service';
      case MaintenanceType.electricalRepair:
        return 'Electrical Repair';
      case MaintenanceType.bodyWork:
        return 'Body Work';
      case MaintenanceType.inspection:
        return 'Inspection';
      case MaintenanceType.preventive:
        return 'Preventive';
      case MaintenanceType.other:
        return 'Other';
    }
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _OverdueBanner extends StatelessWidget {
  final int count;

  const _OverdueBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      backgroundColor: Colors.red.shade50,
      leading: const Icon(Icons.warning_amber, color: Colors.red),
      content: Text(
        '$count overdue maintenance record${count == 1 ? '' : 's'} — '
        'schedule service immediately',
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
      ),
      actions: const [SizedBox.shrink()],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryCard({
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

class _MaintenanceTile extends StatelessWidget {
  final MaintenanceRecord record;
  final VoidCallback onDismiss;

  const _MaintenanceTile({
    required this.record,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _statusColor.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_typeIcon, color: _statusColor, size: 22),
        ),
        title: Text(record.typeLabel,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(record.vehicleLabel,
                style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            const SizedBox(height: 4),
            Text(
              _formatDate(record.scheduledDate),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: _StatusChip(record: record),
        isThreeLine: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  IconData get _typeIcon {
    switch (record.type) {
      case MaintenanceType.oilChange:
        return Icons.oil_barrel;
      case MaintenanceType.tireRotation:
        return Icons.tire_repair;
      case MaintenanceType.brakeService:
        return Icons.do_not_step;
      case MaintenanceType.engineRepair:
        return Icons.engineering;
      case MaintenanceType.transmissionService:
        return Icons.settings;
      case MaintenanceType.electricalRepair:
        return Icons.electrical_services;
      case MaintenanceType.bodyWork:
        return Icons.car_repair;
      case MaintenanceType.inspection:
        return Icons.checklist;
      case MaintenanceType.preventive:
        return Icons.shield_outlined;
      case MaintenanceType.other:
        return Icons.build;
    }
  }

  Color get _statusColor {
    switch (record.status) {
      case MaintenanceStatus.scheduled:
        return Colors.blue;
      case MaintenanceStatus.inProgress:
        return Colors.orange;
      case MaintenanceStatus.completed:
        return Colors.green;
      case MaintenanceStatus.overdue:
        return Colors.red;
      case MaintenanceStatus.cancelled:
        return Colors.grey;
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final MaintenanceRecord record;

  const _StatusChip({required this.record});

  @override
  Widget build(BuildContext context) {
    final color = _chipColor;
    final label = record.isOverdue && record.status == MaintenanceStatus.scheduled
        ? 'Overdue'
        : record.statusLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color get _chipColor {
    if (record.isOverdue) return Colors.red;
    switch (record.status) {
      case MaintenanceStatus.scheduled:
        return Colors.blue;
      case MaintenanceStatus.inProgress:
        return Colors.orange;
      case MaintenanceStatus.completed:
        return Colors.green;
      case MaintenanceStatus.overdue:
        return Colors.red;
      case MaintenanceStatus.cancelled:
        return Colors.grey;
    }
  }
}
