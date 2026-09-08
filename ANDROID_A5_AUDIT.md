# EchoDay Android A5 数据与备份验收

> 验收日期：2026-09-07  
> 环境：Flutter 3.47.2 / Dart 3.13.2 / API 36 AOSP（无 GMS）  
> 结论：A5 完成，可以进入 A6

## 1. 数据库与升级语义

- `AppDatabase.databaseName` 固定为 `echoday`；`drift_flutter` 在原生平台将其解析为应用文档目录中的 `echoday.sqlite`。
- Android 上该目录属于应用私有数据：进程关闭、强制停止和覆盖升级后保留，卸载应用时由 Android 一并删除。
- 现有 schema 版本为 2；自动化测试覆盖 schema 创建以及 v1 → v2 升级并保留 TODO 数据。
- API 36 AOSP 模拟器用 Release APK 覆盖已有开发版本后强制停止并重启，原有 `A3drag` 任务仍显示在 2026-09-15。

## 2. Android 文档导入与导出

- 新增 `AndroidDocumentBackupFileGateway`，设置页不再假设 Android 文档具有普通文件路径。
- 导出使用 Android Storage Access Framework 的 `ACTION_CREATE_DOCUMENT`；JSON 先写入应用缓存中的临时文件，再由原生通道流式写入用户选择的 `content://` 文档。
- 导出临时文件在成功和异常两种情况下都会清理。
- 导入使用系统 `ACTION_OPEN_DOCUMENT` 流程，只允许选择 JSON；所选内容复制到应用缓存后继续执行既有预检、合并与覆盖恢复事务。
- 模拟器实际导出了 `EchoDay-backup-*.json`，文件可被拉取并解析；随后从系统文件选择器重新打开，成功显示格式 v1、应用 v0.1.0、TODO 和总记录数预检信息。
- 用户取消文档选择、文件提供方拒绝写入等分支有自动化测试。

## 3. 跨端 JSON 与数据安全

- 新增 Windows → Android → Windows 往返测试，覆盖任务内容、所属日期、计划执行时间、DDL、优先级、分类、标签、备注、时区、排序值和语言设置。
- 往返后 JSON 文档内容保持一致，仍使用格式版本 1 和 UTC ISO-8601 时间。
- 清空数据会先在应用支持目录生成安全备份；任务、分类、标签、重复规则和用户设置被清空，法定节假日缓存保留。
- 覆盖恢复在单一数据库事务中执行；插入失败会完整回滚，原数据不会被部分删除。

## 4. 节假日联网与离线回退

- `android/app/src/main/AndroidManifest.xml` 已加入 `android.permission.INTERNET`，权限进入最终 Release 合并 Manifest。
- gov.cn 实时发现、解析和校验测试已于 2026-09-07 通过。
- 远端返回空、DNS/网络客户端直接抛错、页面数据校验失败时，均保留数据库缓存或内置年份数据，不破坏现有节假日。
- 数据库与网站均无数据时才返回“不可用”。

## 5. 权限审计

最终 Release 合并 Manifest 包含：

- `android.permission.INTERNET`：法定节假日更新必需。
- `com.vanecho.echoday.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`：Android 构建工具生成的应用签名级内部权限。

未申请 `READ_EXTERNAL_STORAGE`、`WRITE_EXTERNAL_STORAGE`、`MANAGE_EXTERNAL_STORAGE` 或媒体权限。导入导出由系统文档选择器授予单个文档的临时访问能力。

## 6. 验证结果

- `flutter analyze`：通过，无问题。
- `flutter test`：122 项通过，1 项 gov.cn 在线测试按默认条件跳过。
- `ECHODAY_LIVE_HOLIDAY_TEST=1 flutter test test/features/holidays/gov_cn_live_test.dart`：通过。
- `flutter build apk --release`：通过，产物 `build/app/outputs/flutter-apk/app-release.apk`，约 76.9 MB。
- `flutter build windows --debug`：通过，产物 `build/windows/x64/runner/Debug/EchoDay.exe`。
- Android Release：API 36 AOSP/无 GMS 安装、启动、覆盖升级、强制停止后重启、导出、导入与预检均通过。

关键截图：`artifacts/android-current/a5-import-preview.png`。
