enum TenantRole {
  owner,
  admin,
  billingManager,
  member,
  viewer;

  static TenantRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return TenantRole.owner;
      case 'admin':
        return TenantRole.admin;
      case 'billing_manager':
        return TenantRole.billingManager;
      case 'viewer':
        return TenantRole.viewer;
      case 'member':
      default:
        return TenantRole.member;
    }
  }

  bool get canManageBilling =>
      this == TenantRole.owner ||
      this == TenantRole.admin ||
      this == TenantRole.billingManager;

  bool get canManageMembers =>
      this == TenantRole.owner || this == TenantRole.admin;

  bool get isOwner => this == TenantRole.owner;
  bool get isAdminOrAbove => this == TenantRole.owner || this == TenantRole.admin;
  bool get isReadOnly => this == TenantRole.viewer;
}

class TenantMembership {
  final String id;
  final String organizationId;
  final String userId;
  final TenantRole role;

  const TenantMembership({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.role,
  });

  bool get canManageBilling => role.canManageBilling;
  bool get canManageMembers => role.canManageMembers;

  factory TenantMembership.fromJson(Map<String, dynamic> json) {
    return TenantMembership(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      userId: json['user_id'] as String,
      role: TenantRole.fromString(json['role'] as String? ?? 'member'),
    );
  }
}
