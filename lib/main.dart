import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/env_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase if not running in pure demo mode
  if (!EnvConfig.isDemoMode) {
    try {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: EnvConfig.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization failed, falling back to Demo Mode: $e');
    }
  }

  runApp(
    const ProviderScope(
      child: SaasPortalApp(),
    ),
  );
}

class SaasPortalApp extends ConsumerWidget {
  const SaasPortalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Multi-Tenant SaaS Billing & Analytics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
