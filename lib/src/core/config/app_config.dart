enum AppEnvironment { development, production }

abstract final class AppConfig {
  static const String applicationId = 'com.vanecho.echoday';
  static const String appName = 'EchoDay';
  static const String version = '1.0.7';
  static const String releaseDate = '2026/10/6';

  static const AppEnvironment environment =
      bool.fromEnvironment('dart.vm.product')
      ? AppEnvironment.production
      : AppEnvironment.development;
}
