import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/analytics/presentation/analytics_dashboard_screen.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/billing/presentation/subscription_management_screen.dart';
import '../../features/invoicing/presentation/invoice_history_screen.dart';
import '../../features/usage_grid/presentation/customer_usage_grid_screen.dart';
import '../widgets/responsive_scaffold.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      final isLoggingIn = state.uri.path == AppRoutes.login;

      // If user is not authenticated and trying to access protected routes
      if (!authState.isAuthenticated) {
        return isLoggingIn ? null : AppRoutes.login;
      }

      // If user is authenticated and navigating to login
      if (isLoggingIn) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ResponsiveScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const AnalyticsDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.usageGrid,
            builder: (context, state) => const CustomerUsageGridScreen(),
          ),
          GoRoute(
            path: AppRoutes.billing,
            builder: (context, state) => const SubscriptionManagementScreen(),
          ),
          GoRoute(
            path: AppRoutes.invoices,
            builder: (context, state) => const InvoiceHistoryScreen(),
          ),
        ],
      ),
    ],
  );
});
