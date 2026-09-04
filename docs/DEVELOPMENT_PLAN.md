# 丸成 / EchoDay — Flutter 技术架构与开发计划

> 状态：技术基线 v0.1  
> 对应产品需求：`docs/PRD.md`

## 1. 技术目标

- 第一阶段交付 Windows 桌面应用。
- 同一 Flutter 工程保留 Android 平台能力。
- UI、领域逻辑与数据访问解耦，云同步不侵入页面层。
- 数据库、备份格式和节假日数据均支持版本迁移。
- 关键计算可单元测试，关键数据流程可集成测试。

Flutter 官方支持编译原生 Windows 桌面应用，并允许插件按平台提供实现；这适合 EchoDay 的 Windows 先行、Android 后续路线。

## 2. 建议技术栈

不在规划文档中锁死具体版本；创建工程时以当时 Flutter stable 与互相兼容的稳定包为准，并提交锁文件。

| 领域 | 选择 | 用途 |
| --- | --- | --- |
| UI | Flutter + Material 3 | Windows 与 Android 共用组件和主题系统 |
| 状态管理 | Riverpod | 依赖注入、异步状态与可测试的业务状态 |
| 路由 | go_router | 月历、当日详情、搜索、设置与未来深链 |
| 本地数据库 | Drift + SQLite | 关系数据、响应式查询、迁移和跨原生平台支持 |
| 序列化 | json_serializable | 版本化备份 DTO 与节假日 JSON |
| 文件访问 | path_provider + file_picker | 数据库存储、导出和导入选择 |
| 本地化 | intl + Flutter l10n | 中文优先，并预留英文界面 |
| ID | UUID | 本地唯一标识和未来同步主键 |

Drift 的原生实现可覆盖 Android、Windows 等平台，并可把数据库放在后台 isolate 中运行。全局搜索初期可使用索引化查询；数据量或搜索体验需要时启用 SQLite FTS5，而不改变搜索仓库接口。

## 3. 分层结构

```text
Presentation
  页面、组件、主题、键鼠交互
        ↓
Application
  用例、状态控制器、排序与筛选编排
        ↓
Domain
  实体、值对象、规则、Repository 接口
        ↓
Data
  Drift、本地文件、节假日源、备份实现
```

建议采用 feature-first 目录：

```text
lib/
├─ app/                 # 启动、路由、主题、依赖装配
├─ core/                # 时间、错误、ID、通用结果类型
├─ features/
│  ├─ calendar/
│  ├─ todos/
│  ├─ search/
│  ├─ holidays/
│  ├─ backup/
│  └─ settings/
└─ data/
   ├─ database/
   └─ migrations/
```

每个 feature 内按 `domain/application/data/presentation` 按需拆分；小功能不为追求形式强制建立空目录。

## 4. 核心接口

```dart
abstract interface class TodoRepository {
  Stream<List<Todo>> watchByDate(LocalDate date);
  Future<Todo?> getById(String id);
  Future<void> save(Todo todo);
  Future<void> complete(String id, DateTime completedAt);
  Future<void> restore(String id);
  Future<void> delete(String id);
  Future<void> reorder(LocalDate date, List<String> orderedIds);
  Future<SearchPage<Todo>> search(TodoSearchQuery query);
}

abstract interface class HolidayRepository {
  Future<HolidayYear?> getYear(int year);
  Future<HolidayRefreshResult> refresh(int year);
  Future<Set<int>> getAvailableYears();
}

abstract interface class BackupRepository {
  Future<BackupManifest> exportTo(String path);
  Future<ImportPreview> inspect(String path);
  Future<ImportResult> merge(String path);
  Future<ImportResult> replace(String path);
}
```

未来新增 `RemoteTodoRepository` 或 `SyncCoordinator` 时，页面和领域用例继续依赖上述抽象。

## 5. 数据模型草案

### 5.1 主要表

