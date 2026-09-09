import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../../data/database/app_database.dart';
import '../domain/sync_protocol.dart';
import '../domain/sync_repository.dart';
import '../security/host_tls_identity.dart';
import '../security/sync_pairing_service.dart';
import '../security/sync_security_audit.dart';
import '../security/sync_session_manager.dart';
import 'sync_network_discovery.dart';

enum SyncHostLifecycle { stopped, starting, running, stopping, failed }

final class SyncHostBinding {
  const SyncHostBinding({
    required this.address,
    required this.port,
    required this.fingerprintSha256,
  });

  final InternetAddress address;
  final int port;
  final String fingerprintSha256;

  Uri get endpoint => Uri(scheme: 'https', host: address.address, port: port);
}

final class SecureSyncHostService {
  factory SecureSyncHostService({
    required AppDatabase database,
    required SyncRepository syncRepository,
    required HostTlsIdentityStore tlsIdentityStore,
    required SyncSessionManager sessions,
    IdGenerator idGenerator = const UuidV7Generator(),
    UtcClock clock = systemUtcClock,
    int maximumConcurrentRequests = 16,
    Duration requestTimeout = const Duration(seconds: 15),
    Duration eventPollTimeout = const Duration(seconds: 20),
    SyncSecurityEventSink securityEventSink = ignoreSyncSecurityEvent,
  }) => SecureSyncHostService._(
    database,
    syncRepository,
    tlsIdentityStore,
    sessions,
    idGenerator,
    clock,
    maximumConcurrentRequests,
    requestTimeout,
    eventPollTimeout,
    securityEventSink,
  );

  SecureSyncHostService._(
    this._database,
    this._syncRepository,
    this._tlsIdentityStore,
    this._sessions,
    this._ids,
    this._clock,
    this.maximumConcurrentRequests,
    this.requestTimeout,
    this.eventPollTimeout,
    this._securityEvents,
  );

  static const _maximumBodyBytes = SyncProtocol.maximumDecompressedBytes;
  static const _deviceHeader = 'x-echoday-device';
  static const _timestampHeader = 'x-echoday-timestamp';
  static const _nonceHeader = 'x-echoday-nonce';
  static const _signatureHeader = 'x-echoday-signature';

  final AppDatabase _database;
  final SyncRepository _syncRepository;
  final HostTlsIdentityStore _tlsIdentityStore;
  final SyncSessionManager _sessions;
  final IdGenerator _ids;
  final UtcClock _clock;
  final int maximumConcurrentRequests;
  final Duration requestTimeout;
  final Duration eventPollTimeout;
  final SyncSecurityEventSink _securityEvents;
  HttpServer? _server;
  StreamSubscription<HttpRequest>? _subscription;
  SyncPairingService? _pairing;
  SyncHostBinding? _binding;
  SyncHostLifecycle _lifecycle = SyncHostLifecycle.stopped;
  SyncHostStartFailureCode? _lastStartFailure;
  int _activeRequests = 0;
  final Map<String, int> _activeDeviceRequests = {};
  final Set<String> _requestedSyncDevices = {};

  SyncHostLifecycle get lifecycle => _lifecycle;
  SyncHostStartFailureCode? get lastStartFailure => _lastStartFailure;
  SyncHostBinding? get binding => _binding;
  SyncPairingService? get pairing => _pairing;
  Set<String> get onlineDeviceIds => Set.unmodifiable(
    _activeDeviceRequests.entries
        .where((entry) => entry.value > 0)
        .map((entry) => entry.key),
  );
  Set<String> get requestedSyncDeviceIds =>
      Set.unmodifiable(_requestedSyncDevices);

