/// Accounting models — invoices and payments.
enum InvoiceStatus { draft, sent, paid, overdue, cancelled }

enum PaymentMethod { cash, check, creditCard, debitCard, ach, other }

class Invoice {
  final String id;
  final String jobId;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;
  final List<LineItem> lineItems;
  final double taxRate; // e.g. 0.08 for 8%
  final InvoiceStatus status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final PaymentMethod? paymentMethod;
  final String? notes;

  const Invoice({
    required this.id,
    required this.jobId,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    required this.lineItems,
    this.taxRate = 0.0,
    this.status = InvoiceStatus.draft,
    required this.createdAt,
    this.dueDate,
    this.paidAt,
    this.paymentMethod,
    this.notes,
  });

  Invoice copyWith({
    InvoiceStatus? status,
    DateTime? paidAt,
    PaymentMethod? paymentMethod,
    List<LineItem>? lineItems,
    String? notes,
  }) {
    return Invoice(
      id: id,
      jobId: jobId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      lineItems: lineItems ?? this.lineItems,
      taxRate: taxRate,
      status: status ?? this.status,
      createdAt: createdAt,
      dueDate: dueDate,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
    );
  }

  double get subtotal => lineItems.fold(0.0, (sum, item) => sum + item.total);
  double get taxAmount => subtotal * taxRate;
  double get grandTotal => subtotal + taxAmount;

  String get statusLabel {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class LineItem {
  final String description;
  final int quantity;
  final double unitPrice;

  const LineItem({
    required this.description,
    this.quantity = 1,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}
