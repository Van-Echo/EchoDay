import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../core/config/app_config.dart';
import '../../../data/database/app_database.dart';
import '../domain/backup_preferences.dart';
import '../domain/backup_repository.dart';
import 'backup_document_codec.dart';

typedef BackupDirectoryProvider = Future<Directory> Function();

final class LocalBackupRepository implements BackupRepository {
  LocalBackupRepository(
    this._database, {
    BackupDirectoryProvider? safetyBackupDirectory,
    DateTime Function()? now,
    this._codec = const BackupDocumentCodec(),
  }) : _safetyBackupDirectory =
           safetyBackupDirectory ?? _defaultSafetyBackupDirectory,
       _now = now ?? DateTime.now;

  static const int currentFormatVersion =
      BackupDocumentCodec.currentFormatVersion;
  static const int _maximumBackupBytes = 50 * 1024 * 1024;

  final AppDatabase _database;
  final BackupDirectoryProvider _safetyBackupDirectory;
  final DateTime Function() _now;
  final BackupDocumentCodec _codec;

  @override
  Future<BackupManifest> exportTo(String path) async {
    if (path.trim().isEmpty) {
      throw ArgumentError.value(path, 'path', 'must not be blank');
    }
    final exportedAt = _now().toUtc();
    final document = await _snapshot(exportedAt);
    await _writeDocument(path, document);
    return BackupManifest(
      formatVersion: currentFormatVersion,
      exportedAt: exportedAt,
      path: path,
    );
  }

  @override
  Future<ImportPreview> inspect(String path) async {
    try {
      final document = await _readDocument(path);
      return ImportPreview(
        formatVersion: document.formatVersion,
        todoCount: document.todos.length,
        totalRecordCount: document.totalRecordCount,
        exportedAt: document.exportedAt,
        appVersion: document.appVersion,
        isValid: true,
      );
    } catch (error) {
      return ImportPreview(
        formatVersion: 0,
        todoCount: 0,
        isValid: false,
        error: error.toString(),
      );
    }
  }

  @override
  Future<ImportResult> merge(String path) async {
    final document = await _readDocument(path);
    return _database.transaction(() => _mergeDocument(document));
  }

  @override
  Future<ImportResult> replace(String path) async {
    final document = await _readDocument(path);
    final deviceLocalSettings =
        (await _database.select(_database.settings).get())
            .where((row) => isDeviceLocalBackupSettingKey(row.key))
            .toList(growable: false);
    final safetyPath = await _createSafetyBackup('before-restore');
    final skippedSettings = document.settings
        .where((row) => isDeviceLocalBackupSettingKey(row.key))
        .length;

    final result = await _database.transaction(() async {
      await _clearUserData();
      await _insertAll(document);
      for (final row in deviceLocalSettings) {
        await _database
            .into(_database.settings)
            .insertOnConflictUpdate(row.toCompanion(false));
      }
      return ImportResult(
        importedCount: document.totalRecordCount - skippedSettings,
        skippedCount: skippedSettings,
        safetyBackupPath: safetyPath,
      );
    });
    return result;
  }

  @override
  Future<ClearDataResult> clearUserData() async {
    final safetyPath = await _createSafetyBackup('before-clear');
    final deletedRecordCount = await _database.transaction(() async {
      final count =
          (await _database.select(_database.categories).get()).length +
          (await _database.select(_database.tags).get()).length +
          (await _database.select(_database.recurrenceSeriesEntries).get())
              .length +
          (await _database.select(_database.todos).get()).length +
          (await _database.select(_database.todoTags).get()).length +
          (await _database.select(_database.recurrenceExceptions).get())
              .length +
          (await _database.select(_database.settings).get()).length;
      await _clearUserData();
      return count;
    });
    return ClearDataResult(
      deletedRecordCount: deletedRecordCount,
      safetyBackupPath: safetyPath,
    );
  }

  Future<String> _createSafetyBackup(String prefix) async {
    final directory = await _safetyBackupDirectory();
    await directory.create(recursive: true);
    final fileName = '$prefix-${standardBackupFileName(_now())}';
    var path = _join(directory.path, fileName);
    var suffix = 2;
    while (await File(path).exists()) {
      path = _join(
        directory.path,
        fileName.replaceFirst('.json', '-$suffix.json'),
      );
      suffix++;
    }
    await exportTo(path);
    return path;
  }

  Future<BackupDocument> _snapshot(DateTime exportedAt) {
    return _database.transaction(() async {
      final settings = await _database.select(_database.settings).get();
      return BackupDocument(
        formatVersion: currentFormatVersion,
        exportedAt: exportedAt,
        appVersion: AppConfig.version,
        categories: await _database.select(_database.categories).get(),
        tags: await _database.select(_database.tags).get(),
        recurrenceSeries: await _database
            .select(_database.recurrenceSeriesEntries)
            .get(),
        todos: await _database.select(_database.todos).get(),
        todoTags: await _database.select(_database.todoTags).get(),
        recurrenceExceptions: await _database
            .select(_database.recurrenceExceptions)
            .get(),
        settings: settings
            .where((row) => !isDeviceLocalBackupSettingKey(row.key))
            .toList(growable: false),
      );
    });
  }

