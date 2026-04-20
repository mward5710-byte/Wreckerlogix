import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/eld_log.dart';
import '../providers/eld_provider.dart';

/// ELD / HOS Logging screen — duty status, compliance, and log history.
class EldScreen extends StatelessWidget {
  const EldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ELD / HOS Logging'),
        actions: [
          Consumer<EldProvider>(
            builder: (context, eld, _) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle,
                      size: 12,
                      color: eld.eldConnected ? Colors.green : Colors.red),
                  const SizedBox(width: 6),
                  Text(
                    eld.eldConnected
                        ? eld.eldDeviceId ?? 'Connected'
                        : 'Disconnected',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<EldProvider>(
        builder: (context, eld, _) {
          final todayLogs = eld.getLogsForDate(DateTime.now());
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _HosSummaryCard(summary: eld.hosSummary),
              const SizedBox(height: 16),
              _DutyStatusSelector(
                currentStatus: eld.currentStatus,
                onChanged: (status) => eld.changeDutyStatus(status),
              ),
              const SizedBox(height: 16),
              Text("Today's Log Entries",
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (todayLogs.isEmpty)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No log entries for today.'),
                ))
              else
                ...todayLogs.reversed.map((entry) => _LogEntryTile(entry: entry)),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HOS Summary Card
// ---------------------------------------------------------------------------

class _HosSummaryCard extends StatelessWidget {
  final HosSummary summary;

  const _HosSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('HOS Summary',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                _ComplianceBadge(status: summary.complianceStatus),
              ],
            ),
            const Divider(),
            _HoursRow(
              label: 'Driving today',
              remaining: summary.remainingDrivingToday,
              used: summary.drivingHoursToday,
              limit: 11,
            ),
            const SizedBox(height: 8),
            _HoursRow(
              label: 'On-duty today',
              remaining: summary.remainingOnDutyToday,
              used: summary.onDutyHoursToday,
              limit: 14,
            ),
            const SizedBox(height: 8),
            _HoursRow(
              label: 'Driving this week',
              remaining: summary.remainingDrivingThisWeek,
              used: summary.drivingHoursThisWeek,
              limit: 60,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComplianceBadge extends StatelessWidget {
  final String status;

  const _ComplianceBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Violation':
        color = Colors.red;
      case 'Warning':
        color = Colors.orange;
      default:
        color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final String label;
  final double remaining;
  final double used;
  final double limit;

  const _HoursRow({
    required this.label,
    required this.remaining,
    required this.used,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final color = remaining > 2
        ? Colors.green
        : remaining >= 0.5
            ? Colors.orange
            : Colors.red;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (used / limit).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              color: color,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
          child: Text(
            '${remaining.toStringAsFixed(1)} hrs left',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Duty Status Selector
// ---------------------------------------------------------------------------

class _DutyStatusSelector extends StatelessWidget {
  final DutyStatus currentStatus;
  final ValueChanged<DutyStatus> onChanged;

  const _DutyStatusSelector({
    required this.currentStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Duty Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: DutyStatus.values.map((status) {
                final isSelected = status == currentStatus;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _StatusButton(
                      status: status,
                      isSelected: isSelected,
                      onTap: () => onChanged(status),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final DutyStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusButton({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForStatus(status);
    return Material(
      color: isSelected ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(_iconForStatus(status),
                  size: 22, color: isSelected ? Colors.white : color),
              const SizedBox(height: 4),
              Text(
                _shortLabel(status),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _colorForStatus(DutyStatus s) {
    switch (s) {
      case DutyStatus.offDuty:
        return Colors.grey;
      case DutyStatus.sleeperBerth:
        return Colors.indigo;
      case DutyStatus.driving:
        return Colors.green;
      case DutyStatus.onDutyNotDriving:
        return Colors.orange;
    }
  }

  static IconData _iconForStatus(DutyStatus s) {
    switch (s) {
      case DutyStatus.offDuty:
        return Icons.power_settings_new;
      case DutyStatus.sleeperBerth:
        return Icons.hotel;
      case DutyStatus.driving:
        return Icons.directions_car;
      case DutyStatus.onDutyNotDriving:
        return Icons.build;
    }
  }

  static String _shortLabel(DutyStatus s) {
    switch (s) {
      case DutyStatus.offDuty:
        return 'Off\nDuty';
      case DutyStatus.sleeperBerth:
        return 'Sleeper\nBerth';
      case DutyStatus.driving:
        return 'Driving';
      case DutyStatus.onDutyNotDriving:
        return 'On Duty\n(Not Drv)';
    }
  }
}

// ---------------------------------------------------------------------------
// Log Entry Tile
// ---------------------------------------------------------------------------

class _LogEntryTile extends StatelessWidget {
  final EldLogEntry entry;

  const _LogEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final time =
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _statusColor.withAlpha(30),
        child: Icon(_statusIcon, color: _statusColor, size: 20),
      ),
      title: Text(entry.statusLabel),
      subtitle: Text(
        [
          time,
          if (entry.annotation != null) entry.annotation!,
        ].join(' — '),
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: entry.certified
          ? const Icon(Icons.verified, color: Colors.green, size: 20)
          : const Icon(Icons.pending, color: Colors.grey, size: 20),
    );
  }

  Color get _statusColor {
    switch (entry.dutyStatus) {
      case DutyStatus.offDuty:
        return Colors.grey;
      case DutyStatus.sleeperBerth:
        return Colors.indigo;
      case DutyStatus.driving:
        return Colors.green;
      case DutyStatus.onDutyNotDriving:
        return Colors.orange;
    }
  }

  IconData get _statusIcon {
    switch (entry.dutyStatus) {
      case DutyStatus.offDuty:
        return Icons.power_settings_new;
      case DutyStatus.sleeperBerth:
        return Icons.hotel;
      case DutyStatus.driving:
        return Icons.directions_car;
      case DutyStatus.onDutyNotDriving:
        return Icons.build;
    }
  }
}
