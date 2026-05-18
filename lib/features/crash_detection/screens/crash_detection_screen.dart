import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crash_event.dart';
import '../providers/crash_detection_provider.dart';

/// Crash Detection & Auto-Alert screen — monitoring, active alerts, and history.
class CrashDetectionScreen extends StatelessWidget {
  const CrashDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crash Detection'),
        actions: [
          Consumer<CrashDetectionProvider>(
            builder: (context, provider, _) => IconButton(
              icon: Icon(
                provider.isMonitoring
                    ? Icons.shield
                    : Icons.shield_outlined,
              ),
              onPressed: () {
                if (provider.isMonitoring) {
                  provider.stopMonitoring();
                } else {
                  provider.startMonitoring();
                }
              },
              tooltip: provider.isMonitoring
                  ? 'Stop Monitoring'
                  : 'Start Monitoring',
            ),
          ),
        ],
      ),
      body: Consumer<CrashDetectionProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Active crash alert
              if (provider.activeCrash != null)
                _ActiveCrashCard(
                  crash: provider.activeCrash!,
                  countdownRemaining: provider.countdownRemaining,
                  onCancel: () => provider.cancelAlert(),
                ),

              // Monitoring status
              _MonitoringStatusCard(
                isMonitoring: provider.isMonitoring,
                onToggle: () {
                  if (provider.isMonitoring) {
                    provider.stopMonitoring();
                  } else {
                    provider.startMonitoring();
                  }
                },
              ),

              const SizedBox(height: 16),

              // Settings card
              _SettingsCard(settings: provider.settings),

              const SizedBox(height: 16),

              // History header
              Row(
                children: [
                  const Icon(Icons.history, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Crash History (${provider.events.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // History list
              if (provider.events.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No crash events recorded',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                ...provider.events.map(
                  (event) => _CrashHistoryTile(event: event),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Prominent red alert card for an active (unresolved) crash.
class _ActiveCrashCard extends StatelessWidget {
  final CrashEvent crash;
  final int? countdownRemaining;
  final VoidCallback onCancel;

  const _ActiveCrashCard({
    required this.crash,
    this.countdownRemaining,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.red, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🚨 CRASH DETECTED — ${crash.severityLabel}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Driver: ${crash.driverName}',
                style: const TextStyle(fontSize: 14)),
            Text('Vehicle: ${crash.vehicleId}',
                style: const TextStyle(fontSize: 14)),
            Text(
              'Impact: ${crash.impactForceG.toStringAsFixed(1)}G at ${crash.speedAtImpact.toStringAsFixed(0)} mph',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Location: ${crash.latitude.toStringAsFixed(4)}, ${crash.longitude.toStringAsFixed(4)}',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            if (countdownRemaining != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Auto-alert in $countdownRemaining seconds',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel),
                label: const Text("I'm OK — Cancel Alert"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card showing whether monitoring is active.
class _MonitoringStatusCard extends StatelessWidget {
  final bool isMonitoring;
  final VoidCallback onToggle;

  const _MonitoringStatusCard({
    required this.isMonitoring,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          isMonitoring ? Icons.shield : Icons.shield_outlined,
          color: isMonitoring ? Colors.green : Colors.grey,
          size: 32,
        ),
        title: Text(isMonitoring ? 'Monitoring Active' : 'Monitoring Off'),
        subtitle: Text(
          isMonitoring
              ? 'Accelerometer sensors are active'
              : 'Crash detection is paused',
        ),
        trailing: Switch(
          value: isMonitoring,
          onChanged: (_) => onToggle(),
          activeColor: Colors.green,
        ),
      ),
    );
  }
}

/// Settings overview card.
class _SettingsCard extends StatelessWidget {
  final CrashDetectionSettings settings;

  const _SettingsCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, size: 20),
                const SizedBox(width: 8),
                Text('Detection Settings',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            _SettingRow(
              label: 'G-Force Threshold',
              value: '${settings.sensitivityThreshold.toStringAsFixed(1)}G',
            ),
            _SettingRow(
              label: 'Auto-Countdown',
              value: '${settings.countdownSeconds}s',
            ),
            _SettingRow(
              label: 'Auto-Alert 911',
              value: settings.autoAlert911 ? 'On' : 'Off',
              isEnabled: settings.autoAlert911,
            ),
            _SettingRow(
              label: 'Auto-Alert Dispatch',
              value: settings.autoAlertDispatch ? 'On' : 'Off',
              isEnabled: settings.autoAlertDispatch,
            ),
            _SettingRow(
              label: 'Emergency Contacts',
              value: settings.emergencyContacts.isEmpty
                  ? 'None'
                  : '${settings.emergencyContacts.length} configured',
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String value;
  final bool? isEnabled;

  const _SettingRow({
    required this.label,
    required this.value,
    this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isEnabled == null
                  ? null
                  : isEnabled!
                      ? Colors.green
                      : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual crash event in the history list.
class _CrashHistoryTile extends StatelessWidget {
  final CrashEvent event;

  const _CrashHistoryTile({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _severityColor.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.car_crash, color: _severityColor, size: 22),
        ),
        title: Text(
          '${event.severityLabel} — ${event.driverName}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '${event.impactForceG.toStringAsFixed(1)}G at ${event.speedAtImpact.toStringAsFixed(0)} mph',
              style: const TextStyle(fontSize: 13),
            ),
            if (event.address != null)
              Text(
                event.address!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                _StatusBadge(status: event.status, label: event.statusLabel),
                const SizedBox(width: 8),
                Text(
                  _timeAgo(event.timestamp),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Color get _severityColor {
    switch (event.severity) {
      case CrashSeverity.minor:
        return Colors.amber;
      case CrashSeverity.moderate:
        return Colors.orange;
      case CrashSeverity.severe:
        return Colors.deepOrange;
      case CrashSeverity.critical:
        return Colors.red;
    }
  }

  static String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.month}/${time.day}/${time.year % 100}';
  }
}

/// Color-coded status badge.
class _StatusBadge extends StatelessWidget {
  final CrashAlertStatus status;
  final String label;

  const _StatusBadge({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _statusColor.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _statusColor.withAlpha(100)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _statusColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (status) {
      case CrashAlertStatus.detected:
        return Colors.red;
      case CrashAlertStatus.alertSent:
        return Colors.orange;
      case CrashAlertStatus.acknowledged:
        return Colors.blue;
      case CrashAlertStatus.responderDispatched:
        return Colors.purple;
      case CrashAlertStatus.resolved:
        return Colors.green;
      case CrashAlertStatus.falseAlarm:
        return Colors.grey;
    }
  }
}
