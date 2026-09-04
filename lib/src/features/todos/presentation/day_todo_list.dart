import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../app/providers/data_providers.dart';
import '../application/recurrence_actions.dart';
import '../application/todo_providers.dart';
import '../domain/category.dart';
import '../domain/local_date.dart';
import '../domain/tag.dart';
import '../domain/todo_item.dart';
import '../domain/todo_priority.dart';
import '../domain/todo_sort.dart';
import 'todo_editor.dart';

Future<void> showQuickAddTodoDialog(
  BuildContext context,
  WidgetRef ref,
  LocalDate date,
) async {
  final localizations = AppLocalizations.of(context);
  final controller = TextEditingController();
  final title = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(localizations.quickAddTitle),
      content: TextField(
        controller: controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(hintText: localizations.todoTitleHint),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) Navigator.of(context).pop(value.trim());
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        FilledButton(
          onPressed: () {
            final value = controller.text.trim();
            if (value.isNotEmpty) Navigator.of(context).pop(value);
          },
          child: Text(localizations.addTask),
        ),
      ],
    ),
  );
  controller.dispose();
  if (title == null || title.isEmpty) return;
  await ref
      .read(todoRepositoryProvider)
      .create(TodoDraft(title: title, localDate: date));
}

class DayTodoList extends ConsumerStatefulWidget {
  const DayTodoList({required this.date, this.compact = false, super.key});

  final LocalDate date;
  final bool compact;

  @override
  ConsumerState<DayTodoList> createState() => _DayTodoListState();
}

