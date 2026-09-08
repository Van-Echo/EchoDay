import 'dart:io';

import 'package:drift/native.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/todos/application/move_todo_to_date.dart';
import 'package:echoday/src/features/todos/data/local_todo_repository.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const expectedZone = String.fromEnvironment('ECHODAY_EXPECTED_TIME_ZONE');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('moving a task preserves wall-clock time across device zones', (
    tester,
  ) async {
    if (!Platform.isAndroid || expectedZone.isEmpty) return;
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final now = DateTime.utc(2026, 3, 1);
    final todos = LocalTodoRepository(database, clock: () => now);
    final sourceDate = LocalDate(2026, 3, 7);
    final targetDate = LocalDate(2026, 3, 9);
    final sourceLocal = DateTime(2026, 3, 7, 9, 25);

    switch (expectedZone) {
      case 'Asia/Shanghai':
        expect(sourceLocal.timeZoneOffset, const Duration(hours: 8));
      case 'America/New_York':
        expect(sourceLocal.timeZoneOffset, const Duration(hours: -5));
        expect(
          DateTime(2026, 3, 9, 9, 25).timeZoneOffset,
          const Duration(hours: -4),
        );
      default:
        fail('Unsupported ECHODAY_EXPECTED_TIME_ZONE: $expectedZone');
    }

    final created = await todos.create(
      TodoDraft(
        title: '跨时区计划',
        localDate: sourceDate,
        plannedAt: sourceLocal.toUtc(),
        deadlineAt: DateTime(2026, 3, 7, 19, 45).toUtc(),
        timeZoneId: expectedZone,
      ),
    );
    final moved = await MoveTodoToDate(todos)(created, targetDate);

    expect(moved.localDate, targetDate);
    expect(moved.plannedAt?.toLocal().hour, 9);
    expect(moved.plannedAt?.toLocal().minute, 25);
    expect(moved.deadlineAt?.toLocal().hour, 19);
    expect(moved.deadlineAt?.toLocal().minute, 45);
    expect(moved.timeZoneId, expectedZone);
    if (expectedZone == 'America/New_York') {
      expect(moved.plannedAt, DateTime.utc(2026, 3, 9, 13, 25));
    } else {
      expect(moved.plannedAt, DateTime.utc(2026, 3, 9, 1, 25));
    }
  });
}
