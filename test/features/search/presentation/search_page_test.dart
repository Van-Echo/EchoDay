import 'package:drift/native.dart';
import 'package:echoday/src/app/echoday_app.dart';
import 'package:echoday/src/app/providers/data_providers.dart';
import 'package:echoday/src/data/database/app_database.dart';
import 'package:echoday/src/features/todos/application/todo_providers.dart';
import 'package:echoday/src/features/todos/data/local_todo_repository.dart';
import 'package:echoday/src/features/todos/domain/category.dart';
import 'package:echoday/src/features/todos/domain/local_date.dart';
import 'package:echoday/src/features/todos/domain/tag.dart';
import 'package:echoday/src/features/todos/domain/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/in_memory_settings_repository.dart';

void main() {
  testWidgets('searches text and opens the matching task on its day', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = LocalTodoRepository(database);
    final settings = InMemorySettingsRepository();
    final date = LocalDate(2026, 9, 4);
    final todo = await repository.create(
      TodoDraft(title: '准备发布说明', localDate: date, notes: 'EchoDay M4'),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          todoRepositoryProvider.overrideWithValue(repository),
          settingsRepositoryProvider.overrideWithValue(settings),
          categoriesProvider.overrideWith(
            (ref) => Stream.value(const <Category>[]),
          ),
          tagsProvider.overrideWith((ref) => Stream.value(const <Tag>[])),
          holidayYearProvider.overrideWith((ref, year) async => null),
          todosByDateProvider.overrideWith(
            (ref, selectedDate) => Stream.value(
              selectedDate == date ? [todo] : const <TodoItem>[],
            ),
          ),
        ],
        child: const EchoDayApp(locale: Locale('zh')),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(
      find.byKey(const ValueKey('global-search-field')),
      '发布说明',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('准备发布说明'), findsOneWidget);
    await tester.tap(find.text('准备发布说明'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('todo-editor-title')), findsOneWidget);
    expect(find.text('准备发布说明'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
  });
}
