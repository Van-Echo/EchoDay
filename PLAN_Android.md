# 丸成 / EchoDay — Android 开发计划

> 状态：待确认并执行  
> 制定日期：2026-09-05  
> 现有基线：Windows v0.1.0，Flutter 3.47.2 / Dart 3.13.2

## 1. 开发原则

Android 版继续使用现有 Flutter 工程，不重写核心业务逻辑。

以下能力直接复用：

- TODO、分类、标签、优先级和备注领域模型。
- 计划执行时间、计划 DDL、逾期判断和任务顺延。
- 排序、筛选、全局搜索和跨日期移动用例。
- 重复任务、实例例外和工作日计算。
- Drift schema、Repository 接口、UUID、UTC 时间和软删除策略。
- 中国法定节假日、调休和二十四节气。
- Riverpod 状态管理、路由、本地化和主题系统。
- 版本化 JSON 备份格式。

Android 开发重点是移动端布局、触控交互、平台能力隔离、文件访问和发布工程。

## 2. Android 首版范围

### 2.1 纳入首版

- 连续周日历和日期选择。
- TODO 新增、编辑、删除、完成和恢复。
- 分类、标签、优先级、备注、计划执行时间和计划 DDL。
- 重复规则、排序、筛选和全局搜索。
- 未完成任务顺延和任务跨日期移动。
- 中国法定节假日、调休和节气。
- 浅色、深色、跟随系统、主色和现有视觉设置。
- 与 Windows 完全兼容的 JSON 备份与恢复。
- 手机、平板、折叠屏、横屏和分屏适配。
- 签名 APK 和 Android App Bundle（AAB）。

### 2.2 暂不纳入首版

- 云同步和账号系统。
- 系统通知、闹钟和 DDL 提醒。
- Android 桌面小组件。
- 系统日历同步。
- Android 桌面快捷操作和快捷新增入口。
- 后台自动更新节假日。

以上能力进入 Android v1.1 或后续版本，不阻断首个 Android 正式版。

## 3. 设备与发布基线

- 最低版本：Android 7.0 / API 24。
- 目标版本：Android 16 / API 36。
- 主要真机架构：ARM64。
- 包名：`com.vanecho.echoday`。
- GitHub：提供正式签名 APK。
- Google Play：提供正式签名 AAB。
- Android 与 Windows 共用备份格式，不建立 Android 专属数据格式。

Flutter 3.47.2 支持 Android API 24～37，并持续测试 API 24～36。自 2026 年 8 月 31 日起，Google Play 新应用和更新需要面向 API 36，因此 Android 首版直接以 API 36 为目标。

参考：