  Future<BackupDocument> _readDocument(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw const BackupFormatException('备份文件不存在');
    }
    if (await file.length() > _maximumBackupBytes) {
      throw const BackupFormatException('备份文件超过 50 MB 安全上限');
    }
    try {
      return _codec.decode(await file.readAsString());
    } on BackupFormatException {
      rethrow;
    } on Object catch (error) {
      throw BackupFormatException('无法解析备份：$error');
    }
  }

  Future<void> _writeDocument(String path, BackupDocument document) async {
    final target = File(path);
    await target.parent.create(recursive: true);
    final temporary = File('$path.${_now().microsecondsSinceEpoch}.tmp');
    try {
      await temporary.writeAsString(
        '${_codec.encode(document)}\n',
        flush: true,
      );
      await temporary.copy(target.path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }

  Future<ImportResult> _mergeDocument(BackupDocument document) async {
    var imported = 0;
    var skipped = 0;

    Future<void> insertRows<T>(
      List<T> rows,
      Future<bool> Function(T row) insert,
    ) async {
      for (final row in rows) {
        if (await insert(row)) {
          imported++;
        } else {
          skipped++;
        }
      }
    }

    final categoryIds = (await _database.select(_database.categories).get())
        .map((row) => row.id)
        .toSet();
    await insertRows(document.categories, (row) async {
      if (!categoryIds.add(row.id)) return false;
      await _database.into(_database.categories).insert(row.toCompanion(false));
      return true;
    });

    final tagIds = (await _database.select(_database.tags).get())
        .map((row) => row.id)
        .toSet();
    await insertRows(document.tags, (row) async {
      if (!tagIds.add(row.id)) return false;
      await _database.into(_database.tags).insert(row.toCompanion(false));
      return true;
    });

    final seriesIds =
        (await _database.select(_database.recurrenceSeriesEntries).get())
            .map((row) => row.id)
            .toSet();
    await insertRows(document.recurrenceSeries, (row) async {
      if (!seriesIds.add(row.id)) return false;
      await _database
          .into(_database.recurrenceSeriesEntries)
          .insert(row.toCompanion(false));
      return true;
    });

    final todoIds = (await _database.select(_database.todos).get())
        .map((row) => row.id)
        .toSet();
    await insertRows(document.todos, (row) async {
      if (!todoIds.add(row.id)) return false;
      await _database.into(_database.todos).insert(row.toCompanion(false));
      return true;
    });

    final relations = (await _database.select(_database.todoTags).get())
        .map((row) => '${row.todoId}\u0000${row.tagId}')
        .toSet();
    await insertRows(document.todoTags, (row) async {
      if (!relations.add('${row.todoId}\u0000${row.tagId}')) return false;
      await _database.into(_database.todoTags).insert(row.toCompanion(false));
      return true;
    });

    final exceptionIds =
        (await _database.select(_database.recurrenceExceptions).get())
            .map((row) => row.id)
            .toSet();
    await insertRows(document.recurrenceExceptions, (row) async {
      if (!exceptionIds.add(row.id)) return false;
      await _database
          .into(_database.recurrenceExceptions)
          .insert(row.toCompanion(false));
      return true;
    });

    final settingKeys = (await _database.select(_database.settings).get())
        .map((row) => row.key)
        .toSet();
    await insertRows(document.settings, (row) async {
      if (isDeviceLocalBackupSettingKey(row.key)) return false;
      if (!settingKeys.add(row.key)) return false;
      await _database.into(_database.settings).insert(row.toCompanion(false));
      return true;
    });

    return ImportResult(importedCount: imported, skippedCount: skipped);
  }

  Future<void> _clearUserData() async {
    await _database.delete(_database.todoTags).go();
    await _database.delete(_database.recurrenceExceptions).go();
    await _database.delete(_database.todos).go();
    await _database.delete(_database.recurrenceSeriesEntries).go();
    await _database.delete(_database.categories).go();
    await _database.delete(_database.tags).go();
    await _database.delete(_database.settings).go();
  }

  Future<void> _insertAll(BackupDocument document) async {
    for (final row in document.categories) {
      await _database.into(_database.categories).insert(row.toCompanion(false));
    }
    for (final row in document.tags) {
      await _database.into(_database.tags).insert(row.toCompanion(false));
    }
    for (final row in document.recurrenceSeries) {
      await _database
          .into(_database.recurrenceSeriesEntries)
          .insert(row.toCompanion(false));
    }
    for (final row in document.todos) {
      await _database.into(_database.todos).insert(row.toCompanion(false));
    }
    for (final row in document.todoTags) {
      await _database.into(_database.todoTags).insert(row.toCompanion(false));
    }
    for (final row in document.recurrenceExceptions) {
      await _database
          .into(_database.recurrenceExceptions)
          .insert(row.toCompanion(false));
    }
    for (final row in document.settings) {
      if (isDeviceLocalBackupSettingKey(row.key)) continue;
      await _database.into(_database.settings).insert(row.toCompanion(false));
    }
  }

  static Future<Directory> _defaultSafetyBackupDirectory() async {
    final support = await getApplicationSupportDirectory();
    return Directory(_join(_join(support.path, 'EchoDay'), 'safety_backups'));
  }

  static String _join(String parent, String child) {
    final separator = Platform.pathSeparator;
    return parent.endsWith(separator)
        ? '$parent$child'
        : '$parent$separator$child';
  }
}
