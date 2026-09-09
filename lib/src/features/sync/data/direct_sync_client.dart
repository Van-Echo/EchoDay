import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import '../domain/sync_client_models.dart';
import '../domain/sync_protocol.dart';
import '../domain/sync_repository.dart';
import '../security/device_identity.dart';
import '../security/sync_crypto.dart';
import '../security/sync_pairing_service.dart';
import '../security/sync_session_manager.dart';

final class ClientPairingStart {
  const ClientPairingStart({
    required this.requestId,
    required this.clientNonce,
    required this.verificationCode,
    required this.expiresAt,
  });

  final String requestId;
  final String clientNonce;
  final String verificationCode;
  final DateTime expiresAt;
}

final class ClientPairingStatus {
  const ClientPairingStatus({
    required this.state,
    this.sessionToken,
    this.sessionExpiresAt,
    this.groupId,
    this.hostDevice,
  });

  final PairingPollState state;
  final String? sessionToken;
  final DateTime? sessionExpiresAt;
  final String? groupId;
  final SyncDeviceRegistration? hostDevice;
}

final class SyncPushReceipt {
  const SyncPushReceipt({
    required this.acknowledgedCursor,
    required this.conflictCount,
  });

  final SyncCursor acknowledgedCursor;
  final int conflictCount;
}

final class SyncRemoteException implements Exception {
  const SyncRemoteException(this.code, this.statusCode);

  final String code;
  final int statusCode;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'SyncRemoteException($code, $statusCode)';
}

/// Transport boundary kept independent from the controller so lifecycle and
/// queue behavior can be verified without a real socket.
abstract interface class SyncClientTransport {
  void close();

  Future<void> verifyHost();

  Future<ClientPairingStart> preparePairing({
    required SyncPairingEndpoint endpoint,
    required SyncDeviceRegistration device,
  });

  Future<ClientPairingStatus> pollPairing(ClientPairingStart start);

  Future<String> openSession();

  Future<List<SyncDeviceRegistration>> devices(String sessionToken);

  Future<SyncPushReceipt> push(SyncBatch batch, String sessionToken);

  Future<SyncBatch> pull(
    SyncCursor cursor,
    String sessionToken, {
    bool snapshot = false,
  });

  Future<void> acknowledge(SyncCursor cursor, String sessionToken);
}

/// Direct HTTPS transport with certificate pinning and signed requests.
final class DirectSyncClient implements SyncClientTransport {
  DirectSyncClient({
    required this.baseUri,
    required String fingerprintSha256,
    required this.identity,
    required this.identityStore,
    Duration timeout = const Duration(seconds: 15),
  }) : fingerprintSha256 = fingerprintSha256.toLowerCase(),
       _timeout = timeout,
       _http = HttpClient(context: SecurityContext(withTrustedRoots: false)) {
    _http.badCertificateCallback = (certificate, _, _) =>
        sha256.convert(certificate.der).toString() == this.fingerprintSha256;
    _http.connectionTimeout = timeout;
  }

  final Uri baseUri;
  final String fingerprintSha256;
  final DeviceIdentity identity;
  final DeviceIdentityStore identityStore;
  final Duration _timeout;
  final HttpClient _http;

  @override
  void close() => _http.close(force: true);

  @override
  Future<void> verifyHost() async {
    final response = await _request('GET', '/v1/info', const []);
    final json = _decodeObject(response.body);
    if (response.statusCode != 200) _throwRemote(response, json);
    if (json['protocolVersion'] != SyncProtocol.version ||
        json['schemaVersion'] != SyncProtocol.targetDatabaseSchemaVersion) {
      throw const SyncRemoteException('protocol_incompatible', 426);
    }
    if ((json['fingerprintSha256'] as String?)?.toLowerCase() !=
        fingerprintSha256) {
      throw const SyncRemoteException('fingerprint_mismatch', 495);
    }
  }

