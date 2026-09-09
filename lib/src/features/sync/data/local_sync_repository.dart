import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../../data/database/app_database.dart';
import '../domain/hybrid_logical_clock.dart';
import '../domain/sync_change_recorder.dart';
import '../domain/sync_entity_payloads.dart';
import '../domain/sync_merge_engine.dart';
import '../domain/sync_protocol.dart';
import '../domain/sync_repository.dart';
import 'database_sync_change_recorder.dart';
import 'sync_operation_row_codec.dart';

final class LocalSyncRepository implements SyncRepository {
  LocalSyncRepository(
    this._database, {
    this.idGenerator = const UuidV7Generator(),
    this.clock = systemUtcClock,
    DatabaseSyncChangeRecorder? recorder,
  }) : _recorder =
           recorder ??
           DatabaseSyncChangeRecorder(
             _database,
             idGenerator: idGenerator,
             clock: clock,
           );

  final AppDatabase _database;
  final IdGenerator idGenerator;
  final UtcClock clock;
  final DatabaseSyncChangeRecorder _recorder;

  @override
  Future<SyncGroupIdentity?> activeIdentity() async {
    final groups = await (_database.select(
      _database.syncGroups,
    )..where((row) => row.isActive.equals(true))).get();
    if (groups.isEmpty) return null;
    if (groups.length != 1) {
      throw StateError('A database has multiple active sync groups.');
    }
    final state =
        await (_database.select(_database.syncRuntimeStates)..where(
              (row) => row.key.equals(
                DatabaseSyncChangeRecorder.localDeviceStateKey,
              ),
            ))
            .getSingleOrNull();
    if (state == null) {
      throw StateError('Active sync group has no local device identity.');
    }
    return SyncGroupIdentity(
      groupId: groups.single.id,
      localDeviceId: state.value,
      role: _role(groups.single.role),
    );
  }

