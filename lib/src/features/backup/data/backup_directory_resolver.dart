import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../settings/domain/app_setting.dart';
import '../domain/backup_preferences.dart';

typedef DefaultBackupRootProvider = Future<Directory> Function();

final class BackupDirectoryResolution {
  const BackupDirectoryResolution({
    required this.effectiveRoot,
    this.configuredPath,
    this.fallbackReason,
  });

  final Directory effectiveRoot;
  final String? configuredPath;
  final Object? fallbackReason;

  bool get usesFallback => configuredPath != null && fallbackReason != null;
}

final class BackupDirectoryResolver {
  BackupDirectoryResolver(
    this._settings, {
    DefaultBackupRootProvider? defaultRoot,
  }) : _defaultRoot = defaultRoot ?? _defaultBackupRoot;

  final SettingsRepository _settings;
  final DefaultBackupRootProvider _defaultRoot;

  Future<BackupDirectoryResolution> resolve() async {
    final configured = (await _settings.get(BackupPreferenceKeys.directory))
        ?.value
        .trim();
    if (configured != null && configured.isNotEmpty) {
      try {
        final directory = Directory(configured).absolute;
        await directory.create(recursive: true);
        return BackupDirectoryResolution(
          effectiveRoot: directory,
          configuredPath: configured,
        );
      } on Object catch (error) {
        final fallback = await _createDefaultRoot();
        return BackupDirectoryResolution(
          effectiveRoot: fallback,
          configuredPath: configured,
          fallbackReason: error,
        );
      }
    }
    return BackupDirectoryResolution(effectiveRoot: await _createDefaultRoot());
  }

  Future<Directory> manualDirectory() => _subdirectory('Manual Backups');

  Future<Directory> automaticDirectory() => _subdirectory('Automatic Backups');

  Future<Directory> safetyDirectory() => _subdirectory('Safety Backups');

  Future<Directory> _subdirectory(String name) async {
    final resolution = await resolve();
    final directory = Directory(_join(resolution.effectiveRoot.path, name));
    await directory.create(recursive: true);
    return directory;
  }

  Future<Directory> _createDefaultRoot() async {
    final directory = (await _defaultRoot()).absolute;
    await directory.create(recursive: true);
    return directory;
  }

  static Future<Directory> _defaultBackupRoot() async {
    final support = await getApplicationSupportDirectory();
    return Directory(_join(_join(support.path, 'EchoDay'), 'Backups'));
  }

  static String _join(String parent, String child) {
    final separator = Platform.pathSeparator;
    return parent.endsWith(separator)
        ? '$parent$child'
        : '$parent$separator$child';
  }
}
