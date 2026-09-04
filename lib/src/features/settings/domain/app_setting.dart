final class AppSetting {
  const AppSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
    this.revision = 1,
  });

  final String key;
  final String value;
  final DateTime updatedAt;
  final int revision;
}

abstract interface class SettingsRepository {
  Stream<AppSetting?> watch(String key);
  Future<AppSetting?> get(String key);
  Future<void> set(String key, String value);
  Future<void> remove(String key);
}
