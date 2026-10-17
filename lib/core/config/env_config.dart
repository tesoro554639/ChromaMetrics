/// Environment configuration for Supabase and Stripe integration
class EnvConfig {
  // Supabase Configuration
  // In production, these should be supplied via `--dart-define` or .env files.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xyzcompany.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'public-anon-key-placeholder',
  );

  // Stripe Public Key for client-side checkout
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_sample_stripe_publishable_key',
  );

  // Demo / Offline Mode Switch: Allows immediate dashboard simulation without backend lock
  static const bool isDemoMode = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: true,
  );

  /// Returns true if Supabase URL and anon key are populated with real non-placeholder values
  static bool get hasSupabaseCredentials =>
      supabaseUrl.isNotEmpty &&
      !supabaseUrl.contains('xyzcompany') &&
      supabaseAnonKey.isNotEmpty &&
      supabaseAnonKey != 'public-anon-key-placeholder';

  /// Returns true if running in production mode (non-demo and with valid backend configuration)
  static bool get isProduction => !isDemoMode && hasSupabaseCredentials;
}
