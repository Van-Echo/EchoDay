import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../app/providers/data_providers.dart';
import '../../../core/ids/id_generator.dart';
import '../application/recurrence_actions.dart';
import '../application/todo_providers.dart';
import '../domain/category.dart';
import '../domain/local_date.dart';
import '../domain/recurrence_series.dart';
import '../domain/tag.dart';
import '../domain/todo_item.dart';
import '../domain/todo_priority.dart';

Future<TodoItem?> showTodoEditor(
  BuildContext context,
  WidgetRef ref, {
  required LocalDate date,
  TodoItem? todo,
}) {
  return showGeneralDialog<TodoItem>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) => Align(
      alignment: Alignment.centerRight,
      child: _TodoEditor(date: date, todo: todo),
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final offset = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(position: offset, child: child);
    },
  );
}

class _TodoEditor extends ConsumerStatefulWidget {
  const _TodoEditor({required this.date, this.todo});

  final LocalDate date;
  final TodoItem? todo;

  @override
  ConsumerState<_TodoEditor> createState() => _TodoEditorState();
}

class _TodoEditorState extends ConsumerState<_TodoEditor> {
  static const _palette = <int>[
    0xFF7D8F7A,
    0xFF8A7F9F,
    0xFFB07D62,
    0xFF557C8B,
    0xFFA06C78,
    0xFF8C8665,
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _intervalController;
  late final TextEditingController _repeatCountController;
  late LocalDate _date;
  late DateTime? _plannedAt;
  late DateTime? _deadlineAt;
  late TodoPriority _priority;
  late String? _categoryId;
  late Set<String> _tagIds;
  RecurrenceFrequency? _frequency;
  RecurrenceUnit _customUnit = RecurrenceUnit.day;
  Set<int> _weekDays = {};
  int? _monthDay;
  LocalDate? _untilDate;
  bool _recurrenceLoaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    _titleController = TextEditingController(text: todo?.title);
    _notesController = TextEditingController(text: todo?.notes);
    _intervalController = TextEditingController(text: '1');
    _repeatCountController = TextEditingController();
    _date = todo?.localDate ?? widget.date;
    _plannedAt = todo?.plannedAt;
    _deadlineAt = todo?.deadlineAt;
    _priority = todo?.priority ?? TodoPriority.none;
    _categoryId = todo?.categoryId;
    _tagIds = {...?todo?.tagIds};
    _monthDay = _date.day;
    if (todo?.recurrenceSeriesId == null) {
      _recurrenceLoaded = true;
    } else {
      Future<void>.microtask(_loadRecurrence);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _intervalController.dispose();
    _repeatCountController.dispose();
    super.dispose();
  }

  Future<void> _loadRecurrence() async {
    final id = widget.todo?.recurrenceSeriesId;
    if (id == null) return;
    final series = await ref.read(recurrenceRepositoryProvider).getById(id);
    if (!mounted) return;
    setState(() {
      if (series != null) {
        final rule = series.rule;
        _frequency = rule.frequency;
        _intervalController.text = '${rule.interval}';
        _customUnit = rule.customUnit ?? RecurrenceUnit.day;
        _weekDays = {...rule.weekDays};
        _monthDay = rule.monthDay ?? _date.day;
        _untilDate = rule.untilDate;
        _repeatCountController.text = rule.maxOccurrences?.toString() ?? '';
      }
      _recurrenceLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final categories =
        ref.watch(categoriesProvider).value ?? const <Category>[];
    final tags = ref.watch(tagsProvider).value ?? const <Tag>[];
    final width = math.min(MediaQuery.sizeOf(context).width * 0.94, 520.0);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 16,
      child: SafeArea(
        child: SizedBox(
          width: width,
          height: double.infinity,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _EditorHeader(
                  title: widget.todo == null
                      ? strings.addTask
                      : strings.taskDetails,
                  saving: _saving,
                  onClose: () => Navigator.of(context).pop(),
                  onSave: _save,
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      TextFormField(
                        key: const ValueKey('todo-editor-title'),
                        controller: _titleController,
                        autofocus: widget.todo == null,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: strings.titleLabel,
                          hintText: strings.todoTitleHint,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? strings.todoTitleHint
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _DateField(
                        icon: Icons.calendar_today_rounded,
                        label: strings.dateLabel,
                        value: _formatDate(_date),
                        onTap: _pickLocalDate,
                      ),
                      const SizedBox(height: 12),
                      _DateField(
                        icon: Icons.schedule_rounded,
                        label: strings.plannedAtLabel,
                        value: _formatDateTime(_plannedAt),
                        onTap: () => _pickDateTime(isDeadline: false),
                        onClear: _plannedAt == null
                            ? null
                            : () => setState(() => _plannedAt = null),
                      ),
                      const SizedBox(height: 12),
                      _DateField(
                        icon: Icons.flag_outlined,
                        label: strings.deadlineAtLabel,
                        value: _formatDateTime(_deadlineAt),
                        onTap: () => _pickDateTime(isDeadline: true),
                        onClear: _deadlineAt == null
                            ? null
                            : () => setState(() => _deadlineAt = null),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<TodoPriority>(
                        initialValue: _priority,
                        decoration: InputDecoration(
                          labelText: strings.priorityLabel,
                          prefixIcon: const Icon(Icons.low_priority_rounded),
                        ),
                        items: [
                          for (final priority in TodoPriority.values)
                            DropdownMenuItem(
                              value: priority,
                              child: Text(_priorityName(strings, priority)),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _priority = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        initialValue:
                            categories.any((item) => item.id == _categoryId)
                            ? _categoryId
                            : null,
                        decoration: InputDecoration(
                          labelText: strings.categoryLabel,
                          prefixIcon: const Icon(Icons.folder_outlined),
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(strings.priorityNone),
                          ),
                          for (final category in categories)
                            DropdownMenuItem<String?>(
                              value: category.id,
                              child: _CatalogLabel(
                                name: category.name,
                                colorValue: category.colorValue,
                              ),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _categoryId = value),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _createCategory,
                          icon: const Icon(Icons.add_rounded),
                          label: Text(strings.createCategory),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.tagsLabel,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          for (final tag in tags)
                            FilterChip(
                              selected: _tagIds.contains(tag.id),
                              avatar: CircleAvatar(
                                backgroundColor: Color(tag.colorValue),
                              ),
                              label: Text(tag.name),
                              onSelected: (selected) => setState(() {
                                selected
                                    ? _tagIds.add(tag.id)
                                    : _tagIds.remove(tag.id);
                              }),
                            ),
                          ActionChip(
                            avatar: const Icon(Icons.add_rounded, size: 18),
                            label: Text(strings.createTag),
                            onPressed: _createTag,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        minLines: 3,
                        maxLines: 7,
                        decoration: InputDecoration(
                          labelText: strings.notesLabel,
                          alignLabelWithHint: true,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 56),
                            child: Icon(Icons.notes_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRecurrenceEditor(strings),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecurrenceEditor(AppLocalizations strings) {
    if (!_recurrenceLoaded) return const LinearProgressIndicator();
    final weekdayLabels = [
      strings.mondayShort,
      strings.tuesdayShort,
      strings.wednesdayShort,
      strings.thursdayShort,
      strings.fridayShort,
      strings.saturdayShort,
      strings.sundayShort,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<RecurrenceFrequency?>(
          initialValue: _frequency,
          decoration: InputDecoration(
            labelText: strings.repeatRuleLabel,
            prefixIcon: const Icon(Icons.repeat_rounded),
          ),
          items: [
            DropdownMenuItem<RecurrenceFrequency?>(
              value: null,
              child: Text(strings.repeatRuleM4Hint),
            ),
            for (final frequency in RecurrenceFrequency.values)
              DropdownMenuItem<RecurrenceFrequency?>(
                value: frequency,
                child: Text(_frequencyName(strings, frequency)),
              ),
          ],
          onChanged: (value) => setState(() {
            _frequency = value;
            if (value == RecurrenceFrequency.weekly && _weekDays.isEmpty) {
              _weekDays = {
                DateTime.utc(_date.year, _date.month, _date.day).weekday,
              };
            }
          }),
        ),
        if (_frequency == RecurrenceFrequency.weekdays) ...[
          const SizedBox(height: 8),
          Text(
            strings.repeatWorkdayFallback,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ],
        if (_frequency == RecurrenceFrequency.weekly) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var index = 0; index < weekdayLabels.length; index++)
                FilterChip(
                  label: Text(weekdayLabels[index]),
                  selected: _weekDays.contains(index + 1),
                  onSelected: (selected) => setState(() {
                    selected
                        ? _weekDays.add(index + 1)
                        : _weekDays.remove(index + 1);
                  }),
                ),
            ],
          ),
        ],
        if (_frequency == RecurrenceFrequency.monthly) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _monthDay,
            decoration: InputDecoration(labelText: strings.dateLabel),
            items: [
              for (var day = 1; day <= 31; day++)
                DropdownMenuItem(value: day, child: Text('$day')),
            ],
            onChanged: (value) => setState(() => _monthDay = value),
          ),
        ],
        if (_frequency == RecurrenceFrequency.custom) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _intervalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: strings.repeatInterval,
                  ),
                  validator: (value) {
                    if (_frequency != RecurrenceFrequency.custom) return null;
                    final interval = int.tryParse(value ?? '');
                    return interval == null || interval < 1
                        ? strings.repeatInterval
                        : null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<RecurrenceUnit>(
                  initialValue: _customUnit,
                  items: [
                    for (final unit in RecurrenceUnit.values)
                      DropdownMenuItem(
                        value: unit,
                        child: Text(_unitName(strings, unit)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _customUnit = value);
                  },
                ),
              ),
            ],
          ),
        ],
        if (_frequency != null) ...[
          const SizedBox(height: 12),
          _DateField(
            icon: Icons.event_busy_outlined,
            label: strings.repeatUntil,
            value: _untilDate == null
                ? strings.chooseDateTime
                : _formatDate(_untilDate!),
            onTap: _pickUntilDate,
            onClear: _untilDate == null
                ? null
                : () => setState(() => _untilDate = null),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _repeatCountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: strings.repeatCount,
              prefixIcon: const Icon(Icons.numbers_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final count = int.tryParse(value);
              return count == null || count < 1 ? strings.repeatCount : null;
            },
          ),
        ],
      ],
    );
  }

  Future<void> _pickUntilDate() async {
    final initial = _untilDate ?? _date;
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(initial.year, initial.month, initial.day),
      firstDate: DateTime(_date.year, _date.month, _date.day),
      lastDate: DateTime(2200),
    );
    if (selected != null && mounted) {
      setState(() => _untilDate = LocalDate.fromDateTime(selected));
    }
  }

  String _formatDate(LocalDate date) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMMd(locale)
        .format(DateTime(date.year, date.month, date.day));
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return AppLocalizations.of(context).chooseDateTime;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMd(locale).add_Hm().format(value.toLocal());
  }

  Future<void> _pickLocalDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(_date.year, _date.month, _date.day),
      firstDate: DateTime(1970),
      lastDate: DateTime(2200),
    );
    if (selected != null && mounted) {
      setState(() => _date = LocalDate.fromDateTime(selected));
    }
  }

  Future<void> _pickDateTime({required bool isDeadline}) async {
    final current = isDeadline ? _deadlineAt : _plannedAt;
    final initialLocal =
        current?.toLocal() ??
        DateTime(_date.year, _date.month, _date.day, isDeadline ? 18 : 9);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialLocal,
      firstDate: DateTime(1970),
      lastDate: DateTime(2200),
    );
    if (selectedDate == null || !mounted) return;
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialLocal),
    );
    if (selectedTime == null || !mounted) return;
    final value = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    ).toUtc();
    setState(() {
      if (isDeadline) {
        _deadlineAt = value;
      } else {
        _plannedAt = value;
      }
    });
  }

  Future<void> _createCategory() async {
    final draft = await _askForCatalog(
      AppLocalizations.of(context).createCategory,
    );
    if (draft == null || !mounted) return;
    final now = DateTime.now().toUtc();
    final category = Category(
      id: const UuidV7Generator().next(),
      name: draft.name,
      colorValue: draft.colorValue,
      createdAt: now,
      updatedAt: now,
    );
    await ref.read(categoryRepositoryProvider).save(category);
    if (mounted) setState(() => _categoryId = category.id);
  }

  Future<void> _createTag() async {
    final draft = await _askForCatalog(AppLocalizations.of(context).createTag);
    if (draft == null || !mounted) return;
    final now = DateTime.now().toUtc();
    final tag = Tag(
      id: const UuidV7Generator().next(),
      name: draft.name,
      colorValue: draft.colorValue,
      createdAt: now,
      updatedAt: now,
    );
    await ref.read(tagRepositoryProvider).save(tag);
    if (mounted) setState(() => _tagIds.add(tag.id));
  }

  Future<_CatalogDraft?> _askForCatalog(String title) async {
    final strings = AppLocalizations.of(context);
    final controller = TextEditingController();
    var selectedColor = _palette.first;
    final result = await showDialog<_CatalogDraft>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(hintText: strings.nameHint),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.pop(
                      context,
                      _CatalogDraft(value.trim(), selectedColor),
                    );
                  }
                },
              ),
              const SizedBox(height: 18),
              Text(
                strings.colorLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  for (final colorValue in _palette)
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () =>
                          setDialogState(() => selectedColor = colorValue),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color(colorValue),
                          shape: BoxShape.circle,
                          border: selectedColor == colorValue
                              ? Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: selectedColor == colorValue
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  Navigator.pop(context, _CatalogDraft(value, selectedColor));
                }
              },
              child: Text(strings.save),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _save() async {
    if (!_recurrenceLoaded || !_formKey.currentState!.validate() || _saving) {
      return;
    }
    setState(() => _saving = true);
    final title = _titleController.text.trim();
    final notes = _notesController.text.trim();
    final recurrenceRule = _buildRecurrenceRule();
    try {
      final repository = ref.read(todoRepositoryProvider);
      final TodoItem saved;
      if (widget.todo case final todo?) {
        var updated = todo.copyWith(
          title: title,
          localDate: _date,
          plannedAt: _plannedAt,
          deadlineAt: _deadlineAt,
          priority: _priority,
          categoryId: _categoryId,
          tagIds: _tagIds,
          notes: notes.isEmpty ? null : notes,
        );
        if (todo.recurrenceSeriesId != null) {
          final scope = await _askRecurrenceScope();
          if (scope == null) {
            if (mounted) setState(() => _saving = false);
            return;
          }
          saved = await ref
              .read(recurrenceActionsProvider)
              .saveFrom(
                todo,
                updated,
                scope: scope,
                futureRule: recurrenceRule,
              );
        } else if (recurrenceRule != null) {
          final series = await ref
              .read(recurrenceRepositoryProvider)
              .create(_date, recurrenceRule);
          updated = updated.copyWith(
            recurrenceSeriesId: series.id,
            occurrenceDate: _date,
          );
          saved = await repository.save(updated);
        } else {
          saved = await repository.save(updated);
        }
      } else {
        final series = recurrenceRule == null
            ? null
            : await ref
                  .read(recurrenceRepositoryProvider)
                  .create(_date, recurrenceRule);
        saved = await repository.create(
          TodoDraft(
            title: title,
            localDate: _date,
            plannedAt: _plannedAt,
            deadlineAt: _deadlineAt,
            priority: _priority,
            categoryId: _categoryId,
            tagIds: _tagIds,
            notes: notes.isEmpty ? null : notes,
            recurrenceSeriesId: series?.id,
            occurrenceDate: series == null ? null : _date,
          ),
        );
      }
      if (mounted) Navigator.of(context).pop(saved);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).taskSaveFailed)),
      );
    }
  }

  RecurrenceRule? _buildRecurrenceRule() {
    final frequency = _frequency;
    if (frequency == null) return null;
    return RecurrenceRule(
      frequency: frequency,
      interval: frequency == RecurrenceFrequency.custom
          ? int.tryParse(_intervalController.text) ?? 1
          : 1,
      weekDays: frequency == RecurrenceFrequency.weekly ? _weekDays : const {},
      monthDay: frequency == RecurrenceFrequency.monthly ? _monthDay : null,
      customUnit: frequency == RecurrenceFrequency.custom ? _customUnit : null,
      untilDate: _untilDate,
      maxOccurrences: int.tryParse(_repeatCountController.text),
    );
  }

  Future<RecurrenceActionScope?> _askRecurrenceScope() {
    final strings = AppLocalizations.of(context);
    return showDialog<RecurrenceActionScope>(
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
  }
}

