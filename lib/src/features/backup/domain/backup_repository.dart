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
    this.error,
  });

  final int formatVersion;
  final int todoCount;
  final bool isValid;
  final String? error;
}

final class ImportResult {
  const ImportResult({required this.importedCount, required this.skippedCount});

  final int importedCount;
  final int skippedCount;
}

abstract interface class BackupRepository {
  Future<BackupManifest> exportTo(String path);
  Future<ImportPreview> inspect(String path);
  Future<ImportResult> merge(String path);
  Future<ImportResult> replace(String path);
}
