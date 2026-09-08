import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/backup_file_gateway.dart';

typedef AndroidDocumentChooser = Future<String?> Function(String suggestedName);
typedef AndroidDocumentWriter = Future<void> Function(
  String documentUri,
  String sourcePath,
);
typedef AndroidImportChooser = Future<String?> Function();
typedef AndroidTemporaryDirectoryProvider = Future<Directory> Function();

/// Android backup adapter backed by the Storage Access Framework.
///
/// Export data is first written to an app-private staging file so the shared
/// JSON repository never needs to understand `content://` URIs. The native
/// side then streams that file into the document selected by the user.
final class AndroidDocumentBackupFileGateway implements BackupFileGateway {
  AndroidDocumentBackupFileGateway({
    AndroidDocumentChooser? chooseDocument,
    AndroidDocumentWriter? writeDocument,
    AndroidImportChooser? chooseImport,
    AndroidTemporaryDirectoryProvider? temporaryDirectory,
  }) : _chooseDocument = chooseDocument ?? _defaultChooseDocument,
       _writeDocument = writeDocument ?? _defaultWriteDocument,
       _chooseImport = chooseImport ?? _defaultChooseImport,
       _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  static const _channel = MethodChannel('com.vanecho.echoday/document_backup');
  static const _jsonFiles = XTypeGroup(
    label: 'EchoDay JSON backup',
    extensions: ['json'],
    mimeTypes: ['application/json', 'text/json'],
  );

  final AndroidDocumentChooser _chooseDocument;
  final AndroidDocumentWriter _writeDocument;
  final AndroidImportChooser _chooseImport;
  final AndroidTemporaryDirectoryProvider _temporaryDirectory;

  @override
  Future<BackupExportTarget?> chooseExportTarget({
    required String suggestedName,
  }) async {
    final documentUri = await _chooseDocument(suggestedName);
    if (documentUri == null) return null;

    final root = await _temporaryDirectory();
    final stagingDirectory = Directory(
      _join(root.path, 'echoday_backup_exports'),
    );
    await stagingDirectory.create(recursive: true);
    final safeName = suggestedName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final path = _join(
      stagingDirectory.path,
      '${DateTime.now().microsecondsSinceEpoch}-$safeName',
    );
    return BackupExportTarget(path: path, documentUri: documentUri);
  }

  @override
  Future<void> commitExport(BackupExportTarget target) async {
    final uri = target.documentUri;
    if (uri == null || uri.isEmpty) {
      throw ArgumentError.value(target.documentUri, 'documentUri');
    }
    final stagingFile = File(target.path);
    try {
      if (!await stagingFile.exists()) {
        throw StateError('Android backup staging file does not exist.');
      }
      await _writeDocument(uri, target.path);
    } finally {
      if (await stagingFile.exists()) await stagingFile.delete();
    }
  }

  @override
  Future<void> cleanupExport(BackupExportTarget target) async {
    final stagingFile = File(target.path);
    if (await stagingFile.exists()) await stagingFile.delete();
  }

  @override
  Future<String?> chooseImportPath() => _chooseImport();

  static Future<String?> _defaultChooseDocument(String suggestedName) {
    return _channel.invokeMethod<String>('chooseExportDocument', {
      'suggestedName': suggestedName,
      'mimeType': 'application/json',
    });
  }

  static Future<void> _defaultWriteDocument(
    String documentUri,
    String sourcePath,
  ) {
    return _channel.invokeMethod<void>('writeExportDocument', {
      'documentUri': documentUri,
      'sourcePath': sourcePath,
    });
  }

  static Future<String?> _defaultChooseImport() async {
    final file = await openFile(acceptedTypeGroups: const [_jsonFiles]);
    return file?.path;
  }

  static String _join(String parent, String child) {
    final separator = Platform.pathSeparator;
    return parent.endsWith(separator)
        ? '$parent$child'
        : '$parent$separator$child';
  }
}
