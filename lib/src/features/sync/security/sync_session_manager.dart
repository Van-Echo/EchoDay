import '../domain/sync_protocol.dart';
import 'sync_crypto.dart';

typedef DevicePublicKeyResolver = Future<String?> Function(String deviceId);

final class IssuedSyncSession {
  const IssuedSyncSession({required this.token, required this.expiresAt});

  final String token;
  final DateTime expiresAt;
}

final class SyncSessionChallenge {
  const SyncSessionChallenge({
    required this.id,
    required this.challenge,
    required this.expiresAt,
  });

  final String id;
  final String challenge;
  final DateTime expiresAt;
}

final class SyncSessionManager {
  SyncSessionManager({
    required this.publicKeyForDevice,
    DateTime Function()? clock,
    this.sessionLifetime = const Duration(hours: 12),
    this.challengeLifetime = const Duration(minutes: 2),
    this.maximumClockSkew = const Duration(minutes: 5),
    this.nonceLifetime = const Duration(minutes: 10),
  }) : _clock = clock ?? DateTime.now;

  final DevicePublicKeyResolver publicKeyForDevice;
  final DateTime Function() _clock;
  final Duration sessionLifetime;
  final Duration challengeLifetime;
  final Duration maximumClockSkew;
  final Duration nonceLifetime;
  final Map<String, _SessionRecord> _sessionsByHash = {};
  final Map<String, _ChallengeRecord> _challenges = {};
  final Map<String, DateTime> _usedNonces = {};

  int get activeSessionCount {
    _purge();
    return _sessionsByHash.length;
  }

  IssuedSyncSession issue(String deviceId) {
    _purge();
    final token = SyncCrypto.randomToken();
    final expiresAt = _now().add(sessionLifetime);
    _sessionsByHash[SyncCrypto.sha256Text(token)] = _SessionRecord(
      deviceId,
      expiresAt,
    );
    return IssuedSyncSession(token: token, expiresAt: expiresAt);
  }

  SyncSessionChallenge createChallenge(String deviceId) {
    _purge();
    final id = SyncCrypto.randomToken(bytes: 24);
    final challenge = SyncCrypto.randomToken();
    final expiresAt = _now().add(challengeLifetime);
    _challenges[id] = _ChallengeRecord(deviceId, challenge, expiresAt);
    return SyncSessionChallenge(
      id: id,
      challenge: challenge,
      expiresAt: expiresAt,
    );
  }

  Future<IssuedSyncSession> openSession({
    required String deviceId,
    required String challengeId,
    required String signature,
  }) async {
    _purge();
    final challenge = _challenges.remove(challengeId);
    if (challenge == null || challenge.deviceId != deviceId) {
      throw const SyncProtocolException(
        SyncErrorCode.unauthorized,
        'Session challenge is invalid or expired.',
      );
    }
    final publicKey = await publicKeyForDevice(deviceId);
    if (publicKey == null ||
        !await SyncCrypto.verifyEd25519(
          publicKeyBase64Url: publicKey,
          signatureBase64Url: signature,
          message: sessionChallengeMessage(
            deviceId: deviceId,
            challengeId: challengeId,
            challenge: challenge.challenge,
          ),
        )) {
      throw const SyncProtocolException(
        SyncErrorCode.unauthorized,
        'Device authentication failed.',
      );
    }
    return issue(deviceId);
  }

  Future<String> authenticate({
    required String authorization,
    required String deviceId,
    required String timestamp,
    required String nonce,
    required String signature,
    required String method,
    required String path,
    required List<int> bodyBytes,
  }) async {
    _purge();
    const prefix = 'EchoDay ';
    if (!authorization.startsWith(prefix)) {
      throw const SyncProtocolException(
        SyncErrorCode.unauthorized,
        'Authentication is required.',
      );
    }
    final token = authorization.substring(prefix.length);
    final record = _sessionsByHash[SyncCrypto.sha256Text(token)];
    if (record == null || record.deviceId != deviceId) {
      throw const SyncProtocolException(
        SyncErrorCode.unauthorized,
        'Session is invalid or expired.',
      );
    }
    final timestampMillis = int.tryParse(timestamp);
    if (timestampMillis == null) {
      throw const SyncProtocolException(
        SyncErrorCode.unauthorized,
        'Request timestamp is invalid.',
      );
    }
    final requestTime = DateTime.fromMillisecondsSinceEpoch(
      timestampMillis,
      isUtc: true,
    );
    final delta = _now().difference(requestTime).abs();
    if (delta > maximumClockSkew) {
      throw const SyncProtocolException(
        SyncErrorCode.unauthorized,
        'Request timestamp is outside the accepted window.',
      );
    }
    final nonceBytes = SyncCrypto.decodeBase64Url(nonce);
    if (nonceBytes.length < 16 || nonceBytes.length > 64) {
      throw const SyncProtocolException(
        SyncErrorCode.unauthorized,
        'Request nonce is invalid.',
      );
    }
    final nonceKey = '$deviceId:$nonce';
    if (_usedNonces.containsKey(nonceKey)) {
      throw const SyncProtocolException(
        SyncErrorCode.replayDetected,
        'Request nonce was already used.',
      );
    }
    final publicKey = await publicKeyForDevice(deviceId);
    final valid =
        publicKey != null &&
        await SyncCrypto.verifyEd25519(
          publicKeyBase64Url: publicKey,
          signatureBase64Url: signature,
          message: requestSignatureMessage(
            method: method,
            path: path,
            timestamp: timestamp,
            nonce: nonce,
            bodyBytes: bodyBytes,
          ),
        );
    if (!valid) {
      throw const SyncProtocolException(
        SyncErrorCode.unauthorized,
        'Request signature is invalid.',
      );
    }
    _usedNonces[nonceKey] = _now().add(nonceLifetime);
    return deviceId;
  }

  void revokeDevice(String deviceId) {
    _sessionsByHash.removeWhere((_, record) => record.deviceId == deviceId);
    _challenges.removeWhere((_, record) => record.deviceId == deviceId);
    _usedNonces.removeWhere((key, _) => key.startsWith('$deviceId:'));
  }

  void clear() {
    _sessionsByHash.clear();
    _challenges.clear();
    _usedNonces.clear();
  }

  DateTime _now() => _clock().toUtc();

  void _purge() {
    final now = _now();
    _sessionsByHash.removeWhere((_, record) => !record.expiresAt.isAfter(now));
    _challenges.removeWhere((_, record) => !record.expiresAt.isAfter(now));
    _usedNonces.removeWhere((_, expiresAt) => !expiresAt.isAfter(now));
  }
}

String sessionChallengeMessage({
  required String deviceId,
  required String challengeId,
  required String challenge,
}) => 'echoday-session-v1\n$deviceId\n$challengeId\n$challenge';

String requestSignatureMessage({
  required String method,
  required String path,
  required String timestamp,
  required String nonce,
  required List<int> bodyBytes,
}) => [
  'echoday-request-v1',
  method.toUpperCase(),
  path,
  timestamp,
  nonce,
  SyncCrypto.sha256Bytes(bodyBytes),
].join('\n');

final class _SessionRecord {
  const _SessionRecord(this.deviceId, this.expiresAt);
  final String deviceId;
  final DateTime expiresAt;
}

final class _ChallengeRecord {
  const _ChallengeRecord(this.deviceId, this.challenge, this.expiresAt);
  final String deviceId;
  final String challenge;
  final DateTime expiresAt;
}
