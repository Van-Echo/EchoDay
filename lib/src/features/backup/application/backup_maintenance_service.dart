import 'dart:async';
import 'dart:io';

import '../../settings/domain/app_setting.dart';
import '../data/backup_directory_resolver.dart';
import '../domain/backup_preferences.dart';
import '../domain/backup_repository.dart';

final class BackupMaintenanceService {
  BackupMaintenanceService(
    this._repository,
    this._settings,
    this._directories, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final BackupRepository _repository;
  final SettingsRepository _settings;
  final BackupDirectoryResolver _directories;
  final DateTime Function() _now;
  Future<BackupManifest?>? _automaticRun;

  Future<BackupManifest> createDefaultBackup() async {
    final directory = await _directories.manualDirectory();
    final path = _join(directory.path, standardBackupFileName(_now()));
    return _repository.exportTo(await _uniquePath(path));
  }

  Future<BackupManifest?> createAutomaticBackupIfDue() {
    final running = _automaticRun;
    if (running != null) return running;
    final future = _createAutomaticBackupIfDue();
    _automaticRun = future;
    return future.whenComplete(() => _automaticRun = null);
  }

  Future<BackupManifest?> _createAutomaticBackupIfDue() async {
    final enabled =
        (await _settings.get(BackupPreferenceKeys.automaticEnabled))?.value ==
        'true';
    if (!enabled) return null;

    final now = _now();
    final dateKey = _localDateKey(now);
    final lastDate = (await _settings.get(
      BackupPreferenceKeys.lastAutomaticDate,
    ))?.value;
    if (lastDate == dateKey) return null;

    final directory = await _directories.automaticDirectory();
    final name = 'automatic-${standardBackupFileName(now)}';
    final manifest = await _repository.exportTo(
      await _uniquePath(_join(directory.path, name)),
    );
    await _settings.set(BackupPreferenceKeys.lastAutomaticDate, dateKey);
    await pruneAutomaticBackups();
    return manifest;
  }

  Future<int> pruneAutomaticBackups() async {
    final retention = parseAutomaticBackupRetentionCount(
      (await _settings.get(BackupPreferenceKeys.retentionCount))?.value,
    );
    final directory = await _directories.automaticDirectory();
    final root = directory.absolute.path;
    final files = await directory
        .list(followLinks: false)
        .where((entry) => entry is File)
        .cast<File>()
        .where((file) {
          final name = _fileName(file.path);
          return name.startsWith('automatic-EchoDay-backup-') &&
              name.endsWith('.json');
        })
        .toList();
    files.sort((left, right) => right.path.compareTo(left.path));
    var removed = 0;
    for (final file in files.skip(retention)) {
      final candidate = file.absolute.path;
      if (!_isChildPath(root, candidate)) {
        throw StateError('Refusing to delete a backup outside $root');
      }
      await file.delete();
      removed++;
    }
    return removed;
  }

  static String _localDateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  static String _join(String parent, String child) {
    final separator = Platform.pathSeparator;
    return parent.endsWith(separator)
        ? '$parent$child'
        : '$parent$separator$child';
  }

  static String _fileName(String path) => path.split(RegExp(r'[/\\]')).last;

  static bool _isChildPath(String parent, String candidate) {
    final normalizedParent = Directory(parent).absolute.path;
    final normalizedCandidate = File(candidate).absolute.path;
    final prefix = normalizedParent.endsWith(Platform.pathSeparator)
        ? normalizedParent
        : '$normalizedParent${Platform.pathSeparator}';
    if (Platform.isWindows) {
      return normalizedCandidate.toLowerCase().startsWith(prefix.toLowerCase());
    }
    return normalizedCandidate.startsWith(prefix);
  }

  Future<String> _uniquePath(String initial) async {
    if (!await File(initial).exists()) return initial;
    var suffix = 2;
    while (true) {
      final candidate = initial.replaceFirst('.json', '-$suffix.json');
      if (!await File(candidate).exists()) return candidate;
      suffix++;
    }
  }
}
