import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/backup/data/android_document_backup_file_gateway.dart';
import 'package:echoday/src/features/backup/data/local_backup_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Windows JSON restores on Android and returns unchanged to Windows',
    () async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final directory = await Directory.systemTemp.createTemp(
        'echoday-cross-platform-backup-',
      );
      final sourceDatabase = AppDatabase.forTesting(NativeDatabase.memory());
      final androidDatabase = AppDatabase.forTesting(NativeDatabase.memory());
      final restoredDatabase = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(() async {
        await sourceDatabase.close();
        await androidDatabase.close();
        await restoredDatabase.close();
        if (await directory.exists()) await directory.delete(recursive: true);
        driftRuntimeOptions.dontWarnAboutMultipleDatabases = false;
      });
      final now = DateTime.utc(2026, 9, 7, 4, 37);
      Future<Directory> safetyDirectory() async => directory;
      final sourceRepository = LocalBackupRepository(
        sourceDatabase,
        safetyBackupDirectory: safetyDirectory,
        now: () => now,
      );
      final androidRepository = LocalBackupRepository(
        androidDatabase,
        safetyBackupDirectory: safetyDirectory,
        now: () => now,
      );
      final restoredRepository = LocalBackupRepository(
        restoredDatabase,
        safetyBackupDirectory: safetyDirectory,
        now: () => now,
      );
      await _seedPortableData(sourceDatabase, now);
      final windowsPath = _join(directory.path, 'windows-export.json');
      final androidPath = _join(directory.path, 'android-export.json');
      final finalWindowsPath = _join(directory.path, 'windows-restored.json');
      await sourceRepository.exportTo(windowsPath);

      final gateway = AndroidDocumentBackupFileGateway(
        chooseDocument: (_) async => 'content://downloads/echoday-backup',
        writeDocument: (_, sourcePath) async {
          await File(sourcePath).copy(androidPath);
        },
        chooseImport: () async => windowsPath,
        temporaryDirectory: () async => directory,
      );
      final selectedImport = await gateway.chooseImportPath();
      final preview = await androidRepository.inspect(selectedImport!);
      expect(preview.isValid, isTrue);
      expect(preview.todoCount, 1);
      await androidRepository.replace(selectedImport);

      final exportTarget = (await gateway.chooseExportTarget(
        suggestedName: 'EchoDay-backup.json',
      ))!;
      await androidRepository.exportTo(exportTarget.path);
      await gateway.commitExport(exportTarget);
      await restoredRepository.replace(androidPath);
      await restoredRepository.exportTo(finalWindowsPath);

      final original = jsonDecode(await File(windowsPath).readAsString());
      final roundTripped = jsonDecode(
        await File(finalWindowsPath).readAsString(),
      );
      expect(roundTripped, original);
      final originalTodo =
          ((original as Map<String, dynamic>)['data']
                  as Map<String, dynamic>)['todos']
              as List<dynamic>;
      expect(
        (originalTodo.single as Map<String, dynamic>)['plannedAt'],
        '2026-09-07T09:00:00.000Z',
      );
      final todo =
          (await restoredDatabase.select(restoredDatabase.todos).get()).single;
      expect(todo.title, 'Complete Android backup');
      expect(todo.localDate, '2026-09-07');
      expect(todo.plannedAt != null, isTrue);
      expect(todo.deadlineAt != null, isTrue);
      expect(todo.notes, 'Windows to Android to Windows');
      expect(todo.categoryId, 'category-work');
      expect(
        await restoredDatabase.select(restoredDatabase.todoTags).get(),
        hasLength(1),
      );
    },
  );
}

Future<void> _seedPortableData(AppDatabase database, DateTime now) async {
  await database
      .into(database.categories)
      .insert(
        CategoriesCompanion.insert(
          id: 'category-work',
          name: 'Work',
          colorValue: 0xFF788C77,
          sortOrder: const Value(1),
          createdAt: now,
          updatedAt: now,
        ),
      );
  await database
      .into(database.tags)
      .insert(
        TagsCompanion.insert(
          id: 'tag-android',
          name: 'Android',
          colorValue: 0xFF667E8C,
          sortOrder: const Value(1),
          createdAt: now,
          updatedAt: now,
        ),
      );
  await database
      .into(database.todos)
      .insert(
        TodosCompanion.insert(
          id: 'todo-portable',
          title: 'Complete Android backup',
          localDate: '2026-09-07',
          createdAt: now,
          updatedAt: now,
          plannedAt: Value(DateTime.utc(2026, 9, 7, 9)),
          priority: const Value(1),
          categoryId: const Value('category-work'),
          notes: const Value('Windows to Android to Windows'),
          deadlineAt: Value(DateTime.utc(2026, 9, 7, 19, 25)),
          timeZoneId: const Value('Asia/Shanghai'),
          manualOrder: const Value(3.5),
        ),
      );
  await database
      .into(database.todoTags)
      .insert(
        TodoTagsCompanion.insert(todoId: 'todo-portable', tagId: 'tag-android'),
      );
  await database
      .into(database.settings)
      .insert(
        SettingsCompanion.insert(
          key: 'appearance.language',
          value: 'en',
          updatedAt: now,
        ),
      );
}

String _join(String parent, String child) =>
    '$parent${Platform.pathSeparator}$child';
