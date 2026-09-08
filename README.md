<p align="center">
  <img src="assets/branding/echoday_maru.png" width="96" alt="丸成 Logo">
  <img src="assets/branding/echoday_cheng.png" width="96" alt="EchoDay Logo">
</p>

<h1 align="center">丸成 · EchoDay</h1>

<p align="center">
  让每一天，都有迹可循。<br>
  一款面向 Windows 与 Android 的本地优先日历 TODO 应用。
</p>

<p align="center">
  <a href="https://github.com/Van-Echo/EchoDay/actions/workflows/quality.yml"><img src="https://github.com/Van-Echo/EchoDay/actions/workflows/quality.yml/badge.svg" alt="Flutter quality"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-AGPL--3.0-blue.svg" alt="AGPL-3.0 license"></a>
  <a href="https://github.com/Van-Echo/EchoDay/releases"><img src="https://img.shields.io/github/v/release/Van-Echo/EchoDay?display_name=tag" alt="GitHub release"></a>
</p>

## 关于丸成

丸成以连续周日历为主体，把 TODO 直接放回它所属的日期。你可以在日历中快速了解近期安排，也可以进入某一天的完整列表，专注处理当天的工作与生活。

EchoDay 默认离线运行，不要求账号，不依赖云服务，也不收集分析数据。任务保存在设备本地，并可通过版本化 JSON 文件备份、恢复或在 Windows 与 Android 之间迁移。

## 下载与安装

请前往 [GitHub Releases](https://github.com/Van-Echo/EchoDay/releases) 下载最新正式版本。

| 平台 | 下载内容 | 使用方式 |
| --- | --- | --- |
| Windows 10/11 x64 | `windows-x64-portable.zip` | 解压全部文件后运行 `EchoDay.exe` |
| 大多数现代 Android 手机 | `android-arm64-v8a.apk` | 在系统提示下允许安装来自该来源的应用 |
| 其他 Android 设备 | `android-universal.apk` | 不确定 CPU 架构时使用通用包 |

发布包解压或安装后即可使用，不需要另行安装 Flutter、Visual Studio、Android Studio 或 Google Play 服务。`.aab` 文件仅供应用商店发布，普通用户无需下载。

> Android 早期测试版使用 Debug 签名，不能直接覆盖正式版。请先导出 JSON 备份、卸载测试版，再安装正式版。安装正式版后，建议持续使用同一种 APK 类型进行升级。

## 核心功能

- 连续周日历：固定 7 列，跨月连续浏览；Windows 可显示 5～10 周并自动填满窗口。
- 当日 TODO：单击选择日期，双击进入专注列表；支持新增、编辑、删除、完成、恢复和手动排序。
- 完整任务信息：内容、所属日期、计划执行时间、计划 DDL、优先级、分类、标签、备注与重复规则。
- 时间状态：逾期任务醒目标红；已完成任务淡化、添加删除线并自动移至底部。
- 灵活规划：支持任务跨日期拖动、当日未完成任务批量顺延，以及单项任务自定义顺延天数。
- 搜索与筛选：按内容、备注、分类和标签搜索，并组合筛选状态与日期范围。
- 中国日历：显示法定节假日、调休与二十四节气；可在设置中手动获取最新节假日数据。
- 个性化：浅色/深色主题、主色、字号、预览条数、默认排序、分类与标签颜色均可调整。
- 中英双语：支持中文与 English；英文月份和星期采用适合紧凑界面的缩写。
- 本地备份：支持 JSON 导出、导入预检、合并导入、覆盖恢复和清空数据前安全备份。

## 平台体验

### Windows

- 响应式双栏布局，TODO 侧栏宽度可在 12.5%～50% 之间拖动。
- `Ctrl + 鼠标滚轮` 调整可见周数，普通滚轮按周浏览。
- `Ctrl+Q` 全局呼出或最小化丸成。
- `Ctrl+1` 在当前选中日期新增 TODO。
- 支持在设置中重新定义快捷键，以及自定义日历顶部“碎碎念~”的内容和样式。

### Android

- 沉浸式全屏与横竖屏自适应，不依赖 Google Play Services。
- 日历默认显示两周，下半屏展示所选日期的任务列表。
- 可将选中日期展开为 3 列 × 2 行的焦点卡片；是否默认展开今天可在设置中选择。
- 针对小屏提供最低 5px 的日历任务字号，以及紧凑的双时间展示。

## 数据与隐私

EchoDay v0.1.0 不提供账号、云同步、广告或行为分析。TODO、分类、标签和设置默认只保存在设备本地；只有在用户主动更新中国法定节假日时，应用才会访问相关公开数据源。

在“设置 → 数据备份与恢复”中可以：

- 导出标准名称为 `EchoDay-backup-yyyyMMdd-HHmmss.json` 的备份文件；
- 预检并合并导入另一份备份；
- 二次确认后覆盖恢复；
- 清空用户数据。

覆盖恢复或清空数据前，应用会在自身支持目录创建安全备份。完整说明请阅读 [隐私政策](PRIVACY.md) 与 [备份指南](docs/USER_BACKUP_GUIDE.md)。

## 开发

项目基于 Flutter 3.47.2 / Dart 3.13.2，使用 Riverpod 管理状态、Drift/SQLite 存储本地数据，并通过 Repository 接口隔离数据层，为未来增加同步实现保留边界。

### 环境要求

- Flutter 3.47.2 stable
- Dart 3.13.2
- Windows 开发：Visual Studio 2022、MSVC v143、C++ CMake 工具、Windows 11 SDK 10.0.22621.0
- Android 开发：Android Studio、Android SDK 与一台模拟器或启用 USB 调试的真机

### 本地运行

```powershell
flutter pub get
flutter gen-l10n
dart run build_runner build
flutter run -d windows
```

Android 调试：

```powershell
flutter devices
flutter run -d <设备ID>
```

Windows 首次构建前，请在系统“开发者选项”中启用开发者模式，以允许 Flutter 创建符号链接。

### 质量检查

```powershell
.\tool\quality.ps1
```

该脚本依次执行依赖解析、本地化与 Drift 代码生成、格式检查、静态分析和自动化测试。构建与发布细节见下方文档。

## 项目文档

- [产品需求文档](docs/PRD.md)
- [Windows 开发计划](docs/PLAN.md)
- [Android 开发计划](docs/PLAN_Android.md)
- [技术架构与开发计划](docs/DEVELOPMENT_PLAN.md)
- [Android 发布指南](docs/ANDROID_RELEASE_GUIDE.md)
- [Android Data Safety 基线](docs/ANDROID_DATA_SAFETY.md)
- [Windows v0.1.0 发布说明](docs/RELEASE_NOTES_v0.1.0.md)
- [Android v0.1.0 发布说明](docs/RELEASE_NOTES_ANDROID_v0.1.0.md)

## 参与项目

欢迎提交 Issue 或 Pull Request：

- [BUG 反馈与功能建议](https://github.com/Van-Echo/EchoDay/issues)
- [在哔哩哔哩为丸一口充电支持](https://space.bilibili.com/3461572290677609)

## 许可

本项目采用 [GNU Affero General Public License v3.0](LICENSE)，SPDX 标识为 `AGPL-3.0-only`。

个人、企业和商业使用均被允许。发布修改后的版本，或将修改版本作为网络服务提供时，必须继续遵循 AGPLv3，并按照协议向使用者提供对应源代码。

---

由 **丸一口 / Van Echo** 创作与维护。
