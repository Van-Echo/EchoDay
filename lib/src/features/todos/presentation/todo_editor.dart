import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../app/providers/data_providers.dart';
import '../../../core/ids/id_generator.dart';
import '../../settings/application/app_preferences.dart';
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
    final selectedCategory = categories
        .where((item) => item.id == _categoryId)
        .firstOrNull;
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
                        key: const ValueKey('todo-editor-planned-at'),
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
                        key: const ValueKey('todo-editor-deadline-at'),
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
                      _CategoryField(
                        category: selectedCategory,
                        label: strings.categoryLabel,
                        emptyLabel: strings.priorityNone,
                        onTap: () => _pickCategory(categories),
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
                            _EditableTagChip(
                              key: ValueKey('todo-editor-tag-${tag.id}'),
                              selected: _tagIds.contains(tag.id),
                              name: tag.name,
                              color: Color(tag.colorValue),
                              editHint: strings.catalogEditHint,
                              onTap: () => setState(() {
                                final selected = !_tagIds.contains(tag.id);
                                selected
                                    ? _tagIds.add(tag.id)
                                    : _tagIds.remove(tag.id);
                              }),
                              onDoubleTap: () => _editTag(tag),
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
    if (value == null) return AppLocalizations.of(context).chooseTime;
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
      final nextDate = LocalDate.fromDateTime(selected);
      setState(() {
        _date = nextDate;
        _plannedAt = _moveTimeToDate(_plannedAt, nextDate);
        _deadlineAt = _moveTimeToDate(_deadlineAt, nextDate);
      });
    }
  }

  DateTime? _moveTimeToDate(DateTime? value, LocalDate date) {
    if (value == null) return null;
    final local = value.toLocal();
    return DateTime(
      date.year,
      date.month,
      date.day,
      local.hour,
      local.minute,
    ).toUtc();
  }

  Future<void> _pickDateTime({required bool isDeadline}) async {
    final current = isDeadline ? _deadlineAt : _plannedAt;
    final initialLocal =
        current?.toLocal() ??
        DateTime(_date.year, _date.month, _date.day, isDeadline ? 18 : 9);
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialLocal),
    );
    if (selectedTime == null || !mounted) return;
    final value = DateTime(
      _date.year,
      _date.month,
      _date.day,
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
    final result = await _askForCatalog(
      AppLocalizations.of(context).createCategory,
    );
    final draft = result?.draft;
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
    final result = await _askForCatalog(AppLocalizations.of(context).createTag);
    final draft = result?.draft;
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

  Future<void> _pickCategory(List<Category> categories) async {
    final strings = AppLocalizations.of(context);
    final result = await showDialog<_CategoryPickerResult>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.selectCategory),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.catalogEditHint,
                style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                  color: Theme.of(dialogContext).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _CategoryPickerRow(
                      key: const ValueKey('category-option-none'),
                      name: strings.priorityNone,
                      selected: _categoryId == null,
                      onTap: () => Navigator.pop(
                        dialogContext,
                        const _CategoryPickerResult.select(null),
                      ),
                    ),
                    for (final category in categories)
                      _CategoryPickerRow(
                        key: ValueKey('category-option-${category.id}'),
                        name: category.name,
                        colorValue: category.colorValue,
                        selected: _categoryId == category.id,
                        onTap: () => Navigator.pop(
                          dialogContext,
                          _CategoryPickerResult.select(category.id),
                        ),
                        onDoubleTap: () => Navigator.pop(
                          dialogContext,
                          _CategoryPickerResult.edit(category),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings.cancel),
          ),
        ],
      ),
    );
    if (result == null || !mounted) return;
    if (result.category case final category?) {
      await _editCategory(category);
      return;
    }
    setState(() => _categoryId = result.categoryId);
  }

  Future<void> _editCategory(Category category) async {
    final strings = AppLocalizations.of(context);
    final result = await _askForCatalog(
      strings.editCategory,
      initialName: category.name,
      initialColor: category.colorValue,
      deleteLabel: strings.deleteCategory,
    );
    if (result == null || !mounted) return;
    if (result.deleteRequested) {
      if (!await _confirmCatalogDelete(strings.deleteCategory) || !mounted) {
        return;
      }
      await ref.read(categoryRepositoryProvider).softDelete(category.id);
      if (mounted && _categoryId == category.id) {
        setState(() => _categoryId = null);
      }
      return;
    }
    final draft = result.draft;
    if (draft == null) return;
    await ref
        .read(categoryRepositoryProvider)
        .save(
          Category(
            id: category.id,
            name: draft.name,
            colorValue: draft.colorValue,
            sortOrder: category.sortOrder,
            createdAt: category.createdAt,
            updatedAt: DateTime.now().toUtc(),
            revision: category.revision,
          ),
        );
  }

  Future<void> _editTag(Tag tag) async {
    final strings = AppLocalizations.of(context);
    final result = await _askForCatalog(
      strings.editTag,
      initialName: tag.name,
      initialColor: tag.colorValue,
      deleteLabel: strings.deleteTag,
    );
    if (result == null || !mounted) return;
    if (result.deleteRequested) {
      if (!await _confirmCatalogDelete(strings.deleteTag) || !mounted) return;
      await ref.read(tagRepositoryProvider).softDelete(tag.id);
      if (mounted) setState(() => _tagIds.remove(tag.id));
      return;
    }
    final draft = result.draft;
    if (draft == null) return;
    await ref
        .read(tagRepositoryProvider)
        .save(
          Tag(
            id: tag.id,
            name: draft.name,
            colorValue: draft.colorValue,
            sortOrder: tag.sortOrder,
            createdAt: tag.createdAt,
            updatedAt: DateTime.now().toUtc(),
            revision: tag.revision,
          ),
        );
  }

  Future<bool> _confirmCatalogDelete(String deleteLabel) async {
    final strings = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(strings.deleteCatalogTitle),
            content: Text(strings.deleteCatalogMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(strings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(deleteLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<_CatalogDialogResult?> _askForCatalog(
    String title, {
    String initialName = '',
    int? initialColor,
    String? deleteLabel,
  }) async {
    final strings = AppLocalizations.of(context);
    final controller = TextEditingController(text: initialName);
    var palette = [
      ...(ref.read(catalogPaletteProvider).value ?? defaultCatalogPalette),
    ];
    var selectedColor = initialColor ?? palette.first;
    if (!palette.contains(selectedColor)) palette.add(selectedColor);
    final result = await showDialog<_CatalogDialogResult>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const ValueKey('catalog-name-field'),
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(hintText: strings.nameHint),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.pop(
                      context,
                      _CatalogDialogResult.save(
                        _CatalogDraft(value.trim(), selectedColor),
                      ),
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
                runSpacing: 8,
                children: [
                  for (final colorValue in palette)
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
                  IconButton.outlined(
                    key: const ValueKey('palette-add-color'),
                    tooltip: strings.addCustomColor,
                    onPressed: () async {
                      final picked = await _pickCustomColor(
                        Color(selectedColor),
                      );
                      if (picked == null || !context.mounted) return;
                      final value = picked.toARGB32();
                      if (!palette.contains(value)) palette.add(value);
                      selectedColor = value;
                      setDialogState(() {});
                      await ref
                          .read(settingsRepositoryProvider)
                          .set(
                            AppPreferenceKeys.catalogPalette,
                            jsonEncode(palette),
                          );
                    },
                    icon: const Icon(Icons.colorize_rounded, size: 18),
                  ),
                  IconButton.outlined(
                    key: const ValueKey('palette-remove-color'),
                    tooltip: strings.removeSelectedColor,
                    onPressed: palette.length <= 1
                        ? null
                        : () async {
                            palette.remove(selectedColor);
                            selectedColor = palette.first;
                            setDialogState(() {});
                            await ref
                                .read(settingsRepositoryProvider)
                                .set(
                                  AppPreferenceKeys.catalogPalette,
                                  jsonEncode(palette),
                                );
                          },
                    icon: const Icon(Icons.remove_rounded, size: 18),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            if (deleteLabel != null)
              TextButton(
                key: const ValueKey('catalog-delete'),
                onPressed: () =>
                    Navigator.pop(context, const _CatalogDialogResult.delete()),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(deleteLabel),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  Navigator.pop(
                    context,
                    _CatalogDialogResult.save(
                      _CatalogDraft(value, selectedColor),
                    ),
                  );
                }
              },
              child: Text(strings.save),
            ),
          ],
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    return result;
  }

  Future<Color?> _pickCustomColor(Color initial) {
    var hsv = HSVColor.fromColor(initial);
    final strings = AppLocalizations.of(context);
    return showDialog<Color>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setPickerState) {
          final color = hsv.toColor();
          return AlertDialog(
            title: Text(strings.addCustomColor),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    key: const ValueKey('custom-color-preview'),
                    height: 54,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  _ColorSlider(
                    label: strings.hueLabel,
                    value: hsv.hue,
                    max: 360,
                    onChanged: (value) =>
                        setPickerState(() => hsv = hsv.withHue(value)),
                  ),
                  _ColorSlider(
                    label: strings.saturationLabel,
                    value: hsv.saturation,
                    onChanged: (value) =>
                        setPickerState(() => hsv = hsv.withSaturation(value)),
                  ),
                  _ColorSlider(
                    label: strings.brightnessLabel,
                    value: hsv.value,
                    onChanged: (value) =>
                        setPickerState(() => hsv = hsv.withValue(value)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(strings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, color),
                child: Text(strings.save),
              ),
            ],
          );
        },
      ),
    );
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

final class _CatalogDialogResult {
  const _CatalogDialogResult.save(this.draft) : deleteRequested = false;
  const _CatalogDialogResult.delete() : draft = null, deleteRequested = true;

  final _CatalogDraft? draft;
  final bool deleteRequested;
}

final class _CategoryPickerResult {
  const _CategoryPickerResult.select(this.categoryId) : category = null;
  const _CategoryPickerResult.edit(this.category) : categoryId = null;

  final String? categoryId;
  final Category? category;
}

class _ColorSlider extends StatelessWidget {
  const _ColorSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    this.max = 1,
  });

  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 56, child: Text(label)),
        Expanded(
          child: Slider(value: value, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
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
    super.key,
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

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.category,
    required this.label,
    required this.emptyLabel,
    required this.onTap,
  });

  final Category? category;
  final String label;
  final String emptyLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const ValueKey('todo-editor-category'),
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.folder_outlined),
          suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
        ),
        child: category == null
            ? Text(emptyLabel)
            : _CatalogLabel(
                name: category!.name,
                colorValue: category!.colorValue,
              ),
      ),
    );
  }
}

