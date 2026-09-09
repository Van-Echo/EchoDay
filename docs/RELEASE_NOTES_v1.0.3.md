# EchoDay V1.0.3 测试版说明

EchoDay V1.0.3 修正多端同步设备列表中的版本号、在线状态和同步状态显示。

## 修复内容

- 主 PC 启动 Server 后会刷新本机设备记录，正确显示当前应用版本。
- 客户端在经过认证的同步请求中上报当前应用版本，升级后无需重新配对即可刷新设备列表。
- 主 PC 在 Server 运行时始终显示在线，不再显示“尚未完成同步”。
- 客户端不再因为一次 HTTP 请求结束而立即显示离线；正在通信或最近五分钟内成功联系的设备显示在线。
- 增加应用内部版本与 `pubspec.yaml` 的自动一致性测试，避免后续升版遗漏。

## 测试包

- Windows 10/11 x64：`EchoDay-v1.0.3-windows-x64-portable.zip`
- 大多数现代 Android 手机：`EchoDay-v1.0.3-android-arm64-v8a.apk`
- 其他 Android 设备：`EchoDay-v1.0.3-android-universal.apk`

本地测试通过后再创建 GitHub V1.0.3 正式 Release。
