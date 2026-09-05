# 丸成 EchoDay

一个以连续周日历为主体的本地优先 TODO 规划应用。第一阶段面向 Windows，工程同时保留 Android 平台入口。

# For 普通用户
请前往 https://github.com/Van-Echo/EchoDay/releases 下载 EchoDay-v0.1.0-windows-x64-portable.zip，解压后即可使用


# For 开发者

## 当前阶段

- P0：交互原型与视觉基线已完成。
- M0：Flutter 工程、路由、主题、本地化、日志、错误边界和测试骨架已完成。
- M1：领域模型、Drift schema v1、本地 Repository 和数据生命周期测试已完成。
- M2：连续周月历、自适应高度、5～10 周缩放、可调宽侧栏和全屏当日 TODO 已通过体验验收。
- M3：完整 TODO 交互已通过体验验收并关闭。
- M4：重复任务、全局搜索、中国节假日/调休更新、二十四节气与可配置多日顺延已通过体验验收并关闭。
- M5：主题与主色持久化、日期格预览和默认排序设置、版本化 JSON 导出、预检、合并导入、覆盖恢复与自动安全备份已通过体验验收并关闭。
- M6：v0.1.0 Windows x64 便携版 RC1 已生成并通过 Windows 11 本机验收；等待用户体验确认及 Windows 10 实机冒烟。
- 体验增强：丸/成双 Logo、智能月份标题、年/月日期选择器、可双击编辑删除的分类/标签、自定义色板、`Ctrl+Q` 全局显示/最小化、可直接点击编辑的日历“碎碎念~”和完整关于页已实现。
- Flutter：3.47.2 stable / Dart 3.13.2。
- 应用标识：`com.vanecho.echoday`。

## 本地运行

```powershell
flutter pub get
flutter gen-l10n
dart run build_runner build
flutter run -d windows
```

如果 `flutter doctor -v` 报告 Visual Studio 组件缺失，请在 Visual Studio Installer 的“使用 C++ 的桌面开发”工作负载中补齐：

- MSVC v143 x64/x86 build tools
- C++ CMake tools for Windows
- Windows 11 SDK 10.0.22621.0

项目包含 Flutter 原生插件。Windows 首次构建前还需要在“设置 → 隐私和安全性 → 开发者选项”中启用“开发者模式”，允许 Flutter 创建符号链接。

## 质量检查

```powershell
.\tool\quality.ps1
```

工具会依次执行依赖解析、本地化与 Drift 代码生成、格式检查、静态分析和测试。补齐 Windows 构建工具并启用开发者模式后，可使用：

```powershell
.\tool\quality.ps1 -BuildWindows
```

Windows 工具链可用后，可追加 `-RunIntegration` 在桌面设备上运行启动集成测试。

## 目录

```text
lib/src/app/       应用、路由、主题与公共壳层
lib/src/core/      配置、错误处理和日志
lib/src/data/      Drift 数据库与 schema
lib/src/features/  按功能拆分的领域、数据与页面模块
lib/l10n/          中英文资源与生成的本地化代码
docs/              PRD、开发计划和设计规范
prototypes/        P0 交互原型
test/              单元与 Widget 测试
drift_schemas/     版本化数据库 schema 快照
tool/              本地质量脚本
```

## 数据备份

在“设置 → 数据备份与恢复”中可导出 `.json` 文件，标准文件名为 `EchoDay-backup-yyyyMMdd-HHmmss.json`。导入前会先做格式与引用关系预检；可选择按稳定 ID 去重的合并导入，或二次确认后的覆盖恢复。“清空数据”会移除 TODO、分类、标签、重复规则与用户设置，但保留节假日缓存。覆盖恢复或清空前会在应用支持目录的 `EchoDay/safety_backups` 下自动保留当前数据。节假日缓存不进入用户备份。

## Windows 候选包

- 便携包：`dist/EchoDay-v0.1.0-windows-x64-portable.zip`
- SHA-256：同目录 `.sha256` 文件
- 发布说明：`docs/RELEASE_NOTES_v0.1.0.md`
- 生成命令：`.\tool\package_windows.ps1`
- 解压/启动/数据保留验收：`.\tool\test_windows_portable.ps1`

## 许可

本项目采用 [GNU Affero General Public License v3.0](LICENSE)，SPDX 标识为 `AGPL-3.0-only`。个人、企业及商业使用均被允许；发布修改版，或将修改版作为网络服务提供时，须继续遵循 AGPLv3 并按协议提供对应源代码。
