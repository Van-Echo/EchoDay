import 'dart:convert';
import 'dart:io';

import '../security/sync_crypto.dart';
import 'sync_protocol.dart';
import 'sync_repository.dart';

final class SyncPairingEndpoint {
  const SyncPairingEndpoint({
    required this.address,
    required this.port,
    required this.groupId,
    required this.fingerprintSha256,
    required this.inviteId,
    required this.inviteToken,
  });

  final String address;
  final int port;
  final String groupId;
  final String fingerprintSha256;
  final String inviteId;
  final String inviteToken;

  Uri get baseUri => Uri(scheme: 'https', host: address, port: port);

  SyncPairingEndpoint copyWith({String? address, int? port}) =>
      SyncPairingEndpoint(
        address: address ?? this.address,
        port: port ?? this.port,
        groupId: groupId,
        fingerprintSha256: fingerprintSha256,
        inviteId: inviteId,
        inviteToken: inviteToken,
      );
}

abstract final class SyncPairingUriCodec {
  static SyncPairingEndpoint parse(String source) {
    if (source.length > 4096) {
      throw const FormatException('Pairing code is too long.');
    }
    final uri = Uri.tryParse(source.trim());
    if (uri == null || uri.scheme != 'echoday' || uri.host != 'pair') {
      throw const FormatException('Not an EchoDay pairing code.');
    }
    final query = uri.queryParameters;
    final version = int.tryParse(query['v'] ?? '');
    final port = int.tryParse(query['port'] ?? '');
    final address = query['host']?.trim() ?? '';
    final groupId = query['group']?.trim() ?? '';
    final fingerprint = query['fingerprint']?.trim().toLowerCase() ?? '';
    final inviteId = query['invite']?.trim() ?? '';
    final token = query['token']?.trim() ?? '';
    if (version != 1 ||
        port == null ||
        port < 1 ||
        port > 65535 ||
        address.isEmpty ||
        groupId.isEmpty ||
        inviteId.isEmpty ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(fingerprint)) {
      throw const FormatException('Pairing code fields are invalid.');
    }
    try {
      if (SyncCrypto.decodeBase64Url(token).length < 16) {
        throw const FormatException('Pairing token is too short.');
      }
    } on Object {
      throw const FormatException('Pairing token is invalid.');
    }
    return SyncPairingEndpoint(
      address: address,
      port: port,
      groupId: groupId,
      fingerprintSha256: fingerprint,
      inviteId: inviteId,
      inviteToken: token,
    );
  }

  static String normalizeHost(String source) {
    final value = source.trim();
    if (value.isEmpty || value.length > 253) {
      throw const FormatException('Host name is invalid.');
    }
    final literal = InternetAddress.tryParse(value);
    if (literal != null && literal.type == InternetAddressType.IPv6) {
      return literal.address.toLowerCase();
    }
    final parsed = Uri.tryParse('https://$value');
    if (parsed == null ||
        parsed.host.isEmpty ||
        parsed.host.toLowerCase() != value.toLowerCase() ||
        parsed.hasPort ||
        parsed.path.isNotEmpty ||
        parsed.hasQuery ||
        parsed.hasFragment) {
      throw const FormatException('Host name is invalid.');
    }
    return parsed.host;
  }
}

final class SyncSavedEndpoint {
  SyncSavedEndpoint({
    required String address,
    required this.port,
    String label = '',
  }) : address = SyncPairingUriCodec.normalizeHost(address),
       label = label.trim().replaceAll(RegExp(r'[\r\n\t]'), ' ') {
    if (port < 1 || port > 65535 || this.label.length > 128) {
      throw const FormatException('Connection endpoint is invalid.');
    }
  }

  final String address;
  final int port;
  final String label;
  Uri get baseUri => Uri(scheme: 'https', host: address, port: port);
  String get id => baseUri.toString();
  String get displayName =>
      label.isEmpty ? '$address:$port' : '$label · $address:$port';

  Map<String, dynamic> toJson() => {
    'address': address,
    'port': port,
    'label': label,
  };

  static SyncSavedEndpoint fromJson(Object? value) {
    if (value is! Map<String, dynamic> ||
        value['address'] is! String ||
        value['port'] is! int ||
        (value['label'] != null && value['label'] is! String)) {
      throw const FormatException('Saved connection endpoint is invalid.');
    }
    return SyncSavedEndpoint(
      address: value['address'] as String,
      port: value['port'] as int,
      label: value['label'] as String? ?? '',
    );
  }
}