final class _CatalogDraft {
  const _CatalogDraft(this.name, this.colorValue);

  final String name;
  final int colorValue;
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({
    required this.title,
    required this.saving,
    required this.onClose,
    required this.onSave,
  });

  final String title;
  final bool saving;
  final VoidCallback onClose;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            FilledButton.icon(
              onPressed: saving ? null : onSave,
              icon: saving
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(strings.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: onClear == null
              ? const Icon(Icons.chevron_right_rounded)
              : IconButton(
                  tooltip: AppLocalizations.of(context).clear,
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
        child: Text(value),
      ),
    );
  }
}

class _CatalogLabel extends StatelessWidget {
  const _CatalogLabel({required this.name, required this.colorValue});

  final String name;
  final int colorValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 5, backgroundColor: Color(colorValue)),
        const SizedBox(width: 8),
        Flexible(child: Text(name, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

String _priorityName(AppLocalizations strings, TodoPriority priority) {
  return switch (priority) {
    TodoPriority.high => strings.priorityHigh,
    TodoPriority.medium => strings.priorityMedium,
    TodoPriority.low => strings.priorityLow,
    TodoPriority.none => strings.priorityNone,
  };
}

String _frequencyName(AppLocalizations strings, RecurrenceFrequency frequency) {
  return switch (frequency) {
    RecurrenceFrequency.daily => strings.repeatDaily,
    RecurrenceFrequency.weekdays => strings.repeatWeekdays,
    RecurrenceFrequency.weekly => strings.repeatWeekly,
    RecurrenceFrequency.monthly => strings.repeatMonthly,
    RecurrenceFrequency.custom => strings.repeatCustom,
  };
}

String _unitName(AppLocalizations strings, RecurrenceUnit unit) {
  return switch (unit) {
    RecurrenceUnit.day => strings.repeatUnitDay,
    RecurrenceUnit.week => strings.repeatUnitWeek,
    RecurrenceUnit.month => strings.repeatUnitMonth,
  };
}
