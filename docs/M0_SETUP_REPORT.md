# M0 环境与工程骨架记录

> 日期：2026-09-03  
> 状态：已完成并通过验收

## 已完成

- 安装 Flutter 3.47.2 stable 与 Dart 3.13.2，并把 `E:\HappyCoding\tools\flutter\bin` 加入用户 PATH。
- 仅启用 Windows 与 Android Flutter 平台。
- 创建 `echoday` 工程，应用标识为 `com.vanecho.echoday`，Windows 可执行文件名为 `EchoDay.exe`。
- 建立 feature-first 目录、Riverpod、go_router、浅色/深色主题、中英文本地化、日志和错误边界。
- 月历、当日 TODO、搜索、设置与关于页面均可通过空壳导航进入。
- 建立单元测试、Widget 测试、Windows 集成测试入口、本地质量脚本和 GitHub Actions。
- `flutter analyze`：通过，无问题。
- `flutter test`：4 项通过。
- `flutter build windows --debug`：通过，生成 `build/windows/x64/runner/Debug/EchoDay.exe`。
- Windows 启动集成测试：1 项通过。

## 当前工具链

- Windows 11 25H2 x64。
- Visual Studio Community 2022 17.14.39。
- Windows SDK 10.0.22621.0 已安装。
- Flutter 能识别 `windows` 桌面设备。
- Android SDK 尚未安装；第一阶段只开发 Windows，因此延后到 Android 阶段。

## 验收命令

```powershell
flutter doctor -v
.\tool\quality.ps1 -BuildWindows -RunIntegration
```

两条命令已于 2026-09-03 验证。Visual Studio 与 Windows 设备均通过 doctor；Android SDK 延后到移动端阶段，不阻塞 Windows M0。