  Future<SyncHostBinding> start({
    required InternetAddress address,
    int port = 0,
  }) async {
    if (_server != null || _lifecycle != SyncHostLifecycle.stopped) {
      throw StateError('Sync host is already running or changing state.');
    }
    if (SyncNetworkDiscovery.classify(address) == null) {
      throw ArgumentError.value(
        address.address,
        'address',
        'must be a loopback, LAN, or Tailscale address',
      );
    }
    if (port < 0 || port > 65535) {
      throw ArgumentError.value(port, 'port');
    }
    final identity = await _syncRepository.activeIdentity();
    if (identity == null || identity.role != SyncGroupRole.host) {
      throw StateError('An active host sync group is required.');
    }
    _lifecycle = SyncHostLifecycle.starting;
    _lastStartFailure = null;
    try {
      final tls = await _tlsIdentityStore.loadOrCreate();
      final context = SecurityContext(withTrustedRoots: false)
        ..useCertificateChainBytes(utf8.encode(tls.certificatePem))
        ..usePrivateKeyBytes(utf8.encode(tls.privateKeyPem));
      final server = await HttpServer.bindSecure(
        address,
        port,
        context,
        shared: false,
      );
      server.idleTimeout = const Duration(seconds: 30);
      _server = server;
      _pairing = SyncPairingService(
        database: _database,
        syncRepository: _syncRepository,
        sessions: _sessions,
        hostFingerprint: tls.fingerprintSha256,
        idGenerator: _ids,
        clock: _clock,
      );
      _binding = SyncHostBinding(
        address: address,
        port: server.port,
        fingerprintSha256: tls.fingerprintSha256,
      );
      _subscription = server.listen(
        _dispatch,
        onError: (_) {
          if (_lifecycle == SyncHostLifecycle.running) {
            _lifecycle = SyncHostLifecycle.failed;
          }
        },
      );
      _lifecycle = SyncHostLifecycle.running;
      return _binding!;
    } on SocketException catch (error) {
      final failure = SyncHostStartException.fromSocket(error);
      _server = null;
      _binding = null;
      _pairing = null;
      _lastStartFailure = failure.code;
      _lifecycle = SyncHostLifecycle.stopped;
      throw failure;
    } on Object {
      _server = null;
      _binding = null;
      _pairing = null;
      _lifecycle = SyncHostLifecycle.stopped;
      rethrow;
    }
  }

  Future<void> stop() async {
    final server = _server;
    if (server == null) {
      _lifecycle = SyncHostLifecycle.stopped;
      _sessions.clear();
      _pairing?.clearEphemeralState();
      return;
    }
    _lifecycle = SyncHostLifecycle.stopping;
    _pairing?.clearEphemeralState();
    _sessions.clear();
    _activeDeviceRequests.clear();
    _requestedSyncDevices.clear();
    _server = null;
    _binding = null;
    _pairing = null;
    await server.close(force: true);
    await _subscription?.cancel();
    _subscription = null;
    _lifecycle = SyncHostLifecycle.stopped;
  }

  Future<SyncPairingInvite> createPairingInvite() {
    final service = _pairing;
    if (service == null) throw StateError('Sync host is not running.');
    return service.createInvite();
  }

  List<PendingPairingRequest> get pendingPairingRequests =>
      _pairing?.pendingRequests ?? const [];

  Future<void> approvePairing(String requestId) {
    final service = _pairing;
    if (service == null) throw StateError('Sync host is not running.');
    return service.approve(requestId);
  }

  Future<void> rejectPairing(String requestId) {
    final service = _pairing;
    if (service == null) throw StateError('Sync host is not running.');
    return service.reject(requestId);
  }

  Future<void> revokeDevice(String deviceId) async {
    final identity = await _syncRepository.activeIdentity();
    if (identity == null || deviceId == identity.localDeviceId) {
      throw ArgumentError('The local host device cannot be revoked.');
    }
    final now = requireUtc(_clock(), 'clock');
    final updated =
        await (_database.update(_database.syncDevices)..where(
              (row) =>
                  row.syncGroupId.equals(identity.groupId) &
                  row.deviceId.equals(deviceId) &
                  row.revokedAt.isNull(),
            ))
            .write(
              SyncDevicesCompanion(
                revokedAt: Value(now),
                updatedAt: Value(now),
              ),
            );
    if (updated == 0) throw StateError('Device is missing or already revoked.');
    _sessions.revokeDevice(deviceId);
    _requestedSyncDevices.remove(deviceId);
  }

  Future<void> requestDeviceSync(String deviceId) async {
    final identity = await _syncRepository.activeIdentity();
    if (identity == null || identity.role != SyncGroupRole.host) {
      throw StateError('An active host sync group is required.');
    }
    final device =
        await (_database.select(_database.syncDevices)..where(
              (row) =>
                  row.syncGroupId.equals(identity.groupId) &
                  row.deviceId.equals(deviceId) &
                  row.revokedAt.isNull(),
            ))
            .getSingleOrNull();
    if (device == null || device.deviceId == identity.localDeviceId) {
      throw StateError('An active client device is required.');
    }
    _requestedSyncDevices.add(deviceId);
  }