class _CategoryPickerRow extends StatelessWidget {
  const _CategoryPickerRow({
    required this.name,
    required this.selected,
    required this.onTap,
    this.colorValue,
    this.onDoubleTap,
    super.key,
  });

  final String name;
  final int? colorValue;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.secondaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              if (colorValue case final value?) ...[
                CircleAvatar(radius: 5, backgroundColor: Color(value)),
                const SizedBox(width: 8),
              ] else ...[
                const SizedBox(width: 18),
              ],
              Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
              if (selected) const Icon(Icons.check_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditableTagChip extends StatelessWidget {
  const _EditableTagChip({
    required this.selected,
    required this.name,
    required this.color,
    required this.editHint,
    required this.onTap,
    required this.onDoubleTap,
    super.key,
  });

  final bool selected;
  final String name;
  final Color color;
  final String editHint;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: editHint,
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          child: Chip(
            avatar: CircleAvatar(backgroundColor: color),
            label: Text(name),
            backgroundColor: selected
                ? colors.secondaryContainer
                : colors.surfaceContainerLow,
            side: BorderSide(
              color: selected ? colors.primary : colors.outlineVariant,
            ),
            deleteIcon: selected
                ? Icon(Icons.check_rounded, size: 16, color: colors.primary)
                : null,
            onDeleted: selected ? onTap : null,
          ),
        ),
      ),
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
