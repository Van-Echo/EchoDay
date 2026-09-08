# 丸成 / EchoDay — Android A0 基线审计

> 审计日期：2026-09-05
> 结论：A0 通过，可以进入 A1

## 1. 构建与设备基线

- Flutter 3.47.2，Dart 3.13.2。
- Debug APK 构建成功：`build/app/outputs/flutter-apk/app-debug.apk`。
- APK 元数据：`minSdk 24`、`compileSdk 36`、`targetSdk 36`。
- APK ABI：`arm64-v8a`、`armeabi-v7a`、`x86_64`。
- WHPX 硬件加速可用。
- 已建立以下模拟设备：
  - `Pixel_9`：API 36、Google APIs、x86_64。
  - `EchoDay_API24_AOSP`：API 24、AOSP、x86_64。
  - `EchoDay_API36_AOSP`：API 36、AOSP、x86_64。

## 2. 启动验证

| 环境 | 安装 | 启动 | 前台 Activity | Flutter 致命错误 |
| --- | --- | --- | --- | --- |
| API 36 / Google APIs | 通过 | 通过 | `MainActivity` | 无 |
| API 24 / AOSP / 无 GMS | 通过 | 通过 | `MainActivity` | 无 |
| API 36 / AOSP / 无 GMS | 通过 | 通过 | `MainActivity` | 无 |

API 24 日志会记录 FlutterActivity 对 Android 13 返回动画类的非致命类校验信息，但应用进程保持存活、主界面正常获得焦点。后续升级 Flutter 或 Android embedding 时继续监测。

`Pixel_9` 首次使用无窗口 SwiftShader 冷启动时，Google APIs 系统服务曾触发 System UI ANR；EchoDay 本身没有崩溃。API 36 AOSP 在 4 核、4096 MB 内存和 SwiftShader 下完成了干净启动，因此该 ANR 归入模拟器性能问题，不归入应用阻断项。

## 3. Drift 数据库验证

- Android 数据库路径：`app_flutter/echoday.sqlite`。
- 文件大小：106,496 字节。
- `PRAGMA user_version`：2。
- `PRAGMA integrity_check`：`ok`。
- 已创建表：`categories`、`holiday_years`、`recurrence_exceptions`、`recurrence_series`、`settings`、`tags`、`todo_tags`、`todos`。
- 初始化后 `holiday_years` 含 1 条记录，确认数据库发生了实际写入。
- 强制结束并重新启动应用后，数据库 SHA-256 保持一致，应用重新打开成功，未出现 Drift/SQLite 异常。

## 4. 截图证据

- [API 24 AOSP 日历](artifacts/android-a0/echoday-api24-aosp-home.png)
- [API 24 当日 TODO](artifacts/android-a0/echoday-api24-day-todos.png)
- [API 24 设置](artifacts/android-a0/echoday-api24-settings-retry.png)
- [API 24 关于](artifacts/android-a0/echoday-api24-about-valid.png)
- [API 36 AOSP 日历](artifacts/android-a0/echoday-api36-aosp-home.png)
- [API 36 AOSP 搜索](artifacts/android-a0/echoday-api36-search-stable.png)
- [API 36 Google APIs System UI ANR 记录](artifacts/android-a0/echoday-api36-home.png)

## 5. 进入 A1/A2 后的问题清单

### A1：平台能力隔离

1. Android 设置页仍显示“Keyboard shortcuts”，应隐藏 Windows 全局热键相关设置。
2. 继续确认 `window_manager` 与 `hotkey_manager` 在 Android 不初始化、不注册且不暴露入口。
3. Android 主 Manifest 目前没有 `INTERNET` 权限；在 A5 加入后验证 Release 节假日更新。

### A2/A3：移动布局

1. 日历顶部的碎碎念与月份标题明显重叠。
2. 桌面式品牌标题占用较多纵向空间，应为 Compact 布局重新设计。
3. 日历格内“Off / Work”和中文节假日名称被严重截断。
4. “Today”悬浮按钮遮挡右下角日期格内容。
5. 当日 TODO 页标题在右侧操作按钮较多时被截断。
6. 搜索框提示文字在手机宽度下被截断，需要更短的移动端文案或动态布局。
7. 搜索页面首次聚焦可能立即唤起软键盘，需要确认是否符合预期。
8. AOSP 镜像不自带常用中文输入法；输入法验收使用 Google APIs 模拟器及 ARM64 真机。

### 已确认无阻断的页面

- 日历、当日 TODO、搜索、设置和关于页面均可进入。
- 设置页面可滚动并正常渲染折叠栏目。
- 关于页面在手机视口下无明显横向溢出。
- 底部五项导航在稳定帧中完整显示。

## 6. A0 结论

A0 的构建、API 24、API 36、无 GMS、数据库持久化和截图审计均已完成。移动端当前存在预期中的桌面布局迁移问题，但没有阻止进入 A1 的构建、安装、启动或数据层故障。
