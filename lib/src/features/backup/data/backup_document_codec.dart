import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../data/database/app_database.dart';
import '../../todos/domain/local_date.dart';
import '../../todos/domain/recurrence_engine.dart';
import '../domain/backup_repository.dart';

/// Versioned codec shared by file backups and future synchronization payloads.
///
/// The codec intentionally owns no file-system or database behavior. This keeps
/// the stable JSON v1 representation reusable by other transports without
/// coupling them to [LocalBackupRepository].
final class BackupDocumentCodec {
  const BackupDocumentCodec();

  static const int currentFormatVersion = 1;
  static const ValueSerializer serializer = UtcBackupSerializer();

  String encode(BackupDocument document) {
    final json = document.toJson(codec: this);
    // Drift's SQLite DateTime values can lose their UTC marker after a read.
    // Validate the canonical JSON round trip, where the serializer restores it.
    BackupDocumentValidator.validate(decodeMap(json));
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  BackupDocument decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const BackupFormatException('根节点必须是 JSON 对象');
    }
    final document = decodeMap(decoded);
    BackupDocumentValidator.validate(document);
    return document;
  }

  BackupDocument decodeMap(Map<String, dynamic> json) {
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
    if (formatVersion != currentFormatVersion) {
      throw BackupFormatException('不支持的备份格式版本：$formatVersion');
    }
    if (data is! Map<String, dynamic> || settings is! List) {
      throw const BackupFormatException('数据区或设置区格式错误');
    }
    final parsedExportedAt = DateTime.tryParse(exportedAt);
    if (parsedExportedAt == null || !parsedExportedAt.isUtc) {
      throw const BackupFormatException('exportedAt 必须是 UTC ISO-8601 时间');
    }

    return BackupDocument(
      formatVersion: formatVersion,
      exportedAt: parsedExportedAt,
      appVersion: appVersion,
      categories: _maps(
        data['categories'],
        'categories',
      ).map(decodeCategory).toList(growable: false),
      tags: _maps(data['tags'], 'tags').map(decodeTag).toList(growable: false),
      recurrenceSeries: _maps(
        data['recurrenceSeries'],
        'recurrenceSeries',
      ).map(decodeRecurrenceSeries).toList(growable: false),
      todos: _maps(
        data['todos'],
        'todos',
      ).map(decodeTodo).toList(growable: false),
      todoTags: _maps(
        data['todoTags'],
        'todoTags',
      ).map(decodeTodoTag).toList(growable: false),
      recurrenceExceptions: _maps(
        data['recurrenceExceptions'],
        'recurrenceExceptions',
      ).map(decodeRecurrenceException).toList(growable: false),
      settings: _maps(
        settings,
        'settings',
      ).map(decodeSetting).toList(growable: false),
    );
  }

  Map<String, dynamic> encodeRow(Object row) {
    final value = switch (row) {
      CategoryRow value => value.toJson(serializer: serializer),
      TagRow value => value.toJson(serializer: serializer),
      RecurrenceSeriesRow value => value.toJson(serializer: serializer),
      TodoRow value => value.toJson(serializer: serializer),
      TodoTagRow value => value.toJson(serializer: serializer),
      RecurrenceExceptionRow value => value.toJson(serializer: serializer),
      SettingRow value => value.toJson(serializer: serializer),
      _ => throw ArgumentError.value(row, 'row', 'unsupported backup row'),
    };
    return value;
  }

  CategoryRow decodeCategory(Map<String, dynamic> value) =>
      CategoryRow.fromJson(value, serializer: serializer);

  TagRow decodeTag(Map<String, dynamic> value) =>
      TagRow.fromJson(value, serializer: serializer);

  RecurrenceSeriesRow decodeRecurrenceSeries(Map<String, dynamic> value) =>
      RecurrenceSeriesRow.fromJson(value, serializer: serializer);

  TodoRow decodeTodo(Map<String, dynamic> value) =>
      TodoRow.fromJson(value, serializer: serializer);

  TodoTagRow decodeTodoTag(Map<String, dynamic> value) =>
      TodoTagRow.fromJson(value, serializer: serializer);

  RecurrenceExceptionRow decodeRecurrenceException(
    Map<String, dynamic> value,
  ) => RecurrenceExceptionRow.fromJson(value, serializer: serializer);

  SettingRow decodeSetting(Map<String, dynamic> value) =>
      SettingRow.fromJson(value, serializer: serializer);

  List<Map<String, dynamic>> _maps(Object? value, String name) {
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
}

