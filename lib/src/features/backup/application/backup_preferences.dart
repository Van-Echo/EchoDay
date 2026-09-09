import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/data_providers.dart';
import '../data/backup_directory_resolver.dart';
import '../domain/backup_preferences.dart';

final backupDirectoryPreferenceProvider = StreamProvider<String?>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watch(BackupPreferenceKeys.directory)
      .map((setting) {
        final value = setting?.value.trim();
        return value == null || value.isEmpty ? null : value;
      });
});

final automaticBackupEnabledProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watch(BackupPreferenceKeys.automaticEnabled)
      .map(
        (setting) => setting?.value == null
            ? defaultAutomaticBackupEnabled
            : setting?.value == 'true',
      );
});

final automaticBackupRetentionCountProvider = StreamProvider<int>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watch(BackupPreferenceKeys.retentionCount)
      .map((setting) => parseAutomaticBackupRetentionCount(setting?.value));
});

final backupDirectoryResolutionProvider =
    FutureProvider<BackupDirectoryResolution>((ref) {
      ref.watch(backupDirectoryPreferenceProvider);
      return ref.watch(backupDirectoryResolverProvider).resolve();
    });

Future<void> setBackupDirectory(WidgetRef ref, String? path) {
  final repository = ref.read(settingsRepositoryProvider);
  final normalized = path?.trim();
  if (normalized == null || normalized.isEmpty) {
    return repository.remove(BackupPreferenceKeys.directory);
  }
  return repository.set(BackupPreferenceKeys.directory, normalized);
}

Future<void> setAutomaticBackupEnabled(WidgetRef ref, bool enabled) => ref
    .read(settingsRepositoryProvider)
    .set(BackupPreferenceKeys.automaticEnabled, '$enabled');

Future<void> setAutomaticBackupRetentionCount(WidgetRef ref, int count) => ref
    .read(settingsRepositoryProvider)
    .set(
      BackupPreferenceKeys.retentionCount,
      '${count.clamp(minimumAutomaticBackupRetentionCount, maximumAutomaticBackupRetentionCount)}',
    );
