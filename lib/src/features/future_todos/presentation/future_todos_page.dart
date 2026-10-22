import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../app/widgets/app_scaffold.dart';
import '../../todos/domain/local_date.dart';
import '../../todos/presentation/day_todo_list.dart';

class FutureTodosPage extends ConsumerWidget {
  const FutureTodosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = LocalDate.fromDateTime(DateTime.now());
    final strings = AppLocalizations.of(context);
    return AppScaffold(
      selectedIndex: 2,
      title: strings.futureTodosTitle,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: DayTodoList(date: today, future: true),
        ),
      ),
    );
  }
}
