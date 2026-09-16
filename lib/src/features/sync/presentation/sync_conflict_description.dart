import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../domain/sync_merge_engine.dart';
import '../domain/sync_protocol.dart';

final class SyncConflictDescription {
  const SyncConflictDescription(this.title, this.details);

  factory SyncConflictDescription.from(
    SyncConflict conflict,
    AppLocalizations strings,
  ) {
    final entity = switch (conflict.entityType) {
      SyncEntityType.todo => strings.syncConflictEntityTodo,
      SyncEntityType.category => strings.categoryLabel,
      SyncEntityType.tag => strings.tagsLabel,
      SyncEntityType.recurrenceSeries => strings.syncConflictEntitySeries,
      SyncEntityType.recurrenceException => strings.syncConflictEntityException,
      SyncEntityType.todoTag => strings.syncConflictEntityRelation,
    };
    final group = switch (conflict.fieldGroup) {
      SyncFieldGroup.content => strings.syncConflictGroupContent,
      SyncFieldGroup.completion => strings.syncConflictGroupCompletion,
      SyncFieldGroup.order => strings.syncConflictGroupOrder,
      SyncFieldGroup.tags => strings.syncConflictGroupTags,
      SyncFieldGroup.deletion => strings.syncConflictGroupDeletion,
    };
    final payload = conflict.losingPayload;
    final lines = <String>[];
    final separator = strings.localeName.startsWith('zh') ? '：' : ': ';

    void add(String key, String label, {String? Function(Object?)? format}) {
      if (!payload.containsKey(key)) return;
      final value = format?.call(payload[key]) ?? _plain(payload[key], strings);
      if (value != null) lines.add('$label$separator$value');
    }

    add('title', strings.titleLabel);
    add(
      'name',
      conflict.entityType == SyncEntityType.category
          ? strings.categoryLabel
          : strings.tagsLabel,
    );
    add('localDate', strings.dateLabel);
    add('plannedAtUtc', strings.plannedAtLabel, format: _localTime);
    add('deadlineAtUtc', strings.deadlineAtLabel, format: _localTime);
    add('notes', strings.notesLabel);
    add(
      'priority',
      strings.priorityLabel,
      format: (value) {
        return switch (value) {
          0 => strings.priorityHigh,
          1 => strings.priorityMedium,
          2 => strings.priorityLow,
          _ => strings.priorityNone,
        };
      },
    );
    add(
      'isCompleted',
      strings.syncConflictGroupCompletion,
      format: (value) {
        return value == true ? strings.completedTasks : strings.incompleteTasks;
      },
    );
    if (payload.containsKey('deletedAt')) {
      lines.add(
        payload['deletedAt'] == null ? strings.restoreTask : strings.deleteTask,
      );
    }
    if (payload.containsKey('ruleJson')) {
      lines.add(strings.syncConflictRuleChanged);
    }
    if (payload.containsKey('categoryId')) {
      lines.add(
        payload['categoryId'] == null
            ? '${strings.categoryLabel}$separator${strings.syncConflictNotSet}'
            : strings.syncConflictCategoryChanged,
      );
    }
    if (payload.containsKey('colorValue')) {
      final color = payload['colorValue'];
      if (color is int) {
        lines.add(
          '${strings.colorLabel}$separator#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
        );
      }
    }
    if (payload.containsKey('manualOrder') ||
        payload.containsKey('sortOrder')) {
      lines.add(strings.syncConflictGroupOrder);
    }
    if (lines.isEmpty) lines.add(strings.syncConflictValueChanged);
    return SyncConflictDescription(
      '$entity · $group',
      '${strings.syncConflictRecoverableVersion}\n${lines.join('\n')}',
    );
  }

  final String title;
  final String details;

  static String? _plain(Object? value, AppLocalizations strings) {
    if (value == null) return strings.syncConflictNotSet;
    if (value is! String || value.isEmpty) return null;
    return value.length > 160 ? '${value.substring(0, 160)}…' : value;
  }

  static String? _localTime(Object? value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse('$value');
    return parsed == null
        ? null
        : DateFormat('yyyy-MM-dd HH:mm').format(parsed.toLocal());
  }
}
