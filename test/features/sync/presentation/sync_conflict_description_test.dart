import 'package:echoday/l10n/app_localizations_en.dart';
import 'package:echoday/l10n/app_localizations_zh.dart';
import 'package:echoday/src/features/sync/domain/sync_merge_engine.dart';
import 'package:echoday/src/features/sync/domain/sync_protocol.dart';
import 'package:echoday/src/features/sync/presentation/sync_conflict_description.dart';
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
    losingPayload: {
      'title': '手机上编辑的任务',
      'localDate': '2026-09-16',
      'priority': 0,
      'notes': '需要确认',
    },
  );

  test('Chinese conflict summary contains readable values, not JSON', () {
    final description = SyncConflictDescription.from(
      conflict,
      AppLocalizationsZh(),
    );
    expect(description.title, '任务 · 内容');
    expect(description.details, contains('内容：手机上编辑的任务'));
    expect(description.details, contains('所属日期：2026-09-16'));
    expect(description.details, contains('优先级：高'));
    expect(description.details, isNot(contains('"title"')));
  });

  test('English conflict summary uses translated labels', () {
    final description = SyncConflictDescription.from(
      conflict,
      AppLocalizationsEn(),
    );
    expect(description.title, 'Task · Content');
    expect(description.details, contains('Content: 手机上编辑的任务'));
    expect(description.details, contains('Priority: High'));
  });
}
