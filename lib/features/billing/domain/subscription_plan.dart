class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final int amountInCents;
  final String interval; // 'month' or 'year'
  final List<String> features;
  final Map<String, dynamic> limits;
  final String stripePriceId;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.amountInCents,
    required this.interval,
    required this.features,
    required this.limits,
    required this.stripePriceId,
    this.isPopular = false,
  });

  double get amountInDollars => amountInCents / 100.0;
  bool get isAnnual => interval.toLowerCase() == 'year';
  bool get isMonthly => interval.toLowerCase() == 'month';
  int get seatLimit => (limits['seats'] as num?)?.toInt() ?? 1;

  /// Calculates percentage savings of this annual plan compared against an annualized monthly cost.
  /// Returns 0 if this plan is not annual or if monthly baseline is non-positive.
  int annualSavingsPercent(int monthlyAmountInCents) {
    if (!isAnnual || monthlyAmountInCents <= 0) return 0;
    final annualizedMonthly = monthlyAmountInCents * 12;
    if (amountInCents >= annualizedMonthly) return 0;
    final diff = annualizedMonthly - amountInCents;
    return ((diff / annualizedMonthly) * 100).round();
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      amountInCents: json['amount_in_cents'] as int? ?? 0,
      interval: json['interval'] as String? ?? 'month',
      features: (json['features'] as List?)?.map((e) => e.toString()).toList() ?? [],
      limits: (json['limits'] as Map<String, dynamic>?) ?? {},
      stripePriceId: json['stripe_price_id'] as String? ?? '',
      isPopular: (json['name'] as String? ?? '').toLowerCase().contains('pro'),
    );
  }
}
