import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../providers/accounting_provider.dart';

/// Accounting dashboard — invoices, payments, and revenue.
class AccountingScreen extends StatelessWidget {
  const AccountingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounting')),
      body: Consumer<AccountingProvider>(
        builder: (context, acct, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Revenue cards
                Row(
                  children: [
                    Expanded(
                      child: _RevenueCard(
                        title: 'Total Revenue',
                        amount: acct.totalRevenue,
                        icon: Icons.trending_up,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RevenueCard(
                        title: 'Outstanding',
                        amount: acct.totalOutstanding,
                        icon: Icons.pending,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Invoice counts
                Row(
                  children: [
                    _InvoiceCountChip(
                        label: 'Draft',
                        count: acct.draftInvoices.length,
                        color: Colors.grey),
                    _InvoiceCountChip(
                        label: 'Sent',
                        count: acct.sentInvoices.length,
                        color: Colors.blue),
                    _InvoiceCountChip(
                        label: 'Paid',
                        count: acct.paidInvoices.length,
                        color: Colors.green),
                    _InvoiceCountChip(
                        label: 'Overdue',
                        count: acct.overdueInvoices.length,
                        color: Colors.red),
                  ],
                ),
                const SizedBox(height: 24),

                // Invoices list
                const Text('Invoices',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...acct.invoices.map((inv) => _InvoiceCard(
                      invoice: inv,
                      onStatusChange: (status) =>
                          acct.updateInvoiceStatus(inv.id, status),
                      onMarkPaid: () =>
                          acct.markAsPaid(inv.id, PaymentMethod.creditCard),
                    )),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/accounting/create-invoice'),
        icon: const Icon(Icons.receipt_long),
        label: const Text('New Invoice'),
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _RevenueCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
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
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceCountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _InvoiceCountChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Text('$count',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final ValueChanged<InvoiceStatus> onStatusChange;
  final VoidCallback onMarkPaid;

  const _InvoiceCard({
    required this.invoice,
    required this.onStatusChange,
    required this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(invoice.customerName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                _InvoiceStatusBadge(status: invoice.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('Invoice #${invoice.id}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 8),
            ...invoice.lineItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.description,
                          style: const TextStyle(fontSize: 13)),
                      Text('\$${item.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('\$${invoice.grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            if (invoice.status != InvoiceStatus.paid &&
                invoice.status != InvoiceStatus.cancelled) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (invoice.status == InvoiceStatus.draft)
                    OutlinedButton(
                      onPressed: () => onStatusChange(InvoiceStatus.sent),
                      child: const Text('Send'),
                    ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: onMarkPaid,
                    child: const Text('Mark Paid'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InvoiceStatusBadge extends StatelessWidget {
  final InvoiceStatus status;

  const _InvoiceStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case InvoiceStatus.draft:
        color = Colors.grey;
      case InvoiceStatus.sent:
        color = Colors.blue;
      case InvoiceStatus.paid:
        color = Colors.green;
      case InvoiceStatus.overdue:
        color = Colors.red;
      case InvoiceStatus.cancelled:
        color = Colors.red.shade300;
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
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
