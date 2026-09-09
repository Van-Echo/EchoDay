import 'dart:io';

import 'package:file_selector/file_selector.dart';

import '../domain/backup_directory_gateway.dart';

final class DesktopBackupDirectoryGateway implements BackupDirectoryGateway {
  const DesktopBackupDirectoryGateway({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  @override
  Future<String?> chooseDirectory() => getDirectoryPath();

  @override
  Future<void> openDirectory(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      throw FileSystemException('Backup directory does not exist.', path);
    }
    if (!Platform.isWindows) {
      throw UnsupportedError('Opening backup folders is Windows-only.');
    }
    await Process.start('explorer.exe', [
      directory.absolute.path,
    ], mode: ProcessStartMode.detached);
  }

  @override
  Future<void> verifyWritable(String path) async {
    final normalized = path.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(path, 'path', 'must not be blank');
    }
    final directory = Directory(normalized).absolute;
    await directory.create(recursive: true);
    final testFile = File(
      _join(
        directory.path,
        '.echoday-write-test-${_now().microsecondsSinceEpoch}.tmp',
      ),
    );
    try {
      await testFile.writeAsString(
        'EchoDay backup directory test',
        flush: true,
      );
    } finally {
      if (await testFile.exists()) await testFile.delete();
    }
  }

  static String _join(String parent, String child) {
    final separator = Platform.pathSeparator;
    return parent.endsWith(separator)
        ? '$parent$child'
        : '$parent$separator$child';
  }
}