  @override
  Future<ClientPairingStart> preparePairing({
    required SyncPairingEndpoint endpoint,
    required SyncDeviceRegistration device,
  }) async {
    final nonce = SyncCrypto.randomToken();
    final unsigned = PairingPrepareRequest(
      inviteId: endpoint.inviteId,
      inviteToken: endpoint.inviteToken,
      device: device,
      clientNonce: nonce,
      signature: '',
    );
    final signature = await identityStore.sign(
      identity,
      pairingPrepareMessage(unsigned),
    );
    final response = await _post('/v1/pair/prepare', {
      'inviteId': endpoint.inviteId,
      'inviteToken': endpoint.inviteToken,
      'device': _deviceJson(device),
      'clientNonce': nonce,
      'signature': signature,
    });
    final json = _decodeObject(response.body);
    if (response.statusCode != 202) _throwRemote(response, json);
    return ClientPairingStart(
      requestId: _string(json, 'requestId'),
      clientNonce: nonce,
      verificationCode: _string(json, 'verificationCode'),
      expiresAt: _utc(json, 'expiresAtUtc'),
    );
  }

  @override
  Future<ClientPairingStatus> pollPairing(ClientPairingStart start) async {
    final response = await _post('/v1/pair/status', {
      'requestId': start.requestId,
      'clientNonce': start.clientNonce,
    });
    final json = _decodeObject(response.body);
    if (response.statusCode != 200) _throwRemote(response, json);
    final state = PairingPollState.values.firstWhere(
      (value) => value.name == json['state'],
      orElse: () => throw const FormatException('Unknown pairing state.'),
    );
    if (state != PairingPollState.approved) {
      return ClientPairingStatus(state: state);
    }
    return ClientPairingStatus(
      state: state,
      sessionToken: _string(json, 'sessionToken'),
      sessionExpiresAt: _utc(json, 'sessionExpiresAtUtc'),
      groupId: _string(json, 'syncGroupId'),
      hostDevice: _deviceFromJson(_object(json, 'hostDevice')),
    );
  }

  @override
  Future<String> openSession() async {
    final challengeResponse = await _post('/v1/session/challenge', {
      'deviceId': identity.deviceId,
    });
    final challengeJson = _decodeObject(challengeResponse.body);
    if (challengeResponse.statusCode != 200) {
      _throwRemote(challengeResponse, challengeJson);
    }
    final challengeId = _string(challengeJson, 'challengeId');
    final challenge = _string(challengeJson, 'challenge');
    final signature = await identityStore.sign(
      identity,
      sessionChallengeMessage(
        deviceId: identity.deviceId,
        challengeId: challengeId,
        challenge: challenge,
      ),
    );
    final response = await _post('/v1/session/open', {
      'deviceId': identity.deviceId,
      'challengeId': challengeId,
      'signature': signature,
    });
    final json = _decodeObject(response.body);
    if (response.statusCode != 200) _throwRemote(response, json);
    return _string(json, 'sessionToken');
  }

  @override
  Future<List<SyncDeviceRegistration>> devices(String sessionToken) async {
    final json = await _signedJson('/v1/sync/devices', {}, sessionToken);
    final values = json['devices'];
    if (values is! List) throw const FormatException('Invalid device list.');
    return values
        .map((value) {
          if (value is! Map<String, dynamic>) {
            throw const FormatException('Invalid device entry.');
          }
          return _deviceFromJson(value);
        })
        .toList(growable: false);
  }

  @override
  Future<SyncPushReceipt> push(SyncBatch batch, String sessionToken) async {
    final body = SyncProtocolCodec.encodeBatch(batch);
    final json = await _signedRaw('/v1/sync/push', body, sessionToken);
    return SyncPushReceipt(
      acknowledgedCursor: SyncCursor.fromJson(
        _object(json, 'acknowledgedCursor'),
      ),
      conflictCount: _integer(json, 'conflictCount'),
    );
  }

  @override
  Future<SyncBatch> pull(
    SyncCursor cursor,
    String sessionToken, {
    bool snapshot = false,
  }) async {
    final json = await _signedJson(
      snapshot ? '/v1/sync/snapshot' : '/v1/sync/pull',
      {
        'cursor': cursor.toJson(),
        'maximumOperations': SyncProtocol.maximumBatchOperations,
      },
      sessionToken,
    );
    return SyncProtocolCodec.decodeBatch(jsonEncode(json));
  }

