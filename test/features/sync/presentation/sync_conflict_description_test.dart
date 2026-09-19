import 'package:echoday/l10n/app_localizations.dart';
import 'package:echoday/l10n/app_localizations_en.dart';
import 'package:echoday/l10n/app_localizations_zh.dart';
import 'package:echoday/src/features/sync/domain/sync_merge_engine.dart';
import 'package:echoday/src/features/sync/domain/sync_protocol.dart';
import 'package:echoday/src/features/sync/presentation/sync_conflict_comparison.dart';
import 'package:echoday/src/features/sync/presentation/sync_conflict_description.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const conflict = SyncConflict(
    id: 'conflict-1',
    kind: SyncConflictKind.concurrentFieldEdit,
    entityType: SyncEntityType.todo,
    entityId: 'todo-1',
    fieldGroup: SyncFieldGroup.content,
    winnerOperationId: 'winner',
    loserOperationId: 'loser',
    winningPayload: {
      'title': '主 PC 上编辑的任务',
      'localDate': '2026-09-17',
      'priority': 2,
    },
    losingPayload: {
      'title': '手机上编辑的任务',
      'localDate': '2026-09-16',
      'priority': 0,
      'notes': '需要确认',
    },
    winnerSourceDeviceId: 'host',
    loserSourceDeviceId: 'phone',
    localDeviceId: 'phone',
    hostDeviceId: 'host',
  );

  test('Chinese comparison names both devices and task versions', () {
    final description = SyncConflictDescription.from(
      conflict,
      AppLocalizationsZh(),
    );
    expect(description.title, '任务 · 内容');
    expect(description.versions.first.label, '本地端');
    expect(description.versions.first.summary, '手机上编辑的任务');
    expect(description.versions.first.details, contains('所属日期：2026-09-16'));
    expect(description.versions.first.details, contains('优先级：高'));
    expect(description.versions.first.useLosingVersion, isTrue);
    expect(description.versions.last.label, '主 PC 端');
    expect(description.versions.last.summary, '主 PC 上编辑的任务');
    expect(description.versions.last.useLosingVersion, isFalse);
    expect(description.versions.first.details, isNot(contains('"title"')));
  });

  test('English conflict summary uses translated labels', () {
    final description = SyncConflictDescription.from(
      conflict,
      AppLocalizationsEn(),
    );
    expect(description.title, 'Task · Content');
    expect(description.versions.first.label, 'This device');
    expect(description.versions.first.summary, '手机上编辑的任务');
    expect(description.versions.first.details, contains('Priority: High'));
    expect(description.versions.last.label, 'Host PC');
  });

  test('completion conflict repeats the task title on both sides', () {
    const completion = SyncConflict(
      id: 'completion-1',
      kind: SyncConflictKind.concurrentFieldEdit,
      entityType: SyncEntityType.todo,
      entityId: 'todo-1',
      fieldGroup: SyncFieldGroup.completion,
      winnerOperationId: 'winner',
      loserOperationId: 'loser',
      winningPayload: {'isCompleted': true},
      losingPayload: {'isCompleted': false},
      entitySummary: '完成 EchoDay 开发',
      winnerSourceDeviceId: 'host',
      loserSourceDeviceId: 'phone',
      localDeviceId: 'phone',
      hostDeviceId: 'host',
    );
    final description = SyncConflictDescription.from(
      completion,
      AppLocalizationsZh(),
    );
    expect(description.versions.first.summary, '完成 EchoDay 开发');
    expect(description.versions.first.details, contains('完成状态：未完成'));
    expect(description.versions.last.summary, '完成 EchoDay 开发');
    expect(description.versions.last.details, contains('完成状态：已完成'));
  });

  testWidgets('comparison shows two task summaries and lets either side win', (
    tester,
  ) async {
    final choices = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SyncConflictComparison(
            description: SyncConflictDescription.from(
              conflict,
              AppLocalizationsZh(),
            ),
            onChoose: (useLosingVersion) async {
              choices.add(useLosingVersion);
            },
          ),
        ),
      ),
    );
    expect(find.text('本地端：【手机上编辑的任务】'), findsOneWidget);
    expect(find.text('主 PC 端：【主 PC 上编辑的任务】'), findsOneWidget);
    expect(find.text('使用此版本'), findsNWidgets(2));
    await tester.tap(find.text('使用此版本').first);
    await tester.tap(find.text('使用此版本').last);
    expect(choices, [true, false]);
  });
}
