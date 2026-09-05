import 'package:drift/native.dart';
import 'package:echoday/src/core/ids/id_generator.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/todos/data/local_category_repository.dart';
import 'package:echoday/src/features/todos/data/local_recurrence_repository.dart';
import 'package:echoday/src/features/todos/data/local_tag_repository.dart';
import 'package:echoday/src/features/todos/data/local_todo_repository.dart';
import 'package:echoday/src/features/todos/domain/category.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/recurrence_series.dart';
import 'package:echoday/src/features/todos/domain/tag.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:echoday/src/features/todos/domain/todo_priority.dart';
import 'package:echoday/src/features/todos/domain/todo_search.dart';
import 'package:flutter_test/flutter_test.dart';

final class _SequentialIds implements IdGenerator {
  var _value = 0;

  @override
  String next() => 'todo-${++_value}';
}

void main() {
  late AppDatabase database;
  late LocalTodoRepository todos;
  late DateTime now;
  final date = LocalDate(2026, 9, 3);

  setUp(() {
    now = DateTime.utc(2026, 9, 3, 8);
    database = AppDatabase.forTesting(NativeDatabase.memory());
    todos = LocalTodoRepository(
      database,
      idGenerator: _SequentialIds(),
      clock: () => now,
    );
  });

  tearDown(() => database.close());

  test(
    'supports create, edit, complete, restore, soft delete and undo',
    () async {
      final created = await todos.create(
        TodoDraft(
          title: '  准备 M1  ',
          localDate: date,
          priority: TodoPriority.high,
          deadlineAt: DateTime.utc(2026, 9, 3, 18),
        ),
      );

      expect(created.id, 'todo-1');
      expect(created.title, '准备 M1');
      expect(created.revision, 1);

      now = now.add(const Duration(minutes: 1));
      final edited = await todos.save(created.copyWith(notes: '先完成数据层'));
      expect(edited.notes, '先完成数据层');
      expect(edited.revision, 2);

      now = now.add(const Duration(minutes: 1));
      await todos.complete(created.id);
      var fetched = await todos.getById(created.id);
      expect(fetched?.isCompleted, true);
      expect(fetched?.completedAt, now);
      expect(fetched?.revision, 3);

      now = now.add(const Duration(minutes: 1));
      await todos.restore(created.id);
      fetched = await todos.getById(created.id);
      expect(fetched?.isCompleted, false);
      expect(fetched?.completedAt, isNull);

      now = now.add(const Duration(minutes: 1));
      await todos.softDelete(created.id);
      expect(await todos.getById(created.id), isNull);
      expect(
        (await todos.getById(created.id, includeDeleted: true))?.deletedAt,
        now,
      );

      now = now.add(const Duration(minutes: 1));
      await todos.undoDelete(created.id);
      expect((await todos.getById(created.id))?.deletedAt, isNull);
    },
  );

  test(
    'date stream reacts to writes and restores stored tag relations',
    () async {
      final categories = LocalCategoryRepository(database, clock: () => now);
      final tags = LocalTagRepository(database, clock: () => now);
      await categories.save(
        Category(
          id: 'work',
          name: '工作',
          colorValue: 0xFF70877F,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await tags.save(
        Tag(
          id: 'm1',
          name: 'M1',
          colorValue: 0xFFA28F75,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final emission = todos
          .watchByDate(date)
          .firstWhere((items) => items.isNotEmpty);
      final created = await todos.create(
        TodoDraft(
          title: '数据库测试',
          localDate: date,
          categoryId: 'work',
          tagIds: {'m1'},
        ),
      );
      final items = await emission;

      expect(items.single.id, created.id);
      expect(items.single.categoryId, 'work');
      expect(items.single.tagIds, {'m1'});
    },
  );

  test(
    'manual reorder persists and requires an exact active-date set',
    () async {
      final first = await todos.create(TodoDraft(title: 'A', localDate: date));
      final second = await todos.create(TodoDraft(title: 'B', localDate: date));
      final third = await todos.create(TodoDraft(title: 'C', localDate: date));

      await todos.reorder(date, [third.id, first.id, second.id]);

      expect((await todos.getByDate(date)).map((item) => item.id), [
        third.id,
        first.id,
        second.id,
      ]);
      await expectLater(
        todos.reorder(date, [first.id, first.id, second.id]),
        throwsArgumentError,
      );
    },
  );

  test(
    'virtual recurrence occurrences materialize only when changed',
    () async {
      final recurrence = LocalRecurrenceRepository(
        database,
        idGenerator: _SequentialIds(),
        clock: () => now,
      );
      final series = await recurrence.create(
        date,
        RecurrenceRule(frequency: RecurrenceFrequency.daily),
      );
      await todos.create(
        TodoDraft(
          title: '每日复盘',
          localDate: date,
          recurrenceSeriesId: series.id,
          occurrenceDate: date,
        ),
      );

      final nextDate = date.addDays(1);
      var occurrence = (await todos.getByDate(nextDate)).single;
      expect(occurrence.id, startsWith('virtual:'));
      expect(occurrence.occurrenceDate, nextDate);

      await todos.complete(occurrence.id);
      occurrence = (await todos.getByDate(nextDate)).single;
      expect(occurrence.id, isNot(startsWith('virtual:')));
      expect(occurrence.isCompleted, isTrue);

      final thirdDate = date.addDays(2);
      final third = (await todos.getByDate(thirdDate)).single;
      await todos.softDelete(third.id);
      expect(await todos.getByDate(thirdDate), isEmpty);
      await todos.undoDelete(third.id);
      expect(await todos.getByDate(thirdDate), hasLength(1));
    },
  );

  test('search matches title, notes, category and tags with filters', () async {
    final categories = LocalCategoryRepository(database, clock: () => now);
    final tags = LocalTagRepository(database, clock: () => now);
    await categories.save(
      Category(
        id: 'life',
        name: '生活',
        colorValue: 1,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await tags.save(
      Tag(
        id: 'health',
        name: '健康',
        colorValue: 2,
        createdAt: now,
        updatedAt: now,
      ),
    );
    final item = await todos.create(
      TodoDraft(
        title: '慢跑',
        localDate: date,
        notes: '公园五公里',
        categoryId: 'life',
        tagIds: {'health'},
      ),
    );

    for (final text in ['慢跑', '五公里', '生活', '健康']) {
      final page = await todos.search(TodoSearchQuery(text: text));
      expect(page.items.single.id, item.id);
    }
    expect(
      (await todos.search(
        const TodoSearchQuery(completion: CompletionFilter.completed),
      )).items,
      isEmpty,
    );
  });

  test(
    'ordinary search stays responsive with ten thousand local tasks',
    () async {
      await database.batch((batch) {
        for (var index = 0; index < 10000; index++) {
          batch.insert(
            database.todos,
            TodosCompanion.insert(
              id: 'bulk-$index',
              title: index == 7777 ? '唯一性能针' : '普通任务 $index',
              localDate: date.toString(),
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
      });

      final stopwatch = Stopwatch()..start();
      final page = await todos.search(const TodoSearchQuery(text: '唯一性能针'));
      stopwatch.stop();

      expect(page.items.single.id, 'bulk-7777');
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 3)));
    },
  );

  test(
    'foreign keys reject unknown tags without leaving a partial todo',
    () async {
      await expectLater(
        todos.create(
          TodoDraft(
            title: 'bad relation',
            localDate: date,
            tagIds: {'missing'},
          ),
        ),
        throwsA(anything),
      );

      expect(await todos.getByDate(date), isEmpty);
    },
  );

  test(
    'category and tag repositories preserve and soft-delete metadata',
    () async {
      final categories = LocalCategoryRepository(database, clock: () => now);
      final tags = LocalTagRepository(database, clock: () => now);
      final category = await categories.save(
        Category(
          id: 'work',
          name: '  工作  ',
          colorValue: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final tag = await tags.save(
        Tag(
          id: 'deep',
          name: '专注',
          colorValue: 2,
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(category.name, '工作');
      expect(category.revision, 1);
      expect(tag.revision, 1);

      now = now.add(const Duration(minutes: 1));
      await categories.softDelete(category.id);
      await tags.softDelete(tag.id);
      expect(await categories.getAll(), isEmpty);
      expect(await tags.getAll(), isEmpty);

      now = now.add(const Duration(minutes: 1));
      await categories.undoDelete(category.id);
      await tags.undoDelete(tag.id);
      expect((await categories.getAll()).single.id, category.id);
      expect((await tags.getAll()).single.id, tag.id);
    },
  );
}
