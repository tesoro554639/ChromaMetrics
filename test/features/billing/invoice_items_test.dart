import 'package:flutter_test/flutter_test.dart';
import 'package:multi_tenant_saas_billing/features/billing/domain/invoice.dart';

void main() {
  group('Invoice Line Items', () {
    test('hasLineItems and totalItemsCount calculate correctly', () {
      const invoice = Invoice(
        id: 'inv_10',
        organizationId: 'org_1',
        invoiceNumber: 'INV-2026-010',
        amountDueCents: 12000,
        amountPaidCents: 12000,
        status: 'paid',
        lineItems: [
          InvoiceItem(description: 'Base Tier', amountCents: 10000, quantity: 1),
          InvoiceItem(description: 'Add-on', amountCents: 2000, quantity: 2),
        ],
      );

      expect(invoice.hasLineItems, isTrue);
      expect(invoice.totalItemsCount, equals(3));
    });
  });
}