  @override
  Future<void> acknowledge(SyncCursor cursor, String sessionToken) async {
    await _signedJson('/v1/sync/ack', {
      'cursor': cursor.toJson(),
    }, sessionToken);
  }

  Future<Map<String, dynamic>> _signedJson(
    String path,
    Map<String, dynamic> value,
    String sessionToken,
  ) => _signedRaw(path, jsonEncode(value), sessionToken);

  Future<Map<String, dynamic>> _signedRaw(
    String path,
    String source,
    String sessionToken,
  ) async {
    final body = utf8.encode(source);
    final timestamp = '${DateTime.now().toUtc().millisecondsSinceEpoch}';
    final nonce = SyncCrypto.randomToken(bytes: 16);
    final signature = await identityStore.sign(
      identity,
      requestSignatureMessage(
        method: 'POST',
        path: path,
        timestamp: timestamp,
        nonce: nonce,
        bodyBytes: body,
      ),
    );
    final response = await _request(
      'POST',
      path,
      body,
      headers: {
        HttpHeaders.authorizationHeader: 'EchoDay $sessionToken',
        'x-echoday-device': identity.deviceId,
        'x-echoday-timestamp': timestamp,
        'x-echoday-nonce': nonce,
        'x-echoday-signature': signature,
      },
    );
    final json = _decodeObject(response.body);
    if (response.statusCode != 200) _throwRemote(response, json);
    return json;
  }

  Future<_ClientResponse> _post(String path, Map<String, dynamic> value) =>
      _request('POST', path, utf8.encode(jsonEncode(value)));

  Future<_ClientResponse> _request(
    String method,
    String path,
    List<int> body, {
    Map<String, String> headers = const {},
  }) async {
    try {
      final request = await _http
          .openUrl(method, baseUri.replace(path: path))
          .timeout(_timeout);
      request.headers.contentType = ContentType.json;
      headers.forEach(request.headers.set);
      if (body.isNotEmpty) request.add(body);
      final response = await request.close().timeout(_timeout);
      final bytes = <int>[];
      await for (final chunk in response.timeout(_timeout)) {
        bytes.addAll(chunk);
        if (bytes.length > SyncProtocol.maximumDecompressedBytes) {
          throw const SyncRemoteException('payload_too_large', 413);
        }
      }
      return _ClientResponse(response.statusCode, utf8.decode(bytes));
    } on HandshakeException {
      throw const SyncRemoteException('fingerprint_mismatch', 495);
    }
  }

  static Map<String, dynamic> _deviceJson(SyncDeviceRegistration device) => {
    'deviceId': device.deviceId,
    'displayName': device.displayName,
    'platform': device.platform,
    'appVersion': device.appVersion,
    'publicKey': device.publicKey,
    'note': ?device.note,
  };

  static SyncDeviceRegistration _deviceFromJson(Map<String, dynamic> json) =>
      SyncDeviceRegistration(
        deviceId: _string(json, 'deviceId'),
        displayName: _string(json, 'displayName'),
        platform: _string(json, 'platform'),
        appVersion: _string(json, 'appVersion'),
        publicKey: _string(json, 'publicKey'),
        note: json['note'] as String?,
      );

  static Map<String, dynamic> _decodeObject(String source) {
    final decoded = source.isEmpty ? <String, dynamic>{} : jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Response must be a JSON object.');
    }
    return decoded;
  }

  static Never _throwRemote(
    _ClientResponse response,
    Map<String, dynamic> json,
  ) => throw SyncRemoteException(
    json['error'] is String ? json['error'] as String : 'network_error',
    response.statusCode,
  );

  static String _string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$key is invalid.');
    }
    return value;
  }

  static int _integer(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! int) throw FormatException('$key is invalid.');
    return value;
  }

  static DateTime _utc(Map<String, dynamic> json, String key) {
    final parsed = DateTime.tryParse(_string(json, key));
    if (parsed == null) throw FormatException('$key is invalid.');
    return parsed.toUtc();
  }

  static Map<String, dynamic> _object(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! Map<String, dynamic>) {
      throw FormatException('$key is invalid.');
    }
    return value;
  }
}

final class _ClientResponse {
  const _ClientResponse(this.statusCode, this.body);

  final int statusCode;
  final String body;
}
