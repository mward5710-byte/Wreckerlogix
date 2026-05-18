import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/driver_panel_provider.dart';

/// Driver Quick Panel — the mobile-first command center for drivers in the field.
///
/// Designed for one-hand, glance-and-tap operation while on the road.
/// Big buttons, clear status, minimal reading required.
class DriverPanelScreen extends StatelessWidget {
  const DriverPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverPanelProvider>(
      builder: (context, panel, _) {
        return Scaffold(
          backgroundColor: _bgColor(panel.mode),
          appBar: AppBar(
            title: const Text('Driver Panel'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              // Clock in/out toggle
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: panel.isClockedIn
                    ? OutlinedButton.icon(
                        onPressed: () => _confirmClockOut(context, panel),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: Text(
                          'OUT ${panel.hoursWorkedToday}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          body: SafeArea(
            child: panel.isClockedIn
                ? _buildActivePanel(context, panel)
                : _buildClockInPanel(context, panel),
          ),
        );
      },
    );
  }

  /// Off-duty — big clock-in button.
  Widget _buildClockInPanel(BuildContext context, DriverPanelProvider panel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_shipping, size: 80, color: Colors.white54),
          const SizedBox(height: 24),
          const Text(
            'Ready to Roll?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Today: ${panel.todayJobsCompleted} jobs • \$${panel.todayEarnings.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: 220,
            height: 220,
            child: ElevatedButton(
              onPressed: () => panel.clockIn(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                elevation: 8,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.power_settings_new, size: 64),
                  SizedBox(height: 8),
                  Text('CLOCK IN',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Clocked in — show job card or "waiting for dispatch" + quick actions.
  Widget _buildActivePanel(BuildContext context, DriverPanelProvider panel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Today's stats bar
          _TodayStatsBar(panel: panel),
          const SizedBox(height: 16),

          // Current job card or waiting state
          if (panel.hasActiveJob)
            _ActiveJobCard(panel: panel)
          else
            _WaitingForDispatch(panel: panel),

          const SizedBox(height: 20),

          // Quick action buttons — always visible
          _QuickActionsGrid(panel: panel),
        ],
      ),
    );
  }

  Color _bgColor(DriverMode mode) {
    switch (mode) {
      case DriverMode.offDuty:
        return const Color(0xFF1E1E2E);
      case DriverMode.available:
        return const Color(0xFF1B3A2D);
      case DriverMode.onJob:
        return const Color(0xFF1A2744);
    }
  }

  void _confirmClockOut(BuildContext context, DriverPanelProvider panel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clock Out?'),
        content: Text('You\'ve worked ${panel.hoursWorkedToday} today.\n'
            '${panel.todayJobsCompleted} jobs completed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              panel.clockOut();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('CLOCK OUT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// Today's stats — jobs, earnings, hours.
class _TodayStatsBar extends StatelessWidget {
  final DriverPanelProvider panel;

  const _TodayStatsBar({required this.panel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBadge(
          icon: Icons.check_circle,
          value: '${panel.todayJobsCompleted}',
          label: 'Jobs',
          color: Colors.green,
        ),
        _StatBadge(
          icon: Icons.attach_money,
          value: '\$${panel.todayEarnings.toStringAsFixed(0)}',
          label: 'Earned',
          color: Colors.amber,
        ),
        _StatBadge(
          icon: Icons.access_time,
          value: panel.hoursWorkedToday,
          label: 'Hours',
          color: Colors.blue,
        ),
        _StatBadge(
          icon: Icons.route,
          value: '${panel.todayMiles.toStringAsFixed(0)}',
          label: 'Miles',
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

/// Active job card with one-tap status progression.
class _ActiveJobCard extends StatelessWidget {
  final DriverPanelProvider panel;

  const _ActiveJobCard({required this.panel});

  @override
  Widget build(BuildContext context) {
    final isCompleted = panel.currentJobStatus == 'Completed';

    return Card(
      color: isCompleted ? Colors.green.shade900 : const Color(0xFF2A3A5A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor),
                  ),
                  child: Text(
                    panel.currentJobStatus ?? 'Unknown',
                    style: TextStyle(
                        color: _statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
                if (isCompleted)
                  TextButton(
                    onPressed: () => panel.clearCompletedJob(),
                    child: const Text('NEXT',
                        style: TextStyle(color: Colors.white70)),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Customer
            Text(
              panel.currentJobCustomer ?? '',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Vehicle
            _JobDetailRow(Icons.directions_car, panel.currentJobVehicle ?? ''),
            const SizedBox(height: 8),

            // Pickup
            _JobDetailRow(Icons.my_location, panel.currentJobPickup ?? '',
                iconColor: Colors.orange),
            const SizedBox(height: 8),

            // Dropoff
            _JobDetailRow(Icons.flag, panel.currentJobDropoff ?? '',
                iconColor: Colors.green),

            // Status progression buttons
            if (!isCompleted) ...[
              const SizedBox(height: 20),
              _buildProgressionButton(panel),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressionButton(DriverPanelProvider panel) {
    String label;
    IconData icon;
    Color color;
    VoidCallback onTap;

    switch (panel.currentJobStatus) {
      case 'Assigned':
        label = 'EN ROUTE';
        icon = Icons.navigation;
        color = Colors.blue;
        onTap = () => panel.goEnRoute();
      case 'En Route':
        label = 'ARRIVED';
        icon = Icons.place;
        color = Colors.purple;
        onTap = () => panel.arriveOnScene();
      case 'On Scene':
        label = 'START TOW';
        icon = Icons.rv_hookup;
        color = Colors.teal;
        onTap = () => panel.startTow();
      case 'In Progress':
        label = 'COMPLETE';
        icon = Icons.check_circle;
        color = Colors.green;
        onTap = () => panel.completeJob();
      default:
        label = 'UPDATE';
        icon = Icons.sync;
        color = Colors.grey;
        onTap = () {};
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 28),
        label: Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (panel.currentJobStatus) {
      case 'Assigned':
        return Colors.blue;
      case 'En Route':
        return Colors.indigo;
      case 'On Scene':
        return Colors.purple;
      case 'In Progress':
        return Colors.teal;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _JobDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const _JobDetailRow(this.icon, this.text, {this.iconColor = Colors.white54});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ),
      ],
    );
  }
}

/// Waiting for dispatch — shows when clocked in but no active job.
class _WaitingForDispatch extends StatelessWidget {
  final DriverPanelProvider panel;

  const _WaitingForDispatch({required this.panel});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2A4A3A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.wifi_tethering, size: 48, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Available for Dispatch',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Standing by for the next job...',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 24),
            // Demo: Accept a job button
            OutlinedButton.icon(
              onPressed: () => panel.acceptDemoJob(),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('ACCEPT DEMO JOB'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick action grid — always available shortcuts.
class _QuickActionsGrid extends StatelessWidget {
  final DriverPanelProvider panel;

  const _QuickActionsGrid({required this.panel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Row(
          children: [
            _QuickAction(
              icon: Icons.camera_alt,
              label: 'Photo',
              color: Colors.orange,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📸 Camera opening...')),
                );
              },
            ),
            const SizedBox(width: 10),
            _QuickAction(
              icon: Icons.mic,
              label: 'Voice',
              color: Colors.purple,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🎤 Listening...')),
                );
              },
            ),
            const SizedBox(width: 10),
            _QuickAction(
              icon: Icons.phone,
              label: 'Dispatch',
              color: Colors.blue,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📞 Calling dispatch...')),
                );
              },
            ),
            const SizedBox(width: 10),
            _QuickAction(
              icon: Icons.navigation,
              label: 'Navigate',
              color: Colors.teal,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🗺️ Opening navigation...')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(60)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
