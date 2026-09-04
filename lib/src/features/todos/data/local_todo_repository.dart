import 'package:drift/drift.dart';

import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../../data/database/app_database.dart';
import '../../holidays/data/holiday_year_codec.dart';
import '../../holidays/domain/holiday_workday_calendar.dart';
import '../domain/local_date.dart';
import '../domain/recurrence_engine.dart';
import '../domain/recurrence_series.dart';
import '../domain/repositories/todo_repository.dart';
import '../domain/todo_item.dart';
import '../domain/todo_priority.dart';
import '../domain/todo_search.dart';

final class TodoNotFoundException implements Exception {
  const TodoNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'TodoNotFoundException: $id';
}

final class LocalTodoRepository implements TodoRepository {
  factory LocalTodoRepository(
    AppDatabase database, {
    IdGenerator idGenerator = const UuidV7Generator(),
    UtcClock clock = systemUtcClock,
    RecurrenceEngine recurrenceEngine = const RecurrenceEngine(),
    RecurrenceRuleCodec recurrenceCodec = const RecurrenceRuleCodec(),
  }) => LocalTodoRepository._(
    database,
    idGenerator,
    clock,
    recurrenceEngine,
    recurrenceCodec,
  );

  LocalTodoRepository._(
    this._database,
    this._idGenerator,
    this._clock,
    this._recurrenceEngine,
    this._recurrenceCodec,
  );

  final AppDatabase _database;
  final IdGenerator _idGenerator;
  final UtcClock _clock;
  final RecurrenceEngine _recurrenceEngine;
  final RecurrenceRuleCodec _recurrenceCodec;

  static const _virtualPrefix = 'virtual:';

