import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/assistance_request.dart';
import '../providers/roadside_assistance_provider.dart';

/// Roadside Assistance screen — shows active and completed assistance requests.
class RoadsideAssistanceScreen extends StatelessWidget {
  const RoadsideAssistanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Roadside Assistance'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: Consumer<RoadsideAssistanceProvider>(
          builder: (context, provider, _) {
            return TabBarView(
              children: [
                _RequestListView(requests: provider.activeRequests),
                _RequestListView(requests: provider.completedRequests),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateRequestDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('New Request'),
        ),
      ),
    );
  }

  void _showCreateRequestDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final vehicleController = TextEditingController();
    final notesController = TextEditingController();
    AssistanceType selectedType = AssistanceType.tow;
    RequestPriority selectedPriority = RequestPriority.normal;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New Assistance Request'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Customer Name'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<AssistanceType>(
                      value: selectedType,
                      decoration:
                          const InputDecoration(labelText: 'Assistance Type'),
                      items: AssistanceType.values
                          .map((t) => DropdownMenuItem(
                              value: t, child: Text(t.name)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => selectedType = v);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<RequestPriority>(
                      value: selectedPriority,
                      decoration:
                          const InputDecoration(labelText: 'Priority'),
                      items: RequestPriority.values
                          .map((p) => DropdownMenuItem(
                              value: p, child: Text(p.name)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => selectedPriority = v);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: vehicleController,
                      decoration: const InputDecoration(
                          labelText: 'Vehicle Description'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (nameController.text.isEmpty ||
                        phoneController.text.isEmpty ||
                        addressController.text.isEmpty) {
                      return;
                    }
                    context.read<RoadsideAssistanceProvider>().createRequest(
                          customerName: nameController.text,
                          customerPhone: phoneController.text,
                          assistanceType: selectedType,
                          priority: selectedPriority,
                          latitude: 0.0,
                          longitude: 0.0,
                          address: addressController.text,
                          vehicleDescription: vehicleController.text.isNotEmpty
                              ? vehicleController.text
                              : null,
                          notes: notesController.text.isNotEmpty
                              ? notesController.text
                              : null,
                        );
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _RequestListView extends StatelessWidget {
  final List<AssistanceRequest> requests;

  const _RequestListView({required this.requests});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No requests',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: requests.length,
      itemBuilder: (context, index) =>
          _RequestCard(request: requests[index]),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final AssistanceRequest request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final isEmergency = request.priority == RequestPriority.emergency;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isEmergency
            ? const BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
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
                    request.customerName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                _StatusChip(status: request.status),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(_assistanceTypeIcon(request.assistanceType),
                request.assistanceTypeLabel),
            const SizedBox(height: 4),
            _InfoRow(Icons.location_on, request.address),
            if (request.vehicleDescription != null) ...[
              const SizedBox(height: 4),
              _InfoRow(Icons.directions_car, request.vehicleDescription!),
            ],
            if (request.assignedDriverName != null) ...[
              const SizedBox(height: 4),
              _InfoRow(
                  Icons.person, 'Driver: ${request.assignedDriverName}'),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PriorityBadge(priority: request.priority),
                Text('ETA: ${request.etaLabel}',
                    style:
                        TextStyle(color: Colors.grey[600], fontSize: 12)),
                if (request.estimatedCost != null)
                  Text('\$${request.estimatedCost!.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static IconData _assistanceTypeIcon(AssistanceType type) {
    switch (type) {
      case AssistanceType.tow:
        return Icons.local_shipping;
      case AssistanceType.jumpStart:
        return Icons.battery_charging_full;
      case AssistanceType.tireChange:
        return Icons.tire_repair;
      case AssistanceType.lockout:
        return Icons.lock_open;
      case AssistanceType.fuelDelivery:
        return Icons.local_gas_station;
      case AssistanceType.winchOut:
        return Icons.swap_vert;
      case AssistanceType.other:
        return Icons.build;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final RequestStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case RequestStatus.requested:
        color = Colors.orange;
      case RequestStatus.dispatched:
        color = Colors.blue;
      case RequestStatus.enRoute:
        color = Colors.indigo;
      case RequestStatus.onScene:
        color = Colors.purple;
      case RequestStatus.inProgress:
        color = Colors.teal;
      case RequestStatus.completed:
        color = Colors.green;
      case RequestStatus.cancelled:
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
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final RequestPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (priority) {
      case RequestPriority.low:
        color = Colors.grey;
        icon = Icons.arrow_downward;
      case RequestPriority.normal:
        color = Colors.blue;
        icon = Icons.remove;
      case RequestPriority.high:
        color = Colors.orange;
        icon = Icons.arrow_upward;
      case RequestPriority.emergency:
        color = Colors.red;
        icon = Icons.warning;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Text(priority.name.toUpperCase(),
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold)),
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