final class SyncClientProfile {
  SyncClientProfile({
    required this.address,
    required this.port,
    required this.fingerprintSha256,
    required this.groupId,
    required this.hostDevice,
    SyncCursor? remoteCursor,
    this.lastSyncAt,
    List<SyncSavedEndpoint> savedEndpoints = const [],
    String? defaultEndpointId,
  }) : remoteCursor = remoteCursor ?? SyncCursor(),
       defaultEndpointId =
           defaultEndpointId ??
           SyncSavedEndpoint(address: address, port: port).id,
       savedEndpoints = List.unmodifiable(
         {
           SyncSavedEndpoint(address: address, port: port).id:
               SyncSavedEndpoint(address: address, port: port),
           for (final endpoint in savedEndpoints) endpoint.id: endpoint,
         }.values,
       );

  final String address;
  final int port;
  final String fingerprintSha256;
  final String groupId;
  final SyncDeviceRegistration hostDevice;
  final SyncCursor remoteCursor;
  final DateTime? lastSyncAt;
  final List<SyncSavedEndpoint> savedEndpoints;
  final String defaultEndpointId;

  Uri get baseUri => Uri(scheme: 'https', host: address, port: port);

  SyncClientProfile copyWith({
    String? address,
    int? port,
    SyncCursor? remoteCursor,
    DateTime? lastSyncAt,
    List<SyncSavedEndpoint>? savedEndpoints,
    String? defaultEndpointId,
  }) => SyncClientProfile(
    address: address ?? this.address,
    port: port ?? this.port,
    fingerprintSha256: fingerprintSha256,
    groupId: groupId,
    hostDevice: hostDevice,
    remoteCursor: remoteCursor ?? this.remoteCursor,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    savedEndpoints: savedEndpoints ?? this.savedEndpoints,
    defaultEndpointId: defaultEndpointId ?? this.defaultEndpointId,
  );

  Map<String, dynamic> toJson() => {
    'address': address,
    'port': port,
    'fingerprintSha256': fingerprintSha256,
    'groupId': groupId,
    'hostDevice': {
      'deviceId': hostDevice.deviceId,
      'displayName': hostDevice.displayName,
      'platform': hostDevice.platform,
      'appVersion': hostDevice.appVersion,
      'publicKey': hostDevice.publicKey,
      'note': ?hostDevice.note,
    },
    'remoteCursor': remoteCursor.toJson(),
    'lastSyncAtUtc': ?lastSyncAt?.toUtc().toIso8601String(),
    'defaultEndpointId': defaultEndpointId,
    'savedEndpoints': savedEndpoints
        .map((endpoint) => endpoint.toJson())
        .toList(),
  };

  static SyncClientProfile fromJson(Map<String, dynamic> json) {
    final host = json['hostDevice'];
    if (host is! Map<String, dynamic>) {
      throw const FormatException('Missing host device.');
    }
    final lastSyncText = json['lastSyncAtUtc'];
    final lastSync = lastSyncText is String
        ? DateTime.tryParse(lastSyncText)?.toUtc()
        : null;
    return SyncClientProfile(
      address: _string(json, 'address'),
      port: _integer(json, 'port'),
      fingerprintSha256: _string(json, 'fingerprintSha256'),
      groupId: _string(json, 'groupId'),
      hostDevice: SyncDeviceRegistration(
        deviceId: _string(host, 'deviceId'),
        displayName: _string(host, 'displayName'),
        platform: _string(host, 'platform'),
        appVersion: _string(host, 'appVersion'),
        publicKey: _string(host, 'publicKey'),
        note: host['note'] as String?,
      ),
      remoteCursor: SyncCursor.fromJson(_object(json, 'remoteCursor')),
      lastSyncAt: lastSync,
      savedEndpoints: switch (json['savedEndpoints']) {
        null => const [],
        final List<dynamic> list =>
          list.map(SyncSavedEndpoint.fromJson).toList(),
        _ => throw const FormatException('Saved endpoints must be a list.'),
      },
      defaultEndpointId: json['defaultEndpointId'] as String?,
    );
  }

  static SyncClientProfile decode(String source) {
    final value = jsonDecode(source);
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Invalid sync client profile.');
    }
    return fromJson(value);
  }

  String encode() => jsonEncode(toJson());

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

  static Map<String, dynamic> _object(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! Map<String, dynamic>) {
      throw FormatException('$key is invalid.');
    }
    return value;
  }
}

enum SyncClientPhase {
  disconnected,
  connecting,
  waitingForApproval,
  syncing,
  synced,
  offline,
  error,
}

final class SyncRunResult {
  const SyncRunResult({
    required this.uploaded,
    required this.downloaded,
    required this.conflicts,
    required this.completedAt,
  });

  final int uploaded;
  final int downloaded;
  final int conflicts;
  final DateTime completedAt;
}