  Future<int> requestAllDeviceSyncs() async {
    final identity = await _syncRepository.activeIdentity();
    if (identity == null || identity.role != SyncGroupRole.host) {
      throw StateError('An active host sync group is required.');
    }
    final devices =
        await (_database.select(_database.syncDevices)..where(
              (row) =>
                  row.syncGroupId.equals(identity.groupId) &
                  row.deviceId.equals(identity.localDeviceId).not() &
                  row.revokedAt.isNull(),
            ))
            .get();
    _requestedSyncDevices.addAll(devices.map((device) => device.deviceId));
    return devices.length;
  }

  void _dispatch(HttpRequest request) {
    if (_activeRequests >= maximumConcurrentRequests) {
      unawaited(_jsonError(request.response, 429, 'rate_limited'));
      return;
    }
    _activeRequests++;
    unawaited(
      _handle(request).whenComplete(() {
        _activeRequests--;
      }),
    );
  }

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    String? authenticatedDevice;
    response.headers
      ..set(HttpHeaders.cacheControlHeader, 'no-store')
      ..set('x-content-type-options', 'nosniff');
    try {
      final path = request.uri.path;
      if (request.method == 'GET' && path == '/v1/info') {
        await _json(response, 200, {
          'protocolVersion': SyncProtocol.version,
          'schemaVersion': SyncProtocol.targetDatabaseSchemaVersion,
          'service': 'EchoDay',
          'fingerprintSha256': _binding!.fingerprintSha256,
        });
        return;
      }
      final body = await _readBody(request);
      if (request.method == 'POST' && path == '/v1/pair/prepare') {
        final json = _decodeObject(body);
        final pending = await _pairing!.prepare(_prepareRequest(json));
        await _json(response, 202, {
          'requestId': pending.id,
          'verificationCode': pending.verificationCode,
          'expiresAtUtc': pending.expiresAt.toIso8601String(),
        });
        return;
      }
      if (request.method == 'POST' && path == '/v1/pair/status') {
        final json = _decodeObject(body);
        final result = _pairing!.poll(
          requestId: _string(json, 'requestId'),
          clientNonce: _string(json, 'clientNonce'),
        );
        final identity = result.state == PairingPollState.approved
            ? await _syncRepository.activeIdentity()
            : null;
        final hostDevice = identity == null
            ? null
            : await (_database.select(_database.syncDevices)..where(
                    (row) => row.deviceId.equals(identity.localDeviceId),
                  ))
                  .getSingleOrNull();
        await _json(response, 200, {
          'state': result.state.name,
          if (result.session case final session?) ...{
            'sessionToken': session.token,
            'sessionExpiresAtUtc': session.expiresAt.toIso8601String(),
          },
          if (identity != null && hostDevice != null) ...{
            'syncGroupId': identity.groupId,
            'hostDevice': _deviceJson(hostDevice),
          },
        });
        return;
      }
      if (request.method == 'POST' && path == '/v1/session/challenge') {
        final json = _decodeObject(body);
        final challenge = _sessions.createChallenge(_string(json, 'deviceId'));
        await _json(response, 200, {
          'challengeId': challenge.id,
          'challenge': challenge.challenge,
          'expiresAtUtc': challenge.expiresAt.toIso8601String(),
        });
        return;
      }
      if (request.method == 'POST' && path == '/v1/session/open') {
        final json = _decodeObject(body);
        final session = await _sessions.openSession(
          deviceId: _string(json, 'deviceId'),
          challengeId: _string(json, 'challengeId'),
          signature: _string(json, 'signature'),
        );
        await _json(response, 200, {
          'sessionToken': session.token,
          'sessionExpiresAtUtc': session.expiresAt.toIso8601String(),
        });
        return;
      }
      authenticatedDevice = await _authenticate(request, body);
      _activeDeviceRequests.update(
        authenticatedDevice,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
      if (request.method == 'POST' && path == '/v1/sync/devices') {
        final identity = await _syncRepository.activeIdentity();
        if (identity == null) {
          throw const SyncProtocolException(
            SyncErrorCode.unauthorized,
            'The sync group is unavailable.',
          );
        }
        final devices =
            await (_database.select(_database.syncDevices)..where(
                  (row) =>
                      row.syncGroupId.equals(identity.groupId) &
                      row.revokedAt.isNull(),
                ))
                .get();
        await _json(response, 200, {
          'devices': devices.map(_deviceJson).toList(growable: false),
        });
        return;
      }
      if (request.method == 'POST' && path == '/v1/sync/push') {
        final batch = SyncProtocolCodec.decodeBatch(utf8.decode(body));
        if (batch.senderDeviceId != authenticatedDevice) {
          throw const SyncProtocolException(
            SyncErrorCode.unauthorized,
            'Batch sender does not match the authenticated device.',
          );
        }
        final result = await _syncRepository.applyBatch(batch);
        await _json(response, 200, {
          'insertedOperations': result.insertedOperations,
          'duplicateOperations': result.duplicateOperations,
          'conflictCount': result.conflicts.length,
          'acknowledgedCursor': result.acknowledgedCursor.toJson(),
        });
        return;
      }
      if (request.method == 'POST' &&
          (path == '/v1/sync/pull' || path == '/v1/sync/snapshot')) {
        final json = _decodeObject(body);
        final cursor = path == '/v1/sync/snapshot'
            ? SyncCursor()
            : SyncCursor.fromJson(_object(json, 'cursor'));
        final limit =
            json['maximumOperations'] as int? ??
            SyncProtocol.maximumBatchOperations;
        final batch = await _syncRepository.changesAfter(
          cursor,
          maximumOperations: limit,
        );
        await _rawJson(response, 200, SyncProtocolCodec.encodeBatch(batch));
        return;
      }
      if (request.method == 'POST' && path == '/v1/sync/ack') {
        final json = _decodeObject(body);
        await _syncRepository.acknowledge(
          authenticatedDevice,
          SyncCursor.fromJson(_object(json, 'cursor')),
        );
        final now = requireUtc(_clock(), 'clock');
        await (_database.update(_database.syncDevices)
              ..where((row) => row.deviceId.equals(authenticatedDevice!)))
            .write(SyncDevicesCompanion(lastSeenAt: Value(now)));
        _requestedSyncDevices.remove(authenticatedDevice);
        await _json(response, 200, {'acknowledged': true});
        return;
      }
      if (request.method == 'POST' && path == '/v1/sync/events') {
        final json = _decodeObject(body);
        final cursor = SyncCursor.fromJson(_object(json, 'cursor'));
        final event = await _waitForChanges(cursor, authenticatedDevice);
        await _json(response, 200, {
          'hasChanges': event.cursor != cursor,
          'syncRequested': event.syncRequested,
          'cursor': event.cursor.toJson(),
        });
        return;
      }
      await _jsonError(response, 404, 'not_found');
    } on SyncProtocolException catch (error) {
      _securityEvents(
        SyncSecurityEvent.rejected(
          errorCode: error.code,
          occurredAtUtc: _clock(),
          deviceId: request.headers.value(_deviceHeader),
        ),
      );
      await _jsonError(response, _statusFor(error.code), error.code.wireName);
    } on _RequestTooLarge {
      await _jsonError(response, 413, SyncErrorCode.payloadTooLarge.wireName);
    } on FormatException {
      await _jsonError(response, 400, SyncErrorCode.invalidRequest.wireName);
    } on TypeError {
      await _jsonError(response, 400, SyncErrorCode.invalidRequest.wireName);
    } on ArgumentError {
      await _jsonError(response, 400, SyncErrorCode.invalidRequest.wireName);
    } on TimeoutException {
      await _jsonError(response, 408, 'request_timeout');
    } on Object {
      await _jsonError(response, 500, SyncErrorCode.internal.wireName);
    } finally {
      if (authenticatedDevice case final device?) {
        final remaining = (_activeDeviceRequests[device] ?? 1) - 1;
        if (remaining <= 0) {
          _activeDeviceRequests.remove(device);
        } else {
          _activeDeviceRequests[device] = remaining;
        }
      }
    }
  }

