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
  bool get hasStripeCustomer => stripeCustomerId != null && stripeCustomerId!.isNotEmpty;

  int get tierRank {
    final plan = (planName ?? '').toLowerCase();
    if (plan.contains('enterprise')) return 3;
    if (plan.contains('pro') || plan.contains('scale')) return 2;
    return 1; // starter / default
  }

  Tenant copyWith({
    String? id,
    String? name,
    String? slug,
    String? stripeCustomerId,
    String? billingEmail,
    String? currency,
    String? planName,
    String? avatarUrl,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      billingEmail: billingEmail ?? this.billingEmail,
      currency: currency ?? this.currency,
      planName: planName ?? this.planName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
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
