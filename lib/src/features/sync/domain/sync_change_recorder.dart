import 'sync_protocol.dart';

/// A business mutation waiting to be stamped and appended to the local log.
final class PendingSyncChange {
  PendingSyncChange({
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.fieldGroup,
    required Map<String, dynamic> payload,
  }) : payload = Map.unmodifiable(Map.of(payload));

  final SyncEntityType entityType;
  final String entityId;
  final SyncOperationType operationType;
  final SyncFieldGroup fieldGroup;
  final Map<String, dynamic> payload;
}

/// Appends local mutations to the sync log.
///
/// Implementations return an empty list while this database is not part of an
/// active sync group. Callers can therefore use the recorder on every write
/// path without coupling normal offline use to the sync feature.
abstract interface class SyncChangeRecorder {
  Future<List<SyncOperation>> recordAll(Iterable<PendingSyncChange> changes);

  Future<List<String>> activeRelationAddOperationIds({
    required String todoId,
    required String tagId,
  });
}

final class DisabledSyncChangeRecorder implements SyncChangeRecorder {
  const DisabledSyncChangeRecorder();

  @override
  Future<List<String>> activeRelationAddOperationIds({
    required String todoId,
    required String tagId,
  }) async => const [];

  @override
  Future<List<SyncOperation>> recordAll(
    Iterable<PendingSyncChange> changes,
  ) async => const [];
}