  Future<List<int>> _readBody(HttpRequest request) async {
    final length = request.contentLength;
    if (length > _maximumBodyBytes) throw const _RequestTooLarge();
    Stream<List<int>> stream = request;
    final encoding = request.headers.value(HttpHeaders.contentEncodingHeader);
    if (encoding != null && encoding.isNotEmpty) {
      if (encoding.toLowerCase() != 'gzip') {
        throw const FormatException('Unsupported content encoding.');
      }
      stream = gzip.decoder.bind(stream);
    }
    final bytes = <int>[];
    await for (final chunk in stream.timeout(requestTimeout)) {
      if (bytes.length + chunk.length > _maximumBodyBytes) {
        throw const _RequestTooLarge();
      }
      bytes.addAll(chunk);
    }
    return bytes;
  }

  Future<String> _authenticate(HttpRequest request, List<int> body) {
    String requiredHeader(String name) {
      final value = request.headers.value(name);
      if (value == null || value.isEmpty) {
        throw const SyncProtocolException(
          SyncErrorCode.unauthorized,
          'Authentication header is missing.',
        );
      }
      return value;
    }

    return _sessions.authenticate(
      authorization: requiredHeader(HttpHeaders.authorizationHeader),
      deviceId: requiredHeader(_deviceHeader),
      timestamp: requiredHeader(_timestampHeader),
      nonce: requiredHeader(_nonceHeader),
      signature: requiredHeader(_signatureHeader),
      method: request.method,
      path: request.uri.path,
      bodyBytes: body,
    );
  }

