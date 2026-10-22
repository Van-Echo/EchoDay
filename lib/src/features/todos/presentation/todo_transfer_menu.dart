import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../app/platform/platform_capabilities.dart';
import '../../../app/providers/data_providers.dart';
import '../../../app/widgets/app_snack_bar.dart';
import '../application/todo_providers.dart';
import '../domain/local_date.dart';
import '../domain/todo_item.dart';

enum TodoTransferAction { copyToTomorrow, moveToFuture, moveToToday }

String todoTransferLabel(AppLocalizations strings, TodoTransferAction action) =>
    switch (action) {
      TodoTransferAction.copyToTomorrow => strings.copyToTomorrow,
      TodoTransferAction.moveToFuture => strings.moveToFuture,
      TodoTransferAction.moveToToday => strings.moveToToday,
    };

IconData todoTransferIcon(TodoTransferAction action) => switch (action) {
  TodoTransferAction.copyToTomorrow => Icons.content_copy_rounded,
  TodoTransferAction.moveToFuture => Icons.upcoming_outlined,
  TodoTransferAction.moveToToday => Icons.today_rounded,
};

Future<void> runTodoTransferAction(
  BuildContext context,
  WidgetRef ref,
  TodoItem todo,
  TodoTransferAction action,
) async {
  final strings = AppLocalizations.of(context);
  try {
    switch (action) {
      case TodoTransferAction.copyToTomorrow:
        await ref.read(todoTransfersProvider).copyToTomorrow(todo);
      case TodoTransferAction.moveToFuture:
        await ref.read(todoTransfersProvider).moveToFuture(todo);
      case TodoTransferAction.moveToToday:
        final latest = await ref.read(todoRepositoryProvider).getById(todo.id);
        if (latest == null) throw StateError('Task no longer exists.');
        await ref
            .read(moveTodoToDateProvider)
            .call(latest, LocalDate.fromDateTime(DateTime.now()));
    }
    if (!context.mounted) return;
    showAppSnackBar(context, switch (action) {
      TodoTransferAction.copyToTomorrow => strings.taskCopiedToTomorrow,
      TodoTransferAction.moveToFuture => strings.taskMovedToFuture,
      TodoTransferAction.moveToToday => strings.taskMovedToDate(
        LocalDate.fromDateTime(DateTime.now()).toString(),
      ),
    });
  } catch (_) {
    if (context.mounted) showAppSnackBar(context, strings.taskActionFailed);
  }
}

/// Pointer users get a context menu; touch users can tap calendar previews to
/// open the same operations without competing with long-press drag gestures.
class TodoTransferMenu extends ConsumerWidget {
  const TodoTransferMenu({
    required this.todo,
    required this.child,
    this.onTap,
    this.longPressMenu = false,
    super.key,
  });

  final TodoItem todo;
  final Widget child;
  final VoidCallback? onTap;
  final bool longPressMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) =>
          _show(context, ref, details.globalPosition),
      onTap:
          onTap ??
          (ref.watch(platformCapabilitiesProvider).isAndroid
              ? () => _show(context, ref, null)
              : null),
      onLongPress: longPressMenu ? () => _show(context, ref, null) : null,
      child: child,
    );
  }

  Future<void> _show(
    BuildContext context,
    WidgetRef ref,
    Offset? position,
  ) async {
    final strings = AppLocalizations.of(context);
    final actions = todo.isFuture
        ? [TodoTransferAction.moveToToday]
        : [TodoTransferAction.copyToTomorrow, TodoTransferAction.moveToFuture];
    final TodoTransferAction? selected;
    if (position == null) {
      selected = await showModalBottomSheet<TodoTransferAction>(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                todo.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            for (final action in actions)
              ListTile(
                leading: Icon(todoTransferIcon(action)),
                title: Text(todoTransferLabel(strings, action)),
                onTap: () => Navigator.pop(context, action),
              ),
            const SizedBox(height: 12),
          ],
        ),
      );
    } else {
      final overlay =
          Overlay.of(context).context.findRenderObject()! as RenderBox;
      selected = await showMenu<TodoTransferAction>(
        context: context,
        position: RelativeRect.fromRect(
          Rect.fromLTWH(position.dx, position.dy, 0, 0),
          Offset.zero & overlay.size,
        ),
        items: [
          for (final action in actions)
            PopupMenuItem(
              value: action,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(todoTransferIcon(action)),
                title: Text(todoTransferLabel(strings, action)),
              ),
            ),
        ],
      );
    }
    if (selected != null && context.mounted) {
      await runTodoTransferAction(context, ref, todo, selected);
    }
  }
}
