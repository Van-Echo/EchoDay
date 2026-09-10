<p align="center">
  <img src="assets/branding/echoday_maru.png" width="96" alt="丸成 Logo">
  <img src="assets/branding/echoday_cheng.png" width="96" alt="EchoDay Logo">
</p>

<h1 align="center">丸成 · EchoDay</h1>

<p align="center">
  让每一天，都有迹可循。<br>
  一款面向 Windows 与 Android 的去中心化多端数据互通 RunDown + TODOList 应用。
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
| Windows 10/11 x64 | `EchoDay-v1.0.3-windows-x64-portable.zip` | 解压全部文件后运行 `EchoDay.exe` |
| 大多数现代 Android 手机 | `EchoDay-v1.0.3-android-arm64-v8a.apk` | 在系统提示下允许安装来自该来源的应用 |
| 其他 Android 设备 | `EchoDay-v1.0.3-android-universal.apk` | 不确定 CPU 架构时使用通用包 |

发布包解压或安装后即可使用，不需要另行安装 Flutter、Visual Studio、Android Studio 或 Google Play 服务。`.aab` 文件仅供应用商店发布，普通用户无需下载。

> Android 早期测试版使用 Debug 签名，不能直接覆盖正式版。请先导出 JSON 备份、卸载测试版，再安装正式版。安装正式版后，建议持续使用同一种 APK 类型进行升级。

## 多端同步

EchoDay V1.0.3 提供可选的设备直连同步，不需要 EchoDay 云服务器或账号：

- 一台 Windows 电脑作为同步组中唯一的主 PC，负责接收和汇总变更。
- Android 手机及其他 Windows 电脑作为客户端，可以离线编辑，稍后与主 PC 合并。
- 同一网络中可通过局域网连接；异地设备可以安装 Tailscale 并登录用户自己的 Tailnet。
- Android 支持扫描二维码或粘贴完整连接码；Windows 客户端还支持附近主机发现和导入 `.echoday-pair` 临时配对文件。
- 首次配对需要在主 PC 核对六位校验码并确认；之后可在主 PC 查看设备、添加备注、请求同步或撤销设备。
- Android 会在打开或回到 EchoDay 时同步，也可手动同步；Windows 客户端在窗口重新获得焦点或用户操作时同步。
- TODO、分类、标签和重复规则参与同步；主题、语言、快捷键、备份目录等设备偏好不会跨设备覆盖。
- 如使用Tailscale，建议在安卓端为其开启 允许自启动、后台运行权限：无限制、电池优化：不限制，以保证运行稳定性。

传输使用 HTTPS、证书指纹固定、Ed25519 设备签名、短期会话和防重放 nonce。EchoDay 项目方不接收、中转或保存同步数据；使用 Tailscale 时，网络服务由用户自己的 Tailscale 账号提供。

主 PC 必须处于开机且 EchoDay Server 服务可用的状态才能立即同步。设备离线或主 PC 暂时不可用时，本地 TODO 功能不受影响，重新连接后会继续增量合并。发生同字段并发修改时，可在同步设置中查看并恢复冲突版本。

> 本版已完成 Windows 主 PC 与小米 15 Pro 的 Tailscale、离线编辑和恢复收敛真机测试，以及 Windows 客户端的自动化 HTTPS 双数据库测试。由于当前没有第二台实体 Windows PC，PC-PC、三机实体收敛以及真实 PC 休眠/重启/网卡切换验收按项目方决定暂缓；对应自动恢复逻辑已有自动化覆盖，详情见 [S8 发布验收记录](docs/S8_RELEASE_VALIDATION.md)。

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
- 本地备份：支持 JSON 导出、导入预检、合并导入、覆盖恢复和清空数据前安全备份；Windows 可设置默认目录、每日自动备份及保留数量。
- 可选多端同步：一台 Windows 作为主机，Android 或其他 Windows 设备作为客户端；局域网可直连，异地连接复用用户自己的 Tailscale，不依赖 EchoDay 官方服务器。

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

EchoDay V1.0.3 不提供账号、项目方托管云同步、广告或行为分析。TODO、分类、标签和设置默认只保存在设备本地；只有在用户主动更新中国法定节假日时，应用才会访问相关公开数据源。多端同步由用户主动启用，只在用户自己的局域网或 Tailscale 网络中连接设备，EchoDay 项目方不接收或中转任务数据。

在“设置 → 数据备份与恢复”中可以：

- 导出标准名称为 `EchoDay-backup-yyyyMMdd-HHmmss.json` 的备份文件；
- 在 Windows 上选择、打开并测试默认备份目录；
- 在 Windows 上按需开启每日自动备份，并设置保留 1～30 份；
- 预检并合并导入另一份备份；
- 二次确认后覆盖恢复；
- 清空用户数据。

覆盖恢复或清空数据前，应用会在当前默认备份目录创建安全备份。备份目录、自动备份开关与保留数量属于设备本地设置，不写入 JSON，也不会参与多端同步。完整说明请阅读 [隐私政策](PRIVACY.md) 与 [备份指南](docs/USER_BACKUP_GUIDE.md)。

## 开发

项目基于 Flutter 3.47.2 / Dart 3.13.2，使用 Riverpod 管理状态、Drift/SQLite 存储本地数据，并通过 Repository 与传输接口隔离本地存储、增量同步和界面层。

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
- [多端同步开发计划](docs/PLAN_Sync.md)
- [同步协议 V1](docs/SYNC_PROTOCOL_V1.md)
- [同步数据库 Schema v3 设计](docs/SYNC_SCHEMA_V3.md)
- [同步威胁模型与日志规范](docs/SYNC_SECURITY.md)
- [多 PC 互联测试指南](docs/TEST_MULTI_PC_SYNC.md)
- [V1.0.1 / S8 发布验收记录](docs/S8_RELEASE_VALIDATION.md)
- [技术架构与开发计划](docs/DEVELOPMENT_PLAN.md)
- [Android 发布指南](docs/ANDROID_RELEASE_GUIDE.md)
- [Android Data Safety 基线](docs/ANDROID_DATA_SAFETY.md)
- [V1.0.1 发布说明](docs/RELEASE_NOTES_v1.0.1.md)
- [V1.0.2 发布说明](docs/RELEASE_NOTES_v1.0.2.md)
- [V1.0.3 发布说明](docs/RELEASE_NOTES_v1.0.3.md)
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
