import 'sync_merge_engine.dart';
import 'sync_protocol.dart';

enum SyncGroupRole { host, client }

final class SyncGroupIdentity {
  const SyncGroupIdentity({
    required this.groupId,
    required this.localDeviceId,
    required this.role,
  });

  final String groupId;
  final String localDeviceId;
  final SyncGroupRole role;
}

final class SyncDeviceRegistration {
  const SyncDeviceRegistration({
    required this.deviceId,
    required this.displayName,
    required this.platform,
    required this.appVersion,
    required this.publicKey,
    this.note,
  });

  final String deviceId;
  final String displayName;
  final String platform;
  final String appVersion;
  final String publicKey;
  final String? note;
}

final class SyncApplyResult {
  const SyncApplyResult({
    required this.insertedOperations,
    required this.duplicateOperations,
    required this.conflicts,
    required this.acknowledgedCursor,
  });

  final int insertedOperations;
  final int duplicateOperations;
  final List<SyncConflict> conflicts;
  final SyncCursor acknowledgedCursor;
}

abstract interface class SyncRepository {
  Future<SyncGroupIdentity?> activeIdentity();

  Future<SyncGroupIdentity> initializeHost({
    required SyncDeviceRegistration localDevice,
    String? groupId,
  });

  Future<SyncGroupIdentity> initializeClient({
    required String groupId,
    required String hostDeviceId,
    required SyncDeviceRegistration hostDevice,
    required SyncDeviceRegistration localDevice,
  });

  Future<void> registerDevice(SyncDeviceRegistration device);

  Future<SyncBatch> changesAfter(
    SyncCursor cursor, {
    int maximumOperations = SyncProtocol.maximumBatchOperations,
  });

  Future<SyncCursor> currentCursor();

  Future<SyncApplyResult> applyBatch(SyncBatch batch);

  Future<void> acknowledge(String peerDeviceId, SyncCursor cursor);

  Future<List<SyncConflict>> unresolvedConflicts();

  Future<void> resolveConflict(String conflictId);

  /// Removes synchronization metadata while preserving all user entities.
  Future<void> leaveGroup();

  Future<int> compactAcknowledgedChanges({
    Duration safetyWindow = const Duration(days: 30),
  });
}
