import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/sync/data/local_sync_repository.dart';
import 'package:echoday/src/features/sync/domain/sync_protocol.dart';
import 'package:echoday/src/features/sync/domain/sync_repository.dart';
import 'package:echoday/src/features/sync/security/device_identity.dart';
import 'package:echoday/src/features/sync/security/device_secret_store.dart';
import 'package:echoday/src/features/sync/security/host_tls_identity.dart';
import 'package:echoday/src/features/sync/security/sync_crypto.dart';
import 'package:echoday/src/features/sync/security/sync_pairing_service.dart';
import 'package:echoday/src/features/sync/security/sync_session_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'TLS and device identities are generated once and remain usable',
    () async {
      final secrets = MemoryDeviceSecretStore();
      final tlsStore = HostTlsIdentityStore(secrets);
      final firstTls = await tlsStore.loadOrCreate();
      final secondTls = await tlsStore.loadOrCreate();
      expect(secondTls.fingerprintSha256, firstTls.fingerprintSha256);
      expect(firstTls.fingerprintSha256, hasLength(64));
      SecurityContext(withTrustedRoots: false)
        ..useCertificateChainBytes(utf8.encode(firstTls.certificatePem))
        ..usePrivateKeyBytes(utf8.encode(firstTls.privateKeyPem));

      final identityStore = DeviceIdentityStore(secrets);
      final identity = await identityStore.loadOrCreate(() => 'device-a');
      final restored = await identityStore.loadOrCreate(() => 'never-used');
      expect(restored.deviceId, identity.deviceId);
      final signature = await identityStore.sign(identity, 'proof');
      expect(
        await SyncCrypto.verifyEd25519(
          publicKeyBase64Url: identity.publicKeyBase64Url,
          signatureBase64Url: signature,
          message: 'proof',
        ),
        isTrue,
      );
    },
  );

  test('sessions reject nonce replay and stale signed requests', () async {
    var now = DateTime.utc(2026, 9, 9, 10);
    final identityStore = DeviceIdentityStore(MemoryDeviceSecretStore());
    final identity = await identityStore.loadOrCreate(() => 'device-a');
    final sessions = SyncSessionManager(
      publicKeyForDevice: (id) async =>
          id == identity.deviceId ? identity.publicKeyBase64Url : null,
      clock: () => now,
    );
    final challenge = sessions.createChallenge(identity.deviceId);
    final challengeSignature = await identityStore.sign(
      identity,
      sessionChallengeMessage(
        deviceId: identity.deviceId,
        challengeId: challenge.id,
        challenge: challenge.challenge,
      ),
    );
    final session = await sessions.openSession(
      deviceId: identity.deviceId,
      challengeId: challenge.id,
      signature: challengeSignature,
    );
    final body = utf8.encode('{}');
    final timestamp = now.millisecondsSinceEpoch.toString();
    final nonce = SyncCrypto.randomToken(bytes: 16);
    final requestSignature = await identityStore.sign(
      identity,
      requestSignatureMessage(
        method: 'POST',
        path: '/v1/sync/pull',
        timestamp: timestamp,
        nonce: nonce,
        bodyBytes: body,
      ),
    );
    expect(
      await sessions.authenticate(
        authorization: 'EchoDay ${session.token}',
        deviceId: identity.deviceId,
        timestamp: timestamp,
        nonce: nonce,
        signature: requestSignature,
        method: 'POST',
        path: '/v1/sync/pull',
        bodyBytes: body,
      ),
      identity.deviceId,
    );
    await expectLater(
      sessions.authenticate(
        authorization: 'EchoDay ${session.token}',
        deviceId: identity.deviceId,
        timestamp: timestamp,
        nonce: nonce,
        signature: requestSignature,
        method: 'POST',
        path: '/v1/sync/pull',
        bodyBytes: body,
      ),
      throwsA(
        isA<SyncProtocolException>().having(
          (error) => error.code,
          'code',
          SyncErrorCode.replayDetected,
        ),
      ),
    );

    now = now.add(const Duration(minutes: 6));
    final staleNonce = SyncCrypto.randomToken(bytes: 16);
    final staleSignature = await identityStore.sign(
      identity,
      requestSignatureMessage(
        method: 'POST',
        path: '/v1/sync/pull',
        timestamp: timestamp,
        nonce: staleNonce,
        bodyBytes: body,
      ),
    );
    await expectLater(
      sessions.authenticate(
        authorization: 'EchoDay ${session.token}',
        deviceId: identity.deviceId,
        timestamp: timestamp,
        nonce: staleNonce,
        signature: staleSignature,
        method: 'POST',
        path: '/v1/sync/pull',
        bodyBytes: body,
      ),
      throwsA(isA<SyncProtocolException>()),
    );
  });

  test(
    'pairing requires proof, manual approval, and a one-time invite',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final hostIdentity = await DeviceIdentityStore(MemoryDeviceSecretStore())
          .loadOrCreate(() => 'host-device');
      final sync = LocalSyncRepository(database, clock: _fixedNow);
      await sync.initializeHost(
        groupId: 'group-a',
        localDevice: SyncDeviceRegistration(
          deviceId: hostIdentity.deviceId,
          displayName: 'Host',
          platform: 'windows',
          appVersion: '1.0.0',
          publicKey: hostIdentity.publicKeyBase64Url,
        ),
      );
      final sessions = SyncSessionManager(
        publicKeyForDevice: (id) async {
          final row =
              await (database.select(database.syncDevices)..where(
                    (device) =>
                        device.deviceId.equals(id) & device.revokedAt.isNull(),
                  ))
                  .getSingleOrNull();
          return row?.publicKey;
        },
        clock: _fixedNow,
      );
      final pairing = SyncPairingService(
        database: database,
        syncRepository: sync,
        sessions: sessions,
        hostFingerprint: 'host-fingerprint',
        clock: _fixedNow,
        maximumAttempts: 2,
      );
      final invite = await pairing.createInvite();
      final clientStore = DeviceIdentityStore(MemoryDeviceSecretStore());
      final clientIdentity = await clientStore.loadOrCreate(
        () => 'client-device',
      );
      final unsigned = PairingPrepareRequest(
        inviteId: invite.id,
        inviteToken: invite.token,
        device: SyncDeviceRegistration(
          deviceId: clientIdentity.deviceId,
          displayName: 'Phone',
          platform: 'android',
          appVersion: '1.0.0',
          publicKey: clientIdentity.publicKeyBase64Url,
        ),
        clientNonce: SyncCrypto.randomToken(bytes: 16),
        signature: 'pending',
      );
      final request = PairingPrepareRequest(
        inviteId: unsigned.inviteId,
        inviteToken: unsigned.inviteToken,
        device: unsigned.device,
        clientNonce: unsigned.clientNonce,
        signature: await clientStore.sign(
          clientIdentity,
          pairingPrepareMessage(unsigned),
        ),
      );
      final pending = await pairing.prepare(request);
      expect(pending.verificationCode, matches(RegExp(r'^\d{6}$')));
      expect(pairing.pendingRequests.single.id, pending.id);
      expect(
        pairing
            .poll(requestId: pending.id, clientNonce: request.clientNonce)
            .state,
        PairingPollState.pending,
      );
      await pairing.approve(pending.id);
      final approved = pairing.poll(
        requestId: pending.id,
        clientNonce: request.clientNonce,
      );
      expect(approved.state, PairingPollState.approved);
      expect(approved.session?.token, isNotEmpty);
      expect(await database.select(database.syncDevices).get(), hasLength(2));
      final storedInvite = await database
          .select(database.syncPairingInvites)
          .getSingle();
      expect(storedInvite.consumedAt, isNotNull);
    },
  );

  test('pairing invitations expire and stop after failed attempts', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    var now = DateTime.utc(2026, 9, 9, 10);
    final hostIdentity = await DeviceIdentityStore(MemoryDeviceSecretStore())
        .loadOrCreate(() => 'host-device');
    final sync = LocalSyncRepository(database, clock: () => now);
    await sync.initializeHost(
      groupId: 'group-a',
      localDevice: SyncDeviceRegistration(
        deviceId: hostIdentity.deviceId,
        displayName: 'Host',
        platform: 'windows',
        appVersion: '1.0.0',
        publicKey: hostIdentity.publicKeyBase64Url,
      ),
    );
    final pairing = SyncPairingService(
      database: database,
      syncRepository: sync,
      sessions: SyncSessionManager(publicKeyForDevice: (_) async => null),
      hostFingerprint: 'host-fingerprint',
      clock: () => now,
      maximumAttempts: 2,
    );
    final clientStore = DeviceIdentityStore(MemoryDeviceSecretStore());
    final client = await clientStore.loadOrCreate(() => 'client-device');

    Future<PairingPrepareRequest> signedRequest(
      SyncPairingInvite invite,
      String token,
    ) async {
      final unsigned = PairingPrepareRequest(
        inviteId: invite.id,
        inviteToken: token,
        device: SyncDeviceRegistration(
          deviceId: client.deviceId,
          displayName: 'Phone',
          platform: 'android',
          appVersion: '1.0.0',
          publicKey: client.publicKeyBase64Url,
        ),
        clientNonce: SyncCrypto.randomToken(bytes: 16),
        signature: 'pending',
      );
      return PairingPrepareRequest(
        inviteId: unsigned.inviteId,
        inviteToken: unsigned.inviteToken,
        device: unsigned.device,
        clientNonce: unsigned.clientNonce,
        signature: await clientStore.sign(
          client,
          pairingPrepareMessage(unsigned),
        ),
      );
    }

    final expiredInvite = await pairing.createInvite();
    final expiredRequest = await signedRequest(
      expiredInvite,
      expiredInvite.token,
    );
    now = now.add(const Duration(minutes: 6));
    await expectLater(
      pairing.prepare(expiredRequest),
      throwsA(
        isA<SyncProtocolException>().having(
          (error) => error.code,
          'code',
          SyncErrorCode.inviteExpired,
        ),
      ),
    );

    final blockedInvite = await pairing.createInvite();
    final wrongRequest = await signedRequest(blockedInvite, 'wrong-token');
    for (var attempt = 0; attempt < 2; attempt++) {
      await expectLater(
        pairing.prepare(wrongRequest),
        throwsA(
          isA<SyncProtocolException>().having(
            (error) => error.code,
            'code',
            SyncErrorCode.unauthorized,
          ),
        ),
      );
    }
    await expectLater(
      pairing.prepare(wrongRequest),
      throwsA(
        isA<SyncProtocolException>().having(
          (error) => error.code,
          'code',
          SyncErrorCode.inviteExpired,
        ),
      ),
    );
    final blockedRow = await (database.select(
      database.syncPairingInvites,
    )..where((row) => row.id.equals(blockedInvite.id))).getSingle();
    expect(blockedRow.attemptCount, 2);
    expect(blockedRow.consumedAt, isNotNull);
  });
}

DateTime _fixedNow() => DateTime.utc(2026, 9, 9, 10);
