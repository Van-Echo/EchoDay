# EchoDay V1.0.5 发布说明

本版修复 Windows 快捷键、任务删除提示和双端同步冲突的呈现与处理。

## 更新内容

- 修复 Ctrl+1 在其他页面无法打开“在选中日期新增 TODO”的问题；同源问题下的 Ctrl+T 跨页跳转也已修复。
- “任务已删除”与 JSON 导出提示共用 3 秒短提示。删除提示带有“撤销”按钮时也会自动消失。
- Windows 与 Android 的冲突详情改为中英文可读的字段说明，不再直接显示原始 JSON。
- 客户端恢复冲突版本后立即尝试同步，让主 PC 尽快清除对应冲突；主 PC 恢复后会向已配对设备登记同步请求。离线设备在下次打开或回到 EchoDay 时继续增量同步。

## 下载

- Windows 10/11 x64：`EchoDay-v1.0.5-windows-x64-portable.zip`
- 大多数现代 Android 手机：`EchoDay-v1.0.5-android-arm64-v8a.apk`
- 其他 Android 设备：`EchoDay-v1.0.5-android-universal.apk`
- 应用商店发布：`EchoDay-v1.0.5-android.aab`

Android Release APK 沿用 EchoDay 正式签名，可覆盖安装同签名的正式版本并保留本地数据。升级前建议按需导出 JSON 备份。