class _DayTodoListState extends ConsumerState<DayTodoList> {
  bool _completedExpanded = false;
  bool _postponing = false;
  String? _categoryFilter;
  Set<String> _tagFilters = {};

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final todos = ref.watch(todosByDateProvider(widget.date));
    final sortMode =
        ref.watch(todoSortModeProvider).value ?? TodoSortMode.composite;
    final categories =
        ref.watch(categoriesProvider).value ?? const <Category>[];
    final tags = ref.watch(tagsProvider).value ?? const <Tag>[];
    final now = ref.watch(currentTimeProvider).value ?? DateTime.now().toUtc();
    final filteredItems = todos.value?.where((todo) {
      if (_categoryFilter != null && todo.categoryId != _categoryFilter) {
        return false;
      }
      return todo.tagIds.containsAll(_tagFilters);
    }).toList();
    return Column(
      children: [
        _SortToolbar(
          compact: widget.compact,
          mode: sortMode,
          categories: categories,
          tags: tags,
          filters: _TodoFilters(_categoryFilter, _tagFilters),
          canPostpone:
              !_postponing &&
              (todos.value?.any((todo) => !todo.isCompleted) ?? false),
          onPostpone: _postponeIncomplete,
          onFiltersChanged: (filters) => setState(() {
            _categoryFilter = filters.categoryId;
            _tagFilters = {...filters.tagIds};
          }),
        ),
        Expanded(
          child: todos.when(
            data: (items) => _buildList(
              context,
              filteredItems ?? items,
              sortMode,
              categories,
              tags,
              now,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(strings.todoLoadFailed),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _postponeIncomplete() async {
    final strings = AppLocalizations.of(context);
    final count = (ref.read(todosByDateProvider(widget.date)).value ?? const [])
        .where((todo) => !todo.isCompleted)
        .length;
    if (count == 0 || _postponing) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.postponeDialogTitle),
        content: Text(
          strings.postponeDialogBody(count, widget.date.addDays(1).toString()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.postponeAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _postponing = true);
    try {
      final moved = await ref
          .read(postponeIncompleteTodosProvider)
          .call(widget.date);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.postponedTasks(moved))));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.taskActionFailed)));
    } finally {
      if (mounted) setState(() => _postponing = false);
    }
  }

  Widget _buildList(
    BuildContext context,
    List<TodoItem> items,
    TodoSortMode sortMode,
    List<Category> categories,
    List<Tag> tags,
    DateTime now,
  ) {
    final strings = AppLocalizations.of(context);
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_note_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(height: 12),
              Text(
                strings.noTasksForDate,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    showTodoEditor(context, ref, date: widget.date),
                icon: const Icon(Icons.add_rounded),
                label: Text(strings.addTask),
              ),
            ],
          ),
        ),
      );
    }

    final incomplete = items.where((todo) => !todo.isCompleted).toList();
    final completed = items.where((todo) => todo.isCompleted).toList();
    final manual = sortMode == TodoSortMode.manual;
    if (manual) {
      return CustomScrollView(
        slivers: [
          _sectionHeaderSliver(
            _SectionHeader(
              label: strings.incompleteTasks,
              count: incomplete.length,
            ),
          ),
          if (incomplete.isNotEmpty)
            _reorderableSectionSliver(
              incomplete,
              now,
              categories,
              tags,
              (oldIndex, newIndex) => _reorderSection(
                incomplete,
                completed,
                oldIndex,
                newIndex,
                completedSection: false,
              ),
            ),
          if (completed.isNotEmpty)
            _sectionHeaderSliver(
              _SectionHeader(
                label: strings.completedTasks,
                count: completed.length,
                expanded: _completedExpanded,
                onTap: () =>
                    setState(() => _completedExpanded = !_completedExpanded),
              ),
              top: 10,
            ),
          if (_completedExpanded && completed.isNotEmpty)
            _reorderableSectionSliver(
              completed,
              now,
              categories,
              tags,
              (oldIndex, newIndex) => _reorderSection(
                incomplete,
                completed,
                oldIndex,
                newIndex,
                completedSection: true,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      );
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(
        widget.compact ? 8 : 16,
        4,
        widget.compact ? 8 : 16,
        16,
      ),
      children: [
        _SectionHeader(
          label: strings.incompleteTasks,
          count: incomplete.length,
        ),
        if (incomplete.isEmpty)
          const SizedBox(height: 4)
        else
          _TodoSection(
            todos: incomplete,
            compact: widget.compact,
            now: now,
            categories: categories,
            tags: tags,
          ),
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 10),
          _SectionHeader(
            label: strings.completedTasks,
            count: completed.length,
            expanded: _completedExpanded,
            onTap: () =>
                setState(() => _completedExpanded = !_completedExpanded),
          ),
          if (_completedExpanded)
            _TodoSection(
              todos: completed,
              compact: widget.compact,
              now: now,
              categories: categories,
              tags: tags,
            ),
        ],
      ],
    );
  }

  Widget _sectionHeaderSliver(Widget header, {double top = 0}) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        widget.compact ? 8 : 16,
        top,
        widget.compact ? 8 : 16,
        0,
      ),
      sliver: SliverToBoxAdapter(child: header),
    );
  }

  Widget _reorderableSectionSliver(
    List<TodoItem> todos,
    DateTime now,
    List<Category> categories,
    List<Tag> tags,
    ReorderCallback onReorder,
  ) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: widget.compact ? 8 : 16),
      sliver: SliverReorderableList(
        itemCount: todos.length,
        onReorderItem: onReorder,
        itemBuilder: (context, index) => Padding(
          key: ValueKey('todo-${todos[index].id}'),
          padding: EdgeInsets.only(bottom: index == todos.length - 1 ? 0 : 4),
          child: _TodoListTile(
            todo: todos[index],
            compact: widget.compact,
            now: now,
            categories: categories,
            tags: tags,
            dragHandle: ReorderableDragStartListener(
              index: index,
              child: Tooltip(
                message: AppLocalizations.of(context).dragToReorder,
                child: const MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.drag_indicator_rounded, size: 18),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _reorderSection(
    List<TodoItem> incomplete,
    List<TodoItem> completed,
    int oldIndex,
    int newIndex, {
    required bool completedSection,
  }) async {
    final target = [...(completedSection ? completed : incomplete)];
    final moved = target.removeAt(oldIndex);
    target.insert(newIndex, moved);
    final ordered = completedSection
        ? [...incomplete, ...target]
        : [...target, ...completed];
    try {
      await ref
          .read(todoRepositoryProvider)
          .reorder(widget.date, ordered.map((todo) => todo.id).toList());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).taskActionFailed)),
      );
    }
  }
}

class _SortToolbar extends ConsumerWidget {
  const _SortToolbar({
    required this.compact,
    required this.mode,
    required this.categories,
    required this.tags,
    required this.filters,
    required this.canPostpone,
    required this.onPostpone,
    required this.onFiltersChanged,
  });

