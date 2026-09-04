import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../data/database/app_database.dart';
import '../domain/local_date.dart';
import '../domain/recurrence_series.dart';
import '../domain/repositories/recurrence_repository.dart';
import '../domain/repositories/todo_repository.dart';
import '../domain/todo_item.dart';

enum RecurrenceActionScope { occurrence, thisAndFuture }

final class RecurrenceActions {
  factory RecurrenceActions({
    required AppDatabase database,
    required TodoRepository todos,
    required RecurrenceRepository recurrences,
  }) => RecurrenceActions._(database, todos, recurrences);

  const RecurrenceActions._(this._database, this._todos, this._recurrences);

  final AppDatabase _database;
  final TodoRepository _todos;
  final RecurrenceRepository _recurrences;

  Future<TodoItem> saveFrom(
    TodoItem original,
    TodoItem updated, {
    required RecurrenceActionScope scope,
    RecurrenceRule? futureRule,
  }) async {
    final oldSeriesId = original.recurrenceSeriesId;
    if (oldSeriesId == null || scope == RecurrenceActionScope.occurrence) {
      return _todos.save(updated);
    }
    final occurrenceDate = original.occurrenceDate ?? original.localDate;
    await _recurrences.truncateBefore(oldSeriesId, occurrenceDate);
    await _softDeleteStoredAfter(oldSeriesId, occurrenceDate);
    if (futureRule == null) {
      return _todos.save(
        updated.copyWith(recurrenceSeriesId: null, occurrenceDate: null),
      );
    }
    final newSeries = await _recurrences.create(updated.localDate, futureRule);
    return _todos.save(
      updated.copyWith(
        recurrenceSeriesId: newSeries.id,
        occurrenceDate: updated.localDate,
      ),
    );
  }

  Future<void> delete(
    TodoItem todo, {
    required RecurrenceActionScope scope,
  }) async {
    final seriesId = todo.recurrenceSeriesId;
    if (seriesId == null || scope == RecurrenceActionScope.occurrence) {
      await _todos.softDelete(todo.id);
      return;
    }
    final occurrenceDate = todo.occurrenceDate ?? todo.localDate;
    await _recurrences.truncateBefore(seriesId, occurrenceDate);
    await _softDeleteStoredFrom(seriesId, occurrenceDate);
  }

  Future<void> _softDeleteStoredAfter(String seriesId, LocalDate date) {
    return _softDeleteStored(seriesId, date, inclusive: false);
  }

  Future<void> _softDeleteStoredFrom(String seriesId, LocalDate date) {
    return _softDeleteStored(seriesId, date, inclusive: true);
  }

  Future<void> _softDeleteStored(
    String seriesId,
    LocalDate date, {
    required bool inclusive,
  }) async {
    final now = systemUtcClock();
    final operator = inclusive ? '>=' : '>';
    await _database.customUpdate(
      'UPDATE todos SET deleted_at = ?, updated_at = ?, '
      'revision = revision + 1 '
      'WHERE recurrence_series_id = ? AND occurrence_date $operator ? '
      'AND deleted_at IS NULL',
      variables: [
        Variable<DateTime>(now),
        Variable<DateTime>(now),
        Variable<String>(seriesId),
        Variable<String>('$date'),
      ],
      updates: {_database.todos},
    );
  }
}
