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
  String get previousWeek => '上一周';

  @override
  String get nextWeek => '下一周';

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
  String get calendarTodoFontSizeLabel => '日历格 TODO 字体大小';

  @override
  String get expandTodayByDefault => '默认放大当日日历格';

  @override
  String get sidebarTodoFontSizeLabel => '右侧 TODOList 字体大小';

  @override
  String get dayTodoFontSizeLabel => '当日 TODO 字体大小';

  @override
  String get mottoFontSizeLabel => '碎碎念字体大小';

  @override
  String get mottoColorLabel => '碎碎念颜色';

  @override
  String get mottoBoldLabel => '加粗';

  @override
  String get mottoItalicLabel => '斜体';

  @override
  String get mottoUnderlineLabel => '下划线';

  @override
  String get dragTodoToDate => '拖动到其他日期';

  @override
  String get moveToDate => '移动到日期';

  @override
  String get taskActions => '任务操作';

  @override
  String taskMovedToDate(String date) {
    return '已将任务移动到 $date';
  }

  @override
  String get hotkeysTitle => '键位';

  @override
  String get summonHotkey => '全局呼出「丸成」';

  @override
  String get todayHotkey => '回到「今天」';

  @override
  String get addTodoHotkey => '在当前选中日期新增 TODO';

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
  String get languageLabel => '语言';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';

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
  String get dataSafetyDescription =>
      '备份包含任务、分类、标签、重复规则和可迁移的用户设置；法定节假日缓存及设备本地目录设置不会写入。';

  @override
  String get defaultBackupDirectoryTitle => '默认备份目录';

  @override
  String get backupDirectorySystemDefault => '系统默认目录';

  @override
  String backupDirectoryFallback(String path) {
    return '自定义目录当前不可用，已临时回退到：$path';
  }

  @override
  String get chooseBackupDirectory => '选择目录';

  @override
  String get openBackupDirectory => '打开目录';

  @override
  String get testBackupDirectory => '测试写入';

  @override
  String get resetBackupDirectory => '恢复默认';

  @override
  String get backupDirectorySaved => '默认备份目录已保存';

  @override
  String get backupDirectoryReset => '已恢复系统默认备份目录';

  @override
  String get backupDirectoryTestPassed => '目录可写，测试通过';

  @override
  String get backupNow => '立即备份到默认目录';

  @override
  String backupCreatedAt(String path) {
    return '备份已创建：$path';
  }

  @override
  String get automaticBackupTitle => '每日自动备份';

  @override
  String get automaticBackupDescription =>
      '每天首次打开或回到丸成时最多创建一份；同步功能完成后也会在当日首次同步前复用此备份。';

  @override
  String get automaticBackupRetention => '自动备份保留数量';

  @override
  String automaticBackupRetentionValue(int count) {
    return '保留 $count 份';
  }

  @override
  String get syncHostTitle => '多端同步';

  @override
  String get syncHostDescription =>
      '一台 Windows PC 作为主机；局域网或 Tailscale 只负责连接，任务数据仍保存在各设备本地。';

  @override
  String get syncModeLabel => '同步模式';

  @override
  String get syncModeOff => '关闭同步';

  @override
  String get syncModeHost => '作为同步主机';

  @override
  String get syncModeClient => '连接到同步主机';

  @override
  String get syncStatusStopped => '已停止';

  @override
  String get syncStatusStarting => '正在启动';

  @override
  String get syncStatusRunning => '正在运行';

  @override
  String get syncStatusStopping => '正在停止';

  @override
  String get syncStatusFailed => '启动失败';

  @override
  String get syncAddressLabel => '监听网络接口';

  @override
  String get syncRefreshNetworks => '刷新网络';

  @override
  String get syncRestartHost => '重启服务';

  @override
  String syncEndpointLabel(String endpoint) {
    return '服务地址：$endpoint';
  }

  @override
  String syncFingerprintLabel(String fingerprint) {
    return '主机指纹：$fingerprint';
  }

  @override
  String get syncCreatePairing => '添加设备';

  @override
  String get syncPairingTitle => '配对新设备';

  @override
  String get syncPairingHint => '让客户端扫描二维码，或复制完整连接码。随后请核对双方显示的六位校验码。';

  @override
  String get syncConnectionCode => '一次性连接码';

  @override
  String syncExpiresAt(String time) {
    return '有效期至 $time';
  }

  @override
  String get syncCopy => '复制';

  @override
  String get syncCopied => '已复制到剪贴板';

  @override
  String get syncPendingPairings => '待确认设备';

  @override
  String syncVerificationCode(String code) {
    return '校验码 $code';
  }

  @override
  String get syncApprove => '确认配对';

  @override
  String get syncReject => '拒绝';

  @override
  String get syncDevicesTitle => '已连接设备';

  @override
  String get syncLocalDevice => '本机';

  @override
  String get syncOnline => '在线';

  @override
  String get syncOffline => '离线';

  @override
  String get syncWaiting => '等待同步';

  @override
  String get syncRevoked => '已撤销';

  @override
  String get syncNeedsUpgrade => '需要升级';

  @override
  String get syncNeverSynced => '尚未完成同步';

  @override
  String syncLastSynced(String time) {
    return '上次同步：$time';
  }

  @override
  String get syncEditNote => '修改备注';

  @override
  String get syncDeviceNote => '设备备注';

  @override
  String get syncNow => '立即同步';

  @override
  String get syncAll => '主动同步全部设备';

  @override
  String syncRequestedCount(int count) {
    return '已向 $count 台设备发出同步请求；离线设备将在下次连接时收到。';
  }

  @override
  String get syncRevoke => '撤销设备';

  @override
  String get syncRevokeConfirmTitle => '撤销此设备？';

  @override
  String get syncRevokeConfirmBody => '撤销后现有会话立即失效；该设备若要重新加入，必须再次配对。本地任务不会被删除。';

  @override
  String syncConflicts(int count) {
    return '同步冲突（$count）';
  }

  @override
  String syncConflictsNeedAttention(int count) {
    return '有 $count 项同步冲突待处理';
  }

  @override
  String get syncAttentionSemantics => '多端同步需要处理';

  @override
  String get syncConflictTitle => '待处理同步冲突';

  @override
  String get syncConflictEmpty => '没有待处理冲突';

  @override
  String get syncRestoreVersion => '恢复此版本';

  @override
  String get syncLaunchAtStartup => '登录 Windows 后启动丸成';

  @override
  String get syncKeepInTray => '关闭窗口后在托盘继续运行';

  @override
  String get syncHostStartFailed => '同步主机启动失败，请检查所选网络、端口占用和 Windows 防火墙。';

  @override
  String get syncInitializationFailed => '无法载入同步设置，请稍后重试。';

  @override
  String get syncInviteFailed => '无法创建配对邀请，请确认主机服务正在运行。';

  @override
  String get syncOperationFailed => '同步操作失败，请稍后重试。';

  @override
  String get syncRoleChangeBlocked => '本机已是同步组主机，不能直接改为客户端。请先完成主机迁移或清除同步组身份。';

  @override
  String get exportBackup => '导出 JSON 备份';

  @override
  String get importBackup => '导入 JSON 备份';

  @override
  String get clearData => '清空数据';

  @override
  String get clearDataConfirmTitle => '确认清空全部用户数据？';

  @override
  String get clearDataConfirmBody =>
      'TODO、分类、标签、重复规则和全部用户设置将被清空，法定节假日缓存会保留。丸成会先自动创建一份安全备份。';

  @override
  String get clearDataConfirmAction => '确认清空';

  @override
  String clearDataCompleted(int count) {
    return '已清空 $count 条记录';
  }

  @override
  String clearDataSafetyCreated(String path) {
    return '清空前安全备份：$path';
  }

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
  String get syncClientTitle => '多端同步';

  @override
  String get syncClientDescription =>
      '通过局域网或 Tailscale 连接你的主 PC。手机仍可离线使用，只在打开、回到前台或手动操作时同步。';

  @override
  String get syncClientDesktopDescription =>
      '将本机作为客户端连接主 PC。支持局域网、Tailscale IP 和 MagicDNS；离线编辑会在下次打开窗口或手动同步时上传。';

  @override
  String get syncClientDisconnected => '尚未连接同步主机';

  @override
  String get syncClientConnecting => '正在连接主机…';

  @override
  String get syncClientWaitingApproval => '等待主机确认';

  @override
  String get syncClientSyncing => '正在同步…';

  @override
  String get syncClientSynced => '已同步';

  @override
  String get syncClientOffline => '主机暂时不可达，本地编辑不受影响';

  @override
  String get syncClientError => '同步需要处理';

  @override
  String get syncScanQr => '扫描主机二维码';

  @override
  String get syncPasteCode => '粘贴连接码';

  @override
  String get syncPairingCodeLabel => '完整连接码';

  @override
  String get syncImportPairingFile => '导入配对文件';

  @override
  String get syncExportPairingFile => '导出配对文件';

  @override
  String get syncDiscoverNearby => '发现附近主机';

  @override
  String get syncNoNearbyHost => '未发现正在展示配对邀请的主机。请在主 PC 上打开“添加设备”窗口后重试。';

  @override
  String get syncChooseNearbyHost => '选择附近主机';

  @override
  String syncNearbyHostFound(String name) {
    return '已发现 $name，请点击“连接”并在主机上核对校验码。';
  }

  @override
  String get syncDiscoveryFailed => '附近主机发现失败。你仍可粘贴连接码或导入配对文件。';

  @override
  String get syncPairingFileExported => '配对文件已导出';

  @override
  String get syncPairingFileInvalid => '配对文件无效、损坏或已经过期。';

  @override
  String get syncHostOverride => '主机地址（可选覆盖）';

  @override
  String get syncHostOverrideHint =>
      '完整连接码仍负责安全验证；这里可将其中的地址替换为当前可达的局域网 IP、Tailscale IP 或 MagicDNS 名称。';

  @override
  String get syncHostAddress => '主机地址';

  @override
  String get syncPort => '端口';

  @override
  String get syncSaveAndRetry => '保存并重试';

  @override
  String get syncConnect => '连接';

  @override
  String get syncScannerTitle => '扫描 EchoDay 配对码';

  @override
  String get syncScannerHint => '将主 PC 上的二维码放入框内';

  @override
  String get syncScannerPermissionDenied => '需要相机权限才能扫码。你也可以返回后粘贴连接码。';

  @override
  String get syncClientVerificationHint => '请确认主 PC 显示相同的六位校验码，再在主 PC 上批准此设备。';

  @override
  String get syncClientHost => '同步主机';

  @override
  String syncClientAddress(String address) {
    return '地址：$address';
  }

  @override
  String syncClientLastResult(int uploaded, int downloaded, int conflicts) {
    return '本次上传 $uploaded 项，下载 $downloaded 项，冲突 $conflicts 项';
  }

  @override
  String get syncClientDisconnect => '解除本机连接';

  @override
  String get syncClientDisconnectTitle => '解除与主机的连接？';

  @override
  String get syncClientDisconnectBody =>
      '本机中的 TODO 会完整保留，并会先创建安全备份；同步身份与游标将被清除。如需再次同步，必须重新配对。';

  @override
  String get syncClientDisconnectAction => '确认解除';

  @override
  String get syncClientInvalidCode => '连接码无效或已损坏。';

  @override
  String get syncClientHostUnreachable =>
      '无法连接主机，请确认主 PC 已启动 Server 服务，并检查局域网或 Tailscale。';

  @override
  String get syncClientPairRejected => '主机拒绝了本次配对。';

  @override
  String get syncClientInviteExpired => '配对邀请已过期，请在主 PC 上重新生成。';

  @override
  String get syncClientFingerprintMismatch => '主机安全指纹不匹配，已拒绝连接。';

  @override
  String get syncClientProtocolIncompatible => '主机与本机的 EchoDay 版本不兼容，请升级后重试。';

  @override
  String get syncClientAlreadyConnected => '本机已经属于一个同步组，请先解除原连接。';

  @override
  String get syncClientDeviceRevoked =>
      '本设备已被主机撤销。本地数据仍然保留；如需重新加入，请先解除连接并重新配对。';

  @override
  String get syncClientAuthenticationFailed =>
      '同步身份验证失败。本地数据仍然保留，请检查主机设备列表或重新配对。';

  @override
  String get syncClientSyncFailed => '同步失败，本地数据没有丢失；请稍后重试。';

  @override
  String get syncClientDisconnectFailed => '解除连接失败，请稍后重试。';

  @override
  String get syncInvalidHostAddress =>
      '主机地址或端口无效。请输入 IP 地址或 MagicDNS 名称，并检查端口范围。';

  @override
  String get routeNotFound => '页面不存在';

  @override
  String get unexpectedError => '丸成遇到了意外错误';

  @override
  String get unexpectedErrorHint => '请重新启动应用；日志中已记录诊断信息。';
}
