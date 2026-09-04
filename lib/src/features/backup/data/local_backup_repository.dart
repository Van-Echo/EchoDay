import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/config/app_config.dart';
import '../../../data/database/app_database.dart';
import '../../todos/domain/local_date.dart';
import '../../todos/domain/recurrence_engine.dart';
import '../domain/backup_repository.dart';

typedef BackupDirectoryProvider = Future<Directory> Function();

final class LocalBackupRepository implements BackupRepository {
  LocalBackupRepository(
    this._database, {
    BackupDirectoryProvider? safetyBackupDirectory,
    DateTime Function()? now,
  }) : _safetyBackupDirectory =
           safetyBackupDirectory ?? _defaultSafetyBackupDirectory,
       _now = now ?? DateTime.now;

  static const int currentFormatVersion = 1;
  static const int _maximumBackupBytes = 50 * 1024 * 1024;
  static const ValueSerializer _serializer = _UtcBackupSerializer();

  final AppDatabase _database;
  final BackupDirectoryProvider _safetyBackupDirectory;
  final DateTime Function() _now;

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
    final safetyDirectory = await _safetyBackupDirectory();
    await safetyDirectory.create(recursive: true);
    final safetyPath = _join(
      safetyDirectory.path,
      'before-restore-${standardBackupFileName(_now())}',
    );
    await exportTo(safetyPath);

