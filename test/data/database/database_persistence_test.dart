import 'dart:io';

import 'package:drift/native.dart';
import 'package:echoday/src/core/ids/id_generator.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/settings/data/local_settings_repository.dart';
import 'package:echoday/src/features/todos/data/local_todo_repository.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FixedId implements IdGenerator {
  const _FixedId(this.value);

  final String value;

  @override
  String next() => value;
}

void main() {
  test(
    'data and settings remain identical after reopening a file database',
    () async {
      final directory = await Directory.systemTemp.createTemp('echoday_m1_');
      final file = File(
        '${directory.path}${Platform.pathSeparator}echoday.sqlite',
      );
      final now = DateTime.utc(2026, 9, 3, 8);

      try {
        var database = AppDatabase.forTesting(NativeDatabase(file));
        var todos = LocalTodoRepository(
          database,
          idGenerator: const _FixedId('persistent-id'),
          clock: () => now,
        );
        var settings = LocalSettingsRepository(database, clock: () => now);
        await todos.create(
          TodoDraft(title: '重启后仍存在', localDate: LocalDate(2026, 9, 3)),
        );
        await settings.set('calendar.visibleWeekCount', '7');
        await database.close();

        database = AppDatabase.forTesting(NativeDatabase(file));
        todos = LocalTodoRepository(database, clock: () => now);
        settings = LocalSettingsRepository(database, clock: () => now);

        final restored = await todos.getById('persistent-id');
        expect(restored?.title, '重启后仍存在');
        expect(restored?.createdAt, now);
        expect((await settings.get('calendar.visibleWeekCount'))?.value, '7');
        await database.close();
      } finally {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      }
    },
  );
}
