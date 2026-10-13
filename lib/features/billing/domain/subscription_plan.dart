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