- `todos`：用户字段、同步元数据、完成状态、手动顺序和重复实例引用。
- `categories`：名称、颜色、排序和软删除字段。
- `tags`：名称、颜色、排序和软删除字段。
- `todo_tags`：TODO 与标签的多对多关系。
- `recurrence_series`：重复主规则、起始点、结束条件与版本。
- `recurrence_exceptions`：单次修改、跳过、完成或删除的例外。
- `holiday_years`：年度数据、来源、版本、校验值和更新时间。
- `settings`：主题、预览条数、排序偏好、TODO 栏宽度比例等键值设置。

### 5.2 时间存储

- 所属日期保存为不带时区的本地日历日期 `YYYY-MM-DD`。
- 创建、更新、完成、计划执行和 DDL 时间内部统一保存 UTC 时间戳。
- 需要在 UI 中按设备时区显示；数据层预留原始时区 ID，以支持未来跨区同步。
- 逾期计算集中在领域服务中，不散落在组件内。

### 5.3 同步预留字段

- `id`：UUID。
- `createdAt`、`updatedAt`：UTC 时间戳。
- `deletedAt`：软删除时间，可空。
- `revision`：本地递增修订值。
- 不在第一版实现联网同步协议，但所有导入和本地修改都维护这些字段。

## 6. 关键业务模块

### 6.1 排序引擎

- 以纯 Dart comparator/排序键实现，覆盖全部规则单元测试。
- 完成状态始终为第一分区条件。
- 自动排序与手动排序明确分离；只有手动模式写入 `manualOrder`。
- 排序结果使用稳定兜底键（创建时间、UUID），避免界面跳动。

### 6.2 重复任务引擎

- 规则与实例例外分离，避免无限预生成全部任务。
- 查询某个日期范围时展开规则；用户实际修改或完成某次后写入例外记录。
- “本次及之后”通过截断旧规则并创建新规则版本实现。
- 工作日判断依赖 `WorkdayCalendar` 接口；缺少年度节假日数据时回退周一至周五并返回提示状态。

### 6.3 自适应日历布局

- 输入：日历区域有效逻辑宽高、窗口缩放、用户预览上限、用户可见周数与行高设计令牌。
- 输出：固定 7 列、5～10 行、日期格精确高度、实际可展示任务条数与连续周流锚点。
- Flutter 页面使用 `Column + Expanded + LayoutBuilder` 获取日期网格真实约束；工具栏、状态栏和星期标题位于 `Expanded` 之外，禁止按 720p/2K/4K 写死网格高度。
- `LayoutBuilder.constraints.maxHeight` 表示当前窗口剩余内容高度：最大化时自然覆盖可用屏幕，窗口化时随窗口实时变化。
- `dayCellHeight = calendarViewportHeight / visibleWeekCount`，不根据月份周数改变行数。
- 首次使用 `visibleWeekCount = 5`；用户通过 Ctrl+滚轮以整数步长调整并持久化，范围严格限制为 5～10。
- 普通滚轮修改周流起点；Ctrl+滚轮修改可见周数，并以当前中心周为缩放锚点。
- 窗口尺寸或系统缩放变化时保持可见周数不变，只重新计算日期格高度与物理预览上限。
- 日期选择状态独立于滚动控制器；重算布局后重新确保选中日期可见。
- 月首格在内容层下方用内置霞鹜文楷 Medium 绘制自适应字号的月份数字水印，仅显示中文月份数字；浅色/深色主题分别使用约 9%/7% 不透明度。

### 6.4 可调宽双栏

- 用工作区 `LayoutBuilder` 获取实时宽度，按 `sidebarRatio` 计算日历、8px 分隔线与 TODO 栏宽度；比例基于扣除分隔线后的可用宽度。
- `sidebarRatio` 默认 0.125，严格限制在 0.125～0.5；窗口尺寸变化只重新计算像素宽度，不改变比例。
- 分隔线用 `MouseRegion` 提供左右调整光标，用指针拖动实时更新比例；同时支持方向键、Home、End 和双击恢复默认。
- 拖动结束后通过设置 Repository 持久化，避免每个指针移动事件写数据库。
- 单栏断点下不渲染分隔线和 TODO 栏，但保留内存与持久化中的比例，恢复双栏后继续使用。
- 使用连续周索引与按周虚拟化/惰性构建，不建立固定月份页面。
- 单击只更新选中日期；双击通过路由进入全屏 `DayTodoPage`，退出后恢复周流锚点、可见周数和选中日期。