- [Flutter 支持平台](https://docs.flutter.dev/reference/supported-platforms)
- [Google Play Target API 要求](https://developer.android.com/google/play/requirements/target-sdk)
- [Flutter Android 发布指南](https://docs.flutter.dev/deployment/android)

## 4. 自适应布局方案

布局只根据应用当前获得的逻辑宽高切换，不根据设备名称判断手机或平板，以兼容横屏、分屏、折叠屏和 ChromeOS 窗口。

| 可用宽度 | 导航 | 日历与 TODO 布局 |
| --- | --- | --- |
| `<600dp` | 底部导航栏 | 单栏日历；选中日期后通过底部摘要条进入当日 TODO |
| `600～839dp` | NavigationRail | 单栏内容，日历与当日 TODO 独立切换 |
| `≥840dp` | NavigationRail | 日历与右侧 TODO 双栏 |
| `≥960dp` | 展开 NavigationRail | 完整桌面/大平板工作台 |

参考：

- [Flutter 自适应与响应式设计](https://docs.flutter.dev/ui/adaptive-responsive)
- [Android 不同显示尺寸适配](https://developer.android.com/develop/adaptive-apps/guides/support-different-display-sizes)

## 5. 手机端日历交互

- 保持星期一开始、固定 7 列和默认 5 周。
- 日期格根据扣除系统安全区、应用栏、星期栏和底部导航后的剩余高度均分。
- 手机日期格最多显示 1～2 条任务摘要；平板根据实际空间恢复用户配置的预览条数。
- 垂直滑动按周浏览连续日历。
- “今天”和当前选中日期按钮继续保留。
- 单击日期选中；再次点击已选日期或点击底部任务摘要条进入当日 TODO 页面。
- 长按日期格空白区域快速新增任务。
- 日历格中的任务使用长按拖动，放到其他日期格后修改所属日期。
- 拖动任务时同步迁移计划执行日期和计划 DDL 日期，并保留原时分。
- 当日 TODO 列表提供明确的“移动到日期”菜单，解决手机无法跨页面拖动的问题。
- 拖动开始、进入目标格和完成放置时提供适量触觉反馈。
- 不锁定屏幕方向，旋转或窗口尺寸变化时保留选中日期、滚动锚点和编辑状态。

## 6. 平台能力隔离

新增统一的平台能力描述，避免页面直接判断操作系统：

```text
PlatformCapabilities
├─ supportsGlobalHotkeys
├─ supportsWindowManagement
├─ supportsFileSaveDialog
├─ supportsSystemShare
├─ supportsTouchDrag
└─ supportsPointerContextMenu
```

### 6.1 Windows 专属功能

- `window_manager` 仅在 Windows 初始化和调用。
- `hotkey_manager` 仅在支持的平台注册。
- Android 设置页不显示“全局呼出「丸成」”和“回到「今天」”热键配置。
- Windows 现有窗口大小、最大化恢复和全局呼出行为保持不变。

### 6.2 Android 替代交互

- 鼠标右键菜单改为长按菜单或底部操作面板。
- 鼠标悬停提示改为清晰的可点击图标和语义标签。
- 双击日期改为“再次点击已选日期”或点击任务摘要条。
- 分隔线拖动仅保留在大平板双栏布局中。
- Android 系统返回手势遵循路由栈，不在根页面强制拦截。

## 7. 备份与文件访问设计

现有 Windows 设置页直接使用路径式文件选择器。Android 应把 JSON 序列化与文件交互拆开：

```text
BackupSerializer
    生成/读取 JSON 字节
        ↓
BackupFileGateway
├─ WindowsPathBackupGateway
└─ AndroidDocumentBackupGateway
```

Android 采用 Storage Access Framework：

- 导出使用系统“创建文档”流程，让用户选择目标位置。
- 导入使用系统“打开文档”流程，只允许选择 JSON。
- 不申请笼统的外部存储读写权限。
- 对内容 URI、临时文件、取消选择和文件提供者异常进行显式处理。
- 安全备份保存在应用支持目录；需要长期保留时允许用户再次导出。
- 导入仍执行预检、格式版本检查、引用完整性检查和事务恢复。
- Windows 导出的 JSON 必须能在 Android 恢复，Android 导出的 JSON 也必须能在 Windows 恢复。

参考：

- [Android Storage Access Framework](https://developer.android.com/training/data-storage/shared/documents-files)
- [Flutter file_selector](https://pub.dev/packages/file_selector)

## 8. Android 开发阶段

### A0：环境与构建基线

工作内容：

- 安装 Android Studio、Android SDK 36、Platform Tools 和模拟器。
- 准备 API 24 与 API 36 模拟设备。
- 执行 `flutter doctor -v` 和 `flutter devices`。
- 构建并安装现有 Debug APK。
- 记录当前 Android 编译错误、插件兼容问题和页面截图。
- 最终确认包名、最低 API、目标 API 和首发渠道。

完成标志：

- 当前工程能在 API 24 与 API 36 启动。
- Drift 数据库可以创建并重新打开。
- 当前 Android 差异形成明确的问题清单。

### A1：平台能力隔离

工作内容：

- 建立 `PlatformCapabilities` 或等价平台服务。
- 隔离 Windows 窗口管理和全局热键。
- Android 隐藏无意义的热键设置。
- 建立 `BackupFileGateway` 接口。
- 增加应用生命周期监听，为恢复前台后的日期和逾期状态刷新做准备。

完成标志：

- Android 不加载或调用 Windows 专属能力。
- Windows 全部现有测试继续通过。
- Android Debug 构建与启动稳定。

### A2：移动端应用壳

工作内容：

- 实现 Compact、Medium、Expanded 三档布局。
- Compact 使用底部导航栏。
- Medium 使用收起的 NavigationRail。
- Expanded 使用 NavigationRail 与双栏工作台。
- 适配 SafeArea、系统状态栏、导航栏、软键盘和 edge-to-edge。
- 校验 Android 返回键与返回手势。
- 保留页面路由、选中日期和筛选状态。

完成标志：

- 日历、当日 TODO、搜索、设置和关于五个页面均可正常导航。
- 横竖屏、分屏和尺寸变化时没有布局溢出或状态丢失。

### A3：移动端日历

工作内容：

- 重做紧凑型手机日历工具栏。
- 保持 7 列连续周流与日期格高度均分。
- 根据宽度和高度计算任务摘要容量。
- 实现触控按周浏览、日期选择和快速回到今天。
- 实现手机底部任务摘要条。
- 实现长按快速新增和长按拖动任务。
- 平板继续支持日历与右侧 TODO 双栏拖动。
- 处理节假日、节气、月份水印和碎碎念在窄屏的显示。

完成标志：

- 360dp 宽度下无溢出。
- 可完成选日、新增、进入当日页和移动任务。
- 旋转和分屏后日期格重新铺满有效区域。

### A4：TODO、搜索与设置

工作内容：

- 将完整编辑器适配为全屏页面或移动端底部面板。
- 使用长按菜单替代右键菜单。
- 增加“移动到日期”操作。
- 保持完成、恢复、删除、撤销、顺延和重复任务操作。
- 优化日期、时间、颜色、分类和标签选择器的触控尺寸。
- 调整搜索筛选栏在窄屏上的纵向布局。
- 调整设置页展开栏目、滑块和颜色面板。
- 隐藏 Android 不支持的热键设置。
- 保持“已完成”默认展开。

完成标志：

- Windows 版现有核心业务流程均能在手机上完成。
- 软键盘不会遮挡编辑字段和保存按钮。
- 200% 字体缩放仍可操作。

### A5：数据、节假日与备份

工作内容：

- 验证 Drift 数据库路径、升级和卸载语义。
- 实现 Android 文档导入与导出适配器。
- 完成 Windows ↔ Android JSON 往返测试。
- 把 `INTERNET` 权限加入 Android 主 Manifest，确保 Release 可更新节假日。
- 验证联网失败、本地缓存和内置数据回退。
- 验证清空数据和安全备份行为。

完成标志：

- 应用重启后数据完整。
- JSON 跨端导入导出一致。
- Release 构建可以更新法定节假日。
- 应用不要求不必要的存储权限。

### A6：质量与真机验证

工作内容：

- 扩展共享单元测试和 Widget 测试。
- 增加 Android 真机/模拟器集成测试。
- 验证中文输入法、软键盘、返回手势和触觉反馈。
- 验证浅色、深色、系统主题和字体缩放。
- 验证北京时区与一个有夏令时的时区。
- 验证后台恢复、强制终止、重启、旋转、分屏和折叠状态变化。
- 使用 10,000 条任务测试搜索、日历滚动和数据库响应。
- 验证 Windows 版本没有功能回归。

完成标志：

- 自动化测试全部通过。
- API 24、29、34、36 测试矩阵通过。
- 至少一台 ARM64 真机完成完整业务验收。

### A7：Android 发布候选

工作内容：

- 生成独立上传密钥和正式签名配置。
- 密钥与密码只通过本地安全文件或 CI Secret 注入，不提交 Git。
- 移除 Release 使用 Debug 签名的配置。
- 构建正式 AAB 和分架构 APK。
- 使用 Play App Signing 和内部测试轨道验证 AAB。
- 准备应用名称、图标、截图、简介、隐私政策、Data Safety 和 AGPLv3 说明。
- 完成 Android 开发者身份验证与包名登记。
- 生成 SHA-256 校验文件、版本说明和已知限制。
- 确认发布产物不包含测试数据库、备份或签名秘密。
- 验证旧版本覆盖安装后数据库仍可升级和保留。

完成标志：

- 正式签名 APK 可安装、覆盖升级和启动。
- AAB 通过 Google Play 内部测试。
- GitHub Release 可供用户直接下载 APK。
- 发布包不包含用户数据和秘密信息。

参考：

- [Android 应用签名](https://developer.android.com/studio/publish/app-signing)
- [Android 应用发布](https://developer.android.com/studio/publish)

## 9. 测试矩阵

### 9.1 视口尺寸

- 360×640：小屏手机。
- 412×915：常见现代手机。
- 600×960：小平板或展开前后的折叠屏。
- 800×1280：平板竖屏。
- 1280×800：平板横屏或 ChromeOS。

### 9.2 Android 版本

- API 24：最低支持版本。
- API 29：旧版存储行为代表。
- API 34：常见存量系统。
- API 36：目标和发布系统。

### 9.3 必测状态

- 中文和英文。
- 浅色、深色、跟随系统。
- 字体缩放 100%、150%、200%。
- 竖屏、横屏、分屏和窗口尺寸变化。
- 北京时区与带夏令时的时区。
- 后台恢复、进程重建和强制结束后重启。
- Windows ↔ Android JSON 往返恢复。
- 10,000 条本地任务。
- 无网络、超时、政府网页结构变化和缓存回退。

Flutter 集成测试应在 Android 模拟器、至少一台真实 ARM64 设备运行；条件允许时增加 Firebase Test Lab。

参考：[Flutter 集成测试](https://docs.flutter.dev/testing/integration-tests)

## 10. 主要风险与控制

| 风险 | 控制方式 |
| --- | --- |
| 桌面日历在窄屏过密 | 单独设计 Compact 日期格，动态限制任务摘要数量 |
| 鼠标交互无法直接迁移 | 右键改长按，拖拽改长按拖动，双击改再次点击或显式入口 |
| Android 文件系统没有普通桌面路径语义 | 通过 `BackupFileGateway` 使用 SAF 和内容 URI |
| Android Release 无法更新节假日 | 把 `INTERNET` 权限加入主 Manifest，并用 Release 真机测试 |
| Windows 插件影响 Android | 平台能力隔离、条件渲染和双平台 CI |
| 横屏、折叠或分屏导致状态丢失 | 按当前窗口尺寸布局，状态保存在 Riverpod 控制器和数据库中 |
| API 36 edge-to-edge 遮挡控件 | 使用 SafeArea、系统 Insets 和多设备截图测试 |
| 签名文件泄露或丢失 | 密钥离线备份，密码使用 Secret，仓库仅保留模板 |
| Android 改动破坏 Windows | 每个阶段同时执行 Windows 单元、Widget 和构建回归 |

## 11. 建议的执行顺序

```text
A0 工具链与首次启动
  ↓
A1 平台能力隔离
  ↓
A2 移动端应用壳
  ↓
A3 移动日历
  ↓
A4 TODO / 搜索 / 设置
  ↓
A5 数据与备份
  ↓
A6 全量质量验证
  ↓
A7 签名与发布候选
```

每个阶段必须达到自己的完成标志后再进入下一阶段。A1～A5 的每次合并都必须同时通过 Windows 回归，避免在 Android 适配完成后集中修复桌面端。

## 12. 开工前默认决策

若无额外修改，开发按以下决定启动：

1. 最低 Android 版本为 API 24，目标 API 36。
2. 保留包名 `com.vanecho.echoday`。
3. 手机采用“日历单栏 + 当日 TODO 独立页面”。
4. 平板采用日历与右侧 TODO 双栏。
5. GitHub 发布签名 APK，同时准备 Google Play AAB。
6. 通知提醒、桌面小组件和云同步放到 Android v1.1。
7. 下一步从 A0 开始，先完成工具链检查、首次 Debug APK 构建和现有页面手机截图审计。
