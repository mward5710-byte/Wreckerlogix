import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fuel_cloud_provider.dart';
import '../models/fuel_transaction.dart';

/// FuelCloud dashboard — shows fuel transactions and summary stats.
class FuelCloudScreen extends StatefulWidget {
  const FuelCloudScreen({super.key});

  @override
  State<FuelCloudScreen> createState() => _FuelCloudScreenState();
}

// Primary accent color used throughout this screen.
const _kFuelBlue = Color(0xFF1565C0);

class _FuelCloudScreenState extends State<FuelCloudScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FuelCloudProvider>();
      if (provider.isConfigured) provider.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FuelCloudProvider>(
      builder: (context, fuel, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('FuelCloud'),
            actions: [
              if (fuel.isConfigured)
                IconButton(
                  icon: const Icon(Icons.filter_alt_outlined),
                  tooltip: 'Filter',
                  onPressed: () => _showFilterSheet(context, fuel),
                ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'API Settings',
                onPressed: () => context.push('/fuel-cloud/settings'),
              ),
            ],
          ),
          body: !fuel.isConfigured
              ? _NotConfiguredView(
                  onSetup: () => context.push('/fuel-cloud/settings'),
                )
              : fuel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : fuel.error != null
                      ? _ErrorView(error: fuel.error!, onRetry: fuel.refresh)
                      : RefreshIndicator(
                          onRefresh: fuel.refresh,
                          child: CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: _SummaryBar(fuel: fuel),
                              ),
                              if (fuel.vehicles.isNotEmpty)
                                SliverToBoxAdapter(
                                  child: _VehicleFilter(fuel: fuel),
                                ),
                              fuel.transactions.isEmpty
                                  ? const SliverFillRemaining(
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.local_gas_station,
                                                size: 64, color: Colors.grey),
                                            SizedBox(height: 16),
                                            Text('No transactions found',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 16)),
                                          ],
                                        ),
                                      ),
                                    )
                                  : SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) => _TransactionTile(
                                          transaction:
                                              fuel.transactions[index],
                                        ),
                                        childCount: fuel.transactions.length,
                                      ),
                                    ),
                            ],
                          ),
                        ),
          floatingActionButton: fuel.isConfigured
              ? FloatingActionButton(
                  onPressed: fuel.isLoading ? null : fuel.refresh,
                  tooltip: 'Sync FuelCloud',
                  child: const Icon(Icons.sync),
                )
              : null,
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context, FuelCloudProvider fuel) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _FilterSheet(fuel: fuel),
    );
  }
}

// ─── Summary Bar ─────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final FuelCloudProvider fuel;
  const _SummaryBar({required this.fuel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Total Gallons',
              value: fuel.totalVolume.toStringAsFixed(1),
              icon: Icons.local_gas_station,
              color: _kFuelBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'Total Cost',
              value: '\$${fuel.totalCost.toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'Avg PPG',
              value: '\$${fuel.averagePPG.toStringAsFixed(3)}',
              icon: Icons.trending_up,
              color: const Color(0xFFE65100),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─── Vehicle Filter Chips ─────────────────────────────────────────────────────

class _VehicleFilter extends StatelessWidget {
  final FuelCloudProvider fuel;
  const _VehicleFilter({required this.fuel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All Vehicles'),
              selected: fuel.selectedVehicleId == null,
              onSelected: (_) => fuel.setVehicleFilter(null),
            ),
          ),
          ...fuel.vehicles.map(
            (v) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(v.name),
                selected: fuel.selectedVehicleId == v.id,
                onSelected: (_) => fuel.setVehicleFilter(
                  fuel.selectedVehicleId == v.id ? null : v.id,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Transaction Tile ─────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final FuelTransaction transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy h:mm a');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.isVoided
              ? Colors.red.withAlpha(30)
              : _kFuelBlue.withAlpha(30),
          child: Icon(
            Icons.local_gas_station,
            color: transaction.isVoided ? Colors.red : _kFuelBlue,
          ),
        ),
        title: Text(
          transaction.vehicleName ?? 'Unassigned Vehicle',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fmt.format(transaction.transactionDate)),
            if (transaction.siteName != null)
              Text('Site: ${transaction.siteName}',
                  style: const TextStyle(fontSize: 12)),
            if (transaction.driverName != null)
              Text('Driver: ${transaction.driverName}',
                  style: const TextStyle(fontSize: 12)),
            if (transaction.isVoided)
              const Text('VOIDED',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              transaction.formattedCost,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: transaction.isVoided ? Colors.grey : Colors.green),
            ),
            Text(
              transaction.formattedVolume,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              transaction.formattedPPU,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

// ─── Filter Bottom Sheet ──────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final FuelCloudProvider fuel;
  const _FilterSheet({required this.fuel});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late DateTime? _start;
  late DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.fuel.filterStart;
    _end = widget.fuel.filterEnd;
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy');
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter Transactions',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                      _start != null ? fmt.format(_start!) : 'Start Date'),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _start ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => _start = date);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(_end != null ? fmt.format(_end!) : 'End Date'),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _end ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => _end = date);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  widget.fuel.setDateFilter(null, null);
                  widget.fuel.refresh();
                  Navigator.pop(context);
                },
                child: const Text('Clear Filter'),
              ),
              FilledButton(
                onPressed: () {
                  widget.fuel.setDateFilter(_start, _end);
                  widget.fuel.refresh();
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Not Configured ───────────────────────────────────────────────────────────

class _NotConfiguredView extends StatelessWidget {
  final VoidCallback onSetup;
  const _NotConfiguredView({required this.onSetup});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_gas_station, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text('FuelCloud Not Connected',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            const Text(
              'Connect your FuelCloud account to track fuel transactions, monitor fleet fuel costs, and view per-vehicle usage.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onSetup,
              icon: const Icon(Icons.link),
              label: const Text('Connect FuelCloud'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('FuelCloud Sync Error',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
