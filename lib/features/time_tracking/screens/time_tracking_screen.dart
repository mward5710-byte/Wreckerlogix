import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_tracking_provider.dart';

/// Time tracking screen — clock in/out and shift management.
class TimeTrackingScreen extends StatelessWidget {
  const TimeTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Tracking')),
      body: Consumer<TimeTrackingProvider>(
        builder: (context, timeProv, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clock In/Out card
                _ClockCard(timeProv: timeProv),
                const SizedBox(height: 24),

                // Weekly summary
                _WeeklySummary(timeProv: timeProv),
                const SizedBox(height: 24),

                // Shift history
                const Text('Shift History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...timeProv.entries.map((entry) => _ShiftCard(entry: entry)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ClockCard extends StatelessWidget {
  final TimeTrackingProvider timeProv;

  const _ClockCard({required this.timeProv});

  @override
  Widget build(BuildContext context) {
    final isClockedIn = timeProv.isClockedIn;
    final activeShift = timeProv.activeShift;

    return Card(
      color: isClockedIn ? Colors.green.shade50 : Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              isClockedIn ? Icons.timer : Icons.timer_off,
              size: 48,
              color: isClockedIn ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              isClockedIn ? 'Clocked In' : 'Clocked Out',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isClockedIn ? Colors.green[800] : Colors.grey[600],
              ),
            ),
            if (activeShift != null) ...[
              const SizedBox(height: 8),
              Text(
                '${activeShift.totalHours.toStringAsFixed(1)} hours today',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              if (activeShift.status.name == 'paused')
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('On Break',
                      style: TextStyle(color: Colors.orange)),
                ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isClockedIn)
                  FilledButton.icon(
                    onPressed: () =>
                        timeProv.clockIn('driver-current', 'Current User'),
                    icon: const Icon(Icons.login),
                    label: const Text('Clock In'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                  )
                else ...[
                  if (activeShift?.status.name == 'paused')
                    FilledButton.icon(
                      onPressed: () => timeProv.endBreak(),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('End Break'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => timeProv.startBreak(),
                      icon: const Icon(Icons.pause),
                      label: const Text('Break'),
                    ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () => timeProv.clockOut(),
                    icon: const Icon(Icons.logout),
                    label: const Text('Clock Out'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklySummary extends StatelessWidget {
  final TimeTrackingProvider timeProv;

  const _WeeklySummary({required this.timeProv});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This Week',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(
                  label: 'Total Hours',
                  value: timeProv.weeklyHours.toStringAsFixed(1),
                  unit: 'hrs',
                  color: Colors.blue,
                ),
                _SummaryItem(
                  label: 'Shifts',
                  value: '${timeProv.entries.length}',
                  unit: '',
                  color: Colors.green,
                ),
                _SummaryItem(
                  label: 'Overtime',
                  value: timeProv.entries
                      .fold<double>(0, (s, e) => s + e.overtimeHours)
                      .toStringAsFixed(1),
                  unit: 'hrs',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color: color),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class _ShiftCard extends StatelessWidget {
  final dynamic entry;

  const _ShiftCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: entry.isActive ? Colors.green.shade100 : Colors.grey.shade100,
          child: Icon(
            entry.isActive ? Icons.timer : Icons.check_circle,
            color: entry.isActive ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(entry.driverName),
        subtitle: Text(
          '${entry.totalHours.toStringAsFixed(1)} hrs'
          '${entry.overtimeHours > 0 ? " (${entry.overtimeHours.toStringAsFixed(1)} OT)" : ""}',
        ),
        trailing: Text(
          entry.isActive ? 'Active' : 'Completed',
          style: TextStyle(
            color: entry.isActive ? Colors.green : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