### 6.4 节假日数据

```text
HolidayRepository
├─ BundledHolidaySource
├─ CachedHolidaySource
└─ RemoteHolidaySource（首版可为未配置实现）
```

- 内置 JSON 必须标注年份、来源 URL、发布日期、数据版本和校验值。
- 远端更新只接受通过 schema 校验的完整年度文件，采用临时文件验证后原子替换缓存。
- 不在客户端解析政府网页；未来由受控数据源将官方通知整理为结构化 JSON。
- 二十四节气由独立的纯 Dart 服务计算并测试边界年份。

### 6.5 备份

- 备份根对象包含 `formatVersion`、`exportedAt`、`appVersion`、数据区和设置区。
- 导入分为 inspect、validate、transaction 三阶段。
- 合并和覆盖均在数据库事务内执行。
- 覆盖前自动导出安全备份；失败回滚事务并保留原数据库。
- 后续格式升级使用显式 migrator，不在 UI 层兼容旧字段。

## 7. UI 工程原则

- 建立颜色、间距、圆角、阴影、字体和动画时长等 design tokens。
- 桌面端优先支持鼠标悬停、右键菜单、键盘焦点与快捷操作。
- 当日详情页本身采用单栏响应式结构，便于 Android 复用。
- 侧边栏和编辑抽屉使用不同层级：固定侧边栏展示列表，编辑抽屉覆盖或替换侧边栏内容。
- 任务状态必须同时使用图标/文字/删除线表达，不仅依赖颜色。

## 8. 测试策略

### 8.1 单元测试

- 综合排序及每种独立排序。
- 逾期边界、时区转换和日期跨越。
- 重复规则展开、例外与“本次及之后”。
- 工作日回退规则与节气计算。
- 5～10 周缩放、日期格均分高度和任务预览条数计算。
- 最大化、还原及连续改变窗口高度时的布局约束测试。
- TODO 栏 12.5%/50% 边界、拖拽、键盘调整、窗口缩放保持比例与单栏往返恢复测试。
- 备份 schema 验证与版本迁移。

### 8.2 数据集成测试

- Drift CRUD、软删除、标签关系和数据库迁移。
- 导出 → 清空 → 导入的往返一致性。
- 合并导入去重和覆盖导入失败回滚。
- 节假日缓存更新失败后的本地回退。

### 8.3 UI 测试

- 主月历、右侧栏、当日详情、搜索与设置的 widget 测试。
- 日期单击、双击、快速新增、完成、恢复和撤销删除。
- 浅色/深色关键页面 golden test。
- 至少覆盖 1280×720、1920×1080 和窄窗口布局。
- 覆盖 2560×1440、3840×2160，以及 100%～200% Windows 显示缩放的代表组合。

## 9. 开发阶段

### M0：环境与工程骨架

状态：已完成。Flutter 3.47.2、Dart 3.13.2、Windows/Android 工程、应用骨架和质量检查已完成；Windows Debug 构建与启动集成测试通过。

- 检查 Flutter、Visual Studio Windows 工具链与 Android 预留平台。
- 创建 Flutter 工程、静态分析、测试和目录结构。
- 接入主题、Riverpod、路由与错误处理骨架。

完成标志：Windows 空壳应用可运行，测试和静态分析通过。

### M1：领域模型与本地数据

状态：已完成。领域实体与 Repository 契约、Drift schema v1、本地任务/分类/标签/设置实现及 26 项自动化测试已经通过；完成记录见 `docs/M1_DATA_REPORT.md`。

- 实现任务、分类、标签、排序值对象与仓库接口。
- 建立 Drift schema、迁移和本地仓库。
- 完成 CRUD、软删除与响应式按日查询测试。

完成标志：无需 UI 即可通过测试完成核心数据生命周期。

### M2：月历工作台