  @override
  Stream<List<TodoItem>> watchByDate(LocalDate date) {
    return _database
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _database.todos,
            _database.todoTags,
            _database.recurrenceSeriesEntries,
            _database.recurrenceExceptions,
            _database.holidayYears,
          },
        )
        .watch()
        .asyncMap((_) => _getByDateExpanded(date));
  }

  @override
  Future<List<TodoItem>> getByDate(LocalDate date) => _getByDateExpanded(date);

  Future<List<TodoItem>> _getStoredByDate(LocalDate date) async {
    final query =
        _database.select(_database.todos).join([
            leftOuterJoin(
              _database.todoTags,
              _database.todoTags.todoId.equalsExp(_database.todos.id),
            ),
          ])
          ..where(
            _database.todos.localDate.equals(date.toString()) &
                _database.todos.deletedAt.isNull(),
          )
          ..orderBy([
            OrderingTerm.asc(_database.todos.isCompleted),
            OrderingTerm.asc(_database.todos.manualOrder),
            OrderingTerm.asc(_database.todos.createdAt),
          ]);
    return _mapJoinedRows(await query.get());
  }

  @override
  Future<TodoItem?> getById(String id, {bool includeDeleted = false}) async {
    final virtual = _parseVirtualId(id);
    if (virtual != null) {
      final items = await _getByDateExpanded(virtual.date);
      return items.where((item) => item.id == id).firstOrNull;
    }
    final query = _database.select(_database.todos)
      ..where((table) {
        final idExpression = table.id.equals(id);
        return includeDeleted
            ? idExpression
            : idExpression & table.deletedAt.isNull();
      });
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _toDomain(row, await _tagIdsFor(id));
  }

  @override
  Future<TodoItem> create(TodoDraft draft) {
    return _database.transaction(() async {
      final now = requireUtc(_clock(), 'clock');
      final manualOrder =
          draft.manualOrder ??
          await _nextManualOrderForDate(draft.localDate.toString());
      final item = TodoItem(
        id: _idGenerator.next(),
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
        timeZoneId: draft.timeZoneId,
        manualOrder: manualOrder,
        recurrenceSeriesId: draft.recurrenceSeriesId,
        occurrenceDate: draft.occurrenceDate,
      );
      await _database.into(_database.todos).insert(_toCompanion(item));
      await _replaceTags(item.id, item.tagIds);
      return item;
    });
  }

  @override
  Future<TodoItem> save(TodoItem todo) {
    if (_parseVirtualId(todo.id) != null) {
      return _materialize(todo);
    }
    return _database.transaction(() async {
      final existing = await getById(todo.id, includeDeleted: true);
      if (existing == null) throw TodoNotFoundException(todo.id);
      final saved = todo.copyWith(
        updatedAt: requireUtc(_clock(), 'clock'),
        revision: existing.revision + 1,
      );
      await (_database.update(
        _database.todos,
      )..where((table) => table.id.equals(todo.id))).write(_toCompanion(saved));
      await _replaceTags(saved.id, saved.tagIds);
      return saved;
    });
  }

  @override
  Future<void> complete(String id, {DateTime? at}) async {
    final item = await _requireTodo(id);
    if (item.isCompleted) return;
    final completedAt = requireUtc(at ?? _clock(), 'at');
    await save(item.copyWith(isCompleted: true, completedAt: completedAt));
  }

  @override
  Future<void> restore(String id) async {
    final item = await _requireTodo(id);
    if (!item.isCompleted) return;
    await save(item.copyWith(isCompleted: false, completedAt: null));
  }

  @override
  Future<void> softDelete(String id, {DateTime? at}) async {
    final virtual = _parseVirtualId(id);
    if (virtual != null) {
      await _writeException(virtual.seriesId, virtual.date, isSkipped: true);
      return;
    }
    final item = await _requireTodo(id);
    await save(item.copyWith(deletedAt: requireUtc(at ?? _clock(), 'at')));
  }

  @override
  Future<void> undoDelete(String id) async {
    final virtual = _parseVirtualId(id);
    if (virtual != null) {
      await (_database.delete(_database.recurrenceExceptions)..where(
            (table) =>
                table.seriesId.equals(virtual.seriesId) &
                table.occurrenceDate.equals(virtual.date.toString()),
          ))
          .go();
      return;
    }
    final item = await getById(id, includeDeleted: true);
    if (item == null) throw TodoNotFoundException(id);
    if (!item.isDeleted) return;
    await save(item.copyWith(deletedAt: null));
  }

  @override
  Future<void> reorder(LocalDate date, List<String> orderedIds) {
    return _database.transaction(() async {
      if (orderedIds.toSet().length != orderedIds.length) {
        throw ArgumentError.value(orderedIds, 'orderedIds', 'has duplicates');
      }
      final resolvedIds = <String>[];
      for (final id in orderedIds) {
        final virtual = _parseVirtualId(id);
        if (virtual == null) {
          resolvedIds.add(id);
          continue;
        }
        final item = await getById(id);
        if (item == null) throw TodoNotFoundException(id);
        resolvedIds.add((await _materialize(item)).id);
      }
      final current = await getByDate(date);
      final currentIds = current.map((todo) => todo.id).toSet();
      if (currentIds.length != resolvedIds.length ||
          !currentIds.containsAll(resolvedIds)) {
        throw ArgumentError.value(
          orderedIds,
          'orderedIds',
          'must contain every active task for the date exactly once',
        );
      }
      final now = requireUtc(_clock(), 'clock');
      for (var index = 0; index < resolvedIds.length; index++) {
        await (_database.update(
          _database.todos,
        )..where((table) => table.id.equals(resolvedIds[index]))).write(
          TodosCompanion(
            manualOrder: Value(index.toDouble()),
            updatedAt: Value(now),
            revision: const Value.absent(),
          ),
        );
        await _database.customUpdate(
          'UPDATE todos SET revision = revision + 1 WHERE id = ?',
          variables: [Variable<String>(resolvedIds[index])],
          updates: {_database.todos},
        );
      }
    });
  }

  @override
  Future<TodoSearchPage> search(TodoSearchQuery query) async {
    if (query.offset < 0 || query.limit < 1) {
      throw ArgumentError('Search offset and limit are invalid.');
    }
    final todoQuery = _database.select(_database.todos).join([
      leftOuterJoin(
        _database.todoTags,
        _database.todoTags.todoId.equalsExp(_database.todos.id),
      ),
    ])..where(_database.todos.deletedAt.isNull());
    final storedItems = _mapJoinedRows(await todoQuery.get());
    final categories = {
      for (final category in await _database.select(_database.categories).get())
        category.id: category.name,
    };
    final tags = {
      for (final tag in await _database.select(_database.tags).get())
        tag.id: tag.name,
    };
    final loweredText = query.text.trim().toLowerCase();
    final matches = <TodoItem>[];
    for (final item in storedItems) {
      if (!_matchesFilters(item, query)) continue;
      if (loweredText.isNotEmpty) {
        final haystack = [
          item.title,
          item.notes ?? '',
          if (item.categoryId case final id?) categories[id] ?? '',
          ...item.tagIds.map((id) => tags[id] ?? ''),
        ].join('\n').toLowerCase();
        if (!haystack.contains(loweredText)) continue;
      }
      matches.add(item);
    }
    matches.sort((left, right) {
      final date = left.localDate.compareTo(right.localDate);
      return date != 0 ? date : left.createdAt.compareTo(right.createdAt);
    });
    final end = (query.offset + query.limit).clamp(0, matches.length);
    final items = query.offset >= matches.length
        ? const <TodoItem>[]
        : matches.sublist(query.offset, end);
    return SearchPage(items: items, hasMore: end < matches.length);
  }

  Future<List<TodoItem>> _getByDateExpanded(LocalDate date) async {
    final stored = await _getStoredByDate(date);
    final workdayCalendar = await _workdayCalendarFor(date.year);
    final seriesRows = await (_database.select(
      _database.recurrenceSeriesEntries,
    )..where((table) => table.deletedAt.isNull())).get();
    for (final row in seriesRows) {
      final series = RecurrenceSeries(
        id: row.id,
        startDate: LocalDate.parse(row.startDate),
        rule: _recurrenceCodec.decode(row.ruleJson),
        timeZoneId: row.timeZoneId,
        createdAt: row.createdAt.toUtc(),
        updatedAt: row.updatedAt.toUtc(),
        deletedAt: row.deletedAt?.toUtc(),
        revision: row.revision,
      );
      if (!_recurrenceEngine.occursOn(
        startDate: series.startDate,
        rule: series.rule,
        date: date,
        calendar: workdayCalendar,
      )) {
        continue;
      }
      if (await _hasOccurrenceRecord(series.id, date)) continue;
      final exception =
          await (_database.select(_database.recurrenceExceptions)..where(
                (table) =>
                    table.seriesId.equals(series.id) &
                    table.occurrenceDate.equals(date.toString()) &
                    table.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (exception?.isSkipped ?? false) continue;
      final template = await _templateForSeries(series.id);
      if (template == null) continue;
      stored.add(
        TodoItem(
          id: _virtualId(series.id, date),
          title: template.title,
          localDate: date,
          createdAt: template.createdAt,
          updatedAt: series.updatedAt,
          plannedAt: _shiftToDate(template.plannedAt, date),
          priority: template.priority,
          categoryId: template.categoryId,
          tagIds: template.tagIds,
          notes: template.notes,
          deadlineAt: _shiftToDate(template.deadlineAt, date),
          timeZoneId: template.timeZoneId,
          manualOrder: template.manualOrder,
          recurrenceSeriesId: series.id,
          occurrenceDate: date,
        ),
      );
    }
    return stored;
  }

  Future<WorkdayCalendar> _workdayCalendarFor(int year) async {
    final query = _database.select(_database.holidayYears)
      ..where((table) => table.year.equals(year));
    final row = await query.getSingleOrNull();
    if (row == null) return const WeekdayFallbackCalendar();
    try {
      final holidayYear = const HolidayYearCodec().decode(row.payloadJson);
      return HolidayWorkdayCalendar([holidayYear]);
    } on FormatException {
      return const WeekdayFallbackCalendar();
    }
  }

  Future<TodoItem?> _templateForSeries(String seriesId) async {
    final query = _database.select(_database.todos)
      ..where((table) => table.recurrenceSeriesId.equals(seriesId))
      ..orderBy([
        (table) => OrderingTerm.asc(table.occurrenceDate),
        (table) => OrderingTerm.asc(table.createdAt),
      ])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _toDomain(row, await _tagIdsFor(row.id));
  }

  Future<bool> _hasOccurrenceRecord(String seriesId, LocalDate date) async {
    final query = _database.select(_database.todos)
      ..where(
        (table) =>
            table.recurrenceSeriesId.equals(seriesId) &
            table.occurrenceDate.equals(date.toString()),
      )
      ..limit(1);
    return await query.getSingleOrNull() != null;
  }

  Future<TodoItem> _materialize(TodoItem virtualTodo) {
    return _database.transaction(() async {
      final now = requireUtc(_clock(), 'clock');
      final materialized = TodoItem(
        id: _idGenerator.next(),
        title: virtualTodo.title,
        localDate: virtualTodo.localDate,
        isCompleted: virtualTodo.isCompleted,
        createdAt: now,
        updatedAt: now,
        plannedAt: virtualTodo.plannedAt,
        priority: virtualTodo.priority,
        categoryId: virtualTodo.categoryId,
        tagIds: virtualTodo.tagIds,
        notes: virtualTodo.notes,
        deadlineAt: virtualTodo.deadlineAt,
        timeZoneId: virtualTodo.timeZoneId,
        completedAt: virtualTodo.completedAt,
        deletedAt: virtualTodo.deletedAt,
        manualOrder: await _nextManualOrderForDate(
          virtualTodo.localDate.toString(),
        ),
        recurrenceSeriesId: virtualTodo.recurrenceSeriesId,
        occurrenceDate: virtualTodo.occurrenceDate ?? virtualTodo.localDate,
      );
      await _database.into(_database.todos).insert(_toCompanion(materialized));
      await _replaceTags(materialized.id, materialized.tagIds);
      if (materialized.recurrenceSeriesId case final seriesId?) {
        await _writeException(
          seriesId,
          materialized.occurrenceDate!,
          overrideJson: '{"todoId":"${materialized.id}"}',
        );
      }
      return materialized;
    });
  }

  Future<void> _writeException(
    String seriesId,
    LocalDate date, {
    bool isSkipped = false,
    String? overrideJson,
  }) async {
    final existing =
        await (_database.select(_database.recurrenceExceptions)..where(
              (table) =>
                  table.seriesId.equals(seriesId) &
                  table.occurrenceDate.equals(date.toString()),
            ))
            .getSingleOrNull();
    final now = requireUtc(_clock(), 'clock');
    await _database
        .into(_database.recurrenceExceptions)
        .insertOnConflictUpdate(
          RecurrenceExceptionsCompanion(
            id: Value(existing?.id ?? _idGenerator.next()),
            seriesId: Value(seriesId),
            occurrenceDate: Value(date.toString()),
            overrideJson: Value(overrideJson),
            isSkipped: Value(isSkipped),
            createdAt: Value(existing?.createdAt.toUtc() ?? now),
            updatedAt: Value(now),
            deletedAt: const Value(null),
            revision: Value((existing?.revision ?? 0) + 1),
          ),
        );
  }

  DateTime? _shiftToDate(DateTime? value, LocalDate target) {
    if (value == null) return null;
    final local = value.toLocal();
    return DateTime(
      target.year,
      target.month,
      target.day,
      local.hour,
      local.minute,
      local.second,
      local.millisecond,
      local.microsecond,
    ).toUtc();
  }

  String _virtualId(String seriesId, LocalDate date) =>
      '$_virtualPrefix$seriesId:$date';

  _VirtualOccurrence? _parseVirtualId(String id) {
    if (!id.startsWith(_virtualPrefix) || id.length < 12) return null;
    final dateText = id.substring(id.length - 10);
    final separator = id.length - 11;
    if (separator < _virtualPrefix.length || id[separator] != ':') return null;
    try {
      return _VirtualOccurrence(
        id.substring(_virtualPrefix.length, separator),
        LocalDate.parse(dateText),
      );
    } on FormatException {
      return null;
    }
  }

  Future<TodoItem> _requireTodo(String id) async {
    final item = await getById(id);
    if (item == null) throw TodoNotFoundException(id);
    return item;
  }

  Future<Set<String>> _tagIdsFor(String todoId) async {
    final query = _database.select(_database.todoTags)
      ..where((table) => table.todoId.equals(todoId));
    return (await query.get()).map((row) => row.tagId).toSet();
  }

  Future<void> _replaceTags(String todoId, Set<String> tagIds) async {
    await (_database.delete(
      _database.todoTags,
    )..where((table) => table.todoId.equals(todoId))).go();
    for (final tagId in tagIds) {
      await _database
          .into(_database.todoTags)
          .insert(TodoTagsCompanion.insert(todoId: todoId, tagId: tagId));
    }
  }

  Future<double> _nextManualOrderForDate(String localDate) async {
    final rows =
        await (_database.select(_database.todos)..where(
              (table) =>
                  table.localDate.equals(localDate) & table.deletedAt.isNull(),
            ))
            .get();
    if (rows.isEmpty) return 0;
    return rows.map((row) => row.manualOrder).reduce((a, b) => a > b ? a : b) +
        1;
  }

  List<TodoItem> _mapJoinedRows(List<TypedResult> rows) {
    final todosById = <String, TodoRow>{};
    final tagsByTodo = <String, Set<String>>{};
    for (final result in rows) {
      final todo = result.readTable(_database.todos);
      todosById[todo.id] = todo;
      final relation = result.readTableOrNull(_database.todoTags);
      if (relation != null) {
        tagsByTodo.putIfAbsent(todo.id, () => {}).add(relation.tagId);
      }
    }
    return [
      for (final todo in todosById.values)
        _toDomain(todo, tagsByTodo[todo.id] ?? const {}),
    ];
  }

  TodoItem _toDomain(TodoRow row, Set<String> tagIds) {
    return TodoItem(
      id: row.id,
      title: row.title,
      localDate: LocalDate.parse(row.localDate),
      isCompleted: row.isCompleted,
      createdAt: row.createdAt.toUtc(),
      updatedAt: row.updatedAt.toUtc(),
      plannedAt: row.plannedAt?.toUtc(),
      priority: TodoPriority.values[row.priority],
      categoryId: row.categoryId,
      tagIds: tagIds,
      notes: row.notes,
      deadlineAt: row.deadlineAt?.toUtc(),
      timeZoneId: row.timeZoneId,
      completedAt: row.completedAt?.toUtc(),
      deletedAt: row.deletedAt?.toUtc(),
      manualOrder: row.manualOrder,
      revision: row.revision,
      recurrenceSeriesId: row.recurrenceSeriesId,
      occurrenceDate: row.occurrenceDate == null
          ? null
          : LocalDate.parse(row.occurrenceDate!),
    );
  }

  TodosCompanion _toCompanion(TodoItem item) {
    return TodosCompanion(
      id: Value(item.id),
      title: Value(item.title),
      localDate: Value(item.localDate.toString()),
      isCompleted: Value(item.isCompleted),
      createdAt: Value(item.createdAt),
      updatedAt: Value(item.updatedAt),
      plannedAt: Value(item.plannedAt),
      priority: Value(item.priority.index),
      categoryId: Value(item.categoryId),
      notes: Value(item.notes),
      deadlineAt: Value(item.deadlineAt),
      timeZoneId: Value(item.timeZoneId),
      completedAt: Value(item.completedAt),
      deletedAt: Value(item.deletedAt),
      manualOrder: Value(item.manualOrder),
      revision: Value(item.revision),
      recurrenceSeriesId: Value(item.recurrenceSeriesId),
      occurrenceDate: Value(item.occurrenceDate?.toString()),
    );
  }

  bool _matchesFilters(TodoItem item, TodoSearchQuery query) {
    if (query.completion == CompletionFilter.completed && !item.isCompleted) {
      return false;
    }
    if (query.completion == CompletionFilter.incomplete && item.isCompleted) {
      return false;
    }
    if (query.fromDate != null &&
        item.localDate.compareTo(query.fromDate!) < 0) {
      return false;
    }
    if (query.toDate != null && item.localDate.compareTo(query.toDate!) > 0) {
      return false;
    }
    if (query.categoryId != null && item.categoryId != query.categoryId) {
      return false;
    }
    if (!item.tagIds.containsAll(query.tagIds)) return false;
    return true;
  }
}

final class _VirtualOccurrence {
  const _VirtualOccurrence(this.seriesId, this.date);

  final String seriesId;
  final LocalDate date;
}
