import 'dart:convert';

import 'package:echoday/src/features/sync/domain/hybrid_logical_clock.dart';
import 'package:echoday/src/features/sync/domain/sync_merge_engine.dart';
import 'package:echoday/src/features/sync/domain/sync_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('different TODO field groups merge independently', () {
    final content = _operation(
      id: 'a-1',
      device: 'a',
      sequence: 1,
      fieldGroup: SyncFieldGroup.content,
      payload: const {'title': 'Plan work'},
      physicalMillis: 1000,
    );
    final completion = _operation(
      id: 'b-1',
      device: 'b',
      sequence: 1,
      fieldGroup: SyncFieldGroup.completion,
      payload: const {
        'isCompleted': true,
        'completedAt': '2026-09-09T01:00:00Z',
      },
      physicalMillis: 900,
    );
    final replica = InMemorySyncReplica()..applyAll([completion, content]);

    final result = replica.materialize(SyncEntityType.todo, 'todo-1')!;

    expect(result.fieldValues[SyncFieldGroup.content]!['title'], 'Plan work');
    expect(
      result.fieldValues[SyncFieldGroup.completion]!['isCompleted'],
      isTrue,
    );
    expect(result.conflicts, isEmpty);
  });

  test('concurrent same-group edits converge and preserve the loser', () {
    final left = _operation(
      id: 'b-1',
      device: 'b',
      sequence: 1,
      fieldGroup: SyncFieldGroup.content,
      payload: const {'title': 'Edit B'},
      physicalMillis: 2000,
      causal: const {'a': 1},
    );
    final right = _operation(
      id: 'c-1',
      device: 'c',
      sequence: 1,
      fieldGroup: SyncFieldGroup.content,
      payload: const {'title': 'Edit C'},
      physicalMillis: 2000,
      causal: const {'a': 1},
    );

    final first = InMemorySyncReplica()..applyAll([left, right]);
    final second = InMemorySyncReplica()..applyAll([right, left]);
    final firstResult = first.materialize(SyncEntityType.todo, 'todo-1')!;
    final secondResult = second.materialize(SyncEntityType.todo, 'todo-1')!;

    expect(_summary(firstResult), _summary(secondResult));
    expect(firstResult.fieldValues[SyncFieldGroup.content]!['title'], 'Edit C');
    expect(firstResult.conflicts, hasLength(1));
    expect(firstResult.conflicts.single.losingPayload['title'], 'Edit B');
  });

  test('causal successor wins even if its wall clock moved backwards', () {
    final earlier = _operation(
      id: 'a-1',
      device: 'a',
      sequence: 1,
      fieldGroup: SyncFieldGroup.content,
      payload: const {'title': 'Earlier'},
      physicalMillis: 5000,
    );
    final later = _operation(
      id: 'a-2',
      device: 'a',
      sequence: 2,
      fieldGroup: SyncFieldGroup.content,
      payload: const {'title': 'Later'},
      physicalMillis: 4000,
      causal: const {'a': 1},
    );
    final replica = InMemorySyncReplica()..applyAll([later, earlier]);

    final result = replica.materialize(SyncEntityType.todo, 'todo-1')!;

    expect(result.fieldValues[SyncFieldGroup.content]!['title'], 'Later');
    expect(result.conflicts, isEmpty);
  });

  test('concurrent deletion dominates edit and records recovery data', () {
    final edit = _operation(
      id: 'b-1',
      device: 'b',
      sequence: 1,
      fieldGroup: SyncFieldGroup.content,
      payload: const {'title': 'Important edit'},
      physicalMillis: 9000,
    );
    final deletion = _operation(
      id: 'c-1',
      device: 'c',
      sequence: 1,
      fieldGroup: SyncFieldGroup.deletion,
      payload: const {'deletedAt': '2026-09-09T01:00:00Z'},
      physicalMillis: 1000,
      type: SyncOperationType.delete,
    );
    final replica = InMemorySyncReplica()..applyAll([edit, deletion]);

    final result = replica.materialize(SyncEntityType.todo, 'todo-1')!;

    expect(result.deleted, isTrue);
    expect(
      result.conflicts.where(
        (conflict) => conflict.kind == SyncConflictKind.deletionVersusEdit,
      ),
      hasLength(1),
    );
    expect(result.conflicts.single.losingPayload['title'], 'Important edit');
  });

  test('three replicas converge after differently ordered delivery', () {
    final operations = [
      _operation(
        id: 'a-1',
        device: 'a',
        sequence: 1,
        fieldGroup: SyncFieldGroup.content,
        payload: const {'title': 'Base'},
        physicalMillis: 1000,
      ),
      _operation(
        id: 'b-1',
        device: 'b',
        sequence: 1,
        fieldGroup: SyncFieldGroup.content,
        payload: const {'title': 'From B'},
        physicalMillis: 2000,
        causal: const {'a': 1},
      ),
      _operation(
        id: 'c-1',
        device: 'c',
        sequence: 1,
        fieldGroup: SyncFieldGroup.content,
        payload: const {'title': 'From C'},
        physicalMillis: 1500,
        causal: const {'a': 1},
      ),
      _operation(
        id: 'a-2',
        device: 'a',
        sequence: 2,
        fieldGroup: SyncFieldGroup.order,
        payload: const {'manualOrder': 4.0},
        physicalMillis: 2500,
        causal: const {'a': 1, 'b': 1},
      ),
    ];
    final replicas = [
      InMemorySyncReplica()..applyAll(operations),
      InMemorySyncReplica()..applyAll(operations.reversed),
      InMemorySyncReplica()..applyAll([
        operations[2],
        operations[0],
        operations[3],
        operations[1],
      ]),
    ];

    final summaries = replicas
        .map(
          (replica) =>
              _summary(replica.materialize(SyncEntityType.todo, 'todo-1')!),
        )
        .toSet();

    expect(summaries, hasLength(1));
    expect(replicas.map((replica) => replica.cursor).toSet(), hasLength(1));
  });

  test('observed-remove relation keeps a concurrent add', () {
    final addA = _relation(
      id: 'a-add',
      device: 'a',
      type: SyncOperationType.relationAdd,
    );
    final removeB = _relation(
      id: 'b-remove',
      device: 'b',
      type: SyncOperationType.relationRemove,
      observedAdds: const ['a-add'],
      causal: const {'a': 1},
    );
    final addC = _relation(
      id: 'c-add',
      device: 'c',
      type: SyncOperationType.relationAdd,
    );
    final first = InMemorySyncReplica()..applyAll([addA, removeB, addC]);
    final second = InMemorySyncReplica()..applyAll([addC, removeB, addA]);

    final left = first.todoTagMembership('todo-1', 'tag-1')!;
    final right = second.todoTagMembership('todo-1', 'tag-1')!;

    expect(left.activeAddOperationIds, {'c-add'});
    expect(right.activeAddOperationIds, left.activeAddOperationIds);
    expect(left.isPresent, isTrue);
  });

  test('repeated operation is idempotent and id reuse is rejected', () {
    final operation = _operation(
      id: 'a-1',
      device: 'a',
      sequence: 1,
      fieldGroup: SyncFieldGroup.content,
      payload: const {'title': 'First'},
      physicalMillis: 1000,
    );
    final conflicting = _operation(
      id: 'a-1',
      device: 'a',
      sequence: 1,
      fieldGroup: SyncFieldGroup.content,
      payload: const {'title': 'Different'},
      physicalMillis: 1000,
    );
    final replica = InMemorySyncReplica()
      ..apply(operation)
      ..apply(operation);

    expect(replica.operations, hasLength(1));
    expect(
      () => replica.apply(conflicting),
      throwsA(
        isA<SyncProtocolException>().having(
          (error) => error.code,
          'code',
          SyncErrorCode.replayDetected,
        ),
      ),
    );
  });

  test('replica cursor acknowledges only each continuous prefix', () {
    final first = _operation(
      id: 'a-1',
      device: 'a',
      sequence: 1,
      fieldGroup: SyncFieldGroup.content,
      payload: const {'title': 'First'},
      physicalMillis: 1000,
    );
    final second = _operation(
      id: 'a-2',
      device: 'a',
      sequence: 2,
      fieldGroup: SyncFieldGroup.order,
      payload: const {'manualOrder': 2.0},
      physicalMillis: 1001,
      causal: const {'a': 1},
    );
    final replica = InMemorySyncReplica()..apply(second);

    expect(replica.cursor.sequenceFor('a'), 0);

    replica.apply(first);

    expect(replica.cursor.sequenceFor('a'), 2);
  });

  test('rejects cross-group operations and reused source sequences', () {
    final original = _operation(
      id: 'a-1',
      device: 'a',
      sequence: 1,
      fieldGroup: SyncFieldGroup.content,
      payload: const {'title': 'First'},
      physicalMillis: 1000,
    );
    final reusedSequence = _operation(
      id: 'a-other',
      device: 'a',
      sequence: 1,
      fieldGroup: SyncFieldGroup.order,
      payload: const {'manualOrder': 1.0},
      physicalMillis: 1001,
    );
    final crossGroup = SyncOperation(
      operationId: 'b-1',
      syncGroupId: 'group-2',
      sourceDeviceId: 'b',
      sequence: 1,
      transactionId: 'transaction-b-1',
      entityType: SyncEntityType.todo,
      entityId: 'todo-1',
      operationType: SyncOperationType.upsert,
      fieldGroup: SyncFieldGroup.content,
      payload: const {'title': 'Other group'},
      timestamp: const HybridTimestamp(
        physicalMillisUtc: 1002,
        logicalCounter: 0,
        deviceId: 'b',
      ),
      causalCursor: SyncCursor(),
      createdAtUtc: DateTime.utc(2026, 9, 9),
    );
    final replica = InMemorySyncReplica()..apply(original);

    expect(
      () => replica.apply(reusedSequence),
      throwsA(
        isA<SyncProtocolException>().having(
          (error) => error.code,
          'code',
          SyncErrorCode.replayDetected,
        ),
      ),
    );
    expect(
      () => replica.apply(crossGroup),
      throwsA(isA<SyncProtocolException>()),
    );
  });
}