  final bool compact;
  final TodoSortMode mode;
  final List<Category> categories;
  final List<Tag> tags;
  final _TodoFilters filters;
  final bool canPostpone;
  final VoidCallback onPostpone;
  final ValueChanged<_TodoFilters> onFiltersChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final compactIconStyle = compact
        ? IconButton.styleFrom(
            minimumSize: const Size.square(36),
            maximumSize: const Size.square(36),
            padding: const EdgeInsets.all(6),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          )
        : null;
    return SizedBox(
      height: compact ? 42 : 48,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 12),
        child: Row(
          children: [
            if (!compact) ...[
              Icon(
                Icons.sort_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${strings.sortTasks} · ${_sortName(strings, mode)}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ] else
              const Spacer(),
            IconButton(
              key: const ValueKey('postpone-incomplete-todos'),
              tooltip: strings.postponeIncomplete,
              onPressed: canPostpone ? onPostpone : null,
              style: compactIconStyle,
              icon: const Icon(Icons.next_plan_outlined),
            ),
            IconButton(
              tooltip: strings.filterTasks,
              style: compactIconStyle,
              onPressed: () async {
                final result = await showDialog<_TodoFilters>(
                  context: context,
                  builder: (context) => _TodoFilterDialog(
                    categories: categories,
                    tags: tags,
                    initial: filters,
                  ),
                );
                if (result != null) onFiltersChanged(result);
              },
              icon: Badge(
                isLabelVisible: filters.count > 0,
                label: Text('${filters.count}'),
                child: Icon(
                  filters.count > 0
                      ? Icons.filter_alt_rounded
                      : Icons.filter_alt_outlined,
                ),
              ),
            ),
            PopupMenuButton<TodoSortMode>(
              key: const ValueKey('todo-sort-menu'),
              tooltip: strings.sortTasks,
              style: compactIconStyle,
              initialValue: mode,
              onSelected: (value) => setTodoSortMode(ref, value),
              itemBuilder: (context) => [
                for (final candidate in TodoSortMode.values)
                  CheckedPopupMenuItem(
                    value: candidate,
                    checked: candidate == mode,
                    child: Text(_sortName(strings, candidate)),
                  ),
              ],
              icon: const Icon(Icons.sort_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

final class _TodoFilters {
  const _TodoFilters(this.categoryId, this.tagIds);

  final String? categoryId;
  final Set<String> tagIds;

  int get count => (categoryId == null ? 0 : 1) + tagIds.length;
}

class _TodoFilterDialog extends StatefulWidget {
  const _TodoFilterDialog({
    required this.categories,
    required this.tags,
    required this.initial,
  });

  final List<Category> categories;
  final List<Tag> tags;
  final _TodoFilters initial;

  @override
  State<_TodoFilterDialog> createState() => _TodoFilterDialogState();
}

class _TodoFilterDialogState extends State<_TodoFilterDialog> {
  late String? _categoryId = widget.initial.categoryId;
  late final Set<String> _tagIds = {...widget.initial.tagIds};

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(strings.filterTasks),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.categoryLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  ChoiceChip(
                    label: Text(strings.priorityNone),
                    selected: _categoryId == null,
                    onSelected: (_) => setState(() => _categoryId = null),
                  ),
                  for (final category in widget.categories)
                    ChoiceChip(
                      avatar: CircleAvatar(
                        backgroundColor: Color(category.colorValue),
                      ),
                      label: Text(category.name),
                      selected: _categoryId == category.id,
                      onSelected: (_) =>
                          setState(() => _categoryId = category.id),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                strings.tagsLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final tag in widget.tags)
                    FilterChip(
                      avatar: CircleAvatar(
                        backgroundColor: Color(tag.colorValue),
                      ),
                      label: Text(tag.name),
                      selected: _tagIds.contains(tag.id),
                      onSelected: (selected) => setState(() {
                        selected ? _tagIds.add(tag.id) : _tagIds.remove(tag.id);
                      }),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, const _TodoFilters(null, <String>{})),
          child: Text(strings.clearFilters),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, _TodoFilters(_categoryId, _tagIds)),
          child: Text(strings.applyFilters),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.count,
    this.expanded,
    this.onTap,
  });

  final String label;
  final int count;
  final bool? expanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
            const Spacer(),
            if (expanded case final value?)
              Icon(
                value ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _TodoSection extends StatelessWidget {
  const _TodoSection({
    required this.todos,
    required this.compact,
    required this.now,
    required this.categories,
    required this.tags,
  });

  final List<TodoItem> todos;
  final bool compact;
  final DateTime now;
  final List<Category> categories;
  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < todos.length; index++) ...[
          if (index > 0) const SizedBox(height: 4),
          _TodoListTile(
            key: ValueKey('todo-${todos[index].id}'),
            todo: todos[index],
            compact: compact,
            now: now,
            categories: categories,
            tags: tags,
          ),
        ],
      ],
    );
  }
}

enum _TodoAction { edit, toggle, delete }

class _TodoListTile extends ConsumerWidget {
  const _TodoListTile({
    required this.todo,
    required this.compact,
    required this.now,
    required this.categories,
    required this.tags,
    this.dragHandle,
    super.key,
  });

