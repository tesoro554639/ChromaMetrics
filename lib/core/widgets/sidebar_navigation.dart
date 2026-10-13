import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';

class NavItem {
  final String title;
  final IconData icon;
  final String route;

  const NavItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}

class SidebarNavigation extends StatelessWidget {
  final String currentRoute;

  const SidebarNavigation({
    super.key,
    required this.currentRoute,
  });

  static const List<NavItem> navItems = [
    NavItem(title: 'Overview Analytics', icon: Icons.dashboard_outlined, route: AppRoutes.dashboard),
    NavItem(title: 'Customer Usage Grid', icon: Icons.table_chart_outlined, route: AppRoutes.usageGrid),
    NavItem(title: 'Billing & Tiers', icon: Icons.credit_card_outlined, route: AppRoutes.billing),
    NavItem(title: 'Invoices & Receipts', icon: Icons.receipt_long_outlined, route: AppRoutes.invoices),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Brand
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SaaS Core',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Billing & Telemetry',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 16),

          // Section Label
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Text(
              'PLATFORM MODULES',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),

          // Nav Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: navItems.map((item) {
                final bool isSelected = currentRoute == item.route;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                    leading: Icon(
                      item.icon,
                      size: 20,
                      color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                    onTap: () {
                      if (!isSelected) {
                        context.go(item.route);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Version / Environment Footer
          const Divider(color: AppColors.divider, height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Connected • Multi-Tenant v1.0',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
