# EchoDay Android A6 质量验收记录

> 日期：2026-09-08  
> 结论：本机自动化、AOSP 模拟器与 ARM64 真机验收全部通过；A6 已完成

## 1. 本阶段新增的质量基线

- `integration_test/android_quality_test.dart`：覆盖 Android 紧凑布局、中文文本输入、新增任务、完成任务、设置导航和系统返回。
- `integration_test/android_timezone_test.dart`：覆盖北京时区与纽约夏令时切换，并验证任务移日后保留本地时分。
- `integration_test/android_performance_test.dart`：在 Android 设备内写入 10,000 条任务并测量搜索和连续日期读取。
- `integration_test/android_holiday_network_test.dart`：在 AOSP/无 GMS Android 网络栈中获取并校验 gov.cn 法定节假日数据。
- `test/features/todos/data/local_todo_performance_test.dart`：提供可重复运行的宿主机 10,000 条任务性能基线。
- 日历极矮布局增加安全降级：空间不足时仅显示日期，不再让固定表头溢出。
- TODO 空状态改为可滚动布局；软键盘压缩后台页面时不再发生 RenderFlex 溢出。
- 当日期格连“一条更多任务”提示都容纳不下时不再强制绘制该提示。

## 2. Android API 矩阵

所有设备均使用不带 Google Play Services 的 AOSP x86_64 系统镜像。

| Android API | 环境 | 核心集成流程 | 额外条件 | 结果 |
| --- | --- | --- | --- | --- |
| 24 | EchoDay_API24_AOSP | 新增、中文文本、完成、设置、返回 | 最低支持版本 | 通过 |
| 29 | EchoDay_API29_AOSP | 新增、中文文本、完成、设置、返回 | 旧版存储行为代表 | 通过 |
| 34 | EchoDay_API34_AOSP | 新增、中文文本、完成、设置、返回 | 常见现役系统 | 通过 |
| 36 | EchoDay_API36_AOSP | 新增、中文文本、完成、设置、返回 | 系统深色模式、200% 字号 | 通过 |

首轮 API 24 集成测试发现软键盘出现时后台日历格和空 TODO 面板会被压到极小高度，由本阶段的安全降级修复。修复后四个 API 版本全部通过。

## 3. 时区与夏令时

- `Asia/Shanghai`：UTC+8，任务从 2026-03-07 移动到 2026-03-09 后仍保持 09:25 与 19:45 的墙上时间。
- `America/New_York`：验证 2026-03-07 的 UTC-5 和 2026-03-09 的 UTC-4；跨越夏令时起点后仍保持墙上时间，计划执行时间正确转换为 `2026-03-09T13:25:00Z`。
- 两个时区均在 API 36 AOSP 设备进程内执行并通过。

## 4. 性能结果

API 36 AOSP 模拟器、内存 SQLite、10,000 条任务：

| 操作 | 实测 |
| --- | ---: |
| 批量写入 10,000 条 | 378 ms |
| 唯一文本搜索 | 442 ms |
| 连续 70 天读取，共返回 10,000 条 | 404 ms |

宿主机共享性能测试结果为唯一搜索 284 ms、连续 70 天读取 263 ms。设备用例的宽松回归阈值分别为写入 20 秒、搜索 5 秒、连续读取 10 秒，用于发现明显的全表重复扫描或性能退化，而不是承诺所有硬件上的绝对耗时。

## 5. AOSP、网络与生命周期

- AOSP/无 GMS 环境直接访问 gov.cn，并成功解析、校验 2026 年节假日数据。
- 单元测试继续覆盖断网、远端异常、无结果、本地缓存及内置数据回退。
- 普通 Release APK 在飞行模式下可以启动并创建本地 Drift 数据库。
- 同一 Release 进程连续经历 360dp 级 Compact、600dp 级 Medium、宽屏 Expanded 代表尺寸及横竖屏变化，进程未退出。
- 系统返回后重新呼出、退到后台后恢复均复用正常进程；强制停止后重新启动生成新进程。
- 强制停止前后 `echoday.sqlite` 均存在；重新启动后的数据库为 106,496 字节。
- 相关日志中未匹配到 Flutter 致命错误、`MissingPluginException` 或 SQLite 异常。

## 6. 全量回归与构建

- `flutter analyze`：通过，无问题。
- `flutter test`：123 项通过；1 项 gov.cn 实时联网测试按显式环境开关设计跳过。Android 设备端联网用例已单独通过。
- Windows Debug：`build/windows/x64/runner/Debug/EchoDay.exe` 构建成功。
- Android Release：`build/app/outputs/flutter-apk/app-release.apk` 构建成功，约 76.9 MB。

## 7. ARM64 真机验收

验收设备：小米 15 Pro（型号 `2410DPN6CC`，Android 15 / API 35，`arm64-v8a`，1080×2400，简体中文，系统字号 125%）。

- 核心集成流程通过：新增、中文文本、完成、设置导航、系统返回，以及日历页/其他页面标题栏差异。
- 使用真实中文输入法完成了标题、备注、分类、标签、计划执行时间和计划 DDL 输入；软键盘与返回手势正常。
- 长按、拖动和物理触觉反馈通过人工验收。
- 系统 SAF 文件选择器中的 JSON 导出与重新导入通过人工验收。
- gov.cn 节假日真实联网更新通过；`Asia/Shanghai` 设备时区用例通过。
- 真机 10,000 条任务结果：写入 283 ms、唯一搜索 275 ms、连续 70 天读取 172 ms。
- Release 覆盖安装成功；后台/恢复保持同一进程，强停/重启正常，日志未发现 Flutter 致命错误、`MissingPluginException` 或 SQLite 异常。
- 浅色、深色及横竖屏显示通过；日历在安卓端使用沉浸式全屏并移除标题栏，其他页面保留标题栏。
- 状态栏与导航栏在普通界面隐藏；输入法关闭后沉浸模式自动恢复。
- 横屏内容延伸至显示挖孔区域，不为左侧前置镜头预留空白；旋转期间进程未重启。
- 本设备不是折叠屏，因此真实折叠姿态不适用；普通手机横竖屏已覆盖。

真机截图保存在 `artifacts/a6/xiaomi15pro_fullscreen_portrait.png`、`artifacts/a6/xiaomi15pro_fullscreen_landscape.png` 和 `artifacts/a6/xiaomi15pro_fullscreen_search_keyboard_closed.png`。
