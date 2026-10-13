import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../billing/presentation/billing_controller.dart';
import '../../tenant/presentation/tenant_controller.dart';
import '../services/pdf_invoice_generator.dart';

class InvoiceHistoryScreen extends ConsumerWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTenant = ref.watch(activeTenantProvider);
    final invoicesAsync = ref.watch(invoicesListProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invoicing & Historical Billing Receipts',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Client-side PDF invoice compilation, print-preview rendering and audit statements',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(invoicesListProvider),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Invoices Table Card
          Expanded(
            child: Card(
              child: invoicesAsync.when(
                data: (invoices) {
                  if (invoices.isEmpty) {
                    return const Center(
                      child: Text('No historical invoices recorded for this organization.'),
                    );
                  }

                  return ListView.separated(
                    itemCount: invoices.length,
                    separatorBuilder: (_, __) => const Divider(color: AppColors.divider, height: 1),
                    itemBuilder: (context, index) {
                      final invoice = invoices[index];

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 22),
                        ),
                        title: Row(
                          children: [
                            Text(
                              invoice.invoiceNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(width: 12),
                            StatusBadge(status: invoice.badgeStatus),
                          ],
                        ),
                        subtitle: Text(
                          'Issued on ${DateFormatter.formatDate(invoice.paidAt ?? DateTime.now())} • Currency: ${invoice.currency}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              CurrencyFormatter.formatCents(invoice.amountPaidCents, currency: invoice.currency),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (activeTenant != null) {
                                  await PdfInvoiceGenerator.printOrPreviewInvoice(
                                    invoice: invoice,
                                    tenant: activeTenant,
                                  );
                                }
                              },
                              icon: const Icon(Icons.print_outlined, size: 16),
                              label: const Text('PDF / Print'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error loading invoices: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
