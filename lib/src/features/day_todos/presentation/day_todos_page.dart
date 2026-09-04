import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../app/providers/data_providers.dart';
import '../../../app/router/app_routes.dart';
import '../../todos/domain/local_date.dart';
import '../../todos/presentation/day_todo_list.dart';
import '../../todos/presentation/todo_editor.dart';

class DayTodosPage extends ConsumerStatefulWidget {
  const DayTodosPage({required this.date, this.openTodoId, super.key});

  final String date;
  final String? openTodoId;

  @override
  ConsumerState<DayTodosPage> createState() => _DayTodosPageState();
}

class _DayTodosPageState extends ConsumerState<DayTodosPage> {
  var _openRequestedTaskScheduled = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    LocalDate parsedDate;
    try {
      parsedDate = LocalDate.parse(widget.date);
    } on FormatException {
      parsedDate = LocalDate.fromDateTime(DateTime.now());
    }
    _scheduleRequestedTask(parsedDate);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final title = DateFormat.yMMMMEEEEd(locale)
        .format(DateTime(parsedDate.year, parsedDate.month, parsedDate.day));
    void goBack() => context.go(AppRoutes.calendar);

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): goBack},
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: localizations.backToCalendar,
              onPressed: goBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: Text(title),
            actions: [
              IconButton(
                tooltip: localizations.addTask,
                onPressed: () => showTodoEditor(context, ref, date: parsedDate),
                icon: const Icon(Icons.add_rounded),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: DayTodoList(date: parsedDate),
            ),
          ),
        ),
      ),
    );
  }

  void _scheduleRequestedTask(LocalDate date) {
    final id = widget.openTodoId;
    if (_openRequestedTaskScheduled || id == null) return;
    _openRequestedTaskScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final todo = await ref.read(todoRepositoryProvider).getById(id);
      if (!mounted || todo == null) return;
      await showTodoEditor(context, ref, date: date, todo: todo);
    });
  }
}
