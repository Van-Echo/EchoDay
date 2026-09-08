import 'package:drift/native.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/todos/data/local_todo_repository.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/todo_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ten thousand tasks keep search and ten-week browsing responsive', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final todos = LocalTodoRepository(database);
    final firstDate = LocalDate(2026, 1, 5);
    final now = DateTime.utc(2026, 1, 1);
    await database.batch((batch) {
      for (var index = 0; index < 10000; index++) {
        final date = firstDate.addDays(index % 70);
        batch.insert(
          database.todos,
          TodosCompanion.insert(
            id: 'performance-$index',
            title: index == 8765 ? 'A6 唯一检索目标' : '性能任务 $index',
            localDate: date.toString(),
            createdAt: now.add(Duration(microseconds: index)),
            updatedAt: now.add(Duration(microseconds: index)),
          ),
        );
      }
    });

    final searchWatch = Stopwatch()..start();
    final search = await todos.search(const TodoSearchQuery(text: 'A6 唯一检索目标'));
    searchWatch.stop();
    expect(search.items.single.id, 'performance-8765');
    expect(searchWatch.elapsed, lessThan(const Duration(seconds: 5)));

    final calendarWatch = Stopwatch()..start();
    final weeks = await Future.wait([
      for (var offset = 0; offset < 70; offset++)
        todos.getByDate(firstDate.addDays(offset)),
    ]);
    calendarWatch.stop();
    expect(weeks.expand((items) => items), hasLength(10000));
    expect(calendarWatch.elapsed, lessThan(const Duration(seconds: 5)));

    // Printed only when the test is run with expanded reporting; this gives A6
    // a repeatable baseline without making production code depend on profiling.
    // ignore: avoid_print
    print(
      'A6 10k metrics: search=${searchWatch.elapsedMilliseconds}ms, '
      '70-day browse=${calendarWatch.elapsedMilliseconds}ms',
    );
  });
}
