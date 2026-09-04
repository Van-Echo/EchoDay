# 丸成 / EchoDay — M1 数据层完成报告

> 日期：2026-09-03  
> 状态：M1 已通过验收

## 完成内容

- 建立 `LocalDate`、`TodoItem`、`TodoDraft`、`Category`、`Tag`、`RecurrenceSeries`、`HolidayYear`、`AppSetting` 等领域类型。
- 任务时间点统一要求 UTC，所属日期单独保存为严格的 `YYYY-MM-DD`；本地修改维护 UUID、`updatedAt`、`revision` 与软删除时间。
- 定义 Todo、分类、标签、设置、节假日与备份 Repository 接口，UI 后续只依赖抽象，不直接访问 SQLite。
- 建立 Drift schema v1：`todos`、`categories`、`tags`、`todo_tags`、`recurrence_series`、`recurrence_exceptions`、`holiday_years`、`settings`。
- 为按日期、DDL、更新时间、标签和重复实例查询建立索引；启用 SQLite 外键并为关联表配置级联规则。
- 实现任务新增、读取、编辑、完成、恢复、软删除、撤销删除、按日响应式查询、手动顺序持久化和分页搜索。
- 实现单分类、多标签关系，以及分类、标签和设置的本地持久化。
- 实现六种排序模式。所有模式均将已完成项放在底部；综合排序遵循优先级、计划执行时间、计划 DDL 时间、创建时间和 UUID 稳定兜底。
- 实现集中式逾期判断：未完成、未删除、有 DDL，且当前 UTC 时间严格晚于 DDL。
- 保存 `drift_schemas/app_database/drift_schema_v1.json`，作为后续迁移测试的基线。

## 验收结果

- `dart run build_runner build`：通过，可重复生成。
- `dart format --output=none --set-exit-if-changed ...`：通过。
- `flutter analyze`：通过，零问题。
- `flutter test`：26 项通过。
- `flutter build windows --debug`：通过。
- Windows 启动集成测试：1 项通过，应用可实际启动。
- 真实文件数据库关闭并重新打开后，任务与设置保持一致。
- 外键失败在事务中完整回滚，不残留半条任务。
- 排序、逾期的相等时刻与 UTC 约束均有边界测试。

## Windows 构建环境

Windows“开发者模式”已于 2026-09-03 启用，Flutter 原生插件符号链接、Debug 构建与启动集成测试均已验证通过。完整复验命令为：

```powershell
.\tool\quality.ps1 -SkipPubGet -BuildWindows -RunIntegration
```

## M2 入口

下一阶段先实现与 UI 无关的连续周日期、5～10 周缩放和日期格容量计算，再将其连接到月历工作台、右侧栏与已完成的 Repository。
