import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import 'sidebar_navigation.dart';
import 'top_nav_bar.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget child;

  const ResponsiveScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final String currentRoute = GoRouterState.of(context).uri.path;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 900;

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: isDesktop
              ? null
              : Drawer(
                  backgroundColor: AppColors.surface,
                  child: SidebarNavigation(currentRoute: currentRoute),
                ),
          appBar: isDesktop
              ? null
              : AppBar(
                  backgroundColor: AppColors.surface,
                  title: const Text('SaaS Dashboard', style: TextStyle(fontSize: 16)),
                ),
          body: Row(
            children: [
              if (isDesktop) SidebarNavigation(currentRoute: currentRoute),
              Expanded(
                child: Column(
                  children: [
                    const TopNavBar(),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
