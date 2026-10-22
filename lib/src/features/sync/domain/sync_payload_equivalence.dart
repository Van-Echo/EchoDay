import 'dart:convert';

import 'sync_protocol.dart';

/// Compares persisted values, not operation IDs or JSON serialization details.
/// Operation envelopes remain byte/structure strict for replay protection.
abstract final class SyncPayloadEquivalence {
  static bool equivalent(SyncOperation left, SyncOperation right) {
    if (left.syncGroupId != right.syncGroupId ||
        left.entityType != right.entityType ||
        left.entityId != right.entityId ||
        left.fieldGroup != right.fieldGroup ||
        left.operationType != right.operationType) {
      return false;
    }
    return jsonEncode(_normalize(left)) == jsonEncode(_normalize(right));
  }

  static Object? _normalize(SyncOperation operation) {
    final payload = Map<String, dynamic>.of(operation.payload);
    if (operation.entityType == SyncEntityType.todo) {
      if (operation.fieldGroup == SyncFieldGroup.content) {
        payload['isFuture'] ??= false;
      } else if (operation.fieldGroup == SyncFieldGroup.completion) {
        payload['isAbandoned'] ??= false;
        payload.putIfAbsent('completedAtUtc', () => null);
        payload.putIfAbsent('abandonedAtUtc', () => null);
      }
    }
    // Drift's existing DateTime columns persist whole Unix seconds. Rebuilding
    // a baseline loses fractional digits of these automatic timestamps. Do not
    // round planned/DDL times, unknown fields, or arbitrary strings.
    final automaticDates = switch (operation.fieldGroup) {
      SyncFieldGroup.content => const ['createdAtUtc'],
      SyncFieldGroup.completion
          when operation.entityType == SyncEntityType.todo =>
        const ['completedAtUtc', 'abandonedAtUtc'],
      SyncFieldGroup.deletion => const ['deletedAt'],
      _ => const <String>[],
    };
    for (final key in automaticDates) {
      if (payload[key] case final String value) {
        final date = DateTime.tryParse(value);
        if (date != null && date.isUtc) {
          payload[key] =
              date.microsecondsSinceEpoch ~/ Duration.microsecondsPerSecond;
        }
      }
    }
    if (operation.entityType == SyncEntityType.todo &&
        operation.fieldGroup == SyncFieldGroup.content) {
      for (final key in ['plannedAtUtc', 'deadlineAtUtc']) {
        if (payload[key] case final String value) {
          final date = DateTime.tryParse(value);
          if (date != null && date.isUtc) {
            payload[key] = date.microsecondsSinceEpoch;
          }
        }
      }
    }
    return _sorted(payload);
  }

  static Object? _sorted(Object? value) {
    if (value is Map) {
      final keys = value.keys.cast<String>().toList()..sort();
      return {for (final key in keys) key: _sorted(value[key])};
    }
    if (value is List) return value.map(_sorted).toList();
    return value;
  }
}
