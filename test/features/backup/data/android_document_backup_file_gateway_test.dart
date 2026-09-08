import 'dart:io';

import 'package:echoday/src/features/backup/data/android_document_backup_file_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'echoday-android-document-gateway-',
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'canceling the document picker does not create a staging file',
    () async {
      final gateway = AndroidDocumentBackupFileGateway(
        chooseDocument: (_) async => null,
        writeDocument: (_, _) async {},
        chooseImport: () async => null,
        temporaryDirectory: () async => temporaryDirectory,
      );

      final target = await gateway.chooseExportTarget(
        suggestedName: 'EchoDay-backup.json',
      );

      expect(target, isNull);
      expect(temporaryDirectory.listSync(), isEmpty);
    },
  );

  test(
    'commits a staging file to its SAF document and removes staging',
    () async {
      final exported = File(
        '${temporaryDirectory.path}${Platform.pathSeparator}exported.json',
      );
      final gateway = AndroidDocumentBackupFileGateway(
        chooseDocument: (_) async => 'content://documents/echoday-backup',
        writeDocument: (uri, sourcePath) async {
          expect(uri, 'content://documents/echoday-backup');
          await File(sourcePath).copy(exported.path);
        },
        chooseImport: () async => exported.path,
        temporaryDirectory: () async => temporaryDirectory,
      );
      final target = await gateway.chooseExportTarget(
        suggestedName: 'EchoDay:backup.json',
      );

      expect(target, isNotNull);
      expect(target!.path, endsWith('EchoDay_backup.json'));
      await File(target.path).writeAsString('{"formatVersion":1}');
      await gateway.commitExport(target);

      expect(await exported.readAsString(), '{"formatVersion":1}');
      expect(await File(target.path).exists(), isFalse);
      expect(await gateway.chooseImportPath(), exported.path);
    },
  );

  test(
    'removes the staging file when the document provider rejects it',
    () async {
      final gateway = AndroidDocumentBackupFileGateway(
        chooseDocument: (_) async => 'content://documents/rejected',
        writeDocument: (_, _) async =>
            throw const FileSystemException('denied'),
        chooseImport: () async => null,
        temporaryDirectory: () async => temporaryDirectory,
      );
      final target = (await gateway.chooseExportTarget(
        suggestedName: 'backup.json',
      ))!;
      await File(target.path).writeAsString('{}');

      await expectLater(
        gateway.commitExport(target),
        throwsA(isA<FileSystemException>()),
      );
      expect(await File(target.path).exists(), isFalse);
    },
  );

  test('cleans staging when JSON generation fails before commit', () async {
    final gateway = AndroidDocumentBackupFileGateway(
      chooseDocument: (_) async => 'content://documents/unused',
      writeDocument: (_, _) async {},
      chooseImport: () async => null,
      temporaryDirectory: () async => temporaryDirectory,
    );
    final target = (await gateway.chooseExportTarget(
      suggestedName: 'backup.json',
    ))!;
    await File(target.path).writeAsString('partial');

    await gateway.cleanupExport(target);

    expect(await File(target.path).exists(), isFalse);
  });
}
