import 'dart:io';

import 'package:echoday/src/features/backup/data/desktop_backup_directory_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'echoday-directory-test-',
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('write test creates the directory and removes its probe file', () async {
    final target = Directory(
      '${temporaryDirectory.path}${Platform.pathSeparator}Backups',
    );
    final gateway = DesktopBackupDirectoryGateway(
      now: () => DateTime.utc(2026, 9, 5),
    );

    await gateway.verifyWritable(target.path);

    expect(await target.exists(), isTrue);
    expect(await target.list().toList(), isEmpty);
  });

  test('write test fails when the selected path is a file', () async {
    final target = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}occupied',
    );
    await target.writeAsString('not a directory');
    const gateway = DesktopBackupDirectoryGateway();

    await expectLater(gateway.verifyWritable(target.path), throwsA(anything));
  });
}
