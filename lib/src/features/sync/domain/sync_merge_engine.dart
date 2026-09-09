import 'dart:convert';

import 'sync_protocol.dart';

enum SyncConflictKind { concurrentFieldEdit, deletionVersusEdit }

final class SyncConflict {
  const SyncConflict({
    required this.id,
    required this.kind,
    required this.entityType,
    required this.entityId,
    required this.fieldGroup,
    required this.winnerOperationId,
    required this.loserOperationId,
    required this.losingPayload,
  });

  final String id;
  final SyncConflictKind kind;
  final SyncEntityType entityType;
  final String entityId;
  final SyncFieldGroup fieldGroup;
  final String winnerOperationId;
  final String loserOperationId;
  final Map<String, dynamic> losingPayload;
}

final class MaterializedSyncEntity {
  MaterializedSyncEntity({
    required this.entityType,
    required this.entityId,
    required this.deleted,
    required Map<SyncFieldGroup, Map<String, dynamic>> fieldValues,
    required Map<SyncFieldGroup, String> winningOperationIds,
    required List<SyncConflict> conflicts,
  }) : fieldValues = Map.unmodifiable(fieldValues),
       winningOperationIds = Map.unmodifiable(winningOperationIds),
       conflicts = List.unmodifiable(conflicts);

  final SyncEntityType entityType;
  final String entityId;
  final bool deleted;
  final Map<SyncFieldGroup, Map<String, dynamic>> fieldValues;
  final Map<SyncFieldGroup, String> winningOperationIds;
  final List<SyncConflict> conflicts;
}

final class TodoTagMembership {
  TodoTagMembership({
    required this.todoId,
    required this.tagId,
    required Set<String> activeAddOperationIds,
  }) : activeAddOperationIds = Set.unmodifiable(activeAddOperationIds);

  final String todoId;
  final String tagId;
  final Set<String> activeAddOperationIds;

  bool get isPresent => activeAddOperationIds.isNotEmpty;
}

/// Reference CRDT used to freeze V1 merge semantics before database work.
///
/// It retains operations and rematerializes deterministically, so applying the
/// same valid set in any delivery order yields the same entity state.
final class InMemorySyncReplica {
  final Map<String, SyncOperation> _operations = {};
  final Map<(String, int), String> _operationIdBySourceSequence = {};
  final Map<(SyncEntityType, String), Set<String>> _entityOperationIds = {};
  final Map<(String, String), Set<String>> _relationOperationIds = {};
  String? _syncGroupId;

  Iterable<SyncOperation> get operations => _operations.values;

  SyncCursor get cursor {
    final sequencesByDevice = <String, Set<int>>{};
    for (final operation in _operations.values) {
      sequencesByDevice
          .putIfAbsent(operation.sourceDeviceId, () => <int>{})
          .add(operation.sequence);
    }
    var result = SyncCursor();
    for (final entry in sequencesByDevice.entries) {
      var contiguous = 0;
      while (entry.value.contains(contiguous + 1)) {
        contiguous++;
      }
      result = result.advanced(entry.key, contiguous);
    }
    return result;
  }

  void apply(SyncOperation operation) {
    SyncProtocolValidator.validateOperation(operation);
    final groupId = _syncGroupId;
    if (groupId != null && groupId != operation.syncGroupId) {
      throw const SyncProtocolException(
        SyncErrorCode.validationFailed,
        'A replica cannot contain operations from different sync groups.',
      );
    }
    final existing = _operations[operation.operationId];
    if (existing != null) {
      if (_canonical(existing) != _canonical(operation)) {
        throw const SyncProtocolException(
          SyncErrorCode.replayDetected,
          'An operation id was reused with different content.',
        );
      }
      return;
    }
    final sourceSequence = (operation.sourceDeviceId, operation.sequence);
    if (_operationIdBySourceSequence.containsKey(sourceSequence)) {
      throw const SyncProtocolException(
        SyncErrorCode.replayDetected,
        'A source device reused an existing sequence.',
      );
    }
    _syncGroupId = operation.syncGroupId;
    _operations[operation.operationId] = operation;
    _operationIdBySourceSequence[sourceSequence] = operation.operationId;
    if (operation.entityType == SyncEntityType.todoTag) {
      final key = (
        operation.payload['todoId'] as String,
        operation.payload['tagId'] as String,
      );
      _relationOperationIds
          .putIfAbsent(key, () => <String>{})
          .add(operation.operationId);
    } else {
      _entityOperationIds
          .putIfAbsent((
            operation.entityType,
            operation.entityId,
          ), () => <String>{})
          .add(operation.operationId);
    }
  }

  void applyAll(Iterable<SyncOperation> operations) {
    for (final operation in operations) {
      apply(operation);
    }
  }

