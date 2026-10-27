/// Configuration for Cloud Supabase
/// Values can be injected at compile-time using:
/// --dart-define=SUPABASE_URL=https://your-project.supabase.co
/// --dart-define=SUPABASE_ANON_KEY=your-anon-key
class SupabaseConfig {
  SupabaseConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Check whether Cloud Supabase keys are configured
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Optional runtime initialization helper
  static String? activeUrl;
  static String? activeAnonKey;

  static String get currentUrl =>
      activeUrl?.isNotEmpty == true ? activeUrl! : supabaseUrl;

  static String get currentAnonKey =>
      activeAnonKey?.isNotEmpty == true ? activeAnonKey! : supabaseAnonKey;
}
