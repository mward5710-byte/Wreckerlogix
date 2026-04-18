import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../providers/accounting_provider.dart';

/// Create a new invoice.
class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameCtrl = TextEditingController();
  final _customerEmailCtrl = TextEditingController();
  final _customerPhoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<_LineItemEntry> _lineItems = [_LineItemEntry()];
  double _taxRate = 0.08;

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerEmailCtrl.dispose();
    _customerPhoneCtrl.dispose();
    _notesCtrl.dispose();
    for (final item in _lineItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _addLineItem() {
    setState(() => _lineItems.add(_LineItemEntry()));
  }

  void _removeLineItem(int index) {
    if (_lineItems.length <= 1) return;
    setState(() {
      _lineItems[index].dispose();
      _lineItems.removeAt(index);
    });
  }

  double get _subtotal => _lineItems.fold(0.0, (sum, item) {
        final price = double.tryParse(item.priceCtrl.text) ?? 0;
        final qty = int.tryParse(item.qtyCtrl.text) ?? 1;
        return sum + (price * qty);
      });

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final lineItems = _lineItems.map((item) {
      return LineItem(
        description: item.descCtrl.text.trim(),
        unitPrice: double.tryParse(item.priceCtrl.text) ?? 0,
        quantity: int.tryParse(item.qtyCtrl.text) ?? 1,
      );
    }).toList();

    final invoice = Invoice(
      id: 'inv-${DateTime.now().millisecondsSinceEpoch}',
      jobId: '',
      customerName: _customerNameCtrl.text.trim(),
      customerEmail: _customerEmailCtrl.text.trim(),
      customerPhone: _customerPhoneCtrl.text.trim().isNotEmpty
          ? _customerPhoneCtrl.text.trim()
          : null,
      lineItems: lineItems,
      taxRate: _taxRate,
      createdAt: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );

    context.read<AccountingProvider>().createInvoice(invoice);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Invoice')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Customer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customerNameCtrl,
                decoration: const InputDecoration(labelText: 'Customer Name *'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customerEmailCtrl,
                decoration: const InputDecoration(labelText: 'Email *'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (!v.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customerPhoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // Line items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Line Items',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _addLineItem,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Item'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(_lineItems.length, (i) {
                final item = _lineItems[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: item.descCtrl,
                          decoration: InputDecoration(
                            labelText: 'Description *',
                            suffixIcon: _lineItems.length > 1
                                ? IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () => _removeLineItem(i),
                                  )
                                : null,
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: item.qtyCtrl,
                                decoration:
                                    const InputDecoration(labelText: 'Qty'),
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: item.priceCtrl,
                                decoration: const InputDecoration(
                                    labelText: 'Unit Price',
                                    prefixText: '\$ '),
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Totals
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _TotalRow('Subtotal', _subtotal),
                      _TotalRow('Tax (${(_taxRate * 100).toStringAsFixed(0)}%)',
                          _subtotal * _taxRate),
                      const Divider(),
                      _TotalRow('Total', _subtotal * (1 + _taxRate),
                          isBold: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.receipt),
                  label: const Text('Create Invoice'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineItemEntry {
  final descCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '1');
  final priceCtrl = TextEditingController();

  void dispose() {
    descCtrl.dispose();
    qtyCtrl.dispose();
    priceCtrl.dispose();
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;

  const _TotalRow(this.label, this.amount, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text('\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: isBold ? 20 : 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              )),
        ],
      ),
    );
  }
}