  MaterializedSyncEntity? materialize(
    SyncEntityType entityType,
    String entityId,
  ) {
    final relevant = (_entityOperationIds[(entityType, entityId)] ?? const {})
        .map((operationId) => _operations[operationId]!)
        .toList(growable: false);
    if (relevant.isEmpty) return null;

    final grouped = <SyncFieldGroup, List<SyncOperation>>{};
    for (final operation in relevant) {
      grouped.putIfAbsent(operation.fieldGroup, () => []).add(operation);
    }

    final winners = <SyncFieldGroup, SyncOperation>{};
    final conflicts = <SyncConflict>[];
    for (final entry in grouped.entries) {
      final maxima = _causalMaxima(entry.value);
      final winner = maxima.reduce(_laterWinner);
      winners[entry.key] = winner;
      for (final loser in maxima.where(
        (operation) => operation.operationId != winner.operationId,
      )) {
        conflicts.add(
          _conflict(
            SyncConflictKind.concurrentFieldEdit,
            winner,
            loser,
            entry.key,
          ),
        );
      }
    }

    final deletion = winners[SyncFieldGroup.deletion];
    final deleted = deletion?.operationType == SyncOperationType.delete;
    if (deleted && deletion != null) {
      for (final entry in winners.entries) {
        if (entry.key == SyncFieldGroup.deletion) continue;
        final edit = entry.value;
        if (_concurrent(deletion, edit)) {
          conflicts.add(
            _conflict(
              SyncConflictKind.deletionVersusEdit,
              deletion,
              edit,
              entry.key,
            ),
          );
        }
      }
    }

    conflicts.sort((left, right) => left.id.compareTo(right.id));
    return MaterializedSyncEntity(
      entityType: entityType,
      entityId: entityId,
      deleted: deleted,
      fieldValues: {
        for (final entry in winners.entries)
          if (entry.key != SyncFieldGroup.deletion)
            entry.key: Map<String, dynamic>.unmodifiable(entry.value.payload),
      },
      winningOperationIds: {
        for (final entry in winners.entries) entry.key: entry.value.operationId,
      },
      conflicts: conflicts,
    );
  }

  TodoTagMembership? todoTagMembership(String todoId, String tagId) {
    final relevant = (_relationOperationIds[(todoId, tagId)] ?? const {}).map(
      (operationId) => _operations[operationId]!,
    );
    final adds = <String>{};
    final removedAdds = <String>{};
    for (final operation in relevant) {
      switch (operation.operationType) {
        case SyncOperationType.relationAdd:
          adds.add(operation.operationId);
        case SyncOperationType.relationRemove:
          removedAdds.addAll(
            (operation.payload['observedAddOperationIds'] as List)
                .cast<String>(),
          );
        case SyncOperationType.upsert ||
            SyncOperationType.delete ||
            SyncOperationType.restore:
          throw StateError(
            'Invalid relation operation reached materialization.',
          );
      }
    }
    if (adds.isEmpty && removedAdds.isEmpty) return null;
    return TodoTagMembership(
      todoId: todoId,
      tagId: tagId,
      activeAddOperationIds: adds.difference(removedAdds),
    );
  }

  static List<SyncOperation> _causalMaxima(List<SyncOperation> operations) {
    return operations
        .where(
          (candidate) => !operations.any(
            (other) =>
                candidate.operationId != other.operationId &&
                _happensBefore(candidate, other),
          ),
        )
        .toList(growable: false);
  }

  static SyncOperation _laterWinner(SyncOperation left, SyncOperation right) {
    final timestampOrder = left.timestamp.compareTo(right.timestamp);
    if (timestampOrder != 0) return timestampOrder > 0 ? left : right;
    return left.operationId.compareTo(right.operationId) > 0 ? left : right;
  }

  static bool _happensBefore(SyncOperation earlier, SyncOperation later) {
    if (earlier.sourceDeviceId == later.sourceDeviceId &&
        earlier.sequence < later.sequence) {
      return true;
    }
    return later.causalCursor.observes(earlier);
  }

  static bool _concurrent(SyncOperation left, SyncOperation right) =>
      !_happensBefore(left, right) && !_happensBefore(right, left);

  static SyncConflict _conflict(
    SyncConflictKind kind,
    SyncOperation winner,
    SyncOperation loser,
    SyncFieldGroup fieldGroup,
  ) {
    final id = [
      winner.entityType.wireName,
      winner.entityId,
      fieldGroup.wireName,
      winner.operationId,
      loser.operationId,
    ].join(':');
    return SyncConflict(
      id: id,
      kind: kind,
      entityType: winner.entityType,
      entityId: winner.entityId,
      fieldGroup: fieldGroup,
      winnerOperationId: winner.operationId,
      loserOperationId: loser.operationId,
      losingPayload: Map.unmodifiable(loser.payload),
    );
  }

  static String _canonical(SyncOperation operation) {
    final json = operation.toJson();
    return jsonEncode(_sortedJson(json));
  }

  static Object? _sortedJson(Object? value) {
    if (value is Map) {
      final keys = value.keys.cast<String>().toList()..sort();
      return {for (final key in keys) key: _sortedJson(value[key])};
    }
    if (value is List) return value.map(_sortedJson).toList();
    return value;
  }
}
