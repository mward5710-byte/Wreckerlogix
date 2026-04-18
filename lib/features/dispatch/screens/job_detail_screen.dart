import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/dispatch_provider.dart';

/// Job detail screen — view and update job status.
class JobDetailScreen extends StatelessWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Consumer<DispatchProvider>(
      builder: (context, dispatch, _) {
        final job = dispatch.getJobById(jobId);
        if (job == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Job Not Found')),
            body: const Center(child: Text('This job could not be found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Job #${job.id.split("-").last}'),
            actions: [
              if (job.status != JobStatus.completed &&
                  job.status != JobStatus.cancelled)
                PopupMenuButton<JobStatus>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (status) =>
                      dispatch.updateJobStatus(jobId, status),
                  itemBuilder: (context) => _getStatusOptions(job.status),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status banner
                _StatusBanner(job: job),
                const SizedBox(height: 16),

                // Customer info
                _SectionCard(
                  title: 'Customer',
                  icon: Icons.person,
                  children: [
                    _DetailRow('Name', job.customerName),
                    _DetailRow('Phone', job.customerPhone),
                  ],
                ),
                const SizedBox(height: 12),

                // Vehicle info
                _SectionCard(
                  title: 'Vehicle',
                  icon: Icons.directions_car,
                  children: [
                    _DetailRow('Vehicle', job.vehicleDescription),
                    if (job.licensePlate != null)
                      _DetailRow('Plate', job.licensePlate!),
                    _DetailRow('Service', job.towTypeLabel),
                  ],
                ),
                const SizedBox(height: 12),

                // Locations
                _SectionCard(
                  title: 'Locations',
                  icon: Icons.map,
                  children: [
                    _DetailRow('Pickup', job.pickupAddress),
                    _DetailRow('Drop-off', job.dropoffAddress),
                  ],
                ),
                const SizedBox(height: 12),

                // Assignment
                _SectionCard(
                  title: 'Assignment',
                  icon: Icons.assignment_ind,
                  children: [
                    _DetailRow('Driver',
                        job.assignedDriverName ?? 'Unassigned'),
                    _DetailRow('Priority', job.priority.name.toUpperCase()),
                    if (job.estimatedCost != null)
                      _DetailRow('Est. Cost',
                          '\$${job.estimatedCost!.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 12),

                // Notes
                if (job.notes != null && job.notes!.isNotEmpty)
                  _SectionCard(
                    title: 'Notes',
                    icon: Icons.note,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(job.notes!),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<PopupMenuEntry<JobStatus>> _getStatusOptions(JobStatus current) {
    final allStatuses = [
      JobStatus.pending,
      JobStatus.assigned,
      JobStatus.enRoute,
      JobStatus.onScene,
      JobStatus.inProgress,
      JobStatus.completed,
      JobStatus.cancelled,
    ];

    return allStatuses
        .where((s) => s != current)
        .map((s) => PopupMenuItem(
              value: s,
              child: Text('→ ${s.name.toUpperCase()}'),
            ))
        .toList();
  }
}

class _StatusBanner extends StatelessWidget {
  final Job job;

  const _StatusBanner({required this.job});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (job.status) {
      case JobStatus.pending:
        color = Colors.orange;
      case JobStatus.assigned:
        color = Colors.blue;
      case JobStatus.enRoute:
        color = Colors.indigo;
      case JobStatus.onScene:
        color = Colors.purple;
      case JobStatus.inProgress:
        color = Colors.teal;
      case JobStatus.completed:
        color = Colors.green;
      case JobStatus.cancelled:
        color = Colors.red;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 12),
          const SizedBox(width: 12),
          Text(
            job.statusLabel,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
