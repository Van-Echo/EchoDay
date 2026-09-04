import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/data_providers.dart';
import '../../todos/domain/local_date.dart';
import '../domain/calendar_layout.dart';
import '../domain/continuous_calendar.dart';

abstract final class CalendarSettingKeys {
  static const visibleWeekCount = 'calendar.visibleWeekCount';
  static const previewLimit = 'calendar.previewLimit';
  static const sidebarRatio = 'calendar.sidebarRatio';
}

final calendarControllerProvider =
    NotifierProvider<CalendarController, CalendarViewState>(
      CalendarController.new,
    );

final class CalendarViewState {
  const CalendarViewState({
    required this.anchorWeekStart,
    required this.selectedDate,
    this.visibleWeekCount = 5,
    this.previewLimit = 6,
    this.sidebarRatio = 0.125,
    this.preferencesLoaded = false,
  });

  final LocalDate anchorWeekStart;
  final LocalDate selectedDate;
  final int visibleWeekCount;
  final int previewLimit;
  final double sidebarRatio;
  final bool preferencesLoaded;

  List<LocalDate> get visibleDates =>
      continuousDates(anchorWeekStart, visibleWeekCount);

  CalendarViewState copyWith({
    LocalDate? anchorWeekStart,
    LocalDate? selectedDate,
    int? visibleWeekCount,
    int? previewLimit,
    double? sidebarRatio,
    bool? preferencesLoaded,
  }) {
    return CalendarViewState(
      anchorWeekStart: anchorWeekStart ?? this.anchorWeekStart,
      selectedDate: selectedDate ?? this.selectedDate,
      visibleWeekCount: visibleWeekCount ?? this.visibleWeekCount,
      previewLimit: previewLimit ?? this.previewLimit,
      sidebarRatio: sidebarRatio ?? this.sidebarRatio,
      preferencesLoaded: preferencesLoaded ?? this.preferencesLoaded,
    );
  }
}

class CalendarController extends Notifier<CalendarViewState> {
  bool _loadingPreferences = false;

  @override
  CalendarViewState build() {
    final today = LocalDate.fromDateTime(DateTime.now());
    return CalendarViewState(
      anchorWeekStart: startOfIsoWeek(today),
      selectedDate: today,
    );
  }

  Future<void> loadPreferences() async {
    if (_loadingPreferences || state.preferencesLoaded) return;
    _loadingPreferences = true;
    try {
      final settings = ref.read(settingsRepositoryProvider);
      final values = await Future.wait([
        settings.get(CalendarSettingKeys.visibleWeekCount),
        settings.get(CalendarSettingKeys.previewLimit),
        settings.get(CalendarSettingKeys.sidebarRatio),
      ]);
      final weeks = int.tryParse(values[0]?.value ?? '') ?? 5;
      final preview = int.tryParse(values[1]?.value ?? '') ?? 6;
      final ratio = double.tryParse(values[2]?.value ?? '') ?? 0.125;
      state = state.copyWith(
        visibleWeekCount: weeks.clamp(5, 10),
        previewLimit: preview.clamp(1, 12),
        sidebarRatio: clampSidebarRatio(ratio),
        preferencesLoaded: true,
      );
      ensureSelectedVisible();
    } finally {
      _loadingPreferences = false;
    }
  }

  void selectDate(LocalDate date) {
    state = state.copyWith(selectedDate: date);
  }

  void showAdjacentMonth(int delta) {
    final target = sameDayInAdjacentMonth(state.selectedDate, delta);
    state = state.copyWith(
      selectedDate: target,
      anchorWeekStart: startOfIsoWeek(target),
    );
  }

  void goToToday() {
    final today = LocalDate.fromDateTime(DateTime.now());
    state = state.copyWith(
      selectedDate: today,
      anchorWeekStart: startOfIsoWeek(today),
    );
  }

  void scrollWeeks(int delta) {
    if (delta == 0) return;
    state = state.copyWith(
      anchorWeekStart: state.anchorWeekStart.addDays(delta * 7),
    );
  }

  Future<void> changeVisibleWeeks(int delta) async {
    final oldCount = state.visibleWeekCount;
    final newCount = (oldCount + delta).clamp(5, 10);
    if (newCount == oldCount) return;
    final oldCenterOffset = (oldCount ~/ 2) * 7;
    final center = state.anchorWeekStart.addDays(oldCenterOffset);
    final newAnchor = center.addDays(-(newCount ~/ 2) * 7);
    state = state.copyWith(
      visibleWeekCount: newCount,
      anchorWeekStart: newAnchor,
    );
    ensureSelectedVisible();
    await ref
        .read(settingsRepositoryProvider)
        .set(CalendarSettingKeys.visibleWeekCount, '$newCount');
  }

  void ensureSelectedVisible() {
    final dates = state.visibleDates;
    if (dateIsInRange(state.selectedDate, dates.first, dates.last)) return;
    state = state.copyWith(anchorWeekStart: startOfIsoWeek(state.selectedDate));
  }

  void setSidebarRatio(double ratio) {
    state = state.copyWith(sidebarRatio: clampSidebarRatio(ratio));
  }

  Future<void> persistSidebarRatio() {
    return ref
        .read(settingsRepositoryProvider)
        .set(CalendarSettingKeys.sidebarRatio, '${state.sidebarRatio}');
  }

  Future<void> resetSidebarRatio() async {
    setSidebarRatio(0.125);
    await persistSidebarRatio();
  }
}
