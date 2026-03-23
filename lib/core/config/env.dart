class Env {
  static const _defaultSupabaseUrl = 'https://ouieulumtrnnjsjtlyxe.supabase.co';
  static const _defaultSupabaseAnonKey =
      'sb_publishable_JNTjWqrSduUw_ZQtLF22Ug_tBl-QyMG';

  static const _supabaseUrlFromDefine = String.fromEnvironment('SUPABASE_URL');
  static const _supabaseAnonKeyFromDefine =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static const supabaseUrl = _supabaseUrlFromDefine.isNotEmpty
      ? _supabaseUrlFromDefine
      : _defaultSupabaseUrl;
  static const supabaseAnonKey = _supabaseAnonKeyFromDefine.isNotEmpty
      ? _supabaseAnonKeyFromDefine
      : _defaultSupabaseAnonKey;
  static const stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
  );

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
