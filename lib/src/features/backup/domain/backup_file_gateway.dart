final class BackupExportTarget {
  const BackupExportTarget({required this.path, this.documentUri});

  /// A normal destination path on desktop, or an app-private staging path on
  /// Android.
  final String path;

  /// The Storage Access Framework document selected by the Android user.
  final String? documentUri;
}

abstract interface class BackupFileGateway {
  Future<BackupExportTarget?> chooseExportTarget({
    required String suggestedName,
  });

  /// Finishes a prepared export. Desktop targets need no further work, while
  /// Android copies the staging file into the selected SAF document.
  Future<void> commitExport(BackupExportTarget target);

  /// Releases any temporary resources left by an export attempt.
  Future<void> cleanupExport(BackupExportTarget target);

  Future<String?> chooseImportPath();
}
