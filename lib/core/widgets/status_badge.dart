import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum BadgeStatus {
  active,
  trialing,
  pastDue,
  canceled,
  paid,
  pending,
}

class StatusBadge extends StatelessWidget {
  final BadgeStatus status;
  final String? label;

  const StatusBadge({
    super.key,
    required this.status,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String text = label ?? status.name.toUpperCase();

    switch (status) {
      case BadgeStatus.active:
      case BadgeStatus.paid:
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        text = label ?? (status == BadgeStatus.paid ? 'PAID' : 'ACTIVE');
        break;
      case BadgeStatus.trialing:
      case BadgeStatus.pending:
        bg = AppColors.info.withValues(alpha: 0.15);
        fg = AppColors.info;
        text = label ?? (status == BadgeStatus.trialing ? 'TRIAL' : 'PENDING');
        break;
      case BadgeStatus.pastDue:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        text = label ?? 'PAST DUE';
        break;
      case BadgeStatus.canceled:
        bg = AppColors.error.withValues(alpha: 0.15);
        fg = AppColors.error;
        text = label ?? 'CANCELED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
