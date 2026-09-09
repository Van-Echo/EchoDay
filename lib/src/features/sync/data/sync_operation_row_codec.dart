import 'dart:convert';

import '../../../data/database/app_database.dart';
import '../domain/hybrid_logical_clock.dart';
import '../domain/sync_protocol.dart';

abstract final class SyncOperationRowCodec {
  static SyncOperation fromRow(SyncChangeRow row) {
    final payload = jsonDecode(row.payloadJson);
    final cursor = jsonDecode(row.causalCursorJson);
    if (payload is! Map<String, dynamic> || cursor is! Map<String, dynamic>) {
      throw const SyncProtocolException(
        SyncErrorCode.validationFailed,
        'Stored sync JSON has an invalid shape.',
      );
    }
    final operation = SyncOperation(
      operationId: row.operationId,
      syncGroupId: row.syncGroupId,
      sourceDeviceId: row.sourceDeviceId,
      sequence: row.sequence,
      transactionId: row.transactionId,
      entityType: _wireValue(
        SyncEntityType.values,
        row.entityType,
        (value) => value.wireName,
      ),
      entityId: row.entityId,
      operationType: _wireValue(
        SyncOperationType.values,
        row.operationType,
        (value) => value.wireName,
      ),
      fieldGroup: _wireValue(
        SyncFieldGroup.values,
        row.fieldGroup,
        (value) => value.wireName,
      ),
      payload: payload,
      timestamp: HybridTimestamp(
        physicalMillisUtc: row.hlcPhysicalMs,
        logicalCounter: row.hlcLogical,
        deviceId: row.hlcDeviceId,
      ),
      causalCursor: SyncCursor.fromJson(cursor),
      createdAtUtc: row.createdAt.toUtc(),
      payloadFormatVersion: row.payloadFormatVersion,
    );
    SyncProtocolValidator.validateOperation(operation);
    return operation;
  }

  static SyncChangesCompanion toCompanion(
    SyncOperation operation, {
    required DateTime appliedAtUtc,
  }) {
    SyncProtocolValidator.validateOperation(operation);
    return SyncChangesCompanion.insert(
      operationId: operation.operationId,
      syncGroupId: operation.syncGroupId,
      sourceDeviceId: operation.sourceDeviceId,
      sequence: operation.sequence,
      transactionId: operation.transactionId,
      entityType: operation.entityType.wireName,
      entityId: operation.entityId,
      operationType: operation.operationType.wireName,
      fieldGroup: operation.fieldGroup.wireName,
      payloadFormatVersion: operation.payloadFormatVersion,
      payloadJson: jsonEncode(operation.payload),
      hlcPhysicalMs: operation.timestamp.physicalMillisUtc,
      hlcLogical: operation.timestamp.logicalCounter,
      hlcDeviceId: operation.timestamp.deviceId,
      causalCursorJson: jsonEncode(operation.causalCursor.toJson()),
      createdAt: operation.createdAtUtc,
      appliedAt: appliedAtUtc,
    );
  }

  static T _wireValue<T>(
    Iterable<T> values,
    String wireName,
    String Function(T value) nameOf,
  ) {
    for (final value in values) {
      if (nameOf(value) == wireName) return value;
    }
    throw SyncProtocolException(
      SyncErrorCode.validationFailed,
      'Stored sync enum is unknown: $wireName.',
    );
  }
}
