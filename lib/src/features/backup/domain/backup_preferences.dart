abstract final class BackupPreferenceKeys {
  static const directory = 'device.backup.directory';
  static const automaticEnabled = 'device.backup.automaticEnabled';
  static const retentionCount = 'device.backup.retentionCount';
  static const lastAutomaticDate = 'device.backup.lastAutomaticDate';
}

const defaultAutomaticBackupEnabled = false;
const defaultAutomaticBackupRetentionCount = 10;
const minimumAutomaticBackupRetentionCount = 1;
const maximumAutomaticBackupRetentionCount = 30;

bool isDeviceLocalBackupSettingKey(String key) => key.startsWith('device.');

int parseAutomaticBackupRetentionCount(String? value) =>
    (int.tryParse(value ?? '') ?? defaultAutomaticBackupRetentionCount).clamp(
      minimumAutomaticBackupRetentionCount,
      maximumAutomaticBackupRetentionCount,
    );
