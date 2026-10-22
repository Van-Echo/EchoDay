import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../app/platform/window_visibility.dart';
import '../../../app/router/app_routes.dart';
import '../../settings/application/app_preferences.dart';
import '../../todos/application/todo_providers.dart';
import '../../todos/domain/todo_item.dart';
import '../../todos/presentation/todo_transfer_menu.dart';

class FutureTodoTicker extends ConsumerWidget {
  const FutureTodoTicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = (ref.watch(futureTodosProvider).value ?? const <TodoItem>[])
        .where((todo) => !todo.isTerminal && !todo.isDeleted)
        .toList();
    if (todos.isEmpty) return const SizedBox.shrink();
    final interval =
        ref.watch(futureTodoTickerIntervalSecondsProvider).value ??
        defaultFutureTodoTickerIntervalSeconds;
    final numbered = ref.watch(futureTodoTickerNumberedProvider).value ?? false;
    return _FutureTodoTickerItems(
      todos: todos,
      intervalSeconds: interval,
      numbered: numbered,
    );
  }
}

class _FutureTodoTickerItems extends ConsumerStatefulWidget {
  const _FutureTodoTickerItems({
    required this.todos,
    required this.intervalSeconds,
    required this.numbered,
  });

  final List<TodoItem> todos;
  final int intervalSeconds;
  final bool numbered;

  @override
  ConsumerState<_FutureTodoTickerItems> createState() =>
      _FutureTodoTickerItemsState();
}

class _FutureTodoTickerItemsState
    extends ConsumerState<_FutureTodoTickerItems> {
  final _pages = PageController();
  Timer? _timer;
  bool _checkingVisibility = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.todos.length < 2) return;
    _timer = Timer.periodic(Duration(seconds: widget.intervalSeconds), (
      _,
    ) async {
      if (!mounted ||
          !_pages.hasClients ||
          _checkingVisibility ||
          !TickerMode.valuesOf(context).enabled ||
          MediaQuery.disableAnimationsOf(context) ||
          _pages.position.isScrollingNotifier.value) {
        return;
      }
      _checkingVisibility = true;
      try {
        final visible = await ref
            .read(windowVisibilityProbeProvider)
            .hasVisibleArea();
        if (!mounted ||
            !visible ||
            !_pages.hasClients ||
            !TickerMode.valuesOf(context).enabled) {
          return;
        }
        await _pages.nextPage(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      } on PlatformException {
        // Retry on the next tick if Windows is changing desktop/session.
      } finally {
        _checkingVisibility = false;
      }
    });
  }

  @override
  void didUpdateWidget(covariant _FutureTodoTickerItems oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.todos.map((todo) => todo.id).join(',') !=
            widget.todos.map((todo) => todo.id).join(',') ||
        oldWidget.intervalSeconds != widget.intervalSeconds) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Material(
      key: const ValueKey('future-todo-ticker'),
      color: colors.primaryContainer.withValues(alpha: 0.24),
      child: SizedBox(
        height: 36,
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Icon(
                Icons.upcoming_outlined,
                size: 16,
                color: colors.primary,
              ),
            ),
            Expanded(
              child: PageView.builder(
                key: const ValueKey('future-todo-ticker-pages'),
                controller: _pages,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  final todo = widget.todos[index % widget.todos.length];
                  final title = widget.numbered
                      ? '${index % widget.todos.length + 1}. ${todo.title}'
                      : todo.title;
                  return TodoTransferMenu(
                    todo: todo,
                    longPressMenu: true,
                    onTap: () => context.push(AppRoutes.futureTodos),
                    child: Tooltip(
                      message:
                          '${todo.title}\n${strings.futureTodosTickerHint}',
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          title,
                          key: ValueKey('future-ticker-task-${todo.id}'),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: 40,
              child: IconButton(
                tooltip: strings.futureTodosTitle,
                visualDensity: VisualDensity.compact,
                onPressed: () => context.push(AppRoutes.futureTodos),
                icon: const Icon(Icons.chevron_right_rounded, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
