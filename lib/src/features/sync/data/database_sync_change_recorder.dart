import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../../data/database/app_database.dart';
import '../domain/hybrid_logical_clock.dart';
import '../domain/sync_change_recorder.dart';
import '../domain/sync_protocol.dart';
import 'sync_operation_row_codec.dart';

final class DatabaseSyncChangeRecorder implements SyncChangeRecorder {
  DatabaseSyncChangeRecorder(
    this._database, {
    this.idGenerator = const UuidV7Generator(),
    this.clock = systemUtcClock,
  });

  static const localDeviceStateKey = 'sync.localDeviceId';

  final AppDatabase _database;
  final IdGenerator idGenerator;
  final UtcClock clock;

  @override
  Future<List<SyncOperation>> recordAll(
    Iterable<PendingSyncChange> changes,
  ) async {
    final pending = changes.toList(growable: false);
    if (pending.isEmpty) return const [];
    return _database.transaction(() async {
      final context = await _activeContext();
      if (context == null) return const [];

      final now = requireUtc(clock(), 'clock');
      final transactionId = idGenerator.next();
      var cursor = await _currentCursor(context.group.id);
      var sequence = cursor.sequenceFor(context.device.deviceId);
      final hybridClock = await _loadClock(context.device.deviceId);
      final recorded = <SyncOperation>[];

      for (final change in pending) {
        sequence++;
        final operation = SyncOperation(
          operationId: idGenerator.next(),
          syncGroupId: context.group.id,
          sourceDeviceId: context.device.deviceId,
          sequence: sequence,
          transactionId: transactionId,
          entityType: change.entityType,
          entityId: change.entityId,
          operationType: change.operationType,
          fieldGroup: change.fieldGroup,
          payload: change.payload,
          timestamp: hybridClock.tick(),
          causalCursor: cursor,
          createdAtUtc: now,
        );
        await _database
            .into(_database.syncChanges)
            .insert(
              SyncOperationRowCodec.toCompanion(operation, appliedAtUtc: now),
            );
        await _materializeMetadata(operation, now);
        recorded.add(operation);
        cursor = cursor.advanced(context.device.deviceId, sequence);
      }
      await _saveClock(hybridClock.current, now);
      return List.unmodifiable(recorded);
    });
  }

  @override
  Future<List<String>> activeRelationAddOperationIds({
    required String todoId,
    required String tagId,
  }) async {
    final context = await _activeContext();
    if (context == null) return const [];
    final query = _database.select(_database.syncRelationDots)
      ..where(
        (row) =>
            row.syncGroupId.equals(context.group.id) &
            row.todoId.equals(todoId) &
            row.tagId.equals(tagId) &
            row.removedByOperationId.isNull(),
      )
      ..orderBy([(row) => OrderingTerm.asc(row.addOperationId)]);
    return (await query.get())
        .map((row) => row.addOperationId)
        .toList(growable: false);
  }

  Future<_ActiveSyncContext?> _activeContext() async {
    final groupQuery = _database.select(_database.syncGroups)
      ..where((row) => row.isActive.equals(true))
      ..limit(2);
    final groups = await groupQuery.get();
    if (groups.isEmpty) return null;
    if (groups.length != 1) {
      throw StateError('A database must not have multiple active sync groups.');
    }
    final state = await (_database.select(
      _database.syncRuntimeStates,
    )..where((row) => row.key.equals(localDeviceStateKey))).getSingleOrNull();
    if (state == null || state.value.trim().isEmpty) {
      throw StateError('Active sync group has no local device identity.');
    }
    final device =
        await (_database.select(_database.syncDevices)..where(
              (row) =>
                  row.deviceId.equals(state.value) &
                  row.syncGroupId.equals(groups.single.id),
            ))
            .getSingleOrNull();
    if (device == null || device.revokedAt != null) {
      throw StateError('The local sync device is missing or revoked.');
    }
    return _ActiveSyncContext(groups.single, device);
  }

