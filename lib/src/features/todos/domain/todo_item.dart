import '../../../core/time/clock.dart';
import 'local_date.dart';
import 'todo_priority.dart';

const _unset = Object();

final class TodoItem {
  TodoItem({
    required this.id,
    required String title,
    required this.localDate,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.plannedAt,
    this.priority = TodoPriority.none,
    this.categoryId,
    Set<String> tagIds = const {},
    this.notes,
    this.deadlineAt,
    this.timeZoneId,
    this.completedAt,
    this.deletedAt,
    this.manualOrder = 0,
    this.revision = 1,
    this.recurrenceSeriesId,
    this.occurrenceDate,
  }) : title = title.trim(),
       tagIds = Set.unmodifiable(tagIds) {
    if (id.isEmpty) throw ArgumentError.value(id, 'id', 'must not be empty');
    if (this.title.isEmpty) {
      throw ArgumentError.value(title, 'title', 'must not be blank');
    }
    requireUtc(createdAt, 'createdAt');
    requireUtc(updatedAt, 'updatedAt');
    if (plannedAt != null) requireUtc(plannedAt!, 'plannedAt');
    if (deadlineAt != null) requireUtc(deadlineAt!, 'deadlineAt');
    if (completedAt != null) requireUtc(completedAt!, 'completedAt');
    if (deletedAt != null) requireUtc(deletedAt!, 'deletedAt');
    if (revision < 1) {
      throw ArgumentError.value(revision, 'revision', 'must be positive');
    }
    if (!manualOrder.isFinite) {
      throw ArgumentError.value(manualOrder, 'manualOrder', 'must be finite');
    }
    if (isCompleted != (completedAt != null)) {
      throw ArgumentError(
        'isCompleted and completedAt must represent the same state.',
      );
    }
  }

  final String id;
  final String title;
  final LocalDate localDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? plannedAt;
  final TodoPriority priority;
  final String? categoryId;
  final Set<String> tagIds;
  final String? notes;
  final DateTime? deadlineAt;
  final String? timeZoneId;
  final DateTime? completedAt;
  final DateTime? deletedAt;
  final double manualOrder;
  final int revision;
  final String? recurrenceSeriesId;
  final LocalDate? occurrenceDate;

  bool get isDeleted => deletedAt != null;

  bool isOverdueAt(DateTime nowUtc) {
    requireUtc(nowUtc, 'nowUtc');
    return !isCompleted &&
        !isDeleted &&
        deadlineAt != null &&
        nowUtc.isAfter(deadlineAt!);
  }

  TodoItem copyWith({
    String? title,
    LocalDate? localDate,
    bool? isCompleted,
    DateTime? updatedAt,
    Object? plannedAt = _unset,
    TodoPriority? priority,
    Object? categoryId = _unset,
    Set<String>? tagIds,
    Object? notes = _unset,
    Object? deadlineAt = _unset,
    Object? timeZoneId = _unset,
    Object? completedAt = _unset,
    Object? deletedAt = _unset,
    double? manualOrder,
    int? revision,
    Object? recurrenceSeriesId = _unset,
    Object? occurrenceDate = _unset,
  }) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      localDate: localDate ?? this.localDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      plannedAt: identical(plannedAt, _unset)
          ? this.plannedAt
          : plannedAt as DateTime?,
      priority: priority ?? this.priority,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      tagIds: tagIds ?? this.tagIds,
      notes: identical(notes, _unset) ? this.notes : notes as String?,
      deadlineAt: identical(deadlineAt, _unset)
          ? this.deadlineAt
          : deadlineAt as DateTime?,
      timeZoneId: identical(timeZoneId, _unset)
          ? this.timeZoneId
          : timeZoneId as String?,
      completedAt: identical(completedAt, _unset)
          ? this.completedAt
          : completedAt as DateTime?,
      deletedAt: identical(deletedAt, _unset)
          ? this.deletedAt
          : deletedAt as DateTime?,
      manualOrder: manualOrder ?? this.manualOrder,
      revision: revision ?? this.revision,
      recurrenceSeriesId: identical(recurrenceSeriesId, _unset)
          ? this.recurrenceSeriesId
          : recurrenceSeriesId as String?,
      occurrenceDate: identical(occurrenceDate, _unset)
          ? this.occurrenceDate
          : occurrenceDate as LocalDate?,
    );
  }
}

final class TodoDraft {
  TodoDraft({
    required String title,
    required this.localDate,
    this.plannedAt,
    this.priority = TodoPriority.none,
    this.categoryId,
    Set<String> tagIds = const {},
    this.notes,
    this.deadlineAt,
    this.timeZoneId,
    this.manualOrder,
    this.recurrenceSeriesId,
    this.occurrenceDate,
  }) : title = title.trim(),
       tagIds = Set.unmodifiable(tagIds) {
    if (this.title.isEmpty) {
      throw ArgumentError.value(title, 'title', 'must not be blank');
    }
    if (plannedAt != null) requireUtc(plannedAt!, 'plannedAt');
    if (deadlineAt != null) requireUtc(deadlineAt!, 'deadlineAt');
  }

  final String title;
  final LocalDate localDate;
  final DateTime? plannedAt;
  final TodoPriority priority;
  final String? categoryId;
  final Set<String> tagIds;
  final String? notes;
  final DateTime? deadlineAt;
  final String? timeZoneId;
  final double? manualOrder;
  final String? recurrenceSeriesId;
  final LocalDate? occurrenceDate;
}
