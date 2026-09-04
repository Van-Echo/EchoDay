import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 9, 3);

  test('title is trimmed and blank content is rejected', () {
    final item = TodoItem(
      id: 'id',
      title: '  写周报  ',
      localDate: LocalDate(2026, 9, 3),
      createdAt: now,
      updatedAt: now,
    );

    expect(item.title, '写周报');
    expect(
      () => TodoDraft(title: '  ', localDate: LocalDate(2026, 9, 3)),
      throwsArgumentError,
    );
  });

  test('all instants must be UTC', () {
    expect(
      () => TodoItem(
        id: 'id',
        title: 'task',
        localDate: LocalDate(2026, 9, 3),
        createdAt: DateTime(2026, 9, 3),
        updatedAt: now,
      ),
      throwsArgumentError,
    );
  });

  test('completion flag and timestamp cannot diverge', () {
    expect(
      () => TodoItem(
        id: 'id',
        title: 'task',
        localDate: LocalDate(2026, 9, 3),
        isCompleted: true,
        createdAt: now,
        updatedAt: now,
      ),
      throwsArgumentError,
    );
  });
}