  Future<SyncCursor> _currentCursor(String groupId) async {
    final rows = await (_database.select(
      _database.syncChanges,
    )..where((row) => row.syncGroupId.equals(groupId))).get();
    final maxima = <String, int>{};
    for (final row in rows) {
      final current = maxima[row.sourceDeviceId] ?? 0;
      if (row.sequence > current) maxima[row.sourceDeviceId] = row.sequence;
    }
    return SyncCursor(maxima);
  }

  String _clockStateKey(String deviceId) => 'sync.hlc.$deviceId';

  Future<HybridLogicalClock> _loadClock(String deviceId) async {
    final row =
        await (_database.select(_database.syncRuntimeStates)..where(
              (candidate) => candidate.key.equals(_clockStateKey(deviceId)),
            ))
            .getSingleOrNull();
    HybridTimestamp? initial;
    if (row != null) {
      final value = jsonDecode(row.value);
      if (value is! Map<String, dynamic>) {
        throw StateError('Stored hybrid clock state is invalid.');
      }
      initial = HybridTimestamp.fromJson(value);
    }
    return HybridLogicalClock(
      deviceId: deviceId,
      wallClockMillisUtc: () =>
          requireUtc(clock(), 'clock').millisecondsSinceEpoch,
      initial: initial,
    );
  }

  Future<void> _saveClock(HybridTimestamp timestamp, DateTime now) {
    return _database
        .into(_database.syncRuntimeStates)
        .insertOnConflictUpdate(
          SyncRuntimeStatesCompanion.insert(
            key: _clockStateKey(timestamp.deviceId),
            value: jsonEncode(timestamp.toJson()),
            updatedAt: now,
          ),
        );
  }

  Future<void> _materializeMetadata(
    SyncOperation operation,
    DateTime now,
  ) async {
    if (operation.entityType == SyncEntityType.todoTag) {
      final todoId = operation.payload['todoId'] as String;
      final tagId = operation.payload['tagId'] as String;
      if (operation.operationType == SyncOperationType.relationAdd) {
        await _database
            .into(_database.syncRelationDots)
            .insert(
              SyncRelationDotsCompanion.insert(
                syncGroupId: operation.syncGroupId,
                todoId: todoId,
                tagId: tagId,
                addOperationId: operation.operationId,
                addedByDeviceId: operation.sourceDeviceId,
                addedSequence: operation.sequence,
                createdAt: now,
              ),
            );
      } else {
        final observed = (operation.payload['observedAddOperationIds'] as List)
            .cast<String>();
        if (observed.isNotEmpty) {
          await (_database.update(_database.syncRelationDots)..where(
                (row) =>
                    row.syncGroupId.equals(operation.syncGroupId) &
                    row.addOperationId.isIn(observed) &
                    row.removedByOperationId.isNull(),
              ))
              .write(
                SyncRelationDotsCompanion(
                  removedByOperationId: Value(operation.operationId),
                  removedAt: Value(now),
                ),
              );
        }
      }
      return;
    }

    await _database
        .into(_database.syncEntityVersions)
        .insertOnConflictUpdate(
          SyncEntityVersionsCompanion.insert(
            syncGroupId: operation.syncGroupId,
            entityType: operation.entityType.wireName,
            entityId: operation.entityId,
            fieldGroup: operation.fieldGroup.wireName,
            winningOperationId: operation.operationId,
            hlcPhysicalMs: operation.timestamp.physicalMillisUtc,
            hlcLogical: operation.timestamp.logicalCounter,
            hlcDeviceId: operation.timestamp.deviceId,
            causalCursorJson: jsonEncode(operation.causalCursor.toJson()),
            updatedAt: now,
          ),
        );
  }
}

final class _ActiveSyncContext {
  const _ActiveSyncContext(this.group, this.device);

  final SyncGroupRow group;
  final SyncDeviceRow device;
}
