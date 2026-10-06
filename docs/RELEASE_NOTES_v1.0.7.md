# EchoDay V1.0.7 发布说明

发布日期：2026-10-06

## 本次更新

- 修复设备被撤销后，使用相同设备身份重新扫码配对会提示“同步失败”的问题；撤销记录现在可在校验公钥一致后安全恢复为已连接状态。
- 日历右侧 TODO 栏新增“放弃”操作。放弃后的任务与已完成任务一样淡化、添加删除线并移动到底部，但状态图标显示为叉号；该状态支持恢复、JSON 备份和多端同步。
- 全局搜索结果默认按所属日期逆序排列，同一天内按创建时间逆序排列。
- 点击搜索结果会在当前搜索页打开任务编辑器，不再跳转到“当日 TODO”。
- 数据库 Schema 升级至 v4，并提供 v3 到 v4 的无损迁移。

## 下载文件

- Windows 10/11 x64：`EchoDay-v1.0.7-windows-x64-portable.zip`
- 大多数现代 Android 手机：`EchoDay-v1.0.7-android-arm64-v8a.apk`
- 其他 Android 设备：`EchoDay-v1.0.7-android-universal.apk`
- 应用商店发布：`EchoDay-v1.0.7-android.aab`

Windows 便携包解压全部文件后即可运行，不需要安装 Flutter 或开发工具。Android APK 不依赖 Google Play 服务。

由于本版新增了可同步的任务状态并将数据库升级至 Schema v4，多端同步组中的主 PC 与客户端应全部升级到 V1.0.7 后再同步。
