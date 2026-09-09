# EchoDay V1.0.2 发布说明

EchoDay V1.0.2 是多端同步功能的补丁版本，修复设备撤销展示和 Android 卸载重装后的首次同步问题。

## 修复内容

- Windows 主机的“已连接设备”列表不再显示已撤销设备。撤销记录仍安全保留在主机数据库中，用于校验撤销前已经接收的历史同步操作；已撤销设备仍无法认证或上传新数据。
- 修复 Android 卸载重装、重新配对后首次同步失败的问题。新客户端现在可以验证主机已接受的历史设备操作，不会因此中断同步。

## 验证情况

- 小米 15 Pro 已完成修复版覆盖安装与首次同步实机验证。
- Flutter 静态分析、195 项自动化测试、Windows 启动集成测试和 Windows Release 构建均通过。
- Windows ZIP、Android APK/AAB 均通过签名、校验和敏感数据扫描。

## 下载与安装

- Windows 10/11 x64：下载 `EchoDay-v1.0.2-windows-x64-portable.zip`，完整解压后运行 `EchoDay.exe`。
- 大多数现代 Android 手机：下载 `EchoDay-v1.0.2-android-arm64-v8a.apk`。
- 不确定 Android CPU 架构时：下载 `EchoDay-v1.0.2-android-universal.apk`。
- `EchoDay-v1.0.2-android.aab` 仅用于应用商店发布，普通用户无需下载。

便携包和 APK 均可直接使用，不需要安装 Flutter、Visual Studio、Android Studio 或 Google Play 服务。请使用同目录的 `.sha256` 文件核对下载完整性。

## 许可

本项目采用 [GNU Affero General Public License v3.0](../LICENSE)，SPDX 标识为 `AGPL-3.0-only`。
