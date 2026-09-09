import '../../settings/domain/app_setting.dart';
import '../domain/sync_client_models.dart';

abstract final class SyncClientPreferenceKeys {
  static const profile = 'device.sync.client.profile';
  static const lastSafetyBackupDate = 'device.sync.lastSafetyBackupDate';
}

final class SyncConnectionStore {
  const SyncConnectionStore(this._settings);

  final SettingsRepository _settings;

  Future<SyncClientProfile?> load() async {
    final value = (await _settings.get(SyncClientPreferenceKeys.profile))
        ?.value;
    if (value == null) return null;
    return SyncClientProfile.decode(value);
  }

  Future<void> save(SyncClientProfile profile) =>
      _settings.set(SyncClientPreferenceKeys.profile, profile.encode());

  Future<void> clear() => _settings.remove(SyncClientPreferenceKeys.profile);
}