SyncOperation _operation({
  required String id,
  required String device,
  required int sequence,
  required SyncFieldGroup fieldGroup,
  required Map<String, dynamic> payload,
  required int physicalMillis,
  Map<String, int> causal = const {},
  SyncOperationType type = SyncOperationType.upsert,
}) {
  return SyncOperation(
    operationId: id,
    syncGroupId: 'group-1',
    sourceDeviceId: device,
    sequence: sequence,
    transactionId: 'transaction-$id',
    entityType: SyncEntityType.todo,
    entityId: 'todo-1',
    operationType: type,
    fieldGroup: fieldGroup,
    payload: payload,
    timestamp: HybridTimestamp(
      physicalMillisUtc: physicalMillis,
      logicalCounter: 0,
      deviceId: device,
    ),
    causalCursor: SyncCursor(causal),
    createdAtUtc: DateTime.utc(2026, 9, 9),
  );
}

SyncOperation _relation({
  required String id,
  required String device,
  required SyncOperationType type,
  List<String> observedAdds = const [],
  Map<String, int> causal = const {},
}) {
  return SyncOperation(
    operationId: id,
    syncGroupId: 'group-1',
    sourceDeviceId: device,
    sequence: 1,
    transactionId: 'transaction-$id',
    entityType: SyncEntityType.todoTag,
    entityId: 'todo-1|tag-1',
    operationType: type,
    fieldGroup: SyncFieldGroup.tags,
    payload: {
      'todoId': 'todo-1',
      'tagId': 'tag-1',
      if (type == SyncOperationType.relationRemove)
        'observedAddOperationIds': observedAdds,
    },
    timestamp: HybridTimestamp(
      physicalMillisUtc: 1000,
      logicalCounter: 0,
      deviceId: device,
    ),
    causalCursor: SyncCursor(causal),
    createdAtUtc: DateTime.utc(2026, 9, 9),
  );
}

String _summary(MaterializedSyncEntity entity) {
  final fields = <String, Object>{};
  final winners = <String, String>{};
  for (final group in SyncFieldGroup.values) {
    final fieldValue = entity.fieldValues[group];
    final winner = entity.winningOperationIds[group];
    if (fieldValue != null) fields[group.wireName] = fieldValue;
    if (winner != null) winners[group.wireName] = winner;
  }
  return jsonEncode({
    'deleted': entity.deleted,
    'fields': fields,
    'winners': winners,
    'conflicts': entity.conflicts
        .map(
          (conflict) => {
            'id': conflict.id,
            'kind': conflict.kind.name,
            'winner': conflict.winnerOperationId,
            'loser': conflict.loserOperationId,
            'payload': conflict.losingPayload,
          },
        )
        .toList(),
  });
}
