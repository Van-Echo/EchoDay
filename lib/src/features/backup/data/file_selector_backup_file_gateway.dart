import 'package:file_selector/file_selector.dart';

import '../domain/backup_file_gateway.dart';

final class FileSelectorBackupFileGateway implements BackupFileGateway {
  const FileSelectorBackupFileGateway();

  static const _jsonFiles = XTypeGroup(
    label: 'EchoDay JSON backup',
    extensions: ['json'],
  );

  @override
  Future<BackupExportTarget?> chooseExportTarget({
    required String suggestedName,
  }) async {
    final location = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: const [_jsonFiles],
    );
    return location == null ? null : BackupExportTarget(path: location.path);
  }

  @override
  Future<void> commitExport(BackupExportTarget target) async {}

  @override
  Future<void> cleanupExport(BackupExportTarget target) async {}

  @override
  Future<String?> chooseImportPath() async {
    final file = await openFile(acceptedTypeGroups: const [_jsonFiles]);
    return file?.path;
  }
}
