/// EthioLiner application configuration.
///
/// Centralizes environment-specific values to avoid hardcoding
/// throughout the application. Never hardcode API URLs, secrets,
/// or environment-specific values directly in code.
class AppConfig {
  AppConfig._();

  /// Current application environment.
  static const Environment environment = Environment.dev;

  /// Application name.
  static const String appName = 'EthioLiner';

  /// Application version.
  static const String appVersion = '1.0.0';

  /// Base URL for the backend API.
  ///
  /// In production, this would come from environment variables
  /// or a build configuration system.
  static String get apiBaseUrl {
    switch (environment) {
      case Environment.dev:
        return 'http://10.0.2.2:8000/api/v1'; // Android emulator localhost
      case Environment.staging:
        return 'https://staging-api.ethioliner.com/api/v1';
      case Environment.prod:
        return 'https://api.ethioliner.com/api/v1';
    }
  }

  /// API request timeout duration.
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Temporary seat reservation duration.
  static const Duration seatReservationDuration = Duration(minutes: 10);

  /// Token refresh threshold — refresh the token if it expires
  /// within this duration.
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
}

/// Application environment.
enum Environment {
  /// Local development.
  dev,

  /// Staging/testing environment.
  staging,

  /// Production environment.
  prod,
}
