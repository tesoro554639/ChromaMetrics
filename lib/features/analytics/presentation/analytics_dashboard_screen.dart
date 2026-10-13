import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/metric_card.dart';
import '../../tenant/presentation/tenant_controller.dart';
import 'analytics_controller.dart';
import 'charts/churn_rate_gauge.dart';
import 'charts/mrr_trend_chart.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTenant = ref.watch(activeTenantProvider);
    final metricsAsync = ref.watch(saasMetricsProvider);
    final trendAsync = ref.watch(revenueTrendProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Executive Analytics Overview',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time SaaS recurring revenue and telemetry performance for ${activeTenant?.name ?? "Organization"}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(saasMetricsProvider);
                  ref.invalidate(revenueTrendProvider);
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh Data'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4 Key SaaS Metric Cards
          metricsAsync.when(
            data: (metrics) => LayoutBuilder(
              builder: (context, constraints) {
                final int crossAxisCount = constraints.maxWidth > 1100
                    ? 4
                    : constraints.maxWidth > 700
                        ? 2
                        : 1;

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.6,
                  children: [
                    MetricCard(
                      title: 'Monthly Recurrent Revenue (MRR)',
                      value: CurrencyFormatter.formatAmount(metrics.currentMrr),
                      percentageChange: metrics.mrrGrowthPercent,
                      subtitle: 'vs previous month',
                      icon: Icons.payments_outlined,
                      iconColor: AppColors.primary,
                    ),
                    MetricCard(
                      title: 'Annual Recurrent Revenue (ARR)',
                      value: CurrencyFormatter.formatAmount(metrics.currentArr),
                      percentageChange: metrics.arrGrowthPercent,
                      subtitle: 'projected annualized run-rate',
                      icon: Icons.auto_graph_outlined,
                      iconColor: AppColors.success,
                    ),
                    MetricCard(
                      title: 'Average Revenue Per User (ARPU)',
                      value: CurrencyFormatter.formatAmount(metrics.arpu),
                      subtitle: 'across ${metrics.activeSubscriptions} active subscriptions',
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: AppColors.secondary,
                    ),
                    MetricCard(
                      title: 'Customer Lifetime Value (LTV)',
                      value: CurrencyFormatter.formatAmount(metrics.ltv),
                      subtitle: 'churn-adjusted value per tenant',
                      icon: Icons.workspace_premium_outlined,
                      iconColor: AppColors.warning,
                    ),
                  ],
                );
              },
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Text('Error loading metrics: $err'),
          ),

          const SizedBox(height: 28),

          // Charts Row: Revenue Line Chart (70%) + Churn Rate Gauge (30%)
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 900;

              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Revenue Growth Line Chart
                  Expanded(
                    flex: isWide ? 7 : 0,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Recurring Revenue Trend',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Historical monthly recurring billing trajectory',
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Last 6 Months', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              height: 300,
                              child: trendAsync.when(
                                data: (data) => MrrTrendChart(trendData: data),
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (err, _) => Center(child: Text('Error: $err')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (isWide) const SizedBox(width: 16) else const SizedBox(height: 16),

                  // Churn Rate & Retention Gauge
                  Expanded(
                    flex: isWide ? 3 : 0,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Churn & Retention Rate',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Monthly customer cancellation metric',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              height: 300,
                              child: metricsAsync.when(
                                data: (metrics) => ChurnRateGauge(
                                  churnRate: metrics.churnRatePercent,
                                ),
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (err, _) => Center(child: Text('Error: $err')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