  @override
  Future<SyncGroupIdentity> initializeHost({
    required SyncDeviceRegistration localDevice,
    String? groupId,
  }) {
    return _database.transaction(() async {
      if (await activeIdentity() != null) {
        throw StateError('This database already belongs to a sync group.');
      }
      _validateDevice(localDevice);
      final now = requireUtc(clock(), 'clock');
      final resolvedGroupId = groupId ?? idGenerator.next();
      if (resolvedGroupId.trim().isEmpty) {
        throw ArgumentError.value(groupId, 'groupId', 'must not be blank');
      }
      await _database
          .into(_database.syncGroups)
          .insert(
            SyncGroupsCompanion.insert(
              id: resolvedGroupId,
              role: SyncGroupRole.host.name,
              hostDeviceId: localDevice.deviceId,
              protocolVersion: SyncProtocol.version,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _insertDevice(resolvedGroupId, localDevice, now);
      await _database
          .into(_database.syncRuntimeStates)
          .insertOnConflictUpdate(
            SyncRuntimeStatesCompanion.insert(
              key: DatabaseSyncChangeRecorder.localDeviceStateKey,
              value: localDevice.deviceId,
              updatedAt: now,
            ),
          );

      final baseline = await _buildBaseline();
      for (var offset = 0; offset < baseline.length; offset += 500) {
        final end = (offset + 500).clamp(0, baseline.length);
        await _recorder.recordAll(baseline.sublist(offset, end));
      }
      return SyncGroupIdentity(
        groupId: resolvedGroupId,
        localDeviceId: localDevice.deviceId,
        role: SyncGroupRole.host,
      );
    });
  }

  @override
  Future<SyncGroupIdentity> initializeClient({
    required String groupId,
    required String hostDeviceId,
    required SyncDeviceRegistration hostDevice,
    required SyncDeviceRegistration localDevice,
  }) {
    return _database.transaction(() async {
      if (await activeIdentity() != null) {
        throw StateError('This database already belongs to a sync group.');
      }
      _validateDevice(hostDevice);
      _validateDevice(localDevice);
      if (hostDevice.deviceId != hostDeviceId) {
        throw ArgumentError('Host registration does not match hostDeviceId.');
      }
      if (groupId.trim().isEmpty || hostDeviceId == localDevice.deviceId) {
        throw ArgumentError('Client sync group identity is invalid.');
      }
      final now = requireUtc(clock(), 'clock');
      await _database
          .into(_database.syncGroups)
          .insert(
            SyncGroupsCompanion.insert(
              id: groupId,
              role: SyncGroupRole.client.name,
              hostDeviceId: hostDeviceId,
              protocolVersion: SyncProtocol.version,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _insertDevice(groupId, hostDevice, now);
      await _insertDevice(groupId, localDevice, now);
      await _database
          .into(_database.syncRuntimeStates)
          .insertOnConflictUpdate(
            SyncRuntimeStatesCompanion.insert(
              key: DatabaseSyncChangeRecorder.localDeviceStateKey,
              value: localDevice.deviceId,
              updatedAt: now,
            ),
          );
      final baseline = await _buildBaseline();
      for (var offset = 0; offset < baseline.length; offset += 500) {
        final end = (offset + 500).clamp(0, baseline.length);
        await _recorder.recordAll(baseline.sublist(offset, end));
      }
      return SyncGroupIdentity(
        groupId: groupId,
        localDeviceId: localDevice.deviceId,
        role: SyncGroupRole.client,
      );
    });
  }

  @override
  Future<void> registerDevice(SyncDeviceRegistration device) async {
    _validateDevice(device);
    final identity = await _requireIdentity();
    final now = requireUtc(clock(), 'clock');
    await _insertDevice(identity.groupId, device, now);
  }

  @override
  Future<SyncBatch> changesAfter(
    SyncCursor cursor, {
    int maximumOperations = SyncProtocol.maximumBatchOperations,
  }) async {
    if (maximumOperations < 1 ||
        maximumOperations > SyncProtocol.maximumBatchOperations) {
      throw ArgumentError.value(maximumOperations, 'maximumOperations');
    }
    final identity = await _requireIdentity();
    final currentCursor = await _currentCursor(identity.groupId);
    Expression<bool>? missingPredicate;
    for (final sourceDeviceId in currentCursor.sequences.keys) {
      final sourcePredicate =
          _database.syncChanges.sourceDeviceId.equals(sourceDeviceId) &
          _database.syncChanges.sequence.isBiggerThanValue(
            cursor.sequenceFor(sourceDeviceId),
          );
      missingPredicate = missingPredicate == null
          ? sourcePredicate
          : missingPredicate | sourcePredicate;
    }
    if (missingPredicate == null) {
      return SyncBatch(
        syncGroupId: identity.groupId,
        senderDeviceId: identity.localDeviceId,
        cursor: currentCursor,
        operations: const [],
      );
    }
    final rows =
        await (_database.select(_database.syncChanges)
              ..where(
                (row) =>
                    row.syncGroupId.equals(identity.groupId) &
                    missingPredicate!,
              )
              ..orderBy([
                (row) => OrderingTerm.asc(row.appliedAt),
                (row) => OrderingTerm.asc(row.sourceDeviceId),
                (row) => OrderingTerm.asc(row.sequence),
              ])
              ..limit(maximumOperations + 1))
            .get();
    final selected = <SyncChangeRow>[];
    for (final transaction in _transactionsInOrder(rows)) {
      if (selected.isNotEmpty &&
          selected.length + transaction.length > maximumOperations) {
        break;
      }
      if (transaction.length > maximumOperations) {
        throw StateError('One sync transaction exceeds the batch limit.');
      }
      selected.addAll(transaction);
    }
    return SyncBatch(
      syncGroupId: identity.groupId,
      senderDeviceId: identity.localDeviceId,
      cursor: currentCursor,
      operations: selected
          .map(SyncOperationRowCodec.fromRow)
          .toList(growable: false),
    );
  }

  @override
  Future<SyncCursor> currentCursor() async {
    final identity = await _requireIdentity();
    return _currentCursor(identity.groupId);
  }

  @override
  Future<SyncApplyResult> applyBatch(SyncBatch batch) {
    return _database.transaction(() async {
      SyncProtocolValidator.validateBatch(batch);
      final identity = await _requireIdentity();
      if (batch.syncGroupId != identity.groupId) {
        throw const SyncProtocolException(
          SyncErrorCode.unauthorized,
          'The batch belongs to another sync group.',
        );
      }
      await _requireActiveDevice(batch.senderDeviceId, identity.groupId);
      final operations = batch.operations.toList(growable: false);
      for (final source
          in operations.map((item) => item.sourceDeviceId).toSet()) {
        await _requireActiveDevice(source, identity.groupId);
      }
      final existingRows = operations.isEmpty
          ? const <SyncChangeRow>[]
          : await (_database.select(_database.syncChanges)..where(
                  (row) => row.operationId.isIn(
                    operations.map((operation) => operation.operationId),
                  ),
                ))
                .get();
      final existingById = {
        for (final row in existingRows) row.operationId: row,
      };
      await _validateIncomingSequences(
        identity.groupId,
        operations,
        existingById.keys.toSet(),
      );

      final now = requireUtc(clock(), 'clock');
      var inserted = 0;
      var duplicates = 0;
      final insertedRemoteOperations = <SyncOperation>[];
      final affected = <_EntityKey>{};
      final affectedRelations = <_RelationKey>{};
      for (final operation in operations) {
        final existing = existingById[operation.operationId];
        if (existing != null) {
          final stored = SyncOperationRowCodec.fromRow(existing);
          if (_canonical(stored) != _canonical(operation)) {
            throw const SyncProtocolException(
              SyncErrorCode.replayDetected,
              'An operation id was reused with different content.',
            );
          }
          duplicates++;
          continue;
        }
        await _database
            .into(_database.syncChanges)
            .insert(
              SyncOperationRowCodec.toCompanion(operation, appliedAtUtc: now),
            );
        await _applyRelationMetadata(operation, now);
        inserted++;
        if (operation.sourceDeviceId != identity.localDeviceId) {
          insertedRemoteOperations.add(operation);
        }
        if (operation.entityType == SyncEntityType.todoTag) {
          affectedRelations.add(
            _RelationKey(
              operation.payload['todoId'] as String,
              operation.payload['tagId'] as String,
            ),
          );
        } else {
          affected.add(_EntityKey(operation.entityType, operation.entityId));
        }
      }

      final allRows = await _changesForAffectedEntities(
        identity.groupId,
        affected,
        affectedRelations,
      );
      final allOperations = allRows
          .map(SyncOperationRowCodec.fromRow)
          .toList(growable: false);
      final operationsById = {
        for (final operation in allOperations) operation.operationId: operation,
      };
      final replica = InMemorySyncReplica()..applyAll(allOperations);
      final conflicts = <SyncConflict>[];
      final orderedEntities = affected.toList()
        ..sort((left, right) {
          final type = _entityApplyOrder(left.type)
              .compareTo(_entityApplyOrder(right.type));
          return type != 0 ? type : left.id.compareTo(right.id);
        });
      for (final key in orderedEntities) {
        final entity = replica.materialize(key.type, key.id);
        if (entity == null) continue;
        await _applyEntity(identity.groupId, entity, operationsById, now);
        conflicts.addAll(entity.conflicts);
      }
      for (final relation in affectedRelations) {
        await _materializeRelation(replica, relation);
      }
      await _observeRemoteClocks(
        identity.localDeviceId,
        insertedRemoteOperations,
        now,
      );
      return SyncApplyResult(
        insertedOperations: inserted,
        duplicateOperations: duplicates,
        conflicts: List.unmodifiable(conflicts),
        acknowledgedCursor: await _currentCursor(identity.groupId),
      );
    });
  }

  @override
  Future<void> acknowledge(String peerDeviceId, SyncCursor cursor) async {
    final identity = await _requireIdentity();
    await _requireActiveDevice(peerDeviceId, identity.groupId);
    final now = requireUtc(clock(), 'clock');
    await _database.transaction(() async {
      for (final entry in cursor.sequences.entries) {
        await _database
            .into(_database.syncCursors)
            .insertOnConflictUpdate(
              SyncCursorsCompanion.insert(
                syncGroupId: identity.groupId,
                peerDeviceId: peerDeviceId,
                sourceDeviceId: entry.key,
                acknowledgedSequence: Value(entry.value),
                updatedAt: now,
              ),
            );
      }
    });
  }

  @override
  Future<List<SyncConflict>> unresolvedConflicts() async {
    final identity = await _requireIdentity();
    final rows =
        await (_database.select(_database.syncConflicts)
              ..where(
                (row) =>
                    row.syncGroupId.equals(identity.groupId) &
                    row.resolvedAt.isNull(),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
            .get();
    return rows.map(_conflictFromRow).toList(growable: false);
  }

  @override
  Future<void> resolveConflict(String conflictId) {
    return _database.transaction(() async {
      final identity = await _requireIdentity();
      final row =
          await (_database.select(_database.syncConflicts)..where(
                (candidate) =>
                    candidate.id.equals(conflictId) &
                    candidate.syncGroupId.equals(identity.groupId) &
                    candidate.resolvedAt.isNull(),
              ))
              .getSingleOrNull();
      if (row == null) throw StateError('Conflict is missing or resolved.');
      final entityType = SyncEntityType.values.firstWhere(
        (value) => value.wireName == row.entityType,
      );
      final fieldGroup = SyncFieldGroup.values.firstWhere(
        (value) => value.wireName == row.fieldGroup,
      );
      final payload = (jsonDecode(row.losingPayloadJson) as Map)
          .cast<String, dynamic>();
      final pending = <PendingSyncChange>[
        PendingSyncChange(
          entityType: entityType,
          entityId: row.entityId,
          operationType: fieldGroup == SyncFieldGroup.deletion
              ? (payload['deletedAt'] == null
                    ? SyncOperationType.restore
                    : SyncOperationType.delete)
              : SyncOperationType.upsert,
          fieldGroup: fieldGroup,
          payload: payload,
        ),
        if (row.kind == SyncConflictKind.deletionVersusEdit.name)
          PendingSyncChange(
            entityType: entityType,
            entityId: row.entityId,
            operationType: SyncOperationType.restore,
            fieldGroup: SyncFieldGroup.deletion,
            payload: SyncEntityPayloads.deletion(null),
          ),
      ];
      final recorded = await _recorder.recordAll(pending);
      if (recorded.isEmpty) throw StateError('Sync is not active.');
      final now = requireUtc(clock(), 'clock');
      final allRows = await (_database.select(
        _database.syncChanges,
      )..where((change) => change.syncGroupId.equals(identity.groupId))).get();
      final allOperations = allRows
          .map(SyncOperationRowCodec.fromRow)
          .toList(growable: false);
      final replica = InMemorySyncReplica()..applyAll(allOperations);
      final entity = replica.materialize(entityType, row.entityId);
      if (entity != null) {
        await _applyEntity(identity.groupId, entity, {
          for (final operation in allOperations)
            operation.operationId: operation,
        }, now);
      }
      await (_database.update(
        _database.syncConflicts,
      )..where((candidate) => candidate.id.equals(conflictId))).write(
        SyncConflictsCompanion(
          resolvedAt: Value(now),
          resolutionOperationId: Value(recorded.first.operationId),
        ),
      );
    });
  }

  @override
  Future<void> leaveGroup() {
    return _database.transaction(() async {
      await _database.delete(_database.syncConflicts).go();
      await _database.delete(_database.syncCursors).go();
      await _database.delete(_database.syncRelationDots).go();
      await _database.delete(_database.syncEntityVersions).go();
      await _database.delete(_database.syncChanges).go();
      await _database.delete(_database.syncPairingInvites).go();
      await _database.delete(_database.syncDevices).go();
      await _database.delete(_database.syncGroups).go();
      await _database.delete(_database.syncRuntimeStates).go();
    });
  }

  @override
  Future<int> compactAcknowledgedChanges({
    Duration safetyWindow = const Duration(days: 30),
  }) async {
    if (safetyWindow.isNegative) {
      throw ArgumentError.value(safetyWindow, 'safetyWindow');
    }
    final identity = await _requireIdentity();
    final cutoff = requireUtc(clock(), 'clock').subtract(safetyWindow);
    final activeDevices =
        await (_database.select(_database.syncDevices)..where(
              (row) =>
                  row.syncGroupId.equals(identity.groupId) &
                  row.revokedAt.isNull(),
            ))
            .get();
    final protectedIds = <String>{};
    protectedIds.addAll(
      (await (_database.select(
        _database.syncEntityVersions,
      )..where((row) => row.syncGroupId.equals(identity.groupId))).get()).map(
        (row) => row.winningOperationId,
      ),
    );
    for (final row
        in await (_database.select(_database.syncRelationDots)..where(
              (dot) =>
                  dot.syncGroupId.equals(identity.groupId) &
                  dot.removedByOperationId.isNull(),
            ))
            .get()) {
      protectedIds.add(row.addOperationId);
    }
    for (final row
        in await (_database.select(_database.syncConflicts)..where(
              (conflict) =>
                  conflict.syncGroupId.equals(identity.groupId) &
                  conflict.resolvedAt.isNull(),
            ))
            .get()) {
      protectedIds
        ..add(row.winnerOperationId)
        ..add(row.loserOperationId);
    }
    final changes =
        await (_database.select(_database.syncChanges)..where(
              (row) =>
                  row.syncGroupId.equals(identity.groupId) &
                  row.createdAt.isSmallerThanValue(cutoff),
            ))
            .get();
    var removed = 0;
    await _database.transaction(() async {
      for (final change in changes) {
        if (protectedIds.contains(change.operationId)) continue;
        var acknowledgedByAll = true;
        for (final device in activeDevices) {
          if (device.deviceId == identity.localDeviceId) continue;
          final cursor =
              await (_database.select(_database.syncCursors)..where(
                    (row) =>
                        row.syncGroupId.equals(identity.groupId) &
                        row.peerDeviceId.equals(device.deviceId) &
                        row.sourceDeviceId.equals(change.sourceDeviceId),
                  ))
                  .getSingleOrNull();
          if ((cursor?.acknowledgedSequence ?? 0) < change.sequence) {
            acknowledgedByAll = false;
            break;
          }
        }
        if (!acknowledgedByAll) continue;
        removed += await (_database.delete(
          _database.syncChanges,
        )..where((row) => row.operationId.equals(change.operationId))).go();
      }
    });
    return removed;
  }

  Future<List<PendingSyncChange>> _buildBaseline() async {
    final changes = <PendingSyncChange>[];
    for (final row in await _database.select(_database.categories).get()) {
      changes.addAll([
        PendingSyncChange(
          entityType: SyncEntityType.category,
          entityId: row.id,
          operationType: SyncOperationType.upsert,
          fieldGroup: SyncFieldGroup.content,
          payload: {
            'name': row.name,
            'colorValue': row.colorValue,
            'createdAtUtc': row.createdAt.toUtc().toIso8601String(),
          },
        ),
        PendingSyncChange(
          entityType: SyncEntityType.category,
          entityId: row.id,
          operationType: SyncOperationType.upsert,
          fieldGroup: SyncFieldGroup.order,
          payload: {'sortOrder': row.sortOrder},
        ),
        if (row.deletedAt != null)
          _deletion(SyncEntityType.category, row.id, row.deletedAt!.toUtc()),
      ]);
    }
    for (final row in await _database.select(_database.tags).get()) {
      changes.addAll([
        PendingSyncChange(
          entityType: SyncEntityType.tag,
          entityId: row.id,
          operationType: SyncOperationType.upsert,
          fieldGroup: SyncFieldGroup.content,
          payload: {
            'name': row.name,
            'colorValue': row.colorValue,
            'createdAtUtc': row.createdAt.toUtc().toIso8601String(),
          },
        ),
        PendingSyncChange(
          entityType: SyncEntityType.tag,
          entityId: row.id,
          operationType: SyncOperationType.upsert,
          fieldGroup: SyncFieldGroup.order,
          payload: {'sortOrder': row.sortOrder},
        ),
        if (row.deletedAt != null)
          _deletion(SyncEntityType.tag, row.id, row.deletedAt!.toUtc()),
      ]);
    }
    for (final row
        in await _database.select(_database.recurrenceSeriesEntries).get()) {
      changes.addAll([
        PendingSyncChange(
          entityType: SyncEntityType.recurrenceSeries,
          entityId: row.id,
          operationType: SyncOperationType.upsert,
          fieldGroup: SyncFieldGroup.content,
          payload: {
            'startDate': row.startDate,
            'ruleJson': row.ruleJson,
            'timeZoneId': row.timeZoneId,
            'createdAtUtc': row.createdAt.toUtc().toIso8601String(),
          },
        ),
        if (row.deletedAt != null)
          _deletion(
            SyncEntityType.recurrenceSeries,
            row.id,
            row.deletedAt!.toUtc(),
          ),
      ]);
    }
    for (final row in await _database.select(_database.todos).get()) {
      changes.addAll([
        PendingSyncChange(
          entityType: SyncEntityType.todo,
          entityId: row.id,
          operationType: SyncOperationType.upsert,
          fieldGroup: SyncFieldGroup.content,
          payload: _todoContentFromRow(row),
        ),
        PendingSyncChange(
          entityType: SyncEntityType.todo,
          entityId: row.id,
          operationType: SyncOperationType.upsert,
          fieldGroup: SyncFieldGroup.completion,
          payload: {
            'isCompleted': row.isCompleted,
            'completedAtUtc': row.completedAt?.toUtc().toIso8601String(),
          },
        ),
        PendingSyncChange(
          entityType: SyncEntityType.todo,
          entityId: row.id,
          operationType: SyncOperationType.upsert,
          fieldGroup: SyncFieldGroup.order,
          payload: {'manualOrder': row.manualOrder},
        ),
        if (row.deletedAt != null)
          _deletion(SyncEntityType.todo, row.id, row.deletedAt!.toUtc()),
      ]);
    }
    for (final row in await _database.select(_database.todoTags).get()) {
      changes.add(
        PendingSyncChange(
          entityType: SyncEntityType.todoTag,
          entityId: '${row.todoId}:${row.tagId}',
          operationType: SyncOperationType.relationAdd,
          fieldGroup: SyncFieldGroup.tags,
          payload: SyncEntityPayloads.todoTag(
            todoId: row.todoId,
            tagId: row.tagId,
          ),
        ),
      );
    }
    for (final row
        in await _database.select(_database.recurrenceExceptions).get()) {
      changes.addAll([
        PendingSyncChange(
          entityType: SyncEntityType.recurrenceException,
          entityId: row.id,
          operationType: SyncOperationType.upsert,
          fieldGroup: SyncFieldGroup.content,
          payload: SyncEntityPayloads.recurrenceExceptionContent(
            seriesId: row.seriesId,
            occurrenceDate: row.occurrenceDate,
            overrideJson: row.overrideJson,
            isSkipped: row.isSkipped,
            createdAt: row.createdAt.toUtc(),
          ),
        ),
        if (row.deletedAt != null)
          _deletion(
            SyncEntityType.recurrenceException,
            row.id,
            row.deletedAt!.toUtc(),
          ),
      ]);
    }
    return changes;
  }

  Future<void> _applyEntity(
    String groupId,
    MaterializedSyncEntity entity,
    Map<String, SyncOperation> operations,
    DateTime now,
  ) async {
    for (final winner in entity.winningOperationIds.entries) {
      final operation = operations[winner.value]!;
      await _database
          .into(_database.syncEntityVersions)
          .insertOnConflictUpdate(
            SyncEntityVersionsCompanion.insert(
              syncGroupId: groupId,
              entityType: entity.entityType.wireName,
              entityId: entity.entityId,
              fieldGroup: winner.key.wireName,
              winningOperationId: winner.value,
              hlcPhysicalMs: operation.timestamp.physicalMillisUtc,
              hlcLogical: operation.timestamp.logicalCounter,
              hlcDeviceId: operation.timestamp.deviceId,
              causalCursorJson: jsonEncode(operation.causalCursor.toJson()),
              updatedAt: now,
            ),
          );
    }
    final activeConflictIds = entity.conflicts.map((item) => item.id).toSet();
    final existingConflicts =
        await (_database.select(_database.syncConflicts)..where(
              (row) =>
                  row.syncGroupId.equals(groupId) &
                  row.entityType.equals(entity.entityType.wireName) &
                  row.entityId.equals(entity.entityId) &
                  row.resolvedAt.isNull(),
            ))
            .get();
    for (final existing in existingConflicts) {
      if (activeConflictIds.contains(existing.id)) continue;
      final winner =
          entity.winningOperationIds[SyncFieldGroup.values.firstWhere(
            (value) => value.wireName == existing.fieldGroup,
          )];
      await (_database.update(
        _database.syncConflicts,
      )..where((row) => row.id.equals(existing.id))).write(
        SyncConflictsCompanion(
          resolvedAt: Value(now),
          resolutionOperationId: Value(winner),
        ),
      );
    }
    for (final conflict in entity.conflicts) {
      await _database
          .into(_database.syncConflicts)
          .insert(
            SyncConflictsCompanion.insert(
              id: conflict.id,
              syncGroupId: groupId,
              entityType: conflict.entityType.wireName,
              entityId: conflict.entityId,
              fieldGroup: conflict.fieldGroup.wireName,
              kind: conflict.kind.name,
              winnerOperationId: conflict.winnerOperationId,
              loserOperationId: conflict.loserOperationId,
              losingPayloadJson: jsonEncode(conflict.losingPayload),
              createdAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
    final deletionId = entity.winningOperationIds[SyncFieldGroup.deletion];
    final deletedAt = entity.deleted && deletionId != null
        ? _date(operations[deletionId]!.payload['deletedAt'], 'deletedAt')
        : null;
    final content = entity.fieldValues[SyncFieldGroup.content];
    if (content == null) return;
    switch (entity.entityType) {
      case SyncEntityType.category:
        final order = entity.fieldValues[SyncFieldGroup.order];
        final old = await (_database.select(
          _database.categories,
        )..where((row) => row.id.equals(entity.entityId))).getSingleOrNull();
        await _database
            .into(_database.categories)
            .insertOnConflictUpdate(
              CategoriesCompanion.insert(
                id: entity.entityId,
                name: _string(content, 'name'),
                colorValue: _integer(content, 'colorValue'),
                sortOrder: Value(_number(order, 'sortOrder', fallback: 0)),
                createdAt: _date(content['createdAtUtc'], 'createdAtUtc'),
                updatedAt: now,
                deletedAt: Value(deletedAt),
                revision: Value((old?.revision ?? 0) + 1),
              ),
            );
      case SyncEntityType.tag:
        final order = entity.fieldValues[SyncFieldGroup.order];
        final old = await (_database.select(
          _database.tags,
        )..where((row) => row.id.equals(entity.entityId))).getSingleOrNull();
        await _database
            .into(_database.tags)
            .insertOnConflictUpdate(
              TagsCompanion.insert(
                id: entity.entityId,
                name: _string(content, 'name'),
                colorValue: _integer(content, 'colorValue'),
                sortOrder: Value(_number(order, 'sortOrder', fallback: 0)),
                createdAt: _date(content['createdAtUtc'], 'createdAtUtc'),
                updatedAt: now,
                deletedAt: Value(deletedAt),
                revision: Value((old?.revision ?? 0) + 1),
              ),
            );
      case SyncEntityType.recurrenceSeries:
        final old = await (_database.select(
          _database.recurrenceSeriesEntries,
        )..where((row) => row.id.equals(entity.entityId))).getSingleOrNull();
        await _database
            .into(_database.recurrenceSeriesEntries)
            .insertOnConflictUpdate(
              RecurrenceSeriesEntriesCompanion.insert(
                id: entity.entityId,
                startDate: _string(content, 'startDate'),
                ruleJson: _string(content, 'ruleJson'),
                timeZoneId: Value(_nullableString(content, 'timeZoneId')),
                createdAt: _date(content['createdAtUtc'], 'createdAtUtc'),
                updatedAt: now,
                deletedAt: Value(deletedAt),
                revision: Value((old?.revision ?? 0) + 1),
              ),
            );
      case SyncEntityType.todo:
        final completion = entity.fieldValues[SyncFieldGroup.completion];
        final order = entity.fieldValues[SyncFieldGroup.order];
        final old = await (_database.select(
          _database.todos,
        )..where((row) => row.id.equals(entity.entityId))).getSingleOrNull();
        await _database
            .into(_database.todos)
            .insertOnConflictUpdate(
              TodosCompanion.insert(
                id: entity.entityId,
                title: _string(content, 'title'),
                localDate: _string(content, 'localDate'),
                isCompleted: Value(_boolean(completion, 'isCompleted')),
                createdAt: _date(content['createdAtUtc'], 'createdAtUtc'),
                updatedAt: now,
                plannedAt: Value(_nullableDate(content['plannedAtUtc'])),
                priority: Value(_integer(content, 'priority')),
                categoryId: Value(_nullableString(content, 'categoryId')),
                notes: Value(_nullableString(content, 'notes')),
                deadlineAt: Value(_nullableDate(content['deadlineAtUtc'])),
                timeZoneId: Value(_nullableString(content, 'timeZoneId')),
                completedAt: Value(
                  _nullableDate(completion?['completedAtUtc']),
                ),
                deletedAt: Value(deletedAt),
                manualOrder: Value(_number(order, 'manualOrder', fallback: 0)),
                revision: Value((old?.revision ?? 0) + 1),
                recurrenceSeriesId: Value(
                  _nullableString(content, 'recurrenceSeriesId'),
                ),
                occurrenceDate: Value(
                  _nullableString(content, 'occurrenceDate'),
                ),
              ),
            );
      case SyncEntityType.recurrenceException:
        final old = await (_database.select(
          _database.recurrenceExceptions,
        )..where((row) => row.id.equals(entity.entityId))).getSingleOrNull();
        await _database
            .into(_database.recurrenceExceptions)
            .insertOnConflictUpdate(
              RecurrenceExceptionsCompanion.insert(
                id: entity.entityId,
                seriesId: _string(content, 'seriesId'),
                occurrenceDate: _string(content, 'occurrenceDate'),
                overrideJson: Value(_nullableString(content, 'overrideJson')),
                isSkipped: Value(_boolean(content, 'isSkipped')),
                createdAt: _date(content['createdAtUtc'], 'createdAtUtc'),
                updatedAt: now,
                deletedAt: Value(deletedAt),
                revision: Value((old?.revision ?? 0) + 1),
              ),
            );
      case SyncEntityType.todoTag:
        throw StateError('Relations are materialized separately.');
    }
  }

  Future<void> _applyRelationMetadata(
    SyncOperation operation,
    DateTime now,
  ) async {
    if (operation.entityType != SyncEntityType.todoTag) return;
    if (operation.operationType == SyncOperationType.relationAdd) {
      await _database
          .into(_database.syncRelationDots)
          .insert(
            SyncRelationDotsCompanion.insert(
              syncGroupId: operation.syncGroupId,
              todoId: operation.payload['todoId'] as String,
              tagId: operation.payload['tagId'] as String,
              addOperationId: operation.operationId,
              addedByDeviceId: operation.sourceDeviceId,
              addedSequence: operation.sequence,
              createdAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return;
    }
    final observed = (operation.payload['observedAddOperationIds'] as List)
        .cast<String>();
    if (observed.isEmpty) return;
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

  Future<void> _materializeRelation(
    InMemorySyncReplica replica,
    _RelationKey relation,
  ) async {
    final membership = replica.todoTagMembership(
      relation.todoId,
      relation.tagId,
    );
    if (membership?.isPresent ?? false) {
      await _database
          .into(_database.todoTags)
          .insert(
            TodoTagsCompanion.insert(
              todoId: relation.todoId,
              tagId: relation.tagId,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    } else {
      await (_database.delete(_database.todoTags)..where(
            (row) =>
                row.todoId.equals(relation.todoId) &
                row.tagId.equals(relation.tagId),
          ))
          .go();
    }
  }

  Future<void> _validateIncomingSequences(
    String groupId,
    List<SyncOperation> operations,
    Set<String> existingOperationIds,
  ) async {
    final bySource = <String, List<SyncOperation>>{};
    for (final operation in operations) {
      bySource.putIfAbsent(operation.sourceDeviceId, () => []).add(operation);
    }
    for (final entry in bySource.entries) {
      entry.value.sort(
        (left, right) => left.sequence.compareTo(right.sequence),
      );
      final maximumSequence = _database.syncChanges.sequence.max();
      final maximumRow =
          await (_database.selectOnly(_database.syncChanges)
                ..addColumns([maximumSequence])
                ..where(
                  _database.syncChanges.syncGroupId.equals(groupId) &
                      _database.syncChanges.sourceDeviceId.equals(entry.key),
                ))
              .getSingle();
      var sequence = maximumRow.read(maximumSequence) ?? 0;
      for (final operation in entry.value) {
        if (existingOperationIds.contains(operation.operationId)) continue;
        if (operation.sequence != sequence + 1) {
          throw const SyncProtocolException(
            SyncErrorCode.sequenceGap,
            'Incoming operations contain a source sequence gap.',
          );
        }
        sequence = operation.sequence;
      }
    }
  }

  Future<void> _observeRemoteClocks(
    String localDeviceId,
    List<SyncOperation> operations,
    DateTime now,
  ) async {
    if (operations.isEmpty) return;
    final key = 'sync.hlc.$localDeviceId';
    final state = await (_database.select(
      _database.syncRuntimeStates,
    )..where((row) => row.key.equals(key))).getSingleOrNull();
    HybridTimestamp? initial;
    if (state != null) {
      final value = jsonDecode(state.value);
      if (value is Map<String, dynamic>) {
        initial = HybridTimestamp.fromJson(value);
      }
    }
    final hybridClock = HybridLogicalClock(
      deviceId: localDeviceId,
      wallClockMillisUtc: () => now.millisecondsSinceEpoch,
      initial: initial,
    );
    for (final operation in operations) {
      hybridClock.receive(operation.timestamp);
    }
    await _database
        .into(_database.syncRuntimeStates)
        .insertOnConflictUpdate(
          SyncRuntimeStatesCompanion.insert(
            key: key,
            value: jsonEncode(hybridClock.current.toJson()),
            updatedAt: now,
          ),
        );
  }

  Future<void> _insertDevice(
    String groupId,
    SyncDeviceRegistration device,
    DateTime now,
  ) {
    return _database
        .into(_database.syncDevices)
        .insertOnConflictUpdate(
          SyncDevicesCompanion.insert(
            deviceId: device.deviceId,
            syncGroupId: groupId,
            displayName: device.displayName.trim(),
            note: Value(device.note?.trim()),
            platform: device.platform.trim(),
            appVersion: device.appVersion.trim(),
            protocolVersion: SyncProtocol.version,
            publicKey: device.publicKey,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  void _validateDevice(SyncDeviceRegistration device) {
    if ([
      device.deviceId,
      device.displayName,
      device.platform,
      device.appVersion,
      device.publicKey,
    ].any((value) => value.trim().isEmpty)) {
      throw ArgumentError('Sync device fields must not be blank.');
    }
  }

  Future<SyncDeviceRow> _requireActiveDevice(
    String deviceId,
    String groupId,
  ) async {
    final row =
        await (_database.select(_database.syncDevices)..where(
              (candidate) =>
                  candidate.deviceId.equals(deviceId) &
                  candidate.syncGroupId.equals(groupId),
            ))
            .getSingleOrNull();
    if (row == null) {
      throw const SyncProtocolException(
        SyncErrorCode.unauthorized,
        'The source device is not registered.',
      );
    }
    if (row.revokedAt != null) {
      throw const SyncProtocolException(
        SyncErrorCode.deviceRevoked,
        'The source device has been revoked.',
      );
    }
    return row;
  }

  Future<SyncGroupIdentity> _requireIdentity() async {
    final identity = await activeIdentity();
    if (identity == null) throw StateError('Sync is not enabled.');
    return identity;
  }

  Future<SyncCursor> _currentCursor(String groupId) async {
    final maximumSequence = _database.syncChanges.sequence.max();
    final rows =
        await (_database.selectOnly(_database.syncChanges)
              ..addColumns([
                _database.syncChanges.sourceDeviceId,
                maximumSequence,
              ])
              ..where(_database.syncChanges.syncGroupId.equals(groupId))
              ..groupBy([_database.syncChanges.sourceDeviceId]))
            .get();
    final sequences = <String, int>{};
    for (final row in rows) {
      final sourceDeviceId = row.read(_database.syncChanges.sourceDeviceId);
      final sequence = row.read(maximumSequence);
      if (sourceDeviceId != null && sequence != null) {
        sequences[sourceDeviceId] = sequence;
      }
    }
    return SyncCursor(sequences);
  }

  Future<List<SyncChangeRow>> _changesForAffectedEntities(
    String groupId,
    Set<_EntityKey> affected,
    Set<_RelationKey> affectedRelations,
  ) async {
    Expression<bool>? affectedPredicate;
    final idsByType = <SyncEntityType, Set<String>>{};
    for (final key in affected) {
      idsByType.putIfAbsent(key.type, () => <String>{}).add(key.id);
    }
    for (final entry in idsByType.entries) {
      final typePredicate =
          _database.syncChanges.entityType.equals(entry.key.wireName) &
          _database.syncChanges.entityId.isIn(entry.value);
      affectedPredicate = affectedPredicate == null
          ? typePredicate
          : affectedPredicate | typePredicate;
    }
    if (affectedRelations.isNotEmpty) {
      final relationIds = affectedRelations
          .map((relation) => '${relation.todoId}:${relation.tagId}')
          .toSet();
      final relationPredicate =
          _database.syncChanges.entityType.equals(
            SyncEntityType.todoTag.wireName,
          ) &
          _database.syncChanges.entityId.isIn(relationIds);
      affectedPredicate = affectedPredicate == null
          ? relationPredicate
          : affectedPredicate | relationPredicate;
    }
    if (affectedPredicate == null) return const [];
    return (_database.select(
          _database.syncChanges,
        )..where((row) => row.syncGroupId.equals(groupId) & affectedPredicate!))
        .get();
  }

  List<List<SyncChangeRow>> _transactionsInOrder(List<SyncChangeRow> rows) {
    final byTransaction = <String, List<SyncChangeRow>>{};
    final order = <String>[];
    for (final row in rows) {
      if (!byTransaction.containsKey(row.transactionId)) {
        byTransaction[row.transactionId] = [];
        order.add(row.transactionId);
      }
      byTransaction[row.transactionId]!.add(row);
    }
    return order.map((id) => byTransaction[id]!).toList(growable: false);
  }

  SyncGroupRole _role(String value) => switch (value) {
    'host' => SyncGroupRole.host,
    'client' => SyncGroupRole.client,
    _ => throw StateError('Unknown sync group role: $value'),
  };

  PendingSyncChange _deletion(
    SyncEntityType type,
    String id,
    DateTime deletedAt,
  ) => PendingSyncChange(
    entityType: type,
    entityId: id,
    operationType: SyncOperationType.delete,
    fieldGroup: SyncFieldGroup.deletion,
    payload: SyncEntityPayloads.deletion(deletedAt),
  );

  Map<String, dynamic> _todoContentFromRow(TodoRow row) => {
    'title': row.title,
    'localDate': row.localDate,
    'createdAtUtc': row.createdAt.toUtc().toIso8601String(),
    'plannedAtUtc': row.plannedAt?.toUtc().toIso8601String(),
    'priority': row.priority,
    'categoryId': row.categoryId,
    'notes': row.notes,
    'deadlineAtUtc': row.deadlineAt?.toUtc().toIso8601String(),
    'timeZoneId': row.timeZoneId,
    'recurrenceSeriesId': row.recurrenceSeriesId,
    'occurrenceDate': row.occurrenceDate,
  };

  int _entityApplyOrder(SyncEntityType type) => switch (type) {
    SyncEntityType.category => 0,
    SyncEntityType.tag => 1,
    SyncEntityType.recurrenceSeries => 2,
    SyncEntityType.todo => 3,
    SyncEntityType.recurrenceException => 4,
    SyncEntityType.todoTag => 5,
  };

  SyncConflict _conflictFromRow(SyncConflictRow row) => SyncConflict(
    id: row.id,
    kind: SyncConflictKind.values.byName(row.kind),
    entityType: SyncEntityType.values.firstWhere(
      (value) => value.wireName == row.entityType,
    ),
    entityId: row.entityId,
    fieldGroup: SyncFieldGroup.values.firstWhere(
      (value) => value.wireName == row.fieldGroup,
    ),
    winnerOperationId: row.winnerOperationId,
    loserOperationId: row.loserOperationId,
    losingPayload: (jsonDecode(row.losingPayloadJson) as Map).cast(),
  );

  String _canonical(SyncOperation operation) =>
      jsonEncode(_sortedJson(operation.toJson()));

  Object? _sortedJson(Object? value) {
    if (value is Map) {
      final keys = value.keys.cast<String>().toList()..sort();
      return {for (final key in keys) key: _sortedJson(value[key])};
    }
    if (value is List) return value.map(_sortedJson).toList();
    return value;
  }

  String _string(Map<String, dynamic> values, String key) {
    final value = values[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$key must be a non-empty string.');
    }
    return value;
  }

  String? _nullableString(Map<String, dynamic> values, String key) {
    final value = values[key];
    if (value == null) return null;
    if (value is! String) throw FormatException('$key must be a string.');
    return value;
  }

  int _integer(Map<String, dynamic> values, String key) {
    final value = values[key];
    if (value is! int) throw FormatException('$key must be an integer.');
    return value;
  }

  bool _boolean(Map<String, dynamic>? values, String key) {
    final value = values?[key];
    if (value == null && key == 'isCompleted') return false;
    if (value is! bool) throw FormatException('$key must be a boolean.');
    return value;
  }

  double _number(
    Map<String, dynamic>? values,
    String key, {
    required double fallback,
  }) {
    final value = values?[key];
    if (value == null) return fallback;
    if (value is! num || !value.isFinite) {
      throw FormatException('$key must be a finite number.');
    }
    return value.toDouble();
  }

  DateTime _date(Object? value, String key) {
    final parsed = value is String ? DateTime.tryParse(value) : null;
    if (parsed == null || !parsed.isUtc) {
      throw FormatException('$key must be a UTC date-time.');
    }
    return parsed;
  }

  DateTime? _nullableDate(Object? value) =>
      value == null ? null : _date(value, 'date-time');
}

final class _EntityKey {
  const _EntityKey(this.type, this.id);

  final SyncEntityType type;
  final String id;

  @override
  bool operator ==(Object other) =>
      other is _EntityKey && other.type == type && other.id == id;

  @override
  int get hashCode => Object.hash(type, id);
}

final class _RelationKey {
  const _RelationKey(this.todoId, this.tagId);

  final String todoId;
  final String tagId;

  @override
  bool operator ==(Object other) =>
      other is _RelationKey && other.todoId == todoId && other.tagId == tagId;

  @override
  int get hashCode => Object.hash(todoId, tagId);
}
