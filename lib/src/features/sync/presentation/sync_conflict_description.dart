import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../domain/sync_merge_engine.dart';
import '../domain/sync_protocol.dart';

final class SyncConflictVersionDescription {
  const SyncConflictVersionDescription({
    required this.label,
    required this.summary,
    required this.details,
    required this.useLosingVersion,
  });

  final String label;
  final String summary;
  final String details;
  final bool useLosingVersion;
}

final class SyncConflictDescription {
  const SyncConflictDescription(this.title, this.versions);

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
    final versions = [
      _version(
        conflict,
        strings,
        conflict.winningPayload,
        conflict.winnerSourceDeviceId,
        false,
      ),
      _version(
        conflict,
        strings,
        conflict.losingPayload,
        conflict.loserSourceDeviceId,
        true,
      ),
    ];
    versions.sort((left, right) {
      final leftLocal =
          _sourceId(conflict, left.useLosingVersion) == conflict.localDeviceId;
      final rightLocal =
          _sourceId(conflict, right.useLosingVersion) == conflict.localDeviceId;
      if (leftLocal == rightLocal) return 0;
      return leftLocal ? -1 : 1;
    });
    return SyncConflictDescription('$entity · $group', versions);
  }

  final String title;
  final List<SyncConflictVersionDescription> versions;

  static String? _sourceId(SyncConflict conflict, bool losing) =>
      losing ? conflict.loserSourceDeviceId : conflict.winnerSourceDeviceId;

  static SyncConflictVersionDescription _version(
    SyncConflict conflict,
    AppLocalizations strings,
    Map<String, dynamic> payload,
    String? sourceId,
    bool losing,
  ) {
    final label = sourceId != null && sourceId == conflict.hostDeviceId
        ? strings.syncConflictHostSide
        : sourceId != null && sourceId == conflict.localDeviceId
        ? strings.syncConflictLocalSide
        : strings.syncConflictOtherSide;
    final rawSummary =
        payload['title'] ??
        payload['name'] ??
        conflict.entitySummary ??
        conflict.entityId;
    final summary = '$rawSummary'.trim();
    final shortSummary = summary.length > 64
        ? '${summary.substring(0, 64)}…'
        : summary;
    final lines = _detailLines(payload, strings);
    return SyncConflictVersionDescription(
      label: label,
      summary: shortSummary,
      details: lines.join('\n'),
      useLosingVersion: losing,
    );
  }

  static List<String> _detailLines(
    Map<String, dynamic> payload,
    AppLocalizations strings,
  ) {
    final lines = <String>[];
    final separator = strings.localeName.startsWith('zh') ? '：' : ': ';

    void add(String key, String label, {String? Function(Object?)? format}) {
      if (!payload.containsKey(key)) return;
      final value = format?.call(payload[key]) ?? _plain(payload[key], strings);
      if (value != null) lines.add('$label$separator$value');
    }

    add('localDate', strings.dateLabel);
    add(
      'plannedAtUtc',
      strings.plannedAtLabel,
      format: (value) => _localTime(value) ?? strings.syncConflictNotSet,
    );
    add(
      'deadlineAtUtc',
      strings.deadlineAtLabel,
      format: (value) => _localTime(value) ?? strings.syncConflictNotSet,
    );
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
        return value == true
            ? strings.completedTasks
            : strings.syncConflictIncomplete;
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
    return lines;
  }

  static String? _plain(Object? value, AppLocalizations strings) {
    if (value == null || value == '') return strings.syncConflictNotSet;
    if (value is! String) return null;
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