  Future<({SyncCursor cursor, bool syncRequested})> _waitForChanges(
    SyncCursor cursor,
    String deviceId,
  ) async {
    final deadline = DateTime.now().add(eventPollTimeout);
    while (DateTime.now().isBefore(deadline)) {
      final current = await _syncRepository.currentCursor();
      final requested = _requestedSyncDevices.contains(deviceId);
      if (current != cursor || requested) {
        return (cursor: current, syncRequested: requested);
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    return (
      cursor: await _syncRepository.currentCursor(),
      syncRequested: _requestedSyncDevices.contains(deviceId),
    );
  }

  PairingPrepareRequest _prepareRequest(Map<String, dynamic> json) {
    final device = _object(json, 'device');
    return PairingPrepareRequest(
      inviteId: _string(json, 'inviteId'),
      inviteToken: _string(json, 'inviteToken'),
      device: SyncDeviceRegistration(
        deviceId: _string(device, 'deviceId'),
        displayName: _string(device, 'displayName'),
        platform: _string(device, 'platform'),
        appVersion: _string(device, 'appVersion'),
        publicKey: _string(device, 'publicKey'),
        note: device['note'] as String?,
      ),
      clientNonce: _string(json, 'clientNonce'),
      signature: _string(json, 'signature'),
    );
  }

  Map<String, dynamic> _deviceJson(SyncDeviceRow device) => {
    'deviceId': device.deviceId,
    'displayName': device.displayName,
    'platform': device.platform,
    'appVersion': device.appVersion,
    'publicKey': device.publicKey,
    'note': ?device.note,
  };

  Map<String, dynamic> _decodeObject(List<int> bytes) {
    if (bytes.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON root must be an object.');
    }
    _validateJson(decoded, 0);
    return decoded;
  }

  void _validateJson(Object? value, int depth) {
    if (depth > SyncProtocol.maximumJsonDepth) {
      throw const _RequestTooLarge();
    }
    switch (value) {
      case null || bool() || num():
        return;
      case String():
        if (value.length > SyncProtocol.maximumStringLength) {
          throw const _RequestTooLarge();
        }
      case List():
        for (final child in value) {
          _validateJson(child, depth + 1);
        }
      case Map():
        for (final entry in value.entries) {
          if (entry.key is! String) throw const FormatException('Invalid key.');
          _validateJson(entry.value, depth + 1);
        }
      default:
        throw const FormatException('Unsupported JSON value.');
    }
  }

  String _string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$key must be a non-empty string.');
    }
    return value;
  }

  Map<String, dynamic> _object(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! Map<String, dynamic>) {
      throw FormatException('$key must be an object.');
    }
    return value;
  }

  Future<void> _json(
    HttpResponse response,
    int status,
    Map<String, dynamic> body,
  ) => _rawJson(response, status, jsonEncode(body));

  Future<void> _jsonError(HttpResponse response, int status, String code) =>
      _json(response, status, {'error': code});

  Future<void> _rawJson(HttpResponse response, int status, String body) async {
    response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(body);
    await response.close();
  }

  int _statusFor(SyncErrorCode code) => switch (code) {
    SyncErrorCode.unauthorized ||
    SyncErrorCode.deviceRevoked ||
    SyncErrorCode.replayDetected => 401,
    SyncErrorCode.inviteExpired => 410,
    SyncErrorCode.payloadTooLarge || SyncErrorCode.batchTooLarge => 413,
    SyncErrorCode.protocolIncompatible ||
    SyncErrorCode.schemaIncompatible => 426,
    SyncErrorCode.sequenceGap || SyncErrorCode.conflict => 409,
    SyncErrorCode.invalidRequest || SyncErrorCode.validationFailed => 400,
    SyncErrorCode.internal => 500,
  };
}

Future<String?> activeDevicePublicKey(
  AppDatabase database,
  String deviceId,
) async {
  final row =
      await (database.select(database.syncDevices)..where(
            (candidate) =>
                candidate.deviceId.equals(deviceId) &
                candidate.revokedAt.isNull(),
          ))
          .getSingleOrNull();
  return row?.publicKey;
}

final class _RequestTooLarge implements Exception {
  const _RequestTooLarge();
}
