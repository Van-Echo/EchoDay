import 'package:drift/drift.dart';

import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../../data/database/app_database.dart';
import '../domain/sync_protocol.dart';
import '../domain/sync_repository.dart';
import 'sync_crypto.dart';
import 'sync_session_manager.dart';

final class SyncPairingInvite {
  const SyncPairingInvite({
    required this.id,
    required this.token,
    required this.hostFingerprint,
    required this.expiresAt,
  });

  final String id;
  final String token;
  final String hostFingerprint;
  final DateTime expiresAt;
}

final class PairingPrepareRequest {
  const PairingPrepareRequest({
    required this.inviteId,
    required this.inviteToken,
    required this.device,
    required this.clientNonce,
    required this.signature,
  });

  final String inviteId;
  final String inviteToken;
  final SyncDeviceRegistration device;
  final String clientNonce;
  final String signature;
}

final class PendingPairingRequest {
  const PendingPairingRequest({
    required this.id,
    required this.inviteId,
    required this.device,
    required this.verificationCode,
    required this.expiresAt,
  });

  final String id;
  final String inviteId;
  final SyncDeviceRegistration device;
  final String verificationCode;
  final DateTime expiresAt;
}

enum PairingPollState { pending, approved, rejected }

final class PairingPollResult {
  const PairingPollResult({required this.state, this.session});

  final PairingPollState state;
  final IssuedSyncSession? session;
}

final class SyncPairingService {
  factory SyncPairingService({
    required AppDatabase database,
    required SyncRepository syncRepository,
    required SyncSessionManager sessions,
    required String hostFingerprint,
    IdGenerator idGenerator = const UuidV7Generator(),
    UtcClock clock = systemUtcClock,
    Duration inviteLifetime = const Duration(minutes: 5),
    int maximumAttempts = 5,
  }) => SyncPairingService._(
    database,
    syncRepository,
    sessions,
    hostFingerprint,
    idGenerator,
    clock,
    inviteLifetime,
    maximumAttempts,
  );

  SyncPairingService._(
    this._database,
    this._syncRepository,
    this._sessions,
    this.hostFingerprint,
    this._ids,
    this._clock,
    this.inviteLifetime,
    this.maximumAttempts,
  );

  final AppDatabase _database;
  final SyncRepository _syncRepository;
  final SyncSessionManager _sessions;
  final IdGenerator _ids;
  final UtcClock _clock;
  final String hostFingerprint;
  final Duration inviteLifetime;
  final int maximumAttempts;
  final Map<String, _PendingPairing> _pending = {};
  final Map<String, String> _requestByInvite = {};

  List<PendingPairingRequest> get pendingRequests {
    _purgePending();
    return _pending.values
        .where((item) => item.state == PairingPollState.pending)
        .map((item) => item.publicValue)
        .toList(growable: false);
  }

  Future<SyncPairingInvite> createInvite() async {
    final identity = await _syncRepository.activeIdentity();
    if (identity == null || identity.role != SyncGroupRole.host) {
      throw StateError('Only an active host can create pairing invites.');
    }
    if (maximumAttempts < 1) {
      throw StateError('maximumAttempts must be positive.');
    }
    final now = requireUtc(_clock(), 'clock');
    final invite = SyncPairingInvite(
      id: _ids.next(),
      token: SyncCrypto.randomToken(),
      hostFingerprint: hostFingerprint,
      expiresAt: now.add(inviteLifetime),
    );
    await _database
        .into(_database.syncPairingInvites)
        .insert(
          SyncPairingInvitesCompanion.insert(
            id: invite.id,
            syncGroupId: identity.groupId,
            tokenHash: SyncCrypto.sha256Text(invite.token),
            hostFingerprint: hostFingerprint,
            expiresAt: invite.expiresAt,
            maximumAttempts: maximumAttempts,
            createdAt: now,
          ),
        );
    return invite;
  }

  Future<PendingPairingRequest> prepare(PairingPrepareRequest request) async {
    _validatePrepareShape(request);
    final now = requireUtc(_clock(), 'clock');
    final invite = await (_database.select(
      _database.syncPairingInvites,
    )..where((row) => row.id.equals(request.inviteId))).getSingleOrNull();
    if (invite == null || invite.consumedAt != null) {
      throw const SyncProtocolException(
        SyncErrorCode.inviteExpired,
        'Pairing invite is unavailable.',
      );
    }
    if (!invite.expiresAt.toUtc().isAfter(now) ||
        invite.attemptCount >= invite.maximumAttempts) {
      throw const SyncProtocolException(
        SyncErrorCode.inviteExpired,
        'Pairing invite has expired.',
      );
    }
    if (_requestByInvite.containsKey(invite.id)) {
      throw const SyncProtocolException(
        SyncErrorCode.validationFailed,
        'Pairing invite is already awaiting confirmation.',
      );
    }

    final tokenMatches = SyncCrypto.constantTimeEquals(
      invite.tokenHash,
      SyncCrypto.sha256Text(request.inviteToken),
    );
    final signatureMatches =
        tokenMatches &&
        await SyncCrypto.verifyEd25519(
          publicKeyBase64Url: request.device.publicKey,
          signatureBase64Url: request.signature,
          message: pairingPrepareMessage(request),
        );
    if (!signatureMatches) {
      await _recordFailedAttempt(invite, now);
      throw const SyncProtocolException(
        SyncErrorCode.unauthorized,
        'Pairing proof is invalid.',
      );
    }
    final existingDevice =
        await (_database.select(_database.syncDevices)
              ..where((row) => row.deviceId.equals(request.device.deviceId)))
            .getSingleOrNull();
    if (existingDevice != null) {
      await _recordFailedAttempt(invite, now);
      throw const SyncProtocolException(
        SyncErrorCode.validationFailed,
        'Device identity is already registered.',
      );
    }

    final requestId = SyncCrypto.randomToken(bytes: 24);
    final verificationCode = _verificationCode(
      request.device.publicKey,
      request.clientNonce,
      requestId,
    );
    final pending = _PendingPairing(
      publicValue: PendingPairingRequest(
        id: requestId,
        inviteId: invite.id,
        device: request.device,
        verificationCode: verificationCode,
        expiresAt: invite.expiresAt.toUtc(),
      ),
      clientNonceHash: SyncCrypto.sha256Text(request.clientNonce),
    );
    _pending[requestId] = pending;
    _requestByInvite[invite.id] = requestId;
    return pending.publicValue;
  }

