import 'dart:io';

import 'package:drift/native.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/backup/application/backup_maintenance_service.dart';
import 'package:echoday/src/features/backup/data/backup_directory_resolver.dart';
import 'package:echoday/src/features/backup/data/local_backup_repository.dart';
import 'package:echoday/src/features/backup/domain/backup_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/in_memory_settings_repository.dart';

void main() {
  late AppDatabase database;
  late Directory temporaryDirectory;
  late InMemorySettingsRepository settings;
  late BackupDirectoryResolver resolver;
  late LocalBackupRepository repository;
  late DateTime now;
  late BackupMaintenanceService service;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'echoday-maintenance-test-',
    );
    settings = InMemorySettingsRepository();
    resolver = BackupDirectoryResolver(
      settings,
      defaultRoot: () async =>
          Directory(_join(temporaryDirectory.path, 'Default')),
    );
    repository = LocalBackupRepository(
      database,
      safetyBackupDirectory: resolver.safetyDirectory,
      now: () => now,
    );
    now = DateTime(2026, 9, 5, 9, 10, 11);
    service = BackupMaintenanceService(
      repository,
      settings,
      resolver,
      now: () => now,
    );
  });

  tearDown(() async {
    await database.close();
    await settings.dispose();
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('creates manual backups in the configured default directory', () async {
    final configured = Directory(_join(temporaryDirectory.path, 'External'));
    await settings.set(BackupPreferenceKeys.directory, configured.path);

    final first = await service.createDefaultBackup();
    final second = await service.createDefaultBackup();

    expect(
      first.path,
      startsWith(_join(configured.absolute.path, 'Manual Backups')),
    );
    expect(await File(first.path).exists(), isTrue);
    expect(
      await repository.inspect(first.path).then((value) => value.isValid),
      isTrue,
    );
    expect(second.path, isNot(first.path));
    expect(second.path, endsWith('-2.json'));
  });

  test('automatic backup is opt-in, daily, and observes retention', () async {
    expect(await service.createAutomaticBackupIfDue(), isNull);

    await settings.set(BackupPreferenceKeys.automaticEnabled, 'true');
    await settings.set(BackupPreferenceKeys.retentionCount, '2');

    final first = await service.createAutomaticBackupIfDue();
    final duplicate = await service.createAutomaticBackupIfDue();
    now = DateTime(2026, 9, 6, 9, 10, 11);
    final second = await service.createAutomaticBackupIfDue();
    now = DateTime(2026, 9, 7, 9, 10, 11);
    final third = await service.createAutomaticBackupIfDue();

    expect(first, isNotNull);
    expect(duplicate, isNull);
    expect(second, isNotNull);
    expect(third, isNotNull);

    final directory = await resolver.automaticDirectory();
    final files = await directory
        .list()
        .where((entry) => entry is File)
        .cast<File>()
        .toList();
    expect(files, hasLength(2));
    expect(
      files.map((file) => file.path).join('\n'),
      isNot(contains('20260905')),
    );
    expect(files.map((file) => file.path).join('\n'), contains('20260906'));
    expect(files.map((file) => file.path).join('\n'), contains('20260907'));
  });

  test('falls back when the configured backup path is unusable', () async {
    final occupiedPath = _join(temporaryDirectory.path, 'occupied');
    await File(occupiedPath).writeAsString('not a directory');
    await settings.set(BackupPreferenceKeys.directory, occupiedPath);

    final resolution = await resolver.resolve();
    final manifest = await service.createDefaultBackup();

    expect(resolution.usesFallback, isTrue);
    expect(resolution.configuredPath, occupiedPath);
    expect(resolution.effectiveRoot.path, endsWith('Default'));
    expect(manifest.path, startsWith(resolution.effectiveRoot.path));
    expect(await File(manifest.path).exists(), isTrue);
  });
}

String _join(String parent, String child) =>
    '$parent${Platform.pathSeparator}$child';
