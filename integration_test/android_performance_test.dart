import 'dart:io';

import 'package:drift/native.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/todos/data/local_todo_repository.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/todo_search.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android handles ten thousand local tasks responsively', (
    tester,
  ) async {
    if (!Platform.isAndroid) return;
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final todos = LocalTodoRepository(database);
    final firstDate = LocalDate(2026, 1, 5);
    final now = DateTime.utc(2026, 1, 1);

    final insertWatch = Stopwatch()..start();
    await database.batch((batch) {
      for (var index = 0; index < 10000; index++) {
        final date = firstDate.addDays(index % 70);
        batch.insert(
          database.todos,
          TodosCompanion.insert(
            id: 'android-performance-$index',
            title: index == 8765 ? 'A6 Android 唯一检索目标' : '性能任务 $index',
            localDate: date.toString(),
            createdAt: now.add(Duration(microseconds: index)),
            updatedAt: now.add(Duration(microseconds: index)),
          ),
        );
      }
    });
    insertWatch.stop();

    final searchWatch = Stopwatch()..start();
    final search = await todos.search(
      const TodoSearchQuery(text: 'A6 Android 唯一检索目标'),
    );
    searchWatch.stop();
    expect(search.items.single.id, 'android-performance-8765');

    final browseWatch = Stopwatch()..start();
    final days = await Future.wait([
      for (var offset = 0; offset < 70; offset++)
        todos.getByDate(firstDate.addDays(offset)),
    ]);
    browseWatch.stop();
    expect(days.expand((items) => items), hasLength(10000));

    // Device thresholds are intentionally broad enough for the API 24 emulator
    // while still catching accidental full-table work in ordinary queries.
    expect(insertWatch.elapsed, lessThan(const Duration(seconds: 20)));
    expect(searchWatch.elapsed, lessThan(const Duration(seconds: 5)));
    expect(browseWatch.elapsed, lessThan(const Duration(seconds: 10)));

    // ignore: avoid_print
    print(
      'A6 Android 10k metrics: insert=${insertWatch.elapsedMilliseconds}ms, '
      'search=${searchWatch.elapsedMilliseconds}ms, '
      '70-day browse=${browseWatch.elapsedMilliseconds}ms',
    );
  });
}
