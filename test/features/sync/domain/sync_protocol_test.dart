import 'dart:convert';

import 'package:echoday/src/features/sync/domain/hybrid_logical_clock.dart';
import 'package:echoday/src/features/sync/domain/sync_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('operation and batch JSON v1 round trip', () {
    final operation = _operation();
    final decoded = SyncProtocolCodec.decodeOperation(
      SyncProtocolCodec.encodeOperation(operation),
    );
    final batch = SyncBatch(
      syncGroupId: 'group-1',
      senderDeviceId: 'device-a',
      cursor: SyncCursor({'device-a': 1}),
      operations: [operation],
    );
    final decodedBatch = SyncProtocolCodec.decodeBatch(
      SyncProtocolCodec.encodeBatch(batch),
    );

    expect(decoded.operationId, operation.operationId);
    expect(decoded.timestamp, operation.timestamp);
    expect(decoded.payload, operation.payload);
    expect(decodedBatch.operations.single.operationId, operation.operationId);
    expect(decodedBatch.cursor.sequenceFor('device-a'), 1);
  });

  test('rejects protocol and schema versions before use', () {
    final json = _operation().toJson()..['protocolVersion'] = 999;

    expect(
      () => SyncProtocolCodec.decodeOperation(jsonEncode(json)),
      throwsA(
        isA<SyncProtocolException>().having(
          (error) => error.code,
          'code',
          SyncErrorCode.protocolIncompatible,
        ),
      ),
    );
  });

  test('rejects invalid relation shapes and self-observing sequences', () {
    final invalidRelation = _operation(
      type: SyncOperationType.relationAdd,
      fieldGroup: SyncFieldGroup.tags,
    );
    final selfObserving = _operation(causalCursor: SyncCursor({'device-a': 1}));

    expect(
      () => SyncProtocolValidator.validateOperation(invalidRelation),
      throwsA(isA<SyncProtocolException>()),
    );
    expect(
      () => SyncProtocolValidator.validateOperation(selfObserving),
      throwsA(isA<SyncProtocolException>()),
    );
  });

  test('rejects a field group that the entity does not support', () {
    final operation = SyncOperation(
      operationId: 'operation-a-1',
      syncGroupId: 'group-1',
      sourceDeviceId: 'device-a',
      sequence: 1,
      transactionId: 'transaction-1',
      entityType: SyncEntityType.category,
      entityId: 'category-1',
      operationType: SyncOperationType.upsert,
      fieldGroup: SyncFieldGroup.completion,
      payload: const {'isCompleted': true},
      timestamp: const HybridTimestamp(
        physicalMillisUtc: 1000,
        logicalCounter: 0,
        deviceId: 'device-a',
      ),
      causalCursor: SyncCursor(),
      createdAtUtc: DateTime.utc(2026, 9, 9),
    );

    expect(
      () => SyncProtocolValidator.validateOperation(operation),
      throwsA(isA<SyncProtocolException>()),
    );
  });

  test('cursor merge keeps the greatest sequence per source device', () {
    final merged = SyncCursor({'device-a': 3, 'device-b': 1})
        .mergedWith(SyncCursor({'device-a': 2, 'device-b': 4}));

    expect(merged, SyncCursor({'device-a': 3, 'device-b': 4}));
  });

  test('malformed cursor and HLC return structured validation errors', () {
    final malformedCursor = _operation().toJson()
      ..['causalCursor'] = {'device-a': -1};
    final malformedTimestamp = _operation().toJson()
      ..['timestamp'] = {
        'physicalMillisUtc': 'not-an-integer',
        'logicalCounter': 0,
        'deviceId': 'device-a',
      };

    for (final json in [malformedCursor, malformedTimestamp]) {
      expect(
        () => SyncProtocolCodec.decodeOperation(jsonEncode(json)),
        throwsA(
          isA<SyncProtocolException>().having(
            (error) => error.code,
            'code',
            SyncErrorCode.validationFailed,
          ),
        ),
      );
    }
  });
}

SyncOperation _operation({
  SyncOperationType type = SyncOperationType.upsert,
  SyncFieldGroup fieldGroup = SyncFieldGroup.content,
  SyncCursor? causalCursor,
}) {
  return SyncOperation(
    operationId: 'operation-a-1',
    syncGroupId: 'group-1',
    sourceDeviceId: 'device-a',
    sequence: 1,
    transactionId: 'transaction-1',
    entityType: SyncEntityType.todo,
    entityId: 'todo-1',
    operationType: type,
    fieldGroup: fieldGroup,
    payload: const {'title': 'Write S0'},
    timestamp: const HybridTimestamp(
      physicalMillisUtc: 1000,
      logicalCounter: 0,
      deviceId: 'device-a',
    ),
    causalCursor: causalCursor ?? SyncCursor(),
    createdAtUtc: DateTime.utc(2026, 9, 9),
  );
}
