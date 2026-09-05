# 丸成 / EchoDay — M6 Windows 发布候选报告

日期：2026-09-05  
候选版本：v0.1.0 RC1  
发布形态：Windows x64 免安装便携 ZIP

## 1. 候选产物

- `dist/EchoDay-v0.1.0-windows-x64-portable.zip`
- 大小：26,651,236 字节。
- SHA-256：`7ac64f96165369299385b7a00264acec27458d4be07719dd8fc372577d23ac41`。
- 包内包含完整 Flutter Runner、DLL、data、`LICENSE`、便携版说明、备份指南和 v0.1.0 发布说明。
- 包内提供 `msvcp140.dll`、`vcruntime140.dll`、`vcruntime140_1.dll` 应用本地运行库，终端用户无需安装 Flutter、Visual Studio 或 C++ 开发工具。
- 打包和解压验收会扫描并拒绝 SQLite、数据库及 EchoDay 备份 JSON；本候选包用户数据文件数为 0。
- 当前机器没有 Inno Setup 或 MakeAppx，因此 RC1 明确采用便携版，不提供安装器、自动更新或代码签名。

## 2. Windows 资源与品牌

- `EchoDay.exe` 文件描述和产品名为“丸成 EchoDay”；不设置公司名，避免把作者身份误写为公司主体。
- 文件版本/产品版本为 `0.1.0+1`。
- 版权字段为 `Copyright (C) 2026 丸一口 / Van Echo. AGPL-3.0-only.`，两者均为作者名。
- Windows 任务栏和原生标题栏使用白底“丸”图标；ICO 包含 16、20、24、32、40、48、64、128、256 像素九层，各层四角均为不透明白色。
- 应用内容区的品牌图片继续使用原有透明底“丸 / 成”Logo，不受原生窗口图标调整影响。

## 3. 数据库升级

- schema 由 v1 升级至 v2。
- v2 新增 `todos_active_date_completion` 复合索引，覆盖软删除状态、所属日期和完成状态。
- Drift `SchemaVerifier` 验证 v1→v2 最终结构等同于全新 v2 数据库。
- 数据完整性测试在 v1 写入带执行时间、DDL、优先级、备注和排序值的 TODO 及主题设置，升级后逐字段一致。
- 用户数据库继续位于 Windows 用户“文档”目录中的 `echoday.sqlite`，独立于便携程序目录。

## 4. 性能与质量

- `tool/quality.ps1 -SkipPubGet`：通过。
- 格式检查：96 个 Dart 文件无改动。
- `flutter analyze`：无问题。
- 普通自动化测试：95 项通过；1 项访问中国政府网的真实联网测试按设计默认跳过。
- Windows 原生集成测试：1 项通过，验证真实 Runner 可启动应用壳层。
- 10,000 条本地任务搜索在测试阈值 3 秒内完成并准确命中唯一任务。
- SQLite 查询计划确认活动日期查询使用 v2 复合索引。
- 日历 5～10 周流、1280×720 至 3840×2160、100%～200% 显示缩放继续由既有纯函数/widget 测试覆盖。

## 5. 便携安装与数据保留

`tool/test_windows_portable.ps1` 完成以下自动验收：

1. 校验 ZIP 与 `.sha256` 一致。
2. 解压到工作区隔离测试目录。
3. 确认三项应用本地 Visual C++ 运行库齐全，且不存在数据库或备份 JSON。
4. 从解压目录启动 Release `EchoDay.exe`，确认 5 秒内未异常退出。
5. 只终止本次启动的明确 PID。
6. 删除隔离程序目录，模拟便携版卸载。
7. 确认 `C:\Users\WanYikou\Documents\echoday.sqlite` 仍存在且内容哈希保持一致。

本次环境：Microsoft Windows 11 家庭版中文版，64 位，版本 `10.0.26200`。

最终发版前已按用户授权无备份清空当前测试数据库的全部 8 张业务表，并删除应用安全备份与 Release 目录中的测试导出 JSON。随后重新生成最终 ZIP；静态验收确认 41 个包内条目中用户数据文件为 0、应用本地运行库为 3、`EchoDay.exe` 存在。为避免重新创建本机数据库，最终 ZIP 生成后不再启动应用。

## 6. 剩余发布门槛

- 在 Windows 10 x64 真机或可信虚拟机解压并启动一次，确认首页可见、文件选择器可打开、退出正常。
- 用户体验 RC1 的核心 CRUD、主题与 JSON 导出/恢复。

上述两项通过后即可关闭 M6。安装器、签名和自动更新属于后续发布工程，不阻断本便携候选包。

## 7. Android 后续

Android 复用边界与必须适配项已记录在 `docs/ANDROID_PORTING_CHECKLIST.md`，M6 未顺带实现移动端 UI、权限或发布配置。
