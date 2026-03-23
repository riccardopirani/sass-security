class Env {
  static const _defaultSupabaseUrl = 'https://ouieulumtrnnjsjtlyxe.supabase.co';
  static const _defaultSupabaseAnonKey =
      'sb_publishable_JNTjWqrSduUw_ZQtLF22Ug_tBl-QyMG';

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: _defaultSupabaseUrl,
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: _defaultSupabaseAnonKey,
  );
  static const stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
  );

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
