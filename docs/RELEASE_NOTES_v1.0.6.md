# EchoDay V1.0.6 发布说明

本版改进 Windows 与 Android 的同步冲突处理界面，让用户能认出任务并明确选择保留哪一端的版本。

## 更新内容

- 冲突详情并列展示本地端和主 PC 端的任务内容概要与差异。即使只冲突了完成状态，也会同时展示任务标题及两端的完成状态。
- 每端版本都有独立的“使用此版本”按钮。无论选择当前生效版本还是另一端版本，都会产生可同步的解决操作，避免另一台设备继续显示同一冲突。
- 客户端解决后立即尝试同步；主 PC 解决后请求已连接设备同步。离线设备在下次打开或回到应用时接收结果。
- 无需更改已有本地数据或重新配对设备。

## 下载

- Windows 10/11 x64：`EchoDay-v1.0.6-windows-x64-portable.zip`
- 大多数现代 Android 手机：`EchoDay-v1.0.6-android-arm64-v8a.apk`
- 其他 Android 设备：`EchoDay-v1.0.6-android-universal.apk`
- 应用商店发布：`EchoDay-v1.0.6-android.aab`

Android Release APK 沿用 EchoDay 正式签名，可覆盖安装同签名的正式版本并保留本地数据。升级前建议按需导出 JSON 备份。