  final TodoItem todo;
  final bool compact;
  final DateTime now;
  final List<Category> categories;
  final List<Tag> tags;
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final overdue = todo.isOverdueAt(now);
    final category = categories
        .where((item) => item.id == todo.categoryId)
        .firstOrNull;
    final todoTags = tags
        .where((item) => todo.tagIds.contains(item.id))
        .toList();
    final metadata = _metadata(context, overdue);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onSecondaryTapDown: (details) =>
          _showContextMenu(context, ref, details.globalPosition),
      child: Material(
        color: todo.isCompleted
            ? colors.surfaceContainerLow.withValues(alpha: 0.65)
            : colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: overdue
              ? BorderSide(color: colors.error.withValues(alpha: 0.35))
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () =>
              showTodoEditor(context, ref, date: todo.localDate, todo: todo),
          child: Padding(
            padding: EdgeInsets.fromLTRB(compact ? 4 : 8, 6, 4, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: todo.isCompleted,
                  visualDensity: VisualDensity.compact,
                  onChanged: (_) => _toggle(context, ref),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        maxLines: compact ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: todo.isCompleted
                              ? colors.onSurfaceVariant.withValues(alpha: 0.62)
                              : colors.onSurface,
                        ),
                      ),
                      if (metadata.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          metadata,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: overdue ? colors.error : colors.outline,
                              ),
                        ),
                      ],
                      if (!compact &&
                          (category != null || todoTags.isNotEmpty)) ...[
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 5,
                          runSpacing: 3,
                          children: [
                            if (category case final category?)
                              _MiniChip(
                                name: category.name,
                                color: Color(category.colorValue),
                                icon: Icons.folder_outlined,
                              ),
                            for (final tag in todoTags.take(4))
                              _MiniChip(
                                name: tag.name,
                                color: Color(tag.colorValue),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (todo.priority != TodoPriority.none)
                  Tooltip(
                    message: _priorityName(strings, todo.priority),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Icon(
                        Icons.flag_rounded,
                        size: 16,
                        color: _priorityColor(colors, todo.priority),
                      ),
                    ),
                  ),
                if (todo.recurrenceSeriesId != null)
                  Tooltip(
                    message: strings.repeatRuleLabel,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3),
                      child: Icon(Icons.repeat_rounded, size: 16),
                    ),
                  ),
                ?dragHandle,
                PopupMenuButton<_TodoAction>(
                  tooltip: strings.editTask,
                  padding: EdgeInsets.zero,
                  iconSize: 18,
                  onSelected: (action) => _runAction(context, ref, action),
                  itemBuilder: (context) => _menuItems(strings),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _metadata(BuildContext context, bool overdue) {
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final values = <String>[];
    if (todo.plannedAt case final value?) {
      values.add(
        '${strings.plannedAtLabel} ${DateFormat.Hm(locale).format(value.toLocal())}',
      );
    }
    if (todo.deadlineAt case final value?) {
      values.add(
        '${strings.deadlineAtLabel} ${DateFormat.MMMd(locale).add_Hm().format(value.toLocal())}',
      );
    }
    if (overdue) values.add(strings.overdue);
    return values.join(' · ');
  }

  List<PopupMenuEntry<_TodoAction>> _menuItems(AppLocalizations strings) => [
    PopupMenuItem(
      value: _TodoAction.edit,
      child: ListTile(
        leading: const Icon(Icons.edit_outlined),
        title: Text(strings.editTask),
        contentPadding: EdgeInsets.zero,
      ),
    ),
    PopupMenuItem(
      value: _TodoAction.toggle,
      child: ListTile(
        leading: Icon(
          todo.isCompleted
              ? Icons.replay_rounded
              : Icons.check_circle_outline_rounded,
        ),
        title: Text(
          todo.isCompleted ? strings.restoreTask : strings.markComplete,
        ),
        contentPadding: EdgeInsets.zero,
      ),
    ),
    PopupMenuItem(
      value: _TodoAction.delete,
      child: ListTile(
        leading: const Icon(Icons.delete_outline_rounded),
        title: Text(strings.deleteTask),
        contentPadding: EdgeInsets.zero,
      ),
    ),
  ];

  Future<void> _showContextMenu(
    BuildContext context,
    WidgetRef ref,
    Offset position,
  ) async {
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final action = await showMenu<_TodoAction>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: _menuItems(AppLocalizations.of(context)),
    );
    if (action != null && context.mounted) {
      await _runAction(context, ref, action);
    }
  }

