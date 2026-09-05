import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'丸成'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'EchoDay'**
  String get appSubtitle;

  /// No description provided for @navCalendar.
  ///
  /// In zh, this message translates to:
  /// **'日历'**
  String get navCalendar;

  /// No description provided for @navDayTodos.
  ///
  /// In zh, this message translates to:
  /// **'当日 TODO'**
  String get navDayTodos;

  /// No description provided for @navSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get navSearch;

  /// No description provided for @navSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get navSettings;

  /// No description provided for @navAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get navAbout;

  /// No description provided for @expandNavigation.
  ///
  /// In zh, this message translates to:
  /// **'显示导航文字'**
  String get expandNavigation;

  /// No description provided for @collapseNavigation.
  ///
  /// In zh, this message translates to:
  /// **'仅显示导航图标'**
  String get collapseNavigation;

  /// No description provided for @calendarTitle.
  ///
  /// In zh, this message translates to:
  /// **'月历工作台'**
  String get calendarTitle;

  /// No description provided for @calendarDescription.
  ///
  /// In zh, this message translates to:
  /// **'连续周日历将在 M2 接入。'**
  String get calendarDescription;

  /// No description provided for @previousMonth.
  ///
  /// In zh, this message translates to:
  /// **'上个月'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In zh, this message translates to:
  /// **'下个月'**
  String get nextMonth;

  /// No description provided for @today.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get today;

  /// No description provided for @backToToday.
  ///
  /// In zh, this message translates to:
  /// **'回到今天'**
  String get backToToday;

  /// No description provided for @backToSelectedDate.
  ///
  /// In zh, this message translates to:
  /// **'回到选中日期'**
  String get backToSelectedDate;

  /// No description provided for @visibleWeeks.
  ///
  /// In zh, this message translates to:
  /// **'{count} 周'**
  String visibleWeeks(int count);

  /// No description provided for @showFewerWeeks.
  ///
  /// In zh, this message translates to:
  /// **'显示更少周'**
  String get showFewerWeeks;

  /// No description provided for @showMoreWeeks.
  ///
  /// In zh, this message translates to:
  /// **'显示更多周'**
  String get showMoreWeeks;

  /// No description provided for @mondayShort.
  ///
  /// In zh, this message translates to:
  /// **'周一'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In zh, this message translates to:
  /// **'周二'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In zh, this message translates to:
  /// **'周三'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In zh, this message translates to:
  /// **'周四'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In zh, this message translates to:
  /// **'周五'**
  String get fridayShort;

  /// No description provided for @saturdayShort.
  ///
  /// In zh, this message translates to:
  /// **'周六'**
  String get saturdayShort;

  /// No description provided for @sundayShort.
  ///
  /// In zh, this message translates to:
  /// **'周日'**
  String get sundayShort;

  /// No description provided for @quickAddTitle.
  ///
  /// In zh, this message translates to:
  /// **'快速新增 TODO'**
  String get quickAddTitle;

  /// No description provided for @todoTitleHint.
  ///
  /// In zh, this message translates to:
  /// **'要完成什么？'**
  String get todoTitleHint;

  /// No description provided for @addTask.
  ///
  /// In zh, this message translates to:
  /// **'新增'**
  String get addTask;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @clear.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get clear;

  /// No description provided for @editTask.
  ///
  /// In zh, this message translates to:
  /// **'编辑任务'**
  String get editTask;

  /// No description provided for @deleteTask.
  ///
  /// In zh, this message translates to:
  /// **'删除任务'**
  String get deleteTask;

  /// No description provided for @markComplete.
  ///
  /// In zh, this message translates to:
  /// **'标记完成'**
  String get markComplete;

  /// No description provided for @restoreTask.
  ///
  /// In zh, this message translates to:
  /// **'恢复任务'**
  String get restoreTask;

  /// No description provided for @undo.
  ///
  /// In zh, this message translates to:
  /// **'撤销'**
  String get undo;

  /// No description provided for @taskDeleted.
  ///
  /// In zh, this message translates to:
  /// **'任务已删除'**
  String get taskDeleted;

  /// No description provided for @incompleteTasks.
  ///
  /// In zh, this message translates to:
  /// **'待完成'**
  String get incompleteTasks;

  /// No description provided for @completedTasks.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get completedTasks;

  /// No description provided for @overdue.
  ///
  /// In zh, this message translates to:
  /// **'已逾期'**
  String get overdue;

  /// No description provided for @sortTasks.
  ///
  /// In zh, this message translates to:
  /// **'任务排序'**
  String get sortTasks;

  /// No description provided for @filterTasks.
  ///
  /// In zh, this message translates to:
  /// **'筛选任务'**
  String get filterTasks;

  /// No description provided for @clearFilters.
  ///
  /// In zh, this message translates to:
  /// **'清除筛选'**
  String get clearFilters;

  /// No description provided for @applyFilters.
  ///
  /// In zh, this message translates to:
  /// **'应用筛选'**
  String get applyFilters;

  /// No description provided for @sortManual.
  ///
  /// In zh, this message translates to:
  /// **'手动排序'**
  String get sortManual;

  /// No description provided for @sortCreatedAscending.
  ///
  /// In zh, this message translates to:
  /// **'创建时间（早到晚）'**
  String get sortCreatedAscending;

  /// No description provided for @sortCreatedDescending.
  ///
  /// In zh, this message translates to:
  /// **'创建时间（晚到早）'**
  String get sortCreatedDescending;

  /// No description provided for @sortPlannedTime.
  ///
  /// In zh, this message translates to:
  /// **'计划时间'**
  String get sortPlannedTime;

  /// No description provided for @sortPriority.
  ///
  /// In zh, this message translates to:
  /// **'优先级'**
  String get sortPriority;

  /// No description provided for @sortComposite.
  ///
  /// In zh, this message translates to:
  /// **'智能排序'**
  String get sortComposite;

  /// No description provided for @dragToReorder.
  ///
  /// In zh, this message translates to:
  /// **'拖动调整顺序'**
  String get dragToReorder;

  /// No description provided for @taskDetails.
  ///
  /// In zh, this message translates to:
  /// **'任务详情'**
  String get taskDetails;

  /// No description provided for @titleLabel.
  ///
  /// In zh, this message translates to:
  /// **'内容'**
  String get titleLabel;

  /// No description provided for @dateLabel.
  ///
  /// In zh, this message translates to:
  /// **'所属日期'**
  String get dateLabel;

  /// No description provided for @plannedAtLabel.
  ///
  /// In zh, this message translates to:
  /// **'计划执行时间'**
  String get plannedAtLabel;

  /// No description provided for @deadlineAtLabel.
  ///
  /// In zh, this message translates to:
  /// **'计划 DDL 时间'**
  String get deadlineAtLabel;

  /// No description provided for @priorityLabel.
  ///
  /// In zh, this message translates to:
  /// **'优先级'**
  String get priorityLabel;

  /// No description provided for @priorityHigh.
  ///
  /// In zh, this message translates to:
  /// **'高'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In zh, this message translates to:
  /// **'中'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In zh, this message translates to:
  /// **'低'**
  String get priorityLow;

  /// No description provided for @priorityNone.
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get priorityNone;

  /// No description provided for @categoryLabel.
  ///
  /// In zh, this message translates to:
  /// **'分类'**
  String get categoryLabel;

  /// No description provided for @tagsLabel.
  ///
  /// In zh, this message translates to:
  /// **'标签'**
  String get tagsLabel;

  /// No description provided for @notesLabel.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get notesLabel;

  /// No description provided for @createCategory.
  ///
  /// In zh, this message translates to:
  /// **'新建分类'**
  String get createCategory;

  /// No description provided for @createTag.
  ///
  /// In zh, this message translates to:
  /// **'新建标签'**
  String get createTag;

  /// No description provided for @selectCategory.
  ///
  /// In zh, this message translates to:
  /// **'选择分类'**
  String get selectCategory;

  /// No description provided for @catalogEditHint.
  ///
  /// In zh, this message translates to:
  /// **'单击选择，双击修改'**
  String get catalogEditHint;

  /// No description provided for @editCategory.
  ///
  /// In zh, this message translates to:
  /// **'修改分类'**
  String get editCategory;

  /// No description provided for @editTag.
  ///
  /// In zh, this message translates to:
  /// **'修改标签'**
  String get editTag;

  /// No description provided for @deleteCategory.
  ///
  /// In zh, this message translates to:
  /// **'删除分类'**
  String get deleteCategory;

  /// No description provided for @deleteTag.
  ///
  /// In zh, this message translates to:
  /// **'删除标签'**
  String get deleteTag;

  /// No description provided for @deleteCatalogTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认删除？'**
  String get deleteCatalogTitle;

  /// No description provided for @deleteCatalogMessage.
  ///
  /// In zh, this message translates to:
  /// **'删除后任务本身会保留，但不再显示这个分类或标签。'**
  String get deleteCatalogMessage;

  /// No description provided for @nameHint.
  ///
  /// In zh, this message translates to:
  /// **'输入名称'**
  String get nameHint;

  /// No description provided for @colorLabel.
  ///
  /// In zh, this message translates to:
  /// **'颜色'**
  String get colorLabel;

  /// No description provided for @addCustomColor.
  ///
  /// In zh, this message translates to:
  /// **'从调色盘增加颜色'**
  String get addCustomColor;

  /// No description provided for @removeSelectedColor.
  ///
  /// In zh, this message translates to:
  /// **'删除当前选中的颜色'**
  String get removeSelectedColor;

  /// No description provided for @hueLabel.
  ///
  /// In zh, this message translates to:
  /// **'色相'**
  String get hueLabel;

  /// No description provided for @saturationLabel.
  ///
  /// In zh, this message translates to:
  /// **'饱和度'**
  String get saturationLabel;

  /// No description provided for @brightnessLabel.
  ///
  /// In zh, this message translates to:
  /// **'明度'**
  String get brightnessLabel;

  /// No description provided for @repeatRuleLabel.
  ///
  /// In zh, this message translates to:
  /// **'重复规则'**
  String get repeatRuleLabel;

  /// No description provided for @repeatRuleM4Hint.
  ///
  /// In zh, this message translates to:
  /// **'不重复'**
  String get repeatRuleM4Hint;

  /// No description provided for @repeatDaily.
  ///
  /// In zh, this message translates to:
  /// **'每天'**
  String get repeatDaily;

  /// No description provided for @repeatWeekdays.
  ///
  /// In zh, this message translates to:
  /// **'每个工作日'**
  String get repeatWeekdays;

  /// No description provided for @repeatWeekly.
  ///
  /// In zh, this message translates to:
  /// **'每周'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In zh, this message translates to:
  /// **'每月'**
  String get repeatMonthly;

  /// No description provided for @repeatCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义间隔'**
  String get repeatCustom;

  /// No description provided for @repeatInterval.
  ///
  /// In zh, this message translates to:
  /// **'间隔'**
  String get repeatInterval;

  /// No description provided for @repeatUnitDay.
  ///
  /// In zh, this message translates to:
  /// **'天'**
  String get repeatUnitDay;

  /// No description provided for @repeatUnitWeek.
  ///
  /// In zh, this message translates to:
  /// **'周'**
  String get repeatUnitWeek;

  /// No description provided for @repeatUnitMonth.
  ///
  /// In zh, this message translates to:
  /// **'月'**
  String get repeatUnitMonth;

  /// No description provided for @repeatUntil.
  ///
  /// In zh, this message translates to:
  /// **'结束日期'**
  String get repeatUntil;

  /// No description provided for @repeatCount.
  ///
  /// In zh, this message translates to:
  /// **'重复次数'**
  String get repeatCount;

  /// No description provided for @repeatWorkdayFallback.
  ///
  /// In zh, this message translates to:
  /// **'已覆盖年份按中国法定节假日与调休计算；缺少年度数据时按周一至周五，并在月历提示'**
  String get repeatWorkdayFallback;

  /// No description provided for @recurrenceScopeTitle.
  ///
  /// In zh, this message translates to:
  /// **'应用到重复任务'**
  String get recurrenceScopeTitle;

  /// No description provided for @onlyThisOccurrence.
  ///
  /// In zh, this message translates to:
  /// **'仅本次'**
  String get onlyThisOccurrence;

  /// No description provided for @thisAndFuture.
  ///
  /// In zh, this message translates to:
  /// **'本次及之后'**
  String get thisAndFuture;

  /// No description provided for @chooseDateTime.
  ///
  /// In zh, this message translates to:
  /// **'选择日期和时间'**
  String get chooseDateTime;

  /// No description provided for @chooseTime.
  ///
  /// In zh, this message translates to:
  /// **'选择时间'**
  String get chooseTime;

  /// No description provided for @chooseDate.
  ///
  /// In zh, this message translates to:
  /// **'选择日期'**
  String get chooseDate;

  /// No description provided for @yearLabel.
  ///
  /// In zh, this message translates to:
  /// **'年份'**
  String get yearLabel;

  /// No description provided for @monthLabel.
  ///
  /// In zh, this message translates to:
  /// **'月份'**
  String get monthLabel;

  /// No description provided for @monthValue.
  ///
  /// In zh, this message translates to:
  /// **'{month}月'**
  String monthValue(int month);

  /// No description provided for @taskSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败，请重试'**
  String get taskSaveFailed;

  /// No description provided for @taskActionFailed.
  ///
  /// In zh, this message translates to:
  /// **'操作失败，请重试'**
  String get taskActionFailed;

  /// No description provided for @postponeIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'未完成任务顺延至下一天'**
  String get postponeIncomplete;

  /// No description provided for @postponeIncompleteDays.
  ///
  /// In zh, this message translates to:
  /// **'未完成任务顺延 {days} 天（右键配置）'**
  String postponeIncompleteDays(int days);

  /// No description provided for @configurePostponeDays.
  ///
  /// In zh, this message translates to:
  /// **'配置顺延天数'**
  String get configurePostponeDays;

  /// No description provided for @postponeDaysLabel.
  ///
  /// In zh, this message translates to:
  /// **'顺延 X 天'**
  String get postponeDaysLabel;

  /// No description provided for @postponeDaysRange.
  ///
  /// In zh, this message translates to:
  /// **'可填写 1～365 天；批量与单项任务共用'**
  String get postponeDaysRange;

  /// No description provided for @postponeDialogBodyDays.
  ///
  /// In zh, this message translates to:
  /// **'将这一天的 {count} 项未完成任务移至 {date}，顺延 {days} 天。计划执行时间和计划 DDL 也会同步移动。'**
  String postponeDialogBodyDays(int count, String date, int days);

  /// No description provided for @postponedTasksDays.
  ///
  /// In zh, this message translates to:
  /// **'已将 {count} 项未完成任务顺延 {days} 天'**
  String postponedTasksDays(int count, int days);

  /// No description provided for @postponeOneTaskDays.
  ///
  /// In zh, this message translates to:
  /// **'将此任务顺延 {days} 天'**
  String postponeOneTaskDays(int days);

  /// No description provided for @postponedOneTask.
  ///
  /// In zh, this message translates to:
  /// **'已将任务顺延 {days} 天'**
  String postponedOneTask(int days);

  /// No description provided for @postponeDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'顺延未完成任务？'**
  String get postponeDialogTitle;

  /// No description provided for @postponeDialogBody.
  ///
  /// In zh, this message translates to:
  /// **'将这一天的 {count} 项未完成任务移至 {date}。计划执行时间和计划 DDL 也会顺延一天。'**
  String postponeDialogBody(int count, String date);

  /// No description provided for @postponeAction.
  ///
  /// In zh, this message translates to:
  /// **'顺延'**
  String get postponeAction;

  /// No description provided for @postponedTasks.
  ///
  /// In zh, this message translates to:
  /// **'已顺延 {count} 项未完成任务'**
  String postponedTasks(int count);

  /// No description provided for @noTasksForDate.
  ///
  /// In zh, this message translates to:
  /// **'这一天还没有 TODO'**
  String get noTasksForDate;

  /// No description provided for @todoLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'TODO 加载失败'**
  String get todoLoadFailed;

  /// No description provided for @moreTasks.
  ///
  /// In zh, this message translates to:
  /// **'还有 {count} 项'**
  String moreTasks(int count);

  /// No description provided for @openFullScreen.
  ///
  /// In zh, this message translates to:
  /// **'全屏打开当日 TODO'**
  String get openFullScreen;

  /// No description provided for @backToCalendar.
  ///
  /// In zh, this message translates to:
  /// **'返回月历'**
  String get backToCalendar;

  /// No description provided for @holidayDayOff.
  ///
  /// In zh, this message translates to:
  /// **'休'**
  String get holidayDayOff;

  /// No description provided for @holidayWorkday.
  ///
  /// In zh, this message translates to:
  /// **'班'**
  String get holidayWorkday;

  /// No description provided for @holidayCoverageMissingShort.
  ///
  /// In zh, this message translates to:
  /// **'调休未覆盖'**
  String get holidayCoverageMissingShort;

  /// No description provided for @holidayCoverageMissing.
  ///
  /// In zh, this message translates to:
  /// **'{years} 年调休数据尚未发布；工作日重复暂按周一至周五计算。'**
  String holidayCoverageMissing(String years);

  /// No description provided for @dayTodosTitle.
  ///
  /// In zh, this message translates to:
  /// **'当日 TODO'**
  String get dayTodosTitle;

  /// No description provided for @dayTodosDescription.
  ///
  /// In zh, this message translates to:
  /// **'管理当天的工作与生活安排。'**
  String get dayTodosDescription;

  /// No description provided for @searchTitle.
  ///
  /// In zh, this message translates to:
  /// **'全局搜索'**
  String get searchTitle;

  /// No description provided for @searchDescription.
  ///
  /// In zh, this message translates to:
  /// **'搜索内容、备注、分类与标签。'**
  String get searchDescription;

  /// No description provided for @searchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索 TODO 内容、备注、分类或标签'**
  String get searchHint;

  /// No description provided for @searchAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get searchAll;

  /// No description provided for @searchIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'未完成'**
  String get searchIncomplete;

  /// No description provided for @searchCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get searchCompleted;

  /// No description provided for @dateRangeLabel.
  ///
  /// In zh, this message translates to:
  /// **'日期范围'**
  String get dateRangeLabel;

  /// No description provided for @noSearchResults.
  ///
  /// In zh, this message translates to:
  /// **'没有找到符合条件的 TODO'**
  String get noSearchResults;

  /// No description provided for @searchLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'搜索失败，请重试'**
  String get searchLoadFailed;

  /// No description provided for @resultCount.
  ///
  /// In zh, this message translates to:
  /// **'找到 {count} 项'**
  String resultCount(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @settingsDescription.
  ///
  /// In zh, this message translates to:
  /// **'主题与本地偏好设置骨架。'**
  String get settingsDescription;

  /// No description provided for @mottoTitle.
  ///
  /// In zh, this message translates to:
  /// **'碎碎念~'**
  String get mottoTitle;

  /// No description provided for @mottoLabel.
  ///
  /// In zh, this message translates to:
  /// **'显示在日历上方的一句话'**
  String get mottoLabel;

  /// No description provided for @mottoSaved.
  ///
  /// In zh, this message translates to:
  /// **'碎碎念已保存'**
  String get mottoSaved;

  /// No description provided for @editMotto.
  ///
  /// In zh, this message translates to:
  /// **'修改碎碎念'**
  String get editMotto;

  /// No description provided for @calendarTodoFontSizeLabel.
  ///
  /// In zh, this message translates to:
  /// **'日历格 TODO 字体大小'**
  String get calendarTodoFontSizeLabel;

  /// No description provided for @sidebarTodoFontSizeLabel.
  ///
  /// In zh, this message translates to:
  /// **'右侧 TODOList 字体大小'**
  String get sidebarTodoFontSizeLabel;

  /// No description provided for @dayTodoFontSizeLabel.
  ///
  /// In zh, this message translates to:
  /// **'当日 TODO 字体大小'**
  String get dayTodoFontSizeLabel;

  /// No description provided for @mottoFontSizeLabel.
  ///
  /// In zh, this message translates to:
  /// **'碎碎念字体大小'**
  String get mottoFontSizeLabel;

  /// No description provided for @mottoColorLabel.
  ///
  /// In zh, this message translates to:
  /// **'碎碎念颜色'**
  String get mottoColorLabel;

  /// No description provided for @mottoBoldLabel.
  ///
  /// In zh, this message translates to:
  /// **'加粗'**
  String get mottoBoldLabel;

  /// No description provided for @mottoItalicLabel.
  ///
  /// In zh, this message translates to:
  /// **'斜体'**
  String get mottoItalicLabel;

  /// No description provided for @mottoUnderlineLabel.
  ///
  /// In zh, this message translates to:
  /// **'下划线'**
  String get mottoUnderlineLabel;

  /// No description provided for @dragTodoToDate.
  ///
  /// In zh, this message translates to:
  /// **'拖动到其他日期'**
  String get dragTodoToDate;

  /// No description provided for @taskMovedToDate.
  ///
  /// In zh, this message translates to:
  /// **'已将任务移动到 {date}'**
  String taskMovedToDate(String date);

  /// No description provided for @hotkeysTitle.
  ///
  /// In zh, this message translates to:
  /// **'键位'**
  String get hotkeysTitle;

  /// No description provided for @summonHotkey.
  ///
  /// In zh, this message translates to:
  /// **'全局呼出「丸成」'**
  String get summonHotkey;

  /// No description provided for @todayHotkey.
  ///
  /// In zh, this message translates to:
  /// **'回到「今天」'**
  String get todayHotkey;

  /// No description provided for @editHotkey.
  ///
  /// In zh, this message translates to:
  /// **'修改快捷键'**
  String get editHotkey;

  /// No description provided for @recordHotkeyHint.
  ///
  /// In zh, this message translates to:
  /// **'请按下新的快捷键组合'**
  String get recordHotkeyHint;

  /// No description provided for @holidayDataTitle.
  ///
  /// In zh, this message translates to:
  /// **'中国法定节假日数据'**
  String get holidayDataTitle;

  /// No description provided for @holidayYearLabel.
  ///
  /// In zh, this message translates to:
  /// **'更新年份'**
  String get holidayYearLabel;

  /// No description provided for @holidayCoverage.
  ///
  /// In zh, this message translates to:
  /// **'覆盖年份：{years}'**
  String holidayCoverage(String years);

  /// No description provided for @holidaySource.
  ///
  /// In zh, this message translates to:
  /// **'所选年份来源：{source}'**
  String holidaySource(String source);

  /// No description provided for @checkHolidayUpdates.
  ///
  /// In zh, this message translates to:
  /// **'检查更新'**
  String get checkHolidayUpdates;

  /// No description provided for @holidayUpdateUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'远端数据源尚未配置，继续使用已验证的内置数据'**
  String get holidayUpdateUnavailable;

  /// No description provided for @holidayUpdateLocalFallback.
  ///
  /// In zh, this message translates to:
  /// **'中国政府网暂时无法获取；继续使用数据库中的已验证数据'**
  String get holidayUpdateLocalFallback;

  /// No description provided for @holidayUpdateFailed.
  ///
  /// In zh, this message translates to:
  /// **'本地数据库和中国政府网均未找到该年度的有效节假日安排'**
  String get holidayUpdateFailed;

  /// No description provided for @holidayUpdated.
  ///
  /// In zh, this message translates to:
  /// **'节假日数据已更新'**
  String get holidayUpdated;

  /// No description provided for @holidayUnchanged.
  ///
  /// In zh, this message translates to:
  /// **'节假日数据已是最新'**
  String get holidayUnchanged;

  /// No description provided for @holidayValidationFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新数据校验失败，已保留原数据'**
  String get holidayValidationFailed;

  /// No description provided for @aboutTitle.
  ///
  /// In zh, this message translates to:
  /// **'关于丸成'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In zh, this message translates to:
  /// **'丸成 / EchoDay\n由丸一口 / Van Echo 创作'**
  String get aboutDescription;

  /// No description provided for @aboutBrand.
  ///
  /// In zh, this message translates to:
  /// **'丸成 | EchoDay'**
  String get aboutBrand;

  /// No description provided for @aboutCreator.
  ///
  /// In zh, this message translates to:
  /// **'由 丸一口 / Van Echo 使用 ChatGPT 5.6 Sol 创作'**
  String get aboutCreator;

  /// No description provided for @aboutWelcome.
  ///
  /// In zh, this message translates to:
  /// **'欢迎'**
  String get aboutWelcome;

  /// No description provided for @supportCharging.
  ///
  /// In zh, this message translates to:
  /// **'充电支持'**
  String get supportCharging;

  /// No description provided for @aboutAnd.
  ///
  /// In zh, this message translates to:
  /// **'及'**
  String get aboutAnd;

  /// No description provided for @bugFeedback.
  ///
  /// In zh, this message translates to:
  /// **'BUG反馈'**
  String get bugFeedback;

  /// No description provided for @aboutTilde.
  ///
  /// In zh, this message translates to:
  /// **'~'**
  String get aboutTilde;

  /// No description provided for @aboutLicensePrefix.
  ///
  /// In zh, this message translates to:
  /// **'本项目采用'**
  String get aboutLicensePrefix;

  /// No description provided for @aboutLicenseName.
  ///
  /// In zh, this message translates to:
  /// **'GNU Affero General Public License v3.0'**
  String get aboutLicenseName;

  /// No description provided for @aboutLicenseSuffix.
  ///
  /// In zh, this message translates to:
  /// **''**
  String get aboutLicenseSuffix;

  /// No description provided for @communityLicenseDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'GNU Affero General Public License v3.0'**
  String get communityLicenseDialogTitle;

  /// No description provided for @communityLicenseDialogSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'SPDX：AGPL-3.0-only · OSI 认可的强 Copyleft 开源协议'**
  String get communityLicenseDialogSubtitle;

  /// No description provided for @communityLicenseLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在载入协议……'**
  String get communityLicenseLoading;

  /// No description provided for @communityLicenseLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'协议正文载入失败，请查看软件目录中的 LICENSE 文件。'**
  String get communityLicenseLoadFailed;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @aboutPersonalUse.
  ///
  /// In zh, this message translates to:
  /// **'个人、企业及商业使用均被允许'**
  String get aboutPersonalUse;

  /// No description provided for @aboutCommercialUse.
  ///
  /// In zh, this message translates to:
  /// **'发布修改版，或将修改版作为网络服务提供时，须遵循 AGPLv3 并提供对应源代码'**
  String get aboutCommercialUse;

  /// No description provided for @aboutVersion.
  ///
  /// In zh, this message translates to:
  /// **'v{version} | {date}'**
  String aboutVersion(String version, String date);

  /// No description provided for @linkOpenFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开链接，请检查系统默认浏览器'**
  String get linkOpenFailed;

  /// No description provided for @themeModeLabel.
  ///
  /// In zh, this message translates to:
  /// **'主题模式'**
  String get themeModeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get themeDark;

  /// No description provided for @primaryColorLabel.
  ///
  /// In zh, this message translates to:
  /// **'主色'**
  String get primaryColorLabel;

  /// No description provided for @calendarTaskSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'日历与任务'**
  String get calendarTaskSettingsTitle;

  /// No description provided for @calendarPreviewLabel.
  ///
  /// In zh, this message translates to:
  /// **'日期格 TODO 预览'**
  String get calendarPreviewLabel;

  /// No description provided for @calendarPreviewValue.
  ///
  /// In zh, this message translates to:
  /// **'最多 {count} 条'**
  String calendarPreviewValue(int count);

  /// No description provided for @defaultSortLabel.
  ///
  /// In zh, this message translates to:
  /// **'默认任务排序'**
  String get defaultSortLabel;

  /// No description provided for @dataSafetyTitle.
  ///
  /// In zh, this message translates to:
  /// **'数据备份与恢复'**
  String get dataSafetyTitle;

  /// No description provided for @dataSafetyDescription.
  ///
  /// In zh, this message translates to:
  /// **'备份包含任务、分类、标签、重复规则和用户设置；法定节假日缓存不会写入。'**
  String get dataSafetyDescription;

  /// No description provided for @exportBackup.
  ///
  /// In zh, this message translates to:
  /// **'导出 JSON 备份'**
  String get exportBackup;

  /// No description provided for @importBackup.
  ///
  /// In zh, this message translates to:
  /// **'导入 JSON 备份'**
  String get importBackup;

  /// No description provided for @clearData.
  ///
  /// In zh, this message translates to:
  /// **'清空数据'**
  String get clearData;

  /// No description provided for @clearDataConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认清空全部用户数据？'**
  String get clearDataConfirmTitle;

  /// No description provided for @clearDataConfirmBody.
  ///
  /// In zh, this message translates to:
  /// **'TODO、分类、标签、重复规则和全部用户设置将被清空，法定节假日缓存会保留。丸成会先自动创建一份安全备份。'**
  String get clearDataConfirmBody;

  /// No description provided for @clearDataConfirmAction.
  ///
  /// In zh, this message translates to:
  /// **'确认清空'**
  String get clearDataConfirmAction;

  /// No description provided for @clearDataCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已清空 {count} 条记录'**
  String clearDataCompleted(int count);

  /// No description provided for @clearDataSafetyCreated.
  ///
  /// In zh, this message translates to:
  /// **'清空前安全备份：{path}'**
  String clearDataSafetyCreated(String path);

  /// No description provided for @backupExported.
  ///
  /// In zh, this message translates to:
  /// **'备份已导出'**
  String get backupExported;

  /// No description provided for @backupOperationFailed.
  ///
  /// In zh, this message translates to:
  /// **'操作失败：{reason}'**
  String backupOperationFailed(String reason);

  /// No description provided for @backupInvalid.
  ///
  /// In zh, this message translates to:
  /// **'备份预检未通过：{reason}'**
  String backupInvalid(String reason);

  /// No description provided for @backupPreviewTitle.
  ///
  /// In zh, this message translates to:
  /// **'备份预检通过'**
  String get backupPreviewTitle;

  /// No description provided for @backupPreviewBody.
  ///
  /// In zh, this message translates to:
  /// **'格式 v{formatVersion} · 应用 v{appVersion}\n导出时间：{exportedAt}\nTODO：{todoCount} 项 · 全部记录：{totalCount} 项'**
  String backupPreviewBody(
    int formatVersion,
    String appVersion,
    String exportedAt,
    int todoCount,
    int totalCount,
  );

  /// No description provided for @mergeImport.
  ///
  /// In zh, this message translates to:
  /// **'合并导入'**
  String get mergeImport;

  /// No description provided for @replaceRestore.
  ///
  /// In zh, this message translates to:
  /// **'覆盖恢复'**
  String get replaceRestore;

  /// No description provided for @replaceConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认覆盖当前数据？'**
  String get replaceConfirmTitle;

  /// No description provided for @replaceConfirmBody.
  ///
  /// In zh, this message translates to:
  /// **'当前任务和设置会被备份文件替换。丸成会先在应用数据目录自动创建一份安全备份；导入失败时数据库不会改变。'**
  String get replaceConfirmBody;

  /// No description provided for @replaceConfirmAction.
  ///
  /// In zh, this message translates to:
  /// **'确认覆盖'**
  String get replaceConfirmAction;

  /// No description provided for @backupImportCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已导入 {imported} 项，跳过 {skipped} 项'**
  String backupImportCompleted(int imported, int skipped);

  /// No description provided for @backupSafetyCreated.
  ///
  /// In zh, this message translates to:
  /// **'覆盖前安全备份：{path}'**
  String backupSafetyCreated(String path);

  /// No description provided for @routeNotFound.
  ///
  /// In zh, this message translates to:
  /// **'页面不存在'**
  String get routeNotFound;

  /// No description provided for @unexpectedError.
  ///
  /// In zh, this message translates to:
  /// **'丸成遇到了意外错误'**
  String get unexpectedError;

  /// No description provided for @unexpectedErrorHint.
  ///
  /// In zh, this message translates to:
  /// **'请重新启动应用；日志中已记录诊断信息。'**
  String get unexpectedErrorHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
