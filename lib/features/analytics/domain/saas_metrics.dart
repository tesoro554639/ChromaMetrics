class SaasMetrics {
  final double currentMrr;
  final double currentArr;
  final double churnRatePercent;
  final double arpu;
  final double ltv;
  final int activeSubscriptions;
  final double mrrGrowthPercent;
  final double arrGrowthPercent;

  const SaasMetrics({
    required this.currentMrr,
    required this.currentArr,
    required this.churnRatePercent,
    required this.arpu,
    required this.ltv,
    required this.activeSubscriptions,
    this.mrrGrowthPercent = 12.4,
    this.arrGrowthPercent = 14.8,
  });

  factory SaasMetrics.fromJson(Map<String, dynamic> json) {
    final mrr = (json['current_mrr_usd'] as num?)?.toDouble() ?? 0.0;
    final arr = (json['current_arr_usd'] as num?)?.toDouble() ?? (mrr * 12);
    final active = (json['active_subscriptions_count'] as num?)?.toInt() ?? 1;
    final arpu = active > 0 ? (mrr / active) : 0.0;
    const churn = 2.1; // Default low monthly churn %
    final ltv = churn > 0 ? (arpu / (churn / 100)) : (arpu * 24);

    return SaasMetrics(
      currentMrr: mrr,
      currentArr: arr,
      churnRatePercent: churn,
      arpu: arpu,
      ltv: ltv,
      activeSubscriptions: active,
      mrrGrowthPercent: 12.4,
      arrGrowthPercent: 14.8,
    );
  }
}

class RevenueTrendPoint {
  final String month;
  final double revenue;
  final int invoicesCount;
  final int churnCount;

  const RevenueTrendPoint({
    required this.month,
    required this.revenue,
    required this.invoicesCount,
    required this.churnCount,
  });

  factory RevenueTrendPoint.fromJson(Map<String, dynamic> json) {
    return RevenueTrendPoint(
      month: json['month_period'] as String? ?? '',
      revenue: (json['revenue_usd'] as num?)?.toDouble() ?? 0.0,
      invoicesCount: (json['invoices_paid_count'] as num?)?.toInt() ?? 0,
      churnCount: (json['churn_count'] as num?)?.toInt() ?? 0,
    );
  }
}