  Future<void> _runAction(
    BuildContext context,
    WidgetRef ref,
    _TodoAction action,
  ) async {
    switch (action) {
      case _TodoAction.edit:
        await showTodoEditor(context, ref, date: todo.localDate, todo: todo);
      case _TodoAction.toggle:
        await _toggle(context, ref);
      case _TodoAction.delete:
        await _delete(context, ref);
    }
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(todoRepositoryProvider);
      todo.isCompleted
          ? await repository.restore(todo.id)
          : await repository.complete(todo.id);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).taskActionFailed)),
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(todoRepositoryProvider);
    try {
      var scope = RecurrenceActionScope.occurrence;
      if (todo.recurrenceSeriesId != null) {
        final strings = AppLocalizations.of(context);
        final selected = await showDialog<RecurrenceActionScope>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.recurrenceScopeTitle),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(strings.cancel),
              ),
              OutlinedButton(
                onPressed: () =>
                    Navigator.pop(context, RecurrenceActionScope.occurrence),
                child: Text(strings.onlyThisOccurrence),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(context, RecurrenceActionScope.thisAndFuture),
                child: Text(strings.thisAndFuture),
              ),
            ],
          ),
        );
        if (selected == null || !context.mounted) return;
        scope = selected;
      }
      if (scope == RecurrenceActionScope.thisAndFuture) {
        await ref.read(recurrenceActionsProvider).delete(todo, scope: scope);
      } else {
        await repository.softDelete(todo.id);
      }
      if (!context.mounted) return;
      final strings = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.taskDeleted),
          action: scope == RecurrenceActionScope.occurrence
              ? SnackBarAction(
                  label: strings.undo,
                  onPressed: () => repository.undoDelete(todo.id),
                )
              : null,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).taskActionFailed)),
      );
    }
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.name, required this.color, this.icon});

  final String name;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon case final value?) ...[
            Icon(value, size: 10, color: color),
            const SizedBox(width: 3),
          ] else ...[
            CircleAvatar(radius: 3, backgroundColor: color),
            const SizedBox(width: 4),
          ],
          Text(name, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

String _sortName(AppLocalizations strings, TodoSortMode mode) {
  return switch (mode) {
    TodoSortMode.manual => strings.sortManual,
    TodoSortMode.createdAtAscending => strings.sortCreatedAscending,
    TodoSortMode.createdAtDescending => strings.sortCreatedDescending,
    TodoSortMode.plannedTime => strings.sortPlannedTime,
    TodoSortMode.priority => strings.sortPriority,
    TodoSortMode.composite => strings.sortComposite,
  };
}

String _priorityName(AppLocalizations strings, TodoPriority priority) {
  return switch (priority) {
    TodoPriority.high => strings.priorityHigh,
    TodoPriority.medium => strings.priorityMedium,
    TodoPriority.low => strings.priorityLow,
    TodoPriority.none => strings.priorityNone,
  };
}

Color _priorityColor(ColorScheme colors, TodoPriority priority) {
  return switch (priority) {
    TodoPriority.high => colors.error,
    TodoPriority.medium => Colors.orange.shade700,
    TodoPriority.low => colors.primary,
    TodoPriority.none => colors.outline,
  };
}
