import '../../todos/domain/category.dart';
import '../../todos/domain/recurrence_engine.dart';
import '../../todos/domain/recurrence_series.dart';
import '../../todos/domain/tag.dart';
import '../../todos/domain/todo_item.dart';

abstract final class SyncEntityPayloads {
  static Map<String, dynamic> todoContent(TodoItem item) => {
    'title': item.title,
    'localDate': item.localDate.toString(),
    'createdAtUtc': item.createdAt.toIso8601String(),
    'plannedAtUtc': item.plannedAt?.toIso8601String(),
    'priority': item.priority.index,
    'categoryId': item.categoryId,
    'notes': item.notes,
    'deadlineAtUtc': item.deadlineAt?.toIso8601String(),
    'timeZoneId': item.timeZoneId,
    'recurrenceSeriesId': item.recurrenceSeriesId,
    'occurrenceDate': item.occurrenceDate?.toString(),
  };

  static Map<String, dynamic> todoCompletion(TodoItem item) => {
    'isCompleted': item.isCompleted,
    'completedAtUtc': item.completedAt?.toIso8601String(),
  };

  static Map<String, dynamic> todoOrder(TodoItem item) => {
    'manualOrder': item.manualOrder,
  };

  static Map<String, dynamic> deletion(DateTime? deletedAt) => {
    'deletedAt': deletedAt?.toIso8601String(),
  };

  static Map<String, dynamic> categoryContent(Category category) => {
    'name': category.name,
    'colorValue': category.colorValue,
    'createdAtUtc': category.createdAt.toIso8601String(),
  };

  static Map<String, dynamic> categoryOrder(Category category) => {
    'sortOrder': category.sortOrder,
  };

  static Map<String, dynamic> tagContent(Tag tag) => {
    'name': tag.name,
    'colorValue': tag.colorValue,
    'createdAtUtc': tag.createdAt.toIso8601String(),
  };

  static Map<String, dynamic> tagOrder(Tag tag) => {'sortOrder': tag.sortOrder};

  static Map<String, dynamic> recurrenceSeriesContent(
    RecurrenceSeries series,
    RecurrenceRuleCodec codec,
  ) => {
    'startDate': series.startDate.toString(),
    'ruleJson': codec.encode(series.rule),
    'timeZoneId': series.timeZoneId,
    'createdAtUtc': series.createdAt.toIso8601String(),
  };

  static Map<String, dynamic> recurrenceExceptionContent({
    required String seriesId,
    required String occurrenceDate,
    required String? overrideJson,
    required bool isSkipped,
    required DateTime createdAt,
  }) => {
    'seriesId': seriesId,
    'occurrenceDate': occurrenceDate,
    'overrideJson': overrideJson,
    'isSkipped': isSkipped,
    'createdAtUtc': createdAt.toIso8601String(),
  };

  static Map<String, dynamic> todoTag({
    required String todoId,
    required String tagId,
    Iterable<String>? observedAddOperationIds,
  }) => {
    'todoId': todoId,
    'tagId': tagId,
    if (observedAddOperationIds != null)
      'observedAddOperationIds': observedAddOperationIds.toList(),
  };
}
