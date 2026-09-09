import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
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
import 'package:echoday/src/features/sync/security/sync_security_audit.dart';
import 'package:echoday/src/features/sync/security/sync_session_manager.dart';
import 'package:echoday/src/features/sync/server/secure_sync_host_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'HTTPS host pairs, authenticates, rejects replay, and releases its port',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      var now = DateTime.utc(2026, 9, 9, 10);
      final hostIdentity = await DeviceIdentityStore(MemoryDeviceSecretStore())
          .loadOrCreate(() => 'host-device');
      final sync = LocalSyncRepository(database, clock: () => now);
      await sync.initializeHost(
        groupId: 'private-group-id',
        localDevice: SyncDeviceRegistration(
          deviceId: hostIdentity.deviceId,
          displayName: 'Host PC',
          platform: 'windows',
          appVersion: '1.0.0',
          publicKey: hostIdentity.publicKeyBase64Url,
        ),
      );
      final sessions = SyncSessionManager(
        publicKeyForDevice: (id) => activeDevicePublicKey(database, id),
        clock: () => now,
      );
      final securityEvents = <SyncSecurityEvent>[];
      final service = SecureSyncHostService(
        database: database,
        syncRepository: sync,
        tlsIdentityStore: HostTlsIdentityStore(MemoryDeviceSecretStore()),
        sessions: sessions,
        clock: () => now,
        eventPollTimeout: const Duration(milliseconds: 20),
        securityEventSink: securityEvents.add,
      );
      final binding = await service.start(
        address: InternetAddress.loopbackIPv4,
      );
      addTearDown(service.stop);
      expect(service.lifecycle, SyncHostLifecycle.running);

      final client = HttpClient()
        ..badCertificateCallback = (certificate, _, _) =>
            sha256.convert(certificate.der).toString() ==
            binding.fingerprintSha256;
      addTearDown(() => client.close(force: true));

      final info = await _request(client, binding, 'GET', '/v1/info');
      expect(info.status, 200);
      expect(info.text, isNot(contains('private-group-id')));
      expect(info.text.toLowerCase(), isNot(contains('todo')));

      final unauthorized = await _request(
        client,
        binding,
        'POST',
        '/v1/sync/pull',
        body: {'cursor': <String, int>{}},
      );
      expect(unauthorized.status, 401);

      final oversizedJson = utf8.encode(
        jsonEncode({
          'deviceId': 'unknown',
          'padding': 'x' * (SyncProtocol.maximumStringLength + 1),
        }),
      );
      final oversized = await _requestBytes(
        client,
        binding,
        'POST',
        '/v1/session/challenge',
        gzip.encode(oversizedJson),
        headers: {HttpHeaders.contentEncodingHeader: 'gzip'},
      );
      expect(oversized.status, 413);

      final bombClient = HttpClient()
        ..badCertificateCallback = (certificate, _, _) =>
            sha256.convert(certificate.der).toString() ==
            binding.fingerprintSha256;
      try {
        final decompressedLimit = await _requestBytes(
          bombClient,
          binding,
          'POST',
          '/v1/session/challenge',
          gzip.encode(
            utf8.encode('x' * (SyncProtocol.maximumDecompressedBytes + 1)),
          ),
          headers: {HttpHeaders.contentEncodingHeader: 'gzip'},
        );
        expect(decompressedLimit.status, 413);
      } on HttpException {
        // Closing the connection is also an acceptable hard rejection when
        // the decompressed stream crosses the byte limit mid-upload.
      } finally {
        bombClient.close(force: true);
      }

      Object deepJson = true;
      for (var depth = 0; depth <= SyncProtocol.maximumJsonDepth; depth++) {
        deepJson = {'value': deepJson};
      }
      final excessiveDepth = await _requestBytes(
        client,
        binding,
        'POST',
        '/v1/session/challenge',
        utf8.encode(jsonEncode(deepJson)),
      );
      expect(excessiveDepth.status, 413);

      final invalidUtf8 = await _requestBytes(
        client,
        binding,
        'POST',
        '/v1/session/challenge',
        const [0xff, 0xfe],
      );
      expect(invalidUtf8.status, 400);

      final invite = await service.createPairingInvite();
      final clientIdentityStore = DeviceIdentityStore(
        MemoryDeviceSecretStore(),
      );
      final clientIdentity = await clientIdentityStore.loadOrCreate(
        () => 'client-device',
      );
      final nonce = SyncCrypto.randomToken(bytes: 16);
      final device = SyncDeviceRegistration(
        deviceId: clientIdentity.deviceId,
        displayName: 'Phone',
        platform: 'android',
        appVersion: '1.0.0',
        publicKey: clientIdentity.publicKeyBase64Url,
      );
      final unsigned = PairingPrepareRequest(
        inviteId: invite.id,
        inviteToken: invite.token,
        device: device,
        clientNonce: nonce,
        signature: 'pending',
      );
      final prepareSignature = await clientIdentityStore.sign(
        clientIdentity,
        pairingPrepareMessage(unsigned),
      );
      final prepared = await _request(
        client,
        binding,
        'POST',
        '/v1/pair/prepare',
        body: {
          'inviteId': invite.id,
          'inviteToken': invite.token,
          'clientNonce': nonce,
          'signature': prepareSignature,
          'device': {
            'deviceId': device.deviceId,
            'displayName': device.displayName,
            'platform': device.platform,
            'appVersion': device.appVersion,
            'publicKey': device.publicKey,
          },
        },
      );
      expect(prepared.status, 202);
      final requestId = prepared.json['requestId'] as String;
      expect(
        prepared.json['verificationCode'],
        service.pendingPairingRequests.single.verificationCode,
      );
      await service.approvePairing(requestId);
      final poll = await _request(
        client,
        binding,
        'POST',
        '/v1/pair/status',
        body: {'requestId': requestId, 'clientNonce': nonce},
      );
      expect(poll.status, 200);
      expect(poll.json['syncGroupId'], 'private-group-id');
      expect(
        (poll.json['hostDevice'] as Map<String, dynamic>)['deviceId'],
        hostIdentity.deviceId,
      );
      final sessionToken = poll.json['sessionToken'] as String;
      final repeatedPoll = await _request(
        client,
        binding,
        'POST',
        '/v1/pair/status',
        body: {'requestId': requestId, 'clientNonce': nonce},
      );
      expect(repeatedPoll.json['sessionToken'], sessionToken);

      final pullBody = utf8.encode(jsonEncode({'cursor': <String, int>{}}));
      final timestamp = now.millisecondsSinceEpoch.toString();
      final requestNonce = SyncCrypto.randomToken(bytes: 16);
      final pullSignature = await clientIdentityStore.sign(
        clientIdentity,
        requestSignatureMessage(
          method: 'POST',
          path: '/v1/sync/pull',
          timestamp: timestamp,
          nonce: requestNonce,
          bodyBytes: pullBody,
        ),
      );
      final headers = {
        HttpHeaders.authorizationHeader: 'EchoDay $sessionToken',
        'x-echoday-device': clientIdentity.deviceId,
        'x-echoday-timestamp': timestamp,
        'x-echoday-nonce': requestNonce,
        'x-echoday-signature': pullSignature,
      };
      final pull = await _requestBytes(
        client,
        binding,
        'POST',
        '/v1/sync/pull',
        pullBody,
        headers: headers,
      );
      expect(pull.status, 200);
      expect(pull.json['operations'], isA<List<dynamic>>());

      final replay = await _requestBytes(
        client,
        binding,
        'POST',
        '/v1/sync/pull',
        pullBody,
        headers: headers,
      );
      expect(replay.status, 401);

      Future<Map<String, String>> freshHeaders(
        List<int> body, {
        required String path,
      }) async {
        final freshNonce = SyncCrypto.randomToken(bytes: 16);
        final signature = await clientIdentityStore.sign(
          clientIdentity,
          requestSignatureMessage(
            method: 'POST',
            path: path,
            timestamp: timestamp,
            nonce: freshNonce,
            bodyBytes: body,
          ),
        );
        return {
          HttpHeaders.authorizationHeader: 'EchoDay $sessionToken',
          'x-echoday-device': clientIdentity.deviceId,
          'x-echoday-timestamp': timestamp,
          'x-echoday-nonce': freshNonce,
          'x-echoday-signature': signature,
          'x-echoday-app-version': '1.0.2',
        };
      }

      final incompatibleBody = utf8.encode(
        jsonEncode({
          'protocolVersion': SyncProtocol.version + 1,
          'schemaVersion': SyncProtocol.targetDatabaseSchemaVersion,
          'syncGroupId': 'private-group-id',
          'senderDeviceId': clientIdentity.deviceId,
          'cursor': <String, int>{},
          'operations': <Object>[],
        }),
      );
      final incompatible = await _requestBytes(
        client,
        binding,
        'POST',
        '/v1/sync/push',
        incompatibleBody,
        headers: await freshHeaders(incompatibleBody, path: '/v1/sync/push'),
      );
      expect(incompatible.status, 426);

      await service.requestDeviceSync(clientIdentity.deviceId);
      expect(service.requestedSyncDeviceIds, contains(clientIdentity.deviceId));
      final eventBody = utf8.encode(jsonEncode({'cursor': <String, int>{}}));
      final event = await _requestBytes(
        client,
        binding,
        'POST',
        '/v1/sync/events',
        eventBody,
        headers: await freshHeaders(eventBody, path: '/v1/sync/events'),
      );
      expect(event.status, 200);
      expect(event.json['syncRequested'], isTrue);

      final ackBody = utf8.encode(jsonEncode({'cursor': <String, int>{}}));
      final ack = await _requestBytes(
        client,
        binding,
        'POST',
        '/v1/sync/ack',
        ackBody,
        headers: await freshHeaders(ackBody, path: '/v1/sync/ack'),
      );
      expect(ack.status, 200);
      expect(service.requestedSyncDeviceIds, isEmpty);
      expect(service.onlineDeviceIds, contains(clientIdentity.deviceId));
      final syncedDevice =
          await (database.select(database.syncDevices)
                ..where((row) => row.deviceId.equals(clientIdentity.deviceId)))
              .getSingle();
      expect(syncedDevice.lastSeenAt?.toUtc(), now);
      expect(syncedDevice.appVersion, '1.0.2');

      await service.revokeDevice(clientIdentity.deviceId);
      final revokedNonce = SyncCrypto.randomToken(bytes: 16);
      final revokedSignature = await clientIdentityStore.sign(
        clientIdentity,
        requestSignatureMessage(
          method: 'POST',
          path: '/v1/sync/pull',
          timestamp: timestamp,
          nonce: revokedNonce,
          bodyBytes: pullBody,
        ),
      );
      final revoked = await _requestBytes(
        client,
        binding,
        'POST',
        '/v1/sync/pull',
        pullBody,
        headers: {
          HttpHeaders.authorizationHeader: 'EchoDay $sessionToken',
          'x-echoday-device': clientIdentity.deviceId,
          'x-echoday-timestamp': timestamp,
          'x-echoday-nonce': revokedNonce,
          'x-echoday-signature': revokedSignature,
        },
      );
      expect(revoked.status, 401);
      final safeAuditText = securityEvents.join('\n');
      expect(safeAuditText, contains('replayRejected'));
      expect(safeAuditText, contains('protocolRejected'));
      expect(safeAuditText, isNot(contains('private-group-id')));
      expect(safeAuditText, isNot(contains(sessionToken)));
      expect(safeAuditText, isNot(contains(clientIdentity.deviceId)));

      now = now.add(
        SecureSyncHostService.deviceOnlineGracePeriod +
            const Duration(seconds: 1),
      );
      expect(service.onlineDeviceIds, isNot(contains(clientIdentity.deviceId)));

      final unpinnedClient = HttpClient()
        ..badCertificateCallback = (_, _, _) => false;
      await expectLater(
        _request(unpinnedClient, binding, 'GET', '/v1/info'),
        throwsA(isA<HandshakeException>()),
      );
      unpinnedClient.close(force: true);

      final port = binding.port;
      await service.stop();
      expect(service.lifecycle, SyncHostLifecycle.stopped);
      expect(sessions.activeSessionCount, 0);
      await expectLater(
        Socket.connect(InternetAddress.loopbackIPv4, port),
        throwsA(isA<SocketException>()),
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test('host rejects binding directly to a public interface', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final sync = LocalSyncRepository(database);
    final service = SecureSyncHostService(
      database: database,
      syncRepository: sync,
      tlsIdentityStore: HostTlsIdentityStore(MemoryDeviceSecretStore()),
      sessions: SyncSessionManager(publicKeyForDevice: (_) async => null),
    );
    await expectLater(
      service.start(address: InternetAddress('8.8.8.8')),
      throwsArgumentError,
    );
  });
}

Future<_Response> _request(
  HttpClient client,
  SyncHostBinding binding,
  String method,
  String path, {
  Map<String, dynamic>? body,
  Map<String, String> headers = const {},
}) => _requestBytes(
  client,
  binding,
  method,
  path,
  body == null ? const [] : utf8.encode(jsonEncode(body)),
  headers: headers,
);

Future<_Response> _requestBytes(
  HttpClient client,
  SyncHostBinding binding,
  String method,
  String path,
  List<int> body, {
  Map<String, String> headers = const {},
}) async {
  final request = await client.openUrl(method, binding.endpoint.resolve(path));
  request.headers.contentType = ContentType.json;
  headers.forEach(request.headers.set);
  if (body.isNotEmpty) request.add(body);
  final response = await request.close();
  final text = await utf8.decodeStream(response);
  return _Response(response.statusCode, text);
}

final class _Response {
  const _Response(this.status, this.text);
  final int status;
  final String text;
  Map<String, dynamic> get json =>
      (jsonDecode(text) as Map).cast<String, dynamic>();
}
