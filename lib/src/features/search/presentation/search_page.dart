import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../app/providers/data_providers.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/widgets/app_scaffold.dart';
import '../../todos/application/todo_providers.dart';
import '../../todos/domain/category.dart';
import '../../todos/domain/local_date.dart';
import '../../todos/domain/tag.dart';
import '../../todos/domain/todo_item.dart';
import '../../todos/domain/todo_priority.dart';
import '../../todos/domain/todo_search.dart'
    show CompletionFilter, TodoSearchPage, TodoSearchQuery;

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  AsyncValue<TodoSearchPage> _results = const AsyncLoading();
  CompletionFilter _completion = CompletionFilter.all;
  DateTimeRange? _dateRange;
  String? _categoryId;
  final Set<String> _tagIds = {};
  var _generation = 0;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_search);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final categories =
        ref.watch(categoriesProvider).value ?? const <Category>[];
    final tags = ref.watch(tagsProvider).value ?? const <Tag>[];
    return AppScaffold(
      selectedIndex: 2,
      title: strings.searchTitle,
      body: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const ValueKey('global-search-field'),
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: strings.searchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _scheduleSearch(immediate: true);
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                    onChanged: (_) {
                      setState(() {});
                      _scheduleSearch();
                    },
                    onSubmitted: (_) => _scheduleSearch(immediate: true),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final filter in CompletionFilter.values)
                        ChoiceChip(
                          label: Text(_completionName(strings, filter)),
                          selected: _completion == filter,
                          onSelected: (_) {
                            setState(() => _completion = filter);
                            _scheduleSearch(immediate: true);
                          },
                        ),
                      OutlinedButton.icon(
                        onPressed: _pickDateRange,
                        icon: const Icon(Icons.date_range_rounded),
                        label: Text(_dateRangeText(strings)),
                      ),
                      SizedBox(
                        width: 190,
                        child: DropdownButtonFormField<String?>(
                          initialValue: _categoryId,
                          isDense: true,
                          decoration: InputDecoration(
                            labelText: strings.categoryLabel,
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(strings.searchAll),
                            ),
                            for (final category in categories)
                              DropdownMenuItem<String?>(
                                value: category.id,
                                child: Text(
                                  category.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            setState(() => _categoryId = value);
                            _scheduleSearch(immediate: true);
                          },
                        ),
                      ),
                    ],
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        for (final tag in tags)
                          FilterChip(
                            avatar: CircleAvatar(
                              backgroundColor: Color(tag.colorValue),
                            ),
                            label: Text(tag.name),
                            selected: _tagIds.contains(tag.id),
                            onSelected: (selected) {
                              setState(() {
                                selected
                                    ? _tagIds.add(tag.id)
                                    : _tagIds.remove(tag.id);
                              });
                              _scheduleSearch(immediate: true);
                            },
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildResults(categories, tags)),
        ],
      ),
    );
  }

  Widget _buildResults(List<Category> categories, List<Tag> tags) {
    final strings = AppLocalizations.of(context);
    return switch (_results) {
      AsyncLoading() => const Center(child: CircularProgressIndicator()),
      AsyncError() => Center(child: Text(strings.searchLoadFailed)),
      AsyncData(:final value) when value.items.isEmpty => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 44,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 12),
            Text(strings.noSearchResults),
          ],
        ),
      ),
      AsyncData(:final value) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 4),
            child: Text(
              strings.resultCount(value.items.length),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              itemCount: value.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) => _SearchResultTile(
                todo: value.items[index],
                category: categories
                    .where((item) => item.id == value.items[index].categoryId)
                    .firstOrNull,
                tags: tags
                    .where((tag) => value.items[index].tagIds.contains(tag.id))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    };
  }

  void _scheduleSearch({bool immediate = false}) {
    _debounce?.cancel();
    if (immediate) {
      _search();
    } else {
      _debounce = Timer(const Duration(milliseconds: 280), _search);
    }
  }

  Future<void> _search() async {
    final generation = ++_generation;
    if (mounted) setState(() => _results = const AsyncLoading());
    try {
      final result = await ref
          .read(todoRepositoryProvider)
          .search(
            TodoSearchQuery(
              text: _searchController.text,
              completion: _completion,
              fromDate: _dateRange == null
                  ? null
                  : LocalDate.fromDateTime(_dateRange!.start),
              toDate: _dateRange == null
                  ? null
                  : LocalDate.fromDateTime(_dateRange!.end),
              categoryId: _categoryId,
              tagIds: _tagIds,
              limit: 200,
            ),
          );
      if (mounted && generation == _generation) {
        setState(() => _results = AsyncData(result));
      }
    } catch (error, stackTrace) {
      if (mounted && generation == _generation) {
        setState(() => _results = AsyncError(error, stackTrace));
      }
    }
  }

  Future<void> _pickDateRange() async {
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1970),
      lastDate: DateTime(2200),
      initialDateRange: _dateRange,
    );
    if (selected != null && mounted) {
      setState(() => _dateRange = selected);
      _scheduleSearch(immediate: true);
    }
  }

  String _dateRangeText(AppLocalizations strings) {
    if (_dateRange == null) return strings.dateRangeLabel;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final format = DateFormat.yMMMd(locale);
    return '${format.format(_dateRange!.start)} — ${format.format(_dateRange!.end)}';
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.todo,
    required this.category,
    required this.tags,
  });

  final TodoItem todo;
  final Category? category;
  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final metadata = <String>[
      DateFormat.yMMMd(locale).format(
        DateTime(todo.localDate.year, todo.localDate.month, todo.localDate.day),
      ),
      _priorityName(strings, todo.priority),
      if (todo.plannedAt case final value?)
        '${strings.plannedAtLabel} ${DateFormat.Hm(locale).format(value.toLocal())}',
      if (todo.deadlineAt case final value?)
        '${strings.deadlineAtLabel} ${DateFormat.MMMd(locale).add_Hm().format(value.toLocal())}',
    ];
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.go(
          '${AppRoutes.dayTodosForLocalDate(todo.localDate)}'
          '?todo=${Uri.encodeQueryComponent(todo.id)}',
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                todo.isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: todo.isCompleted ? colors.primary : colors.outline,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metadata.join(' · '),
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    if (category != null || tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        [
                          ?category?.name,
                          ...tags.map((tag) => '#${tag.name}'),
                        ].join('  '),
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: colors.primary),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

String _completionName(AppLocalizations strings, CompletionFilter completion) {
  return switch (completion) {
    CompletionFilter.all => strings.searchAll,
    CompletionFilter.incomplete => strings.searchIncomplete,
    CompletionFilter.completed => strings.searchCompleted,
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
