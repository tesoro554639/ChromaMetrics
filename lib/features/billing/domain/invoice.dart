import '../../../../core/widgets/status_badge.dart';

class InvoiceItem {
  final String description;
  final int amountCents;
  final int quantity;

  const InvoiceItem({
    required this.description,
    required this.amountCents,
    this.quantity = 1,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      description: json['description'] as String? ?? 'Subscription Base',
      amountCents: json['amount'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}

class Invoice {
  final String id;
  final String organizationId;
  final String invoiceNumber;
  final int amountDueCents;
  final int amountPaidCents;
  final String currency;
  final String status;
  final DateTime? paidAt;
  final String? invoicePdfUrl;
  final List<InvoiceItem> lineItems;

  const Invoice({
    required this.id,
    required this.organizationId,
    required this.invoiceNumber,
    required this.amountDueCents,
    required this.amountPaidCents,
    this.currency = 'USD',
    required this.status,
    this.paidAt,
    this.invoicePdfUrl,
    this.lineItems = const [],
  });

  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isOpen => status.toLowerCase() == 'open';
  bool get isVoid => status.toLowerCase() == 'void' || status.toLowerCase() == 'uncollectible';

  BadgeStatus get badgeStatus {
    switch (status.toLowerCase()) {
      case 'paid':
        return BadgeStatus.paid;
      case 'open':
        return BadgeStatus.trialing;
      case 'uncollectible':
      case 'void':
      default:
        return BadgeStatus.canceled;
    }
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final rawLines = json['line_items'] as List?;
    final items = rawLines != null
        ? rawLines.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>)).toList()
        : <InvoiceItem>[];

    return Invoice(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      amountDueCents: json['amount_due_cents'] as int? ?? 0,
      amountPaidCents: json['amount_paid_cents'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      status: json['status'] as String? ?? 'paid',
      paidAt: DateTime.tryParse(json['paid_at'] as String? ?? ''),
      invoicePdfUrl: json['invoice_pdf_url'] as String?,
      lineItems: items,
    );
  }
}
