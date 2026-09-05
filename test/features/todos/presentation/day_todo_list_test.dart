import 'dart:async';
import 'dart:convert';

import 'package:echoday/l10n/app_localizations.dart';
import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/features/settings/application/app_preferences.dart';
import 'package:echoday/src/features/todos/application/todo_providers.dart';
import 'package:echoday/src/features/todos/domain/category.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/repositories/category_repository.dart';
import 'package:echoday/src/features/todos/domain/repositories/tag_repository.dart';
import 'package:echoday/src/features/todos/domain/repositories/todo_repository.dart';
import 'package:echoday/src/features/todos/domain/tag.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:echoday/src/features/todos/domain/todo_search.dart';
import 'package:echoday/src/features/todos/presentation/day_todo_list.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/in_memory_settings_repository.dart';

void main() {
  late _MemoryTodoRepository todos;
  late _MemoryCategoryRepository categoryRepository;
  late _MemoryTagRepository tagRepository;
  late InMemorySettingsRepository settings;
  late LocalDate date;
  late DateTime now;

  setUp(() {
    now = DateTime.utc(2026, 9, 4, 12);
    todos = _MemoryTodoRepository(() => now);
    categoryRepository = _MemoryCategoryRepository();
    tagRepository = _MemoryTagRepository();
    settings = InMemorySettingsRepository();
    date = LocalDate(2026, 9, 4);
  });

  Widget app({
    List<Category> categories = const <Category>[],
    List<Tag> tags = const <Tag>[],
    bool compact = false,
  }) => ProviderScope(
    overrides: [
      todoRepositoryProvider.overrideWithValue(todos),
      categoryRepositoryProvider.overrideWithValue(categoryRepository),
      tagRepositoryProvider.overrideWithValue(tagRepository),
      settingsRepositoryProvider.overrideWithValue(settings),
      categoriesProvider.overrideWith((ref) => Stream.value(categories)),
      tagsProvider.overrideWith((ref) => Stream.value(tags)),
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
      home: Scaffold(
        body: DayTodoList(date: date, compact: compact),
      ),
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
    final overdueTile = find.byKey(ValueKey('todo-${todo.id}'));
    final errorColor = Theme.of(tester.element(overdueTile)).colorScheme.error;
    final overdueTitle = tester.widget<Text>(
      find.descendant(of: overdueTile, matching: find.text('提交周报')),
    );
    final overdueCheckbox = tester.widget<Checkbox>(
      find.descendant(of: overdueTile, matching: find.byType(Checkbox)),
    );
    expect(overdueTitle.style?.color, errorColor);
    expect(overdueCheckbox.side?.color, errorColor);

    await tester.tap(
      find.descendant(
        of: find.byKey(ValueKey('todo-${todo.id}')),
        matching: find.byType(Checkbox),
      ),
    );
    await settle(tester);
    // Completed sections start expanded in both the sidebar and day page.
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

  testWidgets('uses independent full-page and sidebar TODO font sizes', (
    tester,
  ) async {
    final todo = await todos.create(TodoDraft(title: '字号测试', localDate: date));
    await settings.set(AppPreferenceKeys.dayTodoFontSize, '20');
    await settings.set(AppPreferenceKeys.sidebarTodoFontSize, '18');

    await tester.pumpWidget(app());
    await settle(tester);
    var title = tester.widget<Text>(
      find.descendant(
        of: find.byKey(ValueKey('todo-${todo.id}')),
        matching: find.text('字号测试'),
      ),
    );
    expect(title.style?.fontSize, 20);

    await tester.pumpWidget(app(compact: true));
    await settle(tester);
    title = tester.widget<Text>(
      find.descendant(
        of: find.byKey(ValueKey('todo-${todo.id}')),
        matching: find.text('字号测试'),
      ),
    );
    expect(title.style?.fontSize, 18);
    expect(find.byType(Draggable<TodoDragPayload>), findsOneWidget);
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

    expect(find.text('已将 1 项未完成任务顺延 1 天'), findsOneWidget);
    expect((await todos.getById(completed.id))?.localDate, date);
    final moved = await todos.getById(incomplete.id);
    expect(moved?.localDate, date.addDays(1));
    expect(moved?.plannedAt, DateTime(2026, 9, 5, 9).toUtc());
    expect(moved?.deadlineAt, DateTime(2026, 9, 5, 18).toUtc());
  });

  testWidgets('shares configured postpone days with single-task context menu', (
    tester,
  ) async {
    final todo = await todos.create(TodoDraft(title: '多日顺延', localDate: date));
    await tester.pumpWidget(app());
    await settle(tester);

    await tester.tap(
      find.byKey(const ValueKey('postpone-incomplete-todos')),
      buttons: kSecondaryMouseButton,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('postpone-days-field')),
      '3',
    );
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect((await settings.get(AppPreferenceKeys.postponeDays))?.value, '3');

    await tester.tap(
      find.descendant(
        of: find.byKey(ValueKey('todo-${todo.id}')),
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('将此任务顺延 3 天'));
    await tester.pumpAndSettle();
    expect((await todos.getById(todo.id))?.localDate, date.addDays(3));
  });

  testWidgets(
    'shows outlined category and filled tag before deadline metadata',
    (tester) async {
      const categoryColor = Color(0xFF476C5E);
      const tagColor = Color(0xFFF2D0A4);
      final category = Category(
        id: 'work',
        name: '工作',
        colorValue: categoryColor.toARGB32(),
        createdAt: now,
        updatedAt: now,
      );
      final tag = Tag(
        id: 'focus',
        name: '专注',
        colorValue: tagColor.toARGB32(),
        createdAt: now,
        updatedAt: now,
      );
      final todo = await todos.create(
        TodoDraft(
          title: '带元数据任务',
          localDate: date,
          categoryId: category.id,
          tagIds: {tag.id},
          notes: '这是一段很长、只应在列表里单行省略显示的备注内容',
          deadlineAt: DateTime(2026, 9, 4, 19, 25).toUtc(),
        ),
      );

      await tester.pumpWidget(app(categories: [category], tags: [tag]));
      await settle(tester);

      final categoryContainer = tester.widget<Container>(
        find
            .ancestor(of: find.text('工作'), matching: find.byType(Container))
            .first,
      );
      final tagContainer = tester.widget<Container>(
        find
            .ancestor(of: find.text('专注'), matching: find.byType(Container))
            .first,
      );
      final categoryDecoration = categoryContainer.decoration! as BoxDecoration;
      final tagDecoration = tagContainer.decoration! as BoxDecoration;
      expect(categoryDecoration.color, Colors.transparent);
      expect(categoryDecoration.border, isNotNull);
      expect(tagDecoration.color, tagColor);

      final row = find.byKey(ValueKey('todo-${todo.id}'));
      final notes = find.byKey(ValueKey('todo-notes-${todo.id}'));
      expect(notes, findsOneWidget);
      final notesText = tester.widget<Text>(notes);
      expect(notesText.maxLines, 1);
      expect(notesText.overflow, TextOverflow.ellipsis);
      expect(
        tester.getTopLeft(notes).dx,
        greaterThan(tester.getTopLeft(find.text('带元数据任务')).dx),
      );
      final categoryX = tester.getTopLeft(find.text('工作')).dx;
      final tagX = tester.getTopLeft(find.text('专注')).dx;
      final deadline = find.descendant(
        of: row,
        matching: find.textContaining('19:25'),
      );
      expect(categoryX, lessThan(tester.getTopLeft(deadline).dx));
      expect(tagX, lessThan(tester.getTopLeft(deadline).dx));
    },
  );

  testWidgets('catalog color palette supports adding and removing colors', (
    tester,
  ) async {
    await todos.create(TodoDraft(title: '调色任务', localDate: date));
    await tester.pumpWidget(app());
    await settle(tester);

    await tester.tap(find.text('调色任务'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('新建分类'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('palette-add-color')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('custom-color-preview')), findsOneWidget);

    await tester.drag(find.byType(Slider).first, const Offset(120, 0));
    await tester.pump();
    final colorDialog = find.byType(AlertDialog).last;
    await tester.tap(
      find.descendant(of: colorDialog, matching: find.text('保存')),
    );
    await tester.pumpAndSettle();
    final added = jsonDecode(
      (await settings.get(AppPreferenceKeys.catalogPalette))!.value,
    ) as List<dynamic>;
    expect(added.length, defaultCatalogPalette.length + 1);

    await tester.tap(find.byKey(const ValueKey('palette-remove-color')));
    await tester.pumpAndSettle();
    final removed = jsonDecode(
      (await settings.get(AppPreferenceKeys.catalogPalette))!.value,
    ) as List<dynamic>;
    expect(removed.length, defaultCatalogPalette.length);
  });

  testWidgets('double-click edits categories and deletes tags', (tester) async {
    final category = Category(
      id: 'work',
      name: '工作',
      colorValue: const Color(0xFF476C5E).toARGB32(),
      createdAt: now,
      updatedAt: now,
    );
    final tag = Tag(
      id: 'focus',
      name: '专注',
      colorValue: const Color(0xFFF2D0A4).toARGB32(),
      createdAt: now,
      updatedAt: now,
    );
    await todos.create(
      TodoDraft(
        title: '目录编辑任务',
        localDate: date,
        categoryId: category.id,
        tagIds: {tag.id},
      ),
    );
    await tester.pumpWidget(app(categories: [category], tags: [tag]));
    await settle(tester);
    await tester.tap(find.text('目录编辑任务'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('todo-editor-category')));
    await tester.pumpAndSettle();
    final categoryOption = find.byKey(const ValueKey('category-option-work'));
    await tester.tap(categoryOption);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(categoryOption);
    await tester.pumpAndSettle();
    expect(find.text('修改分类'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('catalog-name-field')),
      '项目',
    );
    await tester.tap(find.widgetWithText(FilledButton, '保存').last);
    await tester.pumpAndSettle();
    expect(categoryRepository.saved.single.name, '项目');

    final tagChip = find.byKey(const ValueKey('todo-editor-tag-focus'));
    await tester.tap(tagChip);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(tagChip);
    await tester.pumpAndSettle();
    expect(find.text('修改标签'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('catalog-delete')));
    await tester.pumpAndSettle();
    expect(find.text('确认删除？'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '删除标签'));
    await tester.pumpAndSettle();
    expect(tagRepository.deleted, ['focus']);
  });

  testWidgets('planned time uses the current task date without a date picker', (
    tester,
  ) async {
    final todo = await todos.create(TodoDraft(title: '只选时间', localDate: date));
    await tester.pumpWidget(app());
    await settle(tester);
    await tester.tap(find.text('只选时间'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('todo-editor-planned-at')));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
    expect(find.byType(DatePickerDialog), findsNothing);
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '保存').last);
    await tester.pumpAndSettle();

    final plannedAt = (await todos.getById(todo.id))!.plannedAt!.toLocal();
    expect(LocalDate(plannedAt.year, plannedAt.month, plannedAt.day), date);
  });
}

final class _MemoryCategoryRepository implements CategoryRepository {
  final saved = <Category>[];
  final deleted = <String>[];

  @override
  Future<List<Category>> getAll() async => saved;

  @override
  Future<Category> save(Category category) async {
    saved.add(category);
    return category;
  }

  @override
  Future<void> softDelete(String id, {DateTime? at}) async => deleted.add(id);

  @override
  Future<void> undoDelete(String id) async => deleted.remove(id);

  @override
  Stream<List<Category>> watchAll() => Stream.value(saved);
}

final class _MemoryTagRepository implements TagRepository {
  final saved = <Tag>[];
  final deleted = <String>[];

  @override
  Future<List<Tag>> getAll() async => saved;

  @override
  Future<Tag> save(Tag tag) async {
    saved.add(tag);
    return tag;
  }

  @override
  Future<void> softDelete(String id, {DateTime? at}) async => deleted.add(id);

  @override
  Future<void> undoDelete(String id) async => deleted.remove(id);

  @override
  Stream<List<Tag>> watchAll() => Stream.value(saved);
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
