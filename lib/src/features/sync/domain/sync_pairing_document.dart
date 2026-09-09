import 'dart:convert';

import 'sync_client_models.dart';

abstract final class SyncPairingDocumentCodec {
  static const format = 'echoday-pairing';
  static const version = 1;
  static const extension = 'echoday-pair';

  static String encode({
    required Uri pairingUri,
    required DateTime expiresAt,
    DateTime? createdAt,
  }) => const JsonEncoder.withIndent('  ').convert({
    'format': format,
    'version': version,
    'createdAtUtc': (createdAt ?? DateTime.now()).toUtc().toIso8601String(),
    'expiresAtUtc': expiresAt.toUtc().toIso8601String(),
    'pairingUri': pairingUri.toString(),
  });

  static String decode(String source, {DateTime? now}) {
    if (source.length > 16384) {
      throw const FormatException('Pairing file is too large.');
    }
    final trimmed = source.trim();
    if (trimmed.startsWith('echoday://')) {
      SyncPairingUriCodec.parse(trimmed);
      return trimmed;
    }
    final value = jsonDecode(trimmed);
    if (value is! Map<String, dynamic> ||
        value['format'] != format ||
        value['version'] != version) {
      throw const FormatException('Unsupported pairing file.');
    }
    final pairingUri = value['pairingUri'];
    final expiresAtText = value['expiresAtUtc'];
    if (pairingUri is! String || expiresAtText is! String) {
      throw const FormatException('Pairing file fields are invalid.');
    }
    final expiresAt = DateTime.tryParse(expiresAtText)?.toUtc();
    if (expiresAt == null ||
        !(now ?? DateTime.now()).toUtc().isBefore(expiresAt)) {
      throw const FormatException('Pairing file has expired.');
    }
    SyncPairingUriCodec.parse(pairingUri);
    return pairingUri;
  }
}
