// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '丸成';

  @override
  String get appSubtitle => 'EchoDay';

  @override
  String get navCalendar => '日历';

  @override
  String get navDayTodos => '当日 TODO';

  @override
  String get navSearch => '搜索';

  @override
  String get navSettings => '设置';

  @override
  String get navAbout => '关于';

  @override
  String get expandNavigation => '显示导航文字';

  @override
  String get collapseNavigation => '仅显示导航图标';

  @override
  String get calendarTitle => '月历工作台';

  @override
  String get calendarDescription => '连续周日历将在 M2 接入。';

  @override
  String get previousMonth => '上个月';

  @override
  String get nextMonth => '下个月';

  @override
  String get today => '今天';

  @override
  String get backToToday => '回到今天';

  @override
  String get backToSelectedDate => '回到选中日期';

  @override
  String visibleWeeks(int count) {
    return '$count 周';
  }

  @override
  String get showFewerWeeks => '显示更少周';

  @override
  String get showMoreWeeks => '显示更多周';

  @override
  String get mondayShort => '周一';

  @override
  String get tuesdayShort => '周二';

  @override
  String get wednesdayShort => '周三';

  @override
  String get thursdayShort => '周四';

  @override
  String get fridayShort => '周五';

  @override
  String get saturdayShort => '周六';

  @override
  String get sundayShort => '周日';

  @override
  String get quickAddTitle => '快速新增 TODO';

  @override
  String get todoTitleHint => '要完成什么？';

  @override
  String get addTask => '新增';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get clear => '清除';

  @override
  String get editTask => '编辑任务';

  @override
  String get deleteTask => '删除任务';

  @override
  String get markComplete => '标记完成';

  @override
  String get restoreTask => '恢复任务';

  @override
  String get undo => '撤销';

  @override
  String get taskDeleted => '任务已删除';

  @override
  String get incompleteTasks => '待完成';

  @override
  String get completedTasks => '已完成';

  @override
  String get overdue => '已逾期';

  @override
  String get sortTasks => '任务排序';

  @override
  String get filterTasks => '筛选任务';

  @override
  String get clearFilters => '清除筛选';

  @override
  String get applyFilters => '应用筛选';

  @override
  String get sortManual => '手动排序';

  @override
  String get sortCreatedAscending => '创建时间（早到晚）';

  @override
  String get sortCreatedDescending => '创建时间（晚到早）';

  @override
  String get sortPlannedTime => '计划时间';

  @override
  String get sortPriority => '优先级';

  @override
  String get sortComposite => '智能排序';

  @override
  String get dragToReorder => '拖动调整顺序';

  @override
  String get taskDetails => '任务详情';

  @override
  String get titleLabel => '内容';

  @override
  String get dateLabel => '所属日期';

  @override
  String get plannedAtLabel => '计划执行时间';

  @override
  String get deadlineAtLabel => '计划 DDL 时间';

  @override
  String get priorityLabel => '优先级';

  @override
  String get priorityHigh => '高';

  @override
  String get priorityMedium => '中';

  @override
  String get priorityLow => '低';

  @override
  String get priorityNone => '无';

  @override
  String get categoryLabel => '分类';

  @override
  String get tagsLabel => '标签';

  @override
  String get notesLabel => '备注';

  @override
  String get createCategory => '新建分类';

  @override
  String get createTag => '新建标签';

  @override
  String get selectCategory => '选择分类';

  @override
  String get catalogEditHint => '单击选择，双击修改';

  @override
  String get editCategory => '修改分类';

  @override
  String get editTag => '修改标签';

  @override
  String get deleteCategory => '删除分类';

  @override
  String get deleteTag => '删除标签';

  @override
  String get deleteCatalogTitle => '确认删除？';

  @override
  String get deleteCatalogMessage => '删除后任务本身会保留，但不再显示这个分类或标签。';

  @override
  String get nameHint => '输入名称';

  @override
  String get colorLabel => '颜色';

  @override
  String get addCustomColor => '从调色盘增加颜色';

  @override
  String get removeSelectedColor => '删除当前选中的颜色';

  @override
  String get hueLabel => '色相';

  @override
  String get saturationLabel => '饱和度';

  @override
  String get brightnessLabel => '明度';

  @override
  String get repeatRuleLabel => '重复规则';

  @override
  String get repeatRuleM4Hint => '不重复';

  @override
  String get repeatDaily => '每天';

  @override
  String get repeatWeekdays => '每个工作日';

  @override
  String get repeatWeekly => '每周';

  @override
  String get repeatMonthly => '每月';

  @override
  String get repeatCustom => '自定义间隔';

  @override
  String get repeatInterval => '间隔';

  @override
  String get repeatUnitDay => '天';

  @override
  String get repeatUnitWeek => '周';

  @override
  String get repeatUnitMonth => '月';

  @override
  String get repeatUntil => '结束日期';

  @override
  String get repeatCount => '重复次数';

  @override
  String get repeatWorkdayFallback => '已覆盖年份按中国法定节假日与调休计算；缺少年度数据时按周一至周五，并在月历提示';

  @override
  String get recurrenceScopeTitle => '应用到重复任务';

  @override
  String get onlyThisOccurrence => '仅本次';

  @override
  String get thisAndFuture => '本次及之后';

  @override
  String get chooseDateTime => '选择日期和时间';

  @override
  String get chooseTime => '选择时间';

  @override
  String get chooseDate => '选择日期';

  @override
  String get yearLabel => '年份';

  @override
  String get monthLabel => '月份';

  @override
  String monthValue(int month) {
    return '$month月';
  }

  @override
  String get taskSaveFailed => '保存失败，请重试';

  @override
  String get taskActionFailed => '操作失败，请重试';

  @override
  String get postponeIncomplete => '未完成任务顺延至下一天';

  @override
  String postponeIncompleteDays(int days) {
    return '未完成任务顺延 $days 天（右键配置）';
  }

  @override
  String get configurePostponeDays => '配置顺延天数';

  @override
  String get postponeDaysLabel => '顺延 X 天';

  @override
  String get postponeDaysRange => '可填写 1～365 天；批量与单项任务共用';

  @override
  String postponeDialogBodyDays(int count, String date, int days) {
    return '将这一天的 $count 项未完成任务移至 $date，顺延 $days 天。计划执行时间和计划 DDL 也会同步移动。';
  }

  @override
  String postponedTasksDays(int count, int days) {
    return '已将 $count 项未完成任务顺延 $days 天';
  }

  @override
  String postponeOneTaskDays(int days) {
    return '将此任务顺延 $days 天';
  }

  @override
  String postponedOneTask(int days) {
    return '已将任务顺延 $days 天';
  }

  @override
  String get postponeDialogTitle => '顺延未完成任务？';

  @override
  String postponeDialogBody(int count, String date) {
    return '将这一天的 $count 项未完成任务移至 $date。计划执行时间和计划 DDL 也会顺延一天。';
  }

  @override
  String get postponeAction => '顺延';

  @override
  String postponedTasks(int count) {
    return '已顺延 $count 项未完成任务';
  }

  @override
  String get noTasksForDate => '这一天还没有 TODO';

  @override
  String get todoLoadFailed => 'TODO 加载失败';

  @override
  String moreTasks(int count) {
    return '还有 $count 项';
  }

  @override
  String get openFullScreen => '全屏打开当日 TODO';

  @override
  String get backToCalendar => '返回月历';

  @override
  String get holidayDayOff => '休';

  @override
  String get holidayWorkday => '班';

  @override
  String get holidayCoverageMissingShort => '调休未覆盖';

  @override
  String holidayCoverageMissing(String years) {
    return '$years 年调休数据尚未发布；工作日重复暂按周一至周五计算。';
  }

  @override
  String get dayTodosTitle => '当日 TODO';

  @override
  String get dayTodosDescription => '管理当天的工作与生活安排。';

  @override
  String get searchTitle => '全局搜索';

  @override
  String get searchDescription => '搜索内容、备注、分类与标签。';

  @override
  String get searchHint => '搜索 TODO 内容、备注、分类或标签';

  @override
  String get searchAll => '全部';

  @override
  String get searchIncomplete => '未完成';

  @override
  String get searchCompleted => '已完成';

  @override
  String get dateRangeLabel => '日期范围';

  @override
  String get noSearchResults => '没有找到符合条件的 TODO';

  @override
  String get searchLoadFailed => '搜索失败，请重试';

  @override
  String resultCount(int count) {
    return '找到 $count 项';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsDescription => '主题与本地偏好设置骨架。';

  @override
  String get mottoTitle => '碎碎念~';

  @override
  String get mottoLabel => '显示在日历上方的一句话';

  @override
  String get mottoSaved => '碎碎念已保存';

  @override
  String get editMotto => '修改碎碎念';

  @override
  String get hotkeysTitle => '键位';

  @override
  String get summonHotkey => '全局呼出「丸成」';

  @override
  String get todayHotkey => '回到「今天」';

  @override
  String get editHotkey => '修改快捷键';

  @override
  String get recordHotkeyHint => '请按下新的快捷键组合';

  @override
  String get holidayDataTitle => '中国法定节假日数据';

  @override
  String get holidayYearLabel => '更新年份';

  @override
  String holidayCoverage(String years) {
    return '覆盖年份：$years';
  }

  @override
  String holidaySource(String source) {
    return '所选年份来源：$source';
  }

  @override
  String get checkHolidayUpdates => '检查更新';

  @override
  String get holidayUpdateUnavailable => '远端数据源尚未配置，继续使用已验证的内置数据';

  @override
  String get holidayUpdateLocalFallback => '中国政府网暂时无法获取；继续使用数据库中的已验证数据';

  @override
  String get holidayUpdateFailed => '本地数据库和中国政府网均未找到该年度的有效节假日安排';

  @override
  String get holidayUpdated => '节假日数据已更新';

  @override
  String get holidayUnchanged => '节假日数据已是最新';

  @override
  String get holidayValidationFailed => '更新数据校验失败，已保留原数据';

  @override
  String get aboutTitle => '关于丸成';

  @override
  String get aboutDescription => '丸成 / EchoDay\n由丸一口 / Van Echo 创作';

  @override
  String get aboutBrand => '丸成 | EchoDay';

  @override
  String get aboutCreator => '由 丸一口 / Van Echo 使用 ChatGPT 5.6 Sol 创作';

  @override
  String get aboutWelcome => '欢迎';

  @override
  String get supportCharging => '充电支持';

  @override
  String get aboutAnd => '及';

  @override
  String get bugFeedback => 'BUG反馈';

  @override
  String get aboutTilde => '~';

  @override
  String get aboutLicensePrefix => '本项目采用';

  @override
  String get aboutLicenseName => 'GNU Affero General Public License v3.0';

  @override
  String get aboutLicenseSuffix => '';

  @override
  String get communityLicenseDialogTitle =>
      'GNU Affero General Public License v3.0';

  @override
  String get communityLicenseDialogSubtitle =>
      'SPDX：AGPL-3.0-only · OSI 认可的强 Copyleft 开源协议';

  @override
  String get communityLicenseLoading => '正在载入协议……';

  @override
  String get communityLicenseLoadFailed => '协议正文载入失败，请查看软件目录中的 LICENSE 文件。';

  @override
  String get close => '关闭';

  @override
  String get aboutPersonalUse => '个人、企业及商业使用均被允许';

  @override
  String get aboutCommercialUse => '发布修改版，或将修改版作为网络服务提供时，须遵循 AGPLv3 并提供对应源代码';

  @override
  String aboutVersion(String version, String date) {
    return 'v$version | $date';
  }

  @override
  String get linkOpenFailed => '无法打开链接，请检查系统默认浏览器';

  @override
  String get themeModeLabel => '主题模式';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get primaryColorLabel => '主色';

  @override
  String get calendarTaskSettingsTitle => '日历与任务';

  @override
  String get calendarPreviewLabel => '日期格 TODO 预览';

  @override
  String calendarPreviewValue(int count) {
    return '最多 $count 条';
  }

  @override
  String get defaultSortLabel => '默认任务排序';

  @override
  String get dataSafetyTitle => '数据备份与恢复';

  @override
  String get dataSafetyDescription => '备份包含任务、分类、标签、重复规则和用户设置；法定节假日缓存不会写入。';

  @override
  String get exportBackup => '导出 JSON 备份';

  @override
  String get importBackup => '导入 JSON 备份';

  @override
  String get backupExported => '备份已导出';

  @override
  String backupOperationFailed(String reason) {
    return '操作失败：$reason';
  }

  @override
  String backupInvalid(String reason) {
    return '备份预检未通过：$reason';
  }

  @override
  String get backupPreviewTitle => '备份预检通过';

  @override
  String backupPreviewBody(
    int formatVersion,
    String appVersion,
    String exportedAt,
    int todoCount,
    int totalCount,
  ) {
    return '格式 v$formatVersion · 应用 v$appVersion\n导出时间：$exportedAt\nTODO：$todoCount 项 · 全部记录：$totalCount 项';
  }

  @override
  String get mergeImport => '合并导入';

  @override
  String get replaceRestore => '覆盖恢复';

  @override
  String get replaceConfirmTitle => '确认覆盖当前数据？';

  @override
  String get replaceConfirmBody =>
      '当前任务和设置会被备份文件替换。丸成会先在应用数据目录自动创建一份安全备份；导入失败时数据库不会改变。';

  @override
  String get replaceConfirmAction => '确认覆盖';

  @override
  String backupImportCompleted(int imported, int skipped) {
    return '已导入 $imported 项，跳过 $skipped 项';
  }

  @override
  String backupSafetyCreated(String path) {
    return '覆盖前安全备份：$path';
  }

  @override
  String get routeNotFound => '页面不存在';

  @override
  String get unexpectedError => '丸成遇到了意外错误';

  @override
  String get unexpectedErrorHint => '请重新启动应用；日志中已记录诊断信息。';
}