    final result = await _database.transaction(() async {
      await _clearUserData();
      await _insertAll(document);
      return ImportResult(
        importedCount: document.totalRecordCount,
        skippedCount: 0,
        safetyBackupPath: safetyPath,
      );
    });
    return result;
  }

  Future<_BackupDocument> _snapshot(DateTime exportedAt) {
    return _database.transaction(() async {
      return _BackupDocument(
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
        settings: await _database.select(_database.settings).get(),
      );
    });
  }

  Future<_BackupDocument> _readDocument(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw const BackupFormatException('备份文件不存在');
    }
    if (await file.length() > _maximumBackupBytes) {
      throw const BackupFormatException('备份文件超过 50 MB 安全上限');
    }
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) {
        throw const BackupFormatException('根节点必须是 JSON 对象');
      }
      return _BackupDocument.fromJson(decoded)..validate();
    } on BackupFormatException {
      rethrow;
    } on Object catch (error) {
      throw BackupFormatException('无法解析备份：$error');
    }
  }

  Future<void> _writeDocument(String path, _BackupDocument document) async {
    final target = File(path);
    await target.parent.create(recursive: true);
    final temporary = File('$path.${_now().microsecondsSinceEpoch}.tmp');
    try {
      const encoder = JsonEncoder.withIndent('  ');
      await temporary.writeAsString(
        '${encoder.convert(document.toJson())}\n',
        flush: true,
      );
      await temporary.copy(target.path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }

  Future<ImportResult> _mergeDocument(_BackupDocument document) async {
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

  Future<void> _insertAll(_BackupDocument document) async {
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

final class _UtcBackupSerializer extends ValueSerializer {
  const _UtcBackupSerializer();

  static const ValueSerializer _delegate = ValueSerializer.defaults(
    serializeDateTimeValuesAsString: true,
  );

  @override
  T fromJson<T>(dynamic json) {
    final value = _delegate.fromJson<T>(json);
    return value is DateTime ? value.toUtc() as T : value;
  }

  @override
  dynamic toJson<T>(T value) {
    return value is DateTime
        ? value.toUtc().toIso8601String()
        : _delegate.toJson(value);
  }
}

final class _BackupDocument {
  const _BackupDocument({
    required this.formatVersion,
    required this.exportedAt,
    required this.appVersion,
    required this.categories,
    required this.tags,
    required this.recurrenceSeries,
    required this.todos,
    required this.todoTags,
    required this.recurrenceExceptions,
    required this.settings,
  });

  factory _BackupDocument.fromJson(Map<String, dynamic> json) {
    final formatVersion = json['formatVersion'];
    final exportedAt = json['exportedAt'];
    final appVersion = json['appVersion'];
    final data = json['data'];
    final settings = json['settings'];
    if (formatVersion is! int ||
        exportedAt is! String ||
        appVersion is! String) {
      throw const BackupFormatException('备份元数据缺失或类型错误');
    }
    if (formatVersion != LocalBackupRepository.currentFormatVersion) {
      throw BackupFormatException('不支持的备份格式版本：$formatVersion');
    }
    if (data is! Map<String, dynamic> || settings is! List) {
      throw const BackupFormatException('数据区或设置区格式错误');
    }
    final parsedExportedAt = DateTime.tryParse(exportedAt);
    if (parsedExportedAt == null || !parsedExportedAt.isUtc) {
      throw const BackupFormatException('exportedAt 必须是 UTC ISO-8601 时间');
    }

    List<Map<String, dynamic>> maps(dynamic value, String name) {
      if (value is! List) throw BackupFormatException('$name 必须是数组');
      return value
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw BackupFormatException('$name 包含非对象项');
            }
            return item;
          })
          .toList(growable: false);
    }

    return _BackupDocument(
      formatVersion: formatVersion,
      exportedAt: parsedExportedAt,
      appVersion: appVersion,
      categories: maps(data['categories'], 'categories')
          .map(
            (item) => CategoryRow.fromJson(
              item,
              serializer: LocalBackupRepository._serializer,
            ),
          )
          .toList(growable: false),
      tags: maps(data['tags'], 'tags')
          .map(
            (item) => TagRow.fromJson(
              item,
              serializer: LocalBackupRepository._serializer,
            ),
          )
          .toList(growable: false),
      recurrenceSeries: maps(data['recurrenceSeries'], 'recurrenceSeries')
          .map(
            (item) => RecurrenceSeriesRow.fromJson(
              item,
              serializer: LocalBackupRepository._serializer,
            ),
          )
          .toList(growable: false),
      todos: maps(data['todos'], 'todos')
          .map(
            (item) => TodoRow.fromJson(
              item,
              serializer: LocalBackupRepository._serializer,
            ),
          )
          .toList(growable: false),
      todoTags: maps(data['todoTags'], 'todoTags')
          .map(
            (item) => TodoTagRow.fromJson(
              item,
              serializer: LocalBackupRepository._serializer,
            ),
          )
          .toList(growable: false),
      recurrenceExceptions:
          maps(data['recurrenceExceptions'], 'recurrenceExceptions')
              .map(
                (item) => RecurrenceExceptionRow.fromJson(
                  item,
                  serializer: LocalBackupRepository._serializer,
                ),
              )
              .toList(growable: false),
      settings: maps(settings, 'settings')
          .map(
            (item) => SettingRow.fromJson(
              item,
              serializer: LocalBackupRepository._serializer,
            ),
          )
          .toList(growable: false),
    );
  }

  final int formatVersion;
  final DateTime exportedAt;
  final String appVersion;
  final List<CategoryRow> categories;
  final List<TagRow> tags;
  final List<RecurrenceSeriesRow> recurrenceSeries;
  final List<TodoRow> todos;
  final List<TodoTagRow> todoTags;
  final List<RecurrenceExceptionRow> recurrenceExceptions;
  final List<SettingRow> settings;

  int get totalRecordCount =>
      categories.length +
      tags.length +
      recurrenceSeries.length +
      todos.length +
      todoTags.length +
      recurrenceExceptions.length +
      settings.length;

  Map<String, dynamic> toJson() => {
    'formatVersion': formatVersion,
    'exportedAt': exportedAt.toIso8601String(),
    'appVersion': appVersion,
    'data': {
      'categories': categories.map(_rowJson).toList(),
      'tags': tags.map(_rowJson).toList(),
      'recurrenceSeries': recurrenceSeries.map(_rowJson).toList(),
      'todos': todos.map(_rowJson).toList(),
      'todoTags': todoTags.map(_rowJson).toList(),
      'recurrenceExceptions': recurrenceExceptions.map(_rowJson).toList(),
    },
    'settings': settings.map(_rowJson).toList(),
  };

  void validate() {
    if (appVersion.trim().isEmpty) {
      throw const BackupFormatException('appVersion 不能为空');
    }
    _unique(categories.map((row) => row.id), '分类 ID');
    _unique(tags.map((row) => row.id), '标签 ID');
    _unique(recurrenceSeries.map((row) => row.id), '重复规则 ID');
    _unique(todos.map((row) => row.id), 'TODO ID');
    _unique(recurrenceExceptions.map((row) => row.id), '重复例外 ID');
    _unique(settings.map((row) => row.key), '设置键');
    _unique(
      todoTags.map((row) => '${row.todoId}\u0000${row.tagId}'),
      'TODO 标签关系',
    );
    _unique(
      recurrenceExceptions.map(
        (row) => '${row.seriesId}\u0000${row.occurrenceDate}',
      ),
      '重复例外规则日期',
    );

    final categoryIds = categories.map((row) => row.id).toSet();
    final tagIds = tags.map((row) => row.id).toSet();
    final seriesIds = recurrenceSeries.map((row) => row.id).toSet();
    final todoIds = todos.map((row) => row.id).toSet();

    for (final row in categories) {
      _entity(row.id, row.name, row.revision, row.createdAt, row.updatedAt);
      _utc(row.deletedAt, '分类删除时间');
      if (!row.sortOrder.isFinite) {
        throw const BackupFormatException('分类排序值无效');
      }
    }
    for (final row in tags) {
      _entity(row.id, row.name, row.revision, row.createdAt, row.updatedAt);
      _utc(row.deletedAt, '标签删除时间');
      if (!row.sortOrder.isFinite) {
        throw const BackupFormatException('标签排序值无效');
      }
    }
    for (final row in recurrenceSeries) {
      _entity(row.id, row.ruleJson, row.revision, row.createdAt, row.updatedAt);
      LocalDate.parse(row.startDate);
      const RecurrenceRuleCodec().decode(row.ruleJson);
      _utc(row.deletedAt, '重复规则删除时间');
    }
    for (final row in todos) {
      _entity(row.id, row.title, row.revision, row.createdAt, row.updatedAt);
      LocalDate.parse(row.localDate);
      if (row.priority < 0 || row.priority > 3) {
        throw BackupFormatException('TODO ${row.id} 的优先级无效');
      }
      if (!row.manualOrder.isFinite) {
        throw BackupFormatException('TODO ${row.id} 的手动排序值无效');
      }
      _utc(row.plannedAt, '计划执行时间');
      _utc(row.deadlineAt, '计划 DDL 时间');
      _utc(row.completedAt, '完成时间');
      _utc(row.deletedAt, 'TODO 删除时间');
      if (row.isCompleted != (row.completedAt != null)) {
        throw BackupFormatException('TODO ${row.id} 的完成状态不一致');
      }
      if (row.categoryId case final id? when !categoryIds.contains(id)) {
        throw BackupFormatException('TODO ${row.id} 引用了不存在的分类');
      }
      if (row.recurrenceSeriesId case final id? when !seriesIds.contains(id)) {
        throw BackupFormatException('TODO ${row.id} 引用了不存在的重复规则');
      }
      if (row.occurrenceDate case final value?) LocalDate.parse(value);
    }
    for (final row in todoTags) {
      if (!todoIds.contains(row.todoId) || !tagIds.contains(row.tagId)) {
        throw const BackupFormatException('TODO 标签关系存在无效引用');
      }
    }
    for (final row in recurrenceExceptions) {
      _entity(row.id, row.seriesId, row.revision, row.createdAt, row.updatedAt);
      if (!seriesIds.contains(row.seriesId)) {
        throw const BackupFormatException('重复例外引用了不存在的规则');
      }
      LocalDate.parse(row.occurrenceDate);
      if (row.overrideJson case final value?) jsonDecode(value);
      _utc(row.deletedAt, '重复例外删除时间');
    }
    for (final row in settings) {
      _entity(row.key, row.value, row.revision, row.updatedAt, row.updatedAt);
    }
  }

  static Map<String, dynamic> _rowJson(dynamic row) =>
      row.toJson(serializer: LocalBackupRepository._serializer)
          as Map<String, dynamic>;

  static void _unique(Iterable<String> values, String label) {
    final seen = <String>{};
    for (final value in values) {
      if (value.trim().isEmpty || !seen.add(value)) {
        throw BackupFormatException('$label 为空或重复');
      }
    }
  }

  static void _entity(
    String id,
    String content,
    int revision,
    DateTime createdAt,
    DateTime updatedAt,
  ) {
    if (id.trim().isEmpty || content.trim().isEmpty || revision < 1) {
      throw const BackupFormatException('实体包含空字段或无效修订号');
    }
    if (!createdAt.isUtc || !updatedAt.isUtc) {
      throw const BackupFormatException('所有时间戳必须使用 UTC');
    }
  }

  static void _utc(DateTime? value, String label) {
    if (value != null && !value.isUtc) {
      throw BackupFormatException('$label 必须使用 UTC');
    }
  }
}
