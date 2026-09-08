# 丸成 / EchoDay — Android 开发计划

> 状态：A7 正式候选已完成本机、模拟器与 ARM64 真机验收；待 GitHub Release 上传
> 制定日期：2026-09-05
> 最近核验：2026-09-08
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
- 中文 / English 界面语言切换，设置随 JSON 备份同步。
- 与 Windows 完全兼容的 JSON 备份与恢复。
- 手机、平板、折叠屏、横屏和分屏适配。
- 正式签名 APK；选择 Google Play 作为发布渠道时同时提供 Android App Bundle（AAB）。

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
- GitHub、其他应用商店和直接分发：提供正式签名 APK，作为首要发布产物。
- Google Play：可选发布渠道；采用时提供正式签名 AAB。
- 运行时不依赖 Google Play、Google Play Services、GMS 或 Firebase。
- Android 与 Windows 共用备份格式，不建立 Android 专属数据格式。

Flutter 3.47.2 支持 Android API 24～37，并持续测试 API 24～36。自 2026 年 8 月 31 日起，Google Play 新应用和更新需要面向 API 36，因此 Android 首版直接以 API 36 为目标。

参考：

- [Flutter 支持平台](https://docs.flutter.dev/reference/supported-platforms)
- [Google Play Target API 要求](https://developer.android.com/google/play/requirements/target-sdk)
- [Flutter Android 发布指南](https://docs.flutter.dev/deployment/android)

### 3.1 已验证的本机工具链

- 操作系统：Windows 11 25H2 x64。
- Flutter 3.47.2，Dart 3.13.2。
- Android SDK Platforms：API 35、API 36、API 37。
- Android Build Tools 36.0.0，Platform Tools 和 Emulator 37.1.11。
- Gradle 9.3.1，Android Gradle Plugin 9.1.0，Kotlin 2.4.0。
- Android Studio 内置 OpenJDK 25.0.2；项目 Java/Kotlin 字节码目标为 Java 17。
- NDK 28.2.13676358；本项目构建使用 CMake 3.22.1。
- 已建立 Pixel 9 / API 36 / x86_64 / Google APIs 模拟设备。
- 已成功生成 Debug APK：`build/app/outputs/flutter-apk/app-debug.apk`。

项目位于 E 盘，而 Pub Cache 位于 C 盘。Kotlin 增量缓存无法可靠处理该跨盘路径，因此 `android/gradle.properties` 必须保留 `kotlin.incremental=false`。该设置只影响构建速度，不影响应用功能或运行性能。

当前新版 Android CLI 已不再要求 `flutter doctor --android-licenses` 的旧式交互。`flutter doctor` 仍可能显示许可证状态未知，但实际构建已确认 Android Platform 35 和 CMake 3.22.1 的许可证均已接受。后续以 SDK 组件能否安装及 APK 能否成功构建为准。

包名不等同于公司名；当前 `com.vanecho.echoday` 可以继续作为技术标识，但必须在生成正式签名密钥、注册包名或公开发布前完成最终确认。发布后不再随意更改。

## 4. 自适应布局方案

布局只根据应用当前获得的逻辑宽高切换，不根据设备名称判断手机或平板，以兼容横屏、分屏、折叠屏和 ChromeOS 窗口。

| 可用宽度 | 导航 | 日历与 TODO 布局 |
| --- | --- | --- |
| `<600dp` | 底部导航栏 | 上方 2 周连续日历；下方当日 TODO，占用约 3/5 工作区高度 |
| `600～839dp` | NavigationRail | 单栏内容，日历与当日 TODO 独立切换 |
| `≥840dp` | NavigationRail | 日历与右侧 TODO 双栏 |
| `≥960dp` | 展开 NavigationRail | 完整桌面/大平板工作台 |

参考：

- [Flutter 自适应与响应式设计](https://docs.flutter.dev/ui/adaptive-responsive)
- [Android 不同显示尺寸适配](https://developer.android.com/develop/adaptive-apps/guides/support-different-display-sizes)

## 5. 手机端日历交互

- 保持星期一开始和固定 7 列；Android 手机日历页默认显示 2 周，Windows 保持默认 5 周。
- Android 手机日历与下方当日 TODO 按 2:3 分配工作区高度，日期格在日历区域内均分。
- 手机日期格根据实际高度显示任务摘要；平板根据实际空间恢复用户配置的预览条数。
- Android 不显示碎碎念及其设置入口；Windows 继续保留该功能。
- 垂直滑动按周浏览连续日历。
- “今天”和当前选中日期按钮继续保留。
- 单击日期选中，并立即刷新下方当日 TODO；全屏按钮进入完整当日 TODO 页面。
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

已完成：

- [x] 安装 Android Studio、Android SDK 36、Platform Tools、Build Tools、NDK、CMake 和模拟器。
- [x] 执行 `flutter doctor -v`、检查代理和 SDK 目录。
- [x] 配置 Pixel 9 / API 36 / x86_64 / Google APIs 模拟设备。
- [x] 验证 APK 的 `minSdk 24`、`compileSdk 36`、`targetSdk 36` 和三种 ABI。
- [x] 完成首次 Debug APK 构建。
- [x] 处理 Windows 跨盘 Kotlin 增量缓存错误。
- [x] 确认新版 Android CLI 的许可证提示不阻断构建。

A0 收尾：

- [x] 在 API 36 Google APIs 与 API 36 AOSP 模拟器安装并启动现有 Debug APK。
- [x] 建立并运行 API 24 AOSP 模拟设备。
- [x] 在不带 Google APIs/Play 的 AOSP 环境验证无 GMS 运行。
- [x] 验证 Drift 数据库创建、初始化写入、完整性检查、进程关闭和重新打开。
- [x] 记录现有页面在手机视口下的截图、编译问题和插件差异清单。
- [x] 开发阶段继续使用 `com.vanecho.echoday`；首发以签名 APK 直接分发，Google Play 为可选渠道。正式发布前再做最终包名复核。

详细结果见 [`ANDROID_A0_AUDIT.md`](../ANDROID_A0_AUDIT.md)。

完成标志：

- 当前工程能在 API 24、API 36 和无 GMS 环境启动。
- Drift 数据库可以创建并重新打开。
- 当前 Android 差异形成明确的问题清单。

### A1：平台能力隔离

工作内容：

- [x] 建立 `PlatformCapabilities` 平台能力服务。
- [x] 通过 `DesktopRuntime` 隔离 Windows 窗口管理和全局热键调用。
- [x] Android 不订阅热键偏好，并隐藏无意义的热键设置。
- [x] 建立 `BackupFileGateway` 接口，将文件选择从设置页面解耦。
- [x] 增加应用生命周期监听，恢复前台时立即刷新日期和逾期时钟。

完成标志：

- [x] Android 原生插件表不注册 Windows 插件，Dart 层不调用 Windows 专属运行时。
- [x] Windows 全部现有测试和 Debug 构建通过。
- [x] Android Debug 构建、API 36 AOSP 安装、启动及后台恢复稳定。

A1 验证结果：`flutter analyze` 无问题；102 项测试通过、1 项按既有条件跳过；Windows 与 Android Debug 构建成功。Android 无 GMS 模拟器未出现 `MissingPluginException`、Flutter 致命错误或 SQLite 异常。

### A2：移动端应用壳

工作内容：

- [x] 实现 Compact、Medium、Expanded 三档布局。
- [x] Compact 使用底部导航栏。
- [x] Medium 使用收起的 NavigationRail。
- [x] Expanded 使用 NavigationRail 与双栏工作台。
- [x] 适配 SafeArea、系统状态栏、导航栏、软键盘和 edge-to-edge。
- [x] 校验 Android 返回键与返回手势。
- [x] 保留页面路由、选中日期和筛选状态。

完成标志：

- [x] 日历、当日 TODO、搜索、设置和关于五个页面均可正常导航。
- [x] 横竖屏、分屏和尺寸变化时没有布局溢出或状态丢失。

A2 验证结果：`flutter analyze` 无问题；109 项测试通过、1 项按既有条件跳过；Windows 与 Android Debug 构建成功。API 36 模拟器原生横竖屏旋转、Android 返回键、软键盘避让及 AOSP/无 GMS 运行均通过，未发现 Flutter 布局溢出、`MissingPluginException` 或 SQLite 异常。

### A3：移动端日历

工作内容：

- [x] 重做紧凑型手机日历工具栏。
- [x] 保持 7 列连续周流与日期格高度均分。
- [x] 根据宽度和高度计算任务摘要容量。
- [x] 实现触控按周浏览、日期选择和快速回到今天。
- [x] 实现手机上方 2 周日历与下方 3/5 高度的当日 TODO 面板。
- [x] 实现长按快速新增和长按拖动任务。
- [x] 平板继续支持日历与右侧 TODO 双栏拖动。
- [x] 处理节假日、节气和月份水印在窄屏的显示；Android 不显示碎碎念。

完成标志：

- [x] 360dp 宽度下无溢出。
- [x] 可完成选日、新增、进入当日页和移动任务。
- [x] 旋转和分屏后日期格重新铺满有效区域。

A3 验证结果：`flutter analyze` 无问题；112 项测试通过、1 项按既有条件跳过；Windows 与 Android Debug 构建成功。API 36 AOSP/无 GMS 模拟器验证了手机竖屏两周布局、触控按周浏览、长按快速新增、任务长按跨日期拖动及横屏双栏重排，未发现 Flutter 布局溢出、`MissingPluginException`、SQLite 异常或运行崩溃。

### A4：TODO、搜索与设置

工作内容：

- [x] 将完整编辑器适配为全屏页面或移动端底部面板。
- [x] 使用长按菜单替代右键菜单。
- [x] 增加“移动到日期”操作。
- [x] 保持完成、恢复、删除、撤销、顺延和重复任务操作。
- [x] 优化日期、时间、颜色、分类和标签选择器的触控尺寸。
- [x] 调整搜索筛选栏在窄屏上的纵向布局。
- [x] 调整设置页展开栏目、滑块和颜色面板。
- [x] 提供中文 / English 语言设置并持久化；英文日期使用星期与月份缩写。
- [x] 隐藏 Android 不支持的热键设置。
- [x] 保持“已完成”默认展开。

完成标志：

- [x] Windows 版现有核心业务流程均能在手机上完成。
- [x] 软键盘不会遮挡编辑字段和保存按钮。
- [x] 200% 字体缩放仍可操作。

A4 验证结果：`flutter analyze` 无问题；116 项测试通过、1 项按既有条件跳过；Windows 与 Android Debug 构建成功。自动化覆盖 Android 长按任务操作、移动到指定日期并同步迁移计划时间与 DDL、360dp 全屏编辑器、300dp 软键盘避让，以及搜索和设置在 200% 字体下的触控布局。API 36 AOSP 模拟器实际确认了竖屏全屏编辑器；后续模拟器系统进程出现 `System UI isn't responding` 并自行退出，应用日志中未发现 Flutter 崩溃或布局溢出。

### A5：数据、节假日与备份

工作内容：

- [x] 验证 Drift 数据库路径、升级和卸载语义。
- [x] 实现 Android 文档导入与导出适配器。
- [x] 完成 Windows ↔ Android JSON 往返测试。
- [x] 把 `INTERNET` 权限加入 Android 主 Manifest，确保 Release 可更新节假日。
- [x] 验证联网失败、本地缓存和内置数据回退。
- [x] 验证清空数据和安全备份行为。

完成标志：

- [x] 应用重启后数据完整。
- [x] JSON 跨端导入导出一致。
- [x] Release 构建可以更新法定节假日。
- [x] 应用不要求不必要的存储权限。

A5 验证结果：`flutter analyze` 无问题；122 项测试通过、1 项按既有条件跳过，另行启用的 gov.cn 实时测试通过；Android Release APK 与 Windows Debug 构建成功。API 36 AOSP/无 GMS 模拟器完成了 Release 覆盖安装、强制停止后重启、系统文档导出、系统文档导入与备份预检；合并 Manifest 仅包含联网权限和 Android 自动生成的应用内动态接收器权限，不包含外部存储权限。详细结果见 [`ANDROID_A5_AUDIT.md`](../ANDROID_A5_AUDIT.md)。

### A6：质量与真机验证

工作内容：

- [x] 扩展共享单元测试和 Widget 测试。
- [x] 增加 Android 模拟器集成测试，并在 ARM64 真机执行核心集成验收。
- [x] 验证中文文本输入、软键盘、返回路由、真实中文输入法和物理触觉。
- [x] 验证浅色、深色、系统主题和 100%～200% 字体缩放。
- [x] 验证北京时区与纽约夏令时时区。
- [x] 验证后台恢复、强制终止、重启、旋转及 Compact/Medium/Expanded 尺寸变化；非折叠真机完成横竖屏复核。
- [x] 在 AOSP/无 GMS 模拟器验证离线启动、核心业务和节假日网络更新。
- [x] 使用 10,000 条任务测试搜索、连续日期读取和数据库响应。
- [x] 验证 Windows 版本没有功能回归。

完成标志：

- [x] 自动化测试全部通过。
- [x] API 24、29、34、36 测试矩阵通过。
- [x] 至少一个 AOSP/无 GMS 环境通过核心业务验收。
- [x] 至少一台 ARM64 真机完成完整业务验收。

A6 本机验证结果：`flutter analyze` 无问题；123 项共享自动化测试通过、1 项需要显式联网开关的 gov.cn 实时测试按设计跳过；API 24、29、34、36 AOSP 核心流程集成测试均通过，API 36 另通过系统深色模式、200% 字号、北京/纽约时区、10,000 条任务性能及 gov.cn 真机网络栈测试。10,000 条任务在 API 36 模拟器上的结果为写入 378 ms、唯一搜索 442 ms、连续 70 天读取 404 ms。普通 Release 在飞行模式下完成 Compact/Medium/Expanded 代表尺寸切换、横竖屏、返回、后台恢复和强停重启，数据库文件重启后仍存在，日志未发现 Flutter 致命错误、`MissingPluginException` 或 SQLite 异常。Windows Debug 与 Android Release 构建成功。详细结果见 [`ANDROID_A6_AUDIT.md`](../ANDROID_A6_AUDIT.md)。

A6 真机验证结果：小米 15 Pro（Android 15 / API 35、ARM64、系统字号 125%）完成中文输入法、物理触觉、SAF 备份恢复、节假日联网、时区、10,000 条任务性能、Release 生命周期及横竖屏验收。真机 10,000 条任务结果为写入 283 ms、唯一搜索 275 ms、连续 70 天读取 172 ms。新增的安卓沉浸式全屏、日历标题栏移除、其他页面标题保留和横屏挖孔区域延伸均已通过截图与进程检查。A6 已关闭，可以进入 A7。

### A7：Android 发布候选

工作内容：

- [x] 生成独立上传密钥和正式签名配置。
- [x] 密钥与密码只通过本地安全文件或 CI Secret 注入，不提交 Git。
- [x] 移除 Release 使用 Debug 签名的配置；缺少正式签名时 Release 构建直接失败。
- [x] 构建正式通用 APK、ARM64 APK 和 AAB。
- [ ] 若选择 Google Play 渠道，使用 Play App Signing 和内部测试轨道验证 AAB。
- [x] 准备应用名称、图标、简介、隐私政策、Data Safety 和 AGPLv3 说明；商店截图待最终上架时选取。
- [ ] 根据最终分发渠道完成 Android 开发者身份验证、包名和签名证书登记，为 2027 年全球验证要求预留时间。
- [x] 生成 SHA-256 校验文件、版本说明和已知限制。
- [x] 确认发布产物不包含测试数据库、备份或签名秘密。
- [x] 经用户明确授权放弃测试数据后，完成从早期 Debug 签名测试包到正式签名包的一次性卸载—安装迁移。
- [ ] 使用同一正式签名的两个 version code 验证后续覆盖升级时数据库保留。

完成标志：

- [x] 正式签名 APK 可清洁安装、同签名覆盖安装和启动；更高 version code 的最终升级复核仍保留为发版检查项。
- [ ] GitHub Release 可供用户直接下载 APK。
- [ ] 若采用 Google Play，AAB 通过其内部测试轨道。
- [x] 发布包不包含用户数据和秘密信息。

A7 候选结果：EchoDay 独立 RSA 4096 签名已生成，Gradle 不再回退到 Debug 签名；通用 APK 与 ARM64 APK 均通过 Android APK Signature Scheme v2/v3 校验，AAB 通过 JAR 签名校验。三个产物及 SHA-256 文件位于 `dist/android/`，发布脚本会扫描并拒绝包含数据库、备份或签名材料的归档。API 36 AOSP 模拟器完成清洁安装、创建数据、同签名覆盖安装及数据保留验证；小米 15 Pro 完成旧测试包清除、ARM64 正式包安装、启动及日志复核。GitHub Actions 自动签名发布流程、隐私政策、Data Safety 基线、迁移说明和 Android v0.1.0 发布说明已加入工程。详细结果见 [`ANDROID_A7_AUDIT.md`](../ANDROID_A7_AUDIT.md)。

参考：

- [Android 应用签名](https://developer.android.com/studio/publish/app-signing)
- [Android 应用发布](https://developer.android.com/studio/publish)
- [Android 开发者验证](https://developer.android.com/developer-verification)

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

### 9.3 Android 运行环境

- Google APIs 模拟器：用于常规开发、调试和工具兼容验证。
- AOSP/无 GMS 模拟器或真机：验证应用不依赖 Google Play Services。
- ARM64 真机：验证实际性能、触控、输入法、文件选择和安装升级。

### 9.4 必测状态

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
| 项目与 Pub Cache 跨盘导致 Kotlin 缓存失败 | 保留 `kotlin.incremental=false`，CI 使用干净构建验证 |
| 无 Google Play 的设备出现功能缺失 | 不引入不必要的 GMS 依赖，并在 AOSP/无 GMS 环境完成验收 |
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
2. 暂时保留包名 `com.vanecho.echoday`，在正式签名和公开发布前完成最终确认。
3. 手机采用“上方 2 周日历 + 下方 3/5 高度当日 TODO”，并保留完整当日 TODO 独立页面。
4. 平板采用日历与右侧 TODO 双栏。
5. GitHub、其他应用商店和直接分发以签名 APK 为主；Google Play 为可选渠道，采用时再准备 AAB。
6. 通知提醒、桌面小组件和云同步放到 Android v1.1。
7. 应用不得依赖 Google Play Services；API 36 常规模拟器之外必须增加 AOSP/无 GMS 验证。
8. A6 的本机自动化、AOSP 模拟器矩阵与小米 15 Pro ARM64 真机验收均已完成；下一阶段进入 A7。