状态：已于 2026-09-04 通过体验验收并关闭。固定 7 列连续周流、5～10 周缩放、实时高度均分、日期操作、快速新增、双栏调宽与设置持久化已经接入；完成记录见 `docs/M2_CALENDAR_REPORT.md`。

- 顶部工具栏、月切换、今天按钮和日期选择。
- 固定 7 列连续周流、默认 5 周、Ctrl+滚轮 5～10 周缩放、普通滚轮按周浏览和日期格任务摘要。
- 宽窗口可调宽右侧栏、12.5%～50% 限制、比例持久化与窄窗口降级。
- 单击日期更新侧边栏；双击或侧边栏展开按钮进入全屏当日 TODO，并支持返回状态恢复。

完成标志：默认 5 周精确铺满高度，2K/4K 保持 7 列并正确放大日期格，Ctrl+滚轮可在 5～10 周间稳定缩放，改变窗口、系统缩放和预览条数时行为符合 PRD。

### M3：任务交互与当日详情

状态：已通过体验验收并关闭。侧边栏与当日页已支持完整普通任务生命周期、编辑抽屉、分类标签、筛选、排序和拖拽。

- 快速新增、完整编辑抽屉、完成/恢复和撤销删除。
- 独立当日详情页、分类、标签、时间和优先级。
- 手动拖拽与全部自动排序模式。

完成标志：月历和当日页均可完成全部普通任务操作。

### M4：重复、搜索与中国日历

状态：已实现并通过自动化验证，等待体验验收。

- 重复规则和实例例外。
- 全局搜索与筛选、结果定位。
- 节假日数据源、缓存、更新接口和节气。

完成标志：重复任务可独立完成，搜索和年度日历信息通过验收。

### M5：设置、备份与视觉完善

- 三种主题模式、预览条数与排序设置。
- JSON 导出、合并导入、覆盖恢复和安全备份。
- 品牌页、空状态、错误状态、键鼠体验和可访问性。

完成标志：离线功能完整，备份往返验证通过，视觉达到发布候选标准。

### M6：Windows 发布候选

- 全量回归、性能和数据库迁移验证。
- Release 构建、安装/卸载和用户数据保留验证。
- 产出版本说明、已知限制和后续 Android 清单。

完成标志：在目标 Windows 10/11 x64 环境完成验收，可供试用。

## 10. 风险与控制

| 风险 | 控制方式 |
| --- | --- |
| 重复任务语义复杂 | 规则/例外分离，先写测试再接 UI |
| 日历高密度导致布局溢出 | 纯计算布局模型、多分辨率测试、物理上限兜底 |
| 节假日无稳定官方结构化 API | 内置数据 + 缓存 + 可替换数据源，不直接抓网页 |
| 备份升级破坏用户数据 | 格式版本、预检、事务与覆盖前安全备份 |
| 未来云同步冲突 | 从首版使用 UUID、更新时间、修订和软删除字段 |
| 桌面交互难以复用到手机 | 领域/用例共用，页面响应式，平台交互封装 |

## 11. 开发启动前的下一项产物

先制作低保真页面原型和视觉 token 草案，验证以下四项后再创建 Flutter 工程：

1. 固定 7 列连续周流与侧边栏在 1280×720、2560×1440、3840×2160 下的空间分配。
2. 默认 6 条任务时完整月份的可读性。
3. 默认 5 周及 Ctrl+滚轮调整到 6～10 周时的日期格高度和视觉反馈。
4. 单击选日与双击全屏 TODO 的模式切换和状态恢复。
5. 快速新增、完整编辑抽屉和搜索结果定位流程。

## 12. 技术参考

- [Flutter 官方桌面支持](https://docs.flutter.dev/platform-integration/desktop)
- [Flutter 官方 Windows 开发说明](https://docs.flutter.dev/platform-integration/windows)
- [Drift 支持平台](https://drift.simonbinder.eu/platforms/)
- [Drift 原生跨平台数据库](https://drift.simonbinder.eu/platforms/vm/)
- [Riverpod 入门文档](https://riverpod.dev/docs/introduction/getting_started)
- [go_router 包说明](https://pub.dev/packages/go_router)
