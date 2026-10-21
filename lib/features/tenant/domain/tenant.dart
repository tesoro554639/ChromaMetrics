class Tenant {
  final String id;
  final String name;
  final String slug;
  final String? stripeCustomerId;
  final String billingEmail;
  final String currency;
  final String? planName;
  final String? avatarUrl;

  const Tenant({
    required this.id,
    required this.name,
    required this.slug,
    this.stripeCustomerId,
    required this.billingEmail,
    this.currency = 'USD',
    this.planName,
    this.avatarUrl,
  });

  bool get isEnterprise => (planName ?? '').toLowerCase().contains('enterprise');

  int get tierRank {
    final plan = (planName ?? '').toLowerCase();
    if (plan.contains('enterprise')) return 3;
    if (plan.contains('pro') || plan.contains('scale')) return 2;
    return 1; // starter / default
  }

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      stripeCustomerId: json['stripe_customer_id'] as String?,
      billingEmail: json['billing_email'] as String? ?? '',
      currency: json['currency'] as String? ?? 'USD',
      planName: json['plan_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'stripe_customer_id': stripeCustomerId,
    'billing_email': billingEmail,
    'currency': currency,
  };
}
