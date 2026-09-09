import '../domain/sync_protocol.dart';
import 'sync_crypto.dart';

enum SyncSecurityEventKind {
  authenticationRejected,
  replayRejected,
  protocolRejected,
  requestRejected,
}

/// Deliberately contains no request body, token, key, address, or exception
/// message. Consumers may persist this value without another redaction pass.
final class SyncSecurityEvent {
  const SyncSecurityEvent({
    required this.kind,
    required this.occurredAtUtc,
    required this.errorCode,
    this.deviceHashPrefix,
  });

  factory SyncSecurityEvent.rejected({
    required SyncErrorCode errorCode,
    required DateTime occurredAtUtc,
    String? deviceId,
  }) {
    final kind = switch (errorCode) {
      SyncErrorCode.unauthorized || SyncErrorCode.deviceRevoked =>
        SyncSecurityEventKind.authenticationRejected,
      SyncErrorCode.replayDetected => SyncSecurityEventKind.replayRejected,
      SyncErrorCode.protocolIncompatible || SyncErrorCode.schemaIncompatible =>
        SyncSecurityEventKind.protocolRejected,
      _ => SyncSecurityEventKind.requestRejected,
    };
    return SyncSecurityEvent(
      kind: kind,
      occurredAtUtc: occurredAtUtc.toUtc(),
      errorCode: errorCode,
      deviceHashPrefix: deviceId == null || deviceId.isEmpty
          ? null
          : SyncCrypto.sha256Text(deviceId).substring(0, 12),
    );
  }

  final SyncSecurityEventKind kind;
  final DateTime occurredAtUtc;
  final SyncErrorCode errorCode;
  final String? deviceHashPrefix;

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'occurredAtUtc': occurredAtUtc.toIso8601String(),
    'errorCode': errorCode.wireName,
    'deviceHashPrefix': ?deviceHashPrefix,
  };

  @override
  String toString() => toJson().toString();
}

typedef SyncSecurityEventSink = void Function(SyncSecurityEvent event);

void ignoreSyncSecurityEvent(SyncSecurityEvent event) {}