final class UtcBackupSerializer extends ValueSerializer {
  const UtcBackupSerializer();

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

final class BackupDocument {
  const BackupDocument({
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

  Map<String, dynamic> toJson({
    BackupDocumentCodec codec = const BackupDocumentCodec(),
  }) => {
    'formatVersion': formatVersion,
    'exportedAt': exportedAt.toIso8601String(),
    'appVersion': appVersion,
    'data': {
      'categories': categories.map(codec.encodeRow).toList(),
      'tags': tags.map(codec.encodeRow).toList(),
      'recurrenceSeries': recurrenceSeries.map(codec.encodeRow).toList(),
      'todos': todos.map(codec.encodeRow).toList(),
      'todoTags': todoTags.map(codec.encodeRow).toList(),
      'recurrenceExceptions': recurrenceExceptions
          .map(codec.encodeRow)
          .toList(),
    },
    'settings': settings.map(codec.encodeRow).toList(),
  };
}

abstract final class BackupDocumentValidator {
  static void validate(BackupDocument document) {
    if (document.formatVersion != BackupDocumentCodec.currentFormatVersion) {
      throw BackupFormatException('不支持的备份格式版本：${document.formatVersion}');
    }
    if (!document.exportedAt.isUtc) {
      throw const BackupFormatException('exportedAt 必须是 UTC ISO-8601 时间');
    }
    if (document.appVersion.trim().isEmpty) {
      throw const BackupFormatException('appVersion 不能为空');
    }
    _unique(document.categories.map((row) => row.id), '分类 ID');
    _unique(document.tags.map((row) => row.id), '标签 ID');
    _unique(document.recurrenceSeries.map((row) => row.id), '重复规则 ID');
    _unique(document.todos.map((row) => row.id), 'TODO ID');
    _unique(document.recurrenceExceptions.map((row) => row.id), '重复例外 ID');
    _unique(document.settings.map((row) => row.key), '设置键');
    _unique(
      document.todoTags.map((row) => '${row.todoId}\u0000${row.tagId}'),
      'TODO 标签关系',
    );
    _unique(
      document.recurrenceExceptions.map(
        (row) => '${row.seriesId}\u0000${row.occurrenceDate}',
      ),
      '重复例外规则日期',
    );

    final categoryIds = document.categories.map((row) => row.id).toSet();
    final tagIds = document.tags.map((row) => row.id).toSet();
    final seriesIds = document.recurrenceSeries.map((row) => row.id).toSet();
    final todoIds = document.todos.map((row) => row.id).toSet();

    for (final row in document.categories) {
      _entity(row.id, row.name, row.revision, row.createdAt, row.updatedAt);
      _utc(row.deletedAt, '分类删除时间');
      if (!row.sortOrder.isFinite) {
        throw const BackupFormatException('分类排序值无效');
      }
    }
    for (final row in document.tags) {
      _entity(row.id, row.name, row.revision, row.createdAt, row.updatedAt);
      _utc(row.deletedAt, '标签删除时间');
      if (!row.sortOrder.isFinite) {
        throw const BackupFormatException('标签排序值无效');
      }
    }
    for (final row in document.recurrenceSeries) {
      _entity(row.id, row.ruleJson, row.revision, row.createdAt, row.updatedAt);
      LocalDate.parse(row.startDate);
      const RecurrenceRuleCodec().decode(row.ruleJson);
      _utc(row.deletedAt, '重复规则删除时间');
    }
    for (final row in document.todos) {
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
    for (final row in document.todoTags) {
      if (!todoIds.contains(row.todoId) || !tagIds.contains(row.tagId)) {
        throw const BackupFormatException('TODO 标签关系存在无效引用');
      }
    }
    for (final row in document.recurrenceExceptions) {
      _entity(row.id, row.seriesId, row.revision, row.createdAt, row.updatedAt);
      if (!seriesIds.contains(row.seriesId)) {
        throw const BackupFormatException('重复例外引用了不存在的规则');
      }
      LocalDate.parse(row.occurrenceDate);
      if (row.overrideJson case final value?) jsonDecode(value);
      _utc(row.deletedAt, '重复例外删除时间');
    }
    for (final row in document.settings) {
      _entity(row.key, row.value, row.revision, row.updatedAt, row.updatedAt);
    }
  }

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
