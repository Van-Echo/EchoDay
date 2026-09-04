import 'dart:async';

import 'package:echoday/l10n/app_localizations.dart';
import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/features/todos/application/todo_providers.dart';
import 'package:echoday/src/features/todos/domain/category.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/repositories/todo_repository.dart';
import 'package:echoday/src/features/todos/domain/tag.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:echoday/src/features/todos/domain/todo_search.dart';
import 'package:echoday/src/features/todos/presentation/day_todo_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/in_memory_settings_repository.dart';

void main() {
  late _MemoryTodoRepository todos;
  late InMemorySettingsRepository settings;
  late LocalDate date;
  late DateTime now;

  setUp(() {
    now = DateTime.utc(2026, 9, 4, 12);
    todos = _MemoryTodoRepository(() => now);
    settings = InMemorySettingsRepository();
    date = LocalDate(2026, 9, 4);
  });

  Widget app() => ProviderScope(
    overrides: [
      todoRepositoryProvider.overrideWithValue(todos),
      settingsRepositoryProvider.overrideWithValue(settings),
      categoriesProvider.overrideWith(
        (ref) => Stream.value(const <Category>[]),
      ),
      tagsProvider.overrideWith((ref) => Stream.value(const <Tag>[])),
      currentTimeProvider.overrideWith((ref) => Stream.value(now)),
    ],
    child: MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: DayTodoList(date: date)),
    ),
  );

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
  }

  testWidgets('completes, restores, soft deletes and undoes from the list', (
    tester,
  ) async {
    final todo = await todos.create(
      TodoDraft(
        title: '提交周报',
        localDate: date,
        deadlineAt: DateTime.utc(2026, 9, 4, 10),
      ),
    );
    await tester.pumpWidget(app());
    await settle(tester);

    expect(find.text('提交周报'), findsOneWidget);
    expect(find.textContaining('已逾期'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byKey(ValueKey('todo-${todo.id}')),
        matching: find.byType(Checkbox),
      ),
    );
    await settle(tester);
    expect(find.text('提交周报'), findsNothing);

    await tester.tap(find.text('已完成'));
    await settle(tester);
    expect(find.text('提交周报'), findsOneWidget);
    expect((await todos.getById(todo.id))?.isCompleted, isTrue);

    await tester.tap(
      find.descendant(
        of: find.byKey(ValueKey('todo-${todo.id}')),
        matching: find.byType(Checkbox),
      ),
    );
    await settle(tester);
    expect((await todos.getById(todo.id))?.isCompleted, isFalse);

    await tester.tap(
      find.descendant(
        of: find.byKey(ValueKey('todo-${todo.id}')),
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.tap(find.text('删除任务'));
    await settle(tester);
    expect(await todos.getById(todo.id), isNull);

    await tester.tap(find.text('撤销'));
    await settle(tester);
    expect(await todos.getById(todo.id), isNotNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'persists sort choice and only exposes drag handles in manual mode',
    (tester) async {
      await todos.create(TodoDraft(title: '任务一', localDate: date));
      await todos.create(TodoDraft(title: '任务二', localDate: date));
      await tester.pumpWidget(app());
      await settle(tester);

      expect(find.byIcon(Icons.drag_indicator_rounded), findsNothing);
      await tester.tap(find.byKey(const ValueKey('todo-sort-menu')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      await tester.tapAt(tester.getCenter(find.text('手动排序')));
      await settle(tester);

      expect((await settings.get(TodoSettingKeys.sortMode))?.value, 'manual');
      expect(find.byIcon(Icons.drag_indicator_rounded), findsNWidgets(2));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets('edits task content in the right-side detail sheet', (
    tester,
  ) async {
    final todo = await todos.create(TodoDraft(title: '旧标题', localDate: date));
    await tester.pumpWidget(app());
    await settle(tester);

    await tester.tap(find.text('旧标题'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final titleField = find.byKey(const ValueKey('todo-editor-title'));
    expect(titleField, findsOneWidget);
    await tester.enterText(titleField, '新标题');
    await tester.tap(find.text('保存'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect((await todos.getById(todo.id))?.title, '新标题');
    expect(
      find.descendant(
        of: find.byKey(ValueKey('todo-${todo.id}')),
        matching: find.text('新标题'),
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('moves all incomplete tasks to the next day from the toolbar', (
    tester,
  ) async {
    final incomplete = await todos.create(
      TodoDraft(
        title: '顺延任务',
        localDate: date,
        plannedAt: DateTime(2026, 9, 4, 9).toUtc(),
        deadlineAt: DateTime(2026, 9, 4, 18).toUtc(),
      ),
    );
    final completed = await todos.create(
      TodoDraft(title: '保留任务', localDate: date),
    );
    await todos.complete(completed.id);
    await tester.pumpWidget(app());
    await settle(tester);

    await tester.tap(find.byKey(const ValueKey('postpone-incomplete-todos')));
    await tester.pumpAndSettle();
    expect(find.text('顺延未完成任务？'), findsOneWidget);
    await tester.tap(find.text('顺延'));
    await tester.pumpAndSettle();

    expect(find.text('已顺延 1 项未完成任务'), findsOneWidget);
    expect((await todos.getById(completed.id))?.localDate, date);
    final moved = await todos.getById(incomplete.id);
    expect(moved?.localDate, date.addDays(1));
    expect(moved?.plannedAt, DateTime(2026, 9, 5, 9).toUtc());
    expect(moved?.deadlineAt, DateTime(2026, 9, 5, 18).toUtc());
  });
}

final class _MemoryTodoRepository implements TodoRepository {
  _MemoryTodoRepository(this._clock);

  final DateTime Function() _clock;
  final Map<String, TodoItem> _items = {};
  final Map<LocalDate, StreamController<List<TodoItem>>> _controllers = {};
  var _nextId = 0;

  @override
  Stream<List<TodoItem>> watchByDate(LocalDate date) async* {
    yield _forDate(date);
    yield* _controllers
        .putIfAbsent(date, StreamController<List<TodoItem>>.broadcast)
        .stream;
  }

  @override
  Future<List<TodoItem>> getByDate(LocalDate date) async => _forDate(date);

  @override
  Future<TodoItem?> getById(String id, {bool includeDeleted = false}) async {
    final item = _items[id];
    return !includeDeleted && (item?.isDeleted ?? false) ? null : item;
  }

  @override
  Future<TodoItem> create(TodoDraft draft) async {
    final now = _clock();
    final item = TodoItem(
      id: 'todo-${++_nextId}',
      title: draft.title,
      localDate: draft.localDate,
      createdAt: now,
      updatedAt: now,
      plannedAt: draft.plannedAt,
      priority: draft.priority,
      categoryId: draft.categoryId,
      tagIds: draft.tagIds,
      notes: draft.notes,
      deadlineAt: draft.deadlineAt,
      manualOrder:
          draft.manualOrder ?? _forDate(draft.localDate).length.toDouble(),
    );
    _items[item.id] = item;
    _emit(item.localDate);
    return item;
  }

  @override
  Future<TodoItem> save(TodoItem todo) async {
    final previous = _items[todo.id];
    final saved = todo.copyWith(
      updatedAt: _clock(),
      revision: (previous?.revision ?? 0) + 1,
    );
    _items[saved.id] = saved;
    if (previous != null && previous.localDate != saved.localDate) {
      _emit(previous.localDate);
    }
    _emit(saved.localDate);
    return saved;
  }

  @override
  Future<void> complete(String id, {DateTime? at}) async {
    final item = _items[id]!;
    await save(item.copyWith(isCompleted: true, completedAt: at ?? _clock()));
  }

  @override
  Future<void> restore(String id) async {
    final item = _items[id]!;
    await save(item.copyWith(isCompleted: false, completedAt: null));
  }

  @override
  Future<void> softDelete(String id, {DateTime? at}) async {
    await save(_items[id]!.copyWith(deletedAt: at ?? _clock()));
  }

  @override
  Future<void> undoDelete(String id) async {
    await save(_items[id]!.copyWith(deletedAt: null));
  }

  @override
  Future<void> reorder(LocalDate date, List<String> orderedIds) async {
    for (var index = 0; index < orderedIds.length; index++) {
      final item = _items[orderedIds[index]]!;
      _items[item.id] = item.copyWith(manualOrder: index.toDouble());
    }
    _emit(date);
  }

  @override
  Future<TodoSearchPage> search(TodoSearchQuery query) async {
    return const TodoSearchPage(items: [], hasMore: false);
  }

  List<TodoItem> _forDate(LocalDate date) => _items.values
      .where((item) => item.localDate == date && !item.isDeleted)
      .toList();

  void _emit(LocalDate date) => _controllers[date]?.add(_forDate(date));
}
