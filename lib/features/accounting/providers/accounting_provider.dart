import 'package:flutter/foundation.dart';
import '../models/invoice.dart';

/// State management for accounting — invoices and payments.
class AccountingProvider extends ChangeNotifier {
  final List<Invoice> _invoices = [];
  bool _isLoading = false;

  List<Invoice> get invoices => List.unmodifiable(_invoices);
  List<Invoice> get draftInvoices =>
      _invoices.where((i) => i.status == InvoiceStatus.draft).toList();
  List<Invoice> get sentInvoices =>
      _invoices.where((i) => i.status == InvoiceStatus.sent).toList();
  List<Invoice> get paidInvoices =>
      _invoices.where((i) => i.status == InvoiceStatus.paid).toList();
  List<Invoice> get overdueInvoices =>
      _invoices.where((i) => i.status == InvoiceStatus.overdue).toList();
  bool get isLoading => _isLoading;

  /// Revenue totals
  double get totalRevenue =>
      _invoices.where((i) => i.status == InvoiceStatus.paid)
          .fold(0.0, (sum, i) => sum + i.grandTotal);
  double get totalOutstanding =>
      _invoices.where((i) =>
          i.status == InvoiceStatus.sent || i.status == InvoiceStatus.overdue)
          .fold(0.0, (sum, i) => sum + i.grandTotal);

  AccountingProvider() {
    _loadSampleData();
  }

  void createInvoice(Invoice invoice) {
    _invoices.insert(0, invoice);
    notifyListeners();
  }

  void updateInvoiceStatus(String invoiceId, InvoiceStatus status) {
    final index = _invoices.indexWhere((i) => i.id == invoiceId);
    if (index == -1) return;

    _invoices[index] = _invoices[index].copyWith(
      status: status,
      paidAt: status == InvoiceStatus.paid ? DateTime.now() : null,
    );
    notifyListeners();
  }

  void markAsPaid(String invoiceId, PaymentMethod method) {
    final index = _invoices.indexWhere((i) => i.id == invoiceId);
    if (index == -1) return;

    _invoices[index] = _invoices[index].copyWith(
      status: InvoiceStatus.paid,
      paidAt: DateTime.now(),
      paymentMethod: method,
    );
    notifyListeners();
  }

  void deleteInvoice(String invoiceId) {
    _invoices.removeWhere((i) => i.id == invoiceId);
    notifyListeners();
  }

  void _loadSampleData() {
    _invoices.addAll([
      Invoice(
        id: 'inv-001',
        jobId: 'job-003',
        customerName: 'Lisa Chen',
        customerEmail: 'lisa.chen@email.com',
        customerPhone: '(555) 456-7890',
        lineItems: const [
          LineItem(description: 'Light Duty Tow — 12 miles', unitPrice: 75.00),
          LineItem(description: 'Hookup Fee', unitPrice: 20.00),
        ],
        taxRate: 0.08,
        status: InvoiceStatus.paid,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        dueDate: DateTime.now().add(const Duration(days: 28)),
        paidAt: DateTime.now().subtract(const Duration(hours: 1)),
        paymentMethod: PaymentMethod.creditCard,
      ),
      Invoice(
        id: 'inv-002',
        jobId: 'job-002',
        customerName: 'Tom Williams',
        customerEmail: 'tom.w@email.com',
        customerPhone: '(555) 987-6543',
        lineItems: const [
          LineItem(description: 'Heavy Duty Tow — 8 miles', unitPrice: 200.00),
          LineItem(description: 'Winch Recovery', unitPrice: 50.00),
        ],
        taxRate: 0.08,
        status: InvoiceStatus.sent,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        dueDate: DateTime.now().add(const Duration(days: 30)),
      ),
      Invoice(
        id: 'inv-003',
        jobId: 'job-001',
        customerName: 'Sarah Johnson',
        customerEmail: 'sarah.j@email.com',
        lineItems: const [
          LineItem(description: 'Flatbed Tow — 5 miles', unitPrice: 100.00),
          LineItem(description: 'After-Hours Surcharge', unitPrice: 25.00),
        ],
        taxRate: 0.08,
        status: InvoiceStatus.draft,
        createdAt: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
      ),
    ]);
  }
}