  Future<void> approve(String requestId) async {
    _purgePending();
    final pending = _pending[requestId];
    if (pending == null || pending.state != PairingPollState.pending) {
      throw StateError('Pairing request is missing or no longer pending.');
    }
    final now = requireUtc(_clock(), 'clock');
    await _database.transaction(() async {
      final invite =
          await (_database.select(_database.syncPairingInvites)
                ..where((row) => row.id.equals(pending.publicValue.inviteId)))
              .getSingleOrNull();
      if (invite == null ||
          invite.consumedAt != null ||
          !invite.expiresAt.toUtc().isAfter(now)) {
        throw StateError('Pairing invite expired before approval.');
      }
      await _syncRepository.registerDevice(pending.publicValue.device);
      await (_database.update(_database.syncPairingInvites)
            ..where((row) => row.id.equals(invite.id)))
          .write(SyncPairingInvitesCompanion(consumedAt: Value(now)));
    });
    pending
      ..state = PairingPollState.approved
      ..session = _sessions.issue(pending.publicValue.device.deviceId);
  }

  Future<void> reject(String requestId) async {
    _purgePending();
    final pending = _pending[requestId];
    if (pending == null || pending.state != PairingPollState.pending) return;
    final now = requireUtc(_clock(), 'clock');
    await (_database.update(_database.syncPairingInvites)
          ..where((row) => row.id.equals(pending.publicValue.inviteId)))
        .write(SyncPairingInvitesCompanion(consumedAt: Value(now)));
    pending.state = PairingPollState.rejected;
  }

  PairingPollResult poll({
    required String requestId,
    required String clientNonce,
  }) {
    _purgePending();
    final pending = _pending[requestId];
    if (pending == null ||
        !SyncCrypto.constantTimeEquals(
          pending.clientNonceHash,
          SyncCrypto.sha256Text(clientNonce),
        )) {
      throw const SyncProtocolException(
        SyncErrorCode.unauthorized,
        'Pairing request is invalid or expired.',
      );
    }
    final result = PairingPollResult(
      state: pending.state,
      session: pending.session,
    );
    // Keep the terminal result until the invite expires. A mobile client may
    // lose the response after approval and must be able to poll again without
    // consuming a second invitation.
    return result;
  }

  void clearEphemeralState() {
    _pending.clear();
    _requestByInvite.clear();
  }

  Future<void> _recordFailedAttempt(
    SyncPairingInviteRow invite,
    DateTime now,
  ) async {
    final next = invite.attemptCount + 1;
    await (_database.update(
      _database.syncPairingInvites,
    )..where((row) => row.id.equals(invite.id))).write(
      SyncPairingInvitesCompanion(
        attemptCount: Value(next),
        consumedAt: next >= invite.maximumAttempts
            ? Value(now)
            : const Value.absent(),
      ),
    );
  }

  void _validatePrepareShape(PairingPrepareRequest request) {
    final values = [
      request.inviteId,
      request.inviteToken,
      request.device.deviceId,
      request.device.displayName,
      request.device.platform,
      request.device.appVersion,
      request.device.publicKey,
      request.clientNonce,
      request.signature,
    ];
    if (values.any(
      (value) =>
          value.trim().isEmpty ||
          value.length > SyncProtocol.maximumIdentifierLength * 4,
    )) {
      throw const SyncProtocolException(
        SyncErrorCode.validationFailed,
        'Pairing request contains an invalid field.',
      );
    }
    if (SyncCrypto.decodeBase64Url(request.clientNonce).length < 16) {
      throw const SyncProtocolException(
        SyncErrorCode.validationFailed,
        'Pairing nonce is too short.',
      );
    }
  }

  String _verificationCode(
    String publicKey,
    String clientNonce,
    String requestId,
  ) {
    final digest = SyncCrypto.sha256Text(
      '$hostFingerprint\n$publicKey\n$clientNonce\n$requestId',
    );
    final value = int.parse(digest.substring(0, 12), radix: 16) % 1000000;
    return value.toString().padLeft(6, '0');
  }

  void _purgePending() {
    final now = requireUtc(_clock(), 'clock');
    final expired = _pending.values
        .where((item) => !item.publicValue.expiresAt.isAfter(now))
        .toList(growable: false);
    for (final item in expired) {
      _pending.remove(item.publicValue.id);
      _requestByInvite.remove(item.publicValue.inviteId);
    }
  }
}

String pairingPrepareMessage(PairingPrepareRequest request) => [
  'echoday-pair-v1',
  request.inviteId,
  SyncCrypto.sha256Text(request.inviteToken),
  request.device.deviceId,
  request.device.displayName,
  request.device.platform,
  request.device.appVersion,
  request.device.publicKey,
  request.clientNonce,
].join('\n');

final class _PendingPairing {
  _PendingPairing({required this.publicValue, required this.clientNonceHash});

  final PendingPairingRequest publicValue;
  final String clientNonceHash;
  PairingPollState state = PairingPollState.pending;
  IssuedSyncSession? session;
}
