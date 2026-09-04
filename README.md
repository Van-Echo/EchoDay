# 丸成 EchoDay

一个以连续周日历为主体的本地优先 TODO 规划应用。第一阶段面向 Windows，工程同时保留 Android 平台入口。

## 当前阶段

- P0：交互原型与视觉基线已完成。
- M0：Flutter 工程、路由、主题、本地化、日志、错误边界和测试骨架已完成。
- M1：领域模型、Drift schema v1、本地 Repository 和数据生命周期测试已完成。
- M2：连续周月历、自适应高度、5～10 周缩放、可调宽侧栏和全屏当日 TODO 已通过体验验收。
- M3：完整 TODO 交互已通过体验验收并关闭。
- M4：重复任务、全局搜索、中国节假日/调休更新与二十四节气已实现，等待体验验收。
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
