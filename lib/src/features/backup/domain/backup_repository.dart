final class BackupManifest {
  const BackupManifest({
    required this.formatVersion,
    required this.exportedAt,
    required this.path,
  });

  final int formatVersion;
  final DateTime exportedAt;
  final String path;
}

final class ImportPreview {
  const ImportPreview({
    required this.formatVersion,
    required this.todoCount,
    required this.isValid,
    this.totalRecordCount = 0,
    this.exportedAt,
    this.appVersion,
    this.error,
  });

  final int formatVersion;
  final int todoCount;
  final int totalRecordCount;
  final bool isValid;
  final DateTime? exportedAt;
  final String? appVersion;
  final String? error;
}

final class ImportResult {
  const ImportResult({
    required this.importedCount,
    required this.skippedCount,
    this.safetyBackupPath,
  });

  final int importedCount;
  final int skippedCount;
  final String? safetyBackupPath;
}

final class BackupFormatException implements FormatException {
  const BackupFormatException(this.message, [this.source, this.offset]);

  @override
  final String message;
  @override
  final dynamic source;
  @override
  final int? offset;

  @override
  String toString() => 'BackupFormatException: $message';
}

abstract interface class BackupRepository {
  Future<BackupManifest> exportTo(String path);
  Future<ImportPreview> inspect(String path);
  Future<ImportResult> merge(String path);
  Future<ImportResult> replace(String path);
}

String standardBackupFileName(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return 'EchoDay-backup-${value.year}${two(value.month)}${two(value.day)}-'
      '${two(value.hour)}${two(value.minute)}${two(value.second)}.json';
}
