/// Configuration for Meta Developer App
/// Populated from .env via: --dart-define-from-file=.env
class MetaConfig {
  MetaConfig._();

  static const String appId = String.fromEnvironment(
    'META_APP_ID',
    defaultValue: '',
  );

  static const String clientToken = String.fromEnvironment(
    'META_CLIENT_TOKEN',
    defaultValue: '',
  );

  static bool get isConfigured => appId.isNotEmpty;
}
