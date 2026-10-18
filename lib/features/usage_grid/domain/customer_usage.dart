class CustomerUsage {
  final String userId;
  final String userEmail;
  final String userName;
  final String meterKey;
  final String meterName;
  final double totalQuantity;
  final String unit;
  final DateTime lastActivity;
  final String status;

  const CustomerUsage({
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.meterKey,
    required this.meterName,
    required this.totalQuantity,
    required this.unit,
    required this.lastActivity,
    this.status = 'ACTIVE',
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  CustomerUsage copyWith({
    String? userId,
    String? userEmail,
    String? userName,
    String? meterKey,
    String? meterName,
    double? totalQuantity,
    String? unit,
    DateTime? lastActivity,
    String? status,
  }) {
    return CustomerUsage(
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      meterKey: meterKey ?? this.meterKey,
      meterName: meterName ?? this.meterName,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      unit: unit ?? this.unit,
      lastActivity: lastActivity ?? this.lastActivity,
      status: status ?? this.status,
    );
  }

  factory CustomerUsage.fromJson(Map<String, dynamic> json) {
    return CustomerUsage(
      userId: json['user_id'] as String,
      userEmail: json['user_email'] as String,
      userName: json['user_name'] as String? ?? 'Team Member',
      meterKey: json['meter_key'] as String,
      meterName: json['meter_name'] as String,
      totalQuantity: (json['total_quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String,
      lastActivity: DateTime.tryParse(json['last_activity'] as String? ?? '') ??
          DateTime.now(),
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }
}
