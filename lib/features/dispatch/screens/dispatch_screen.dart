import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/dispatch_provider.dart';

/// Dispatch board — shows all jobs with status filtering.
class DispatchScreen extends StatefulWidget {
  const DispatchScreen({super.key});

  @override
  State<DispatchScreen> createState() => _DispatchScreenState();
}

class _DispatchScreenState extends State<DispatchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch Board'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Consumer<DispatchProvider>(
        builder: (context, dispatch, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _JobListView(jobs: dispatch.pendingJobs),
              _JobListView(jobs: dispatch.activeJobs),
              _JobListView(jobs: dispatch.completedJobs),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/dispatch/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Job'),
      ),
    );
  }
}

class _JobListView extends StatelessWidget {
  final List<Job> jobs;

  const _JobListView({required this.jobs});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No jobs', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: jobs.length,
      itemBuilder: (context, index) => _JobCard(job: jobs[index]),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;

  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/dispatch/${job.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.customerName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _StatusChip(status: job.status),
                ],
              ),
              const SizedBox(height: 8),
              _InfoRow(Icons.directions_car, job.vehicleDescription),
              const SizedBox(height: 4),
              _InfoRow(Icons.my_location, job.pickupAddress),
              const SizedBox(height: 4),
              _InfoRow(Icons.flag, job.dropoffAddress),
              if (job.assignedDriverName != null) ...[
                const SizedBox(height: 4),
                _InfoRow(Icons.person, 'Driver: ${job.assignedDriverName}'),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PriorityBadge(priority: job.priority),
                  Text(job.towTypeLabel,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  if (job.estimatedCost != null)
                    Text('\$${job.estimatedCost!.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final JobStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final JobPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (priority) {
      case JobPriority.low:
        color = Colors.grey;
        icon = Icons.arrow_downward;
      case JobPriority.normal:
        color = Colors.blue;
        icon = Icons.remove;
      case JobPriority.high:
        color = Colors.orange;
        icon = Icons.arrow_upward;
      case JobPriority.emergency:
        color = Colors.red;
        icon = Icons.warning;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Text(priority.name.toUpperCase(),
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
