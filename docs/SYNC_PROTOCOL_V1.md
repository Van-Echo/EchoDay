# EchoDay 同步协议 V1

> 状态：S0 冻结基线
> 协议版本：1
> 目标数据库 schema：3
> 日期：2026-09-09

本文冻结 EchoDay V1.0.1 的数据边界、操作格式、因果关系与冲突语义。网络、SQLite 和页面实现必须依赖这些规则，不能各自创造另一套合并逻辑。

## 1. 数据边界

同步实体只有：

| 实体 | wire name | 字段组 |
| --- | --- | --- |
| TODO | `todo` | `content`、`completion`、`order`、`tags`、`deletion` |
| 分类 | `category` | `content`、`order`、`deletion` |
| 标签 | `tag` | `content`、`order`、`deletion` |
| 重复系列 | `recurrenceSeries` | `content`、`deletion` |
| 重复例外 | `recurrenceException` | `content`、`completion`、`deletion` |
| TODO–标签关系 | `todoTag` | `tags` |

V1 不同步整个 `settings` 表，也不同步节假日缓存、备份目录、快捷键、窗口与平台布局、同步运行配置、日志、私钥或令牌。未来可漫游设置必须通过新的协议版本和显式白名单加入。

TODO 字段固定分组：

- `content`：`title`、`localDate`、`plannedAt`、`deadlineAt`、`priority`、`categoryId`、`notes`、`timeZoneId`、`recurrenceSeriesId`、`occurrenceDate`、首次创建时间。
- `completion`：`isCompleted`、`completedAt`。
- `order`：`manualOrder`。
- `tags`：仅由关系操作表达，不在 TODO payload 中发送标签集合。
- `deletion`：`deletedAt`，恢复使用显式 `restore` 操作。

分类和标签的名称、颜色放在 `content`，排序值放在 `order`。`updatedAt` 与本地 `revision` 不是冲突裁决依据；S2 应根据已应用操作更新它们。

## 2. 版本与标识

- `protocolVersion = 1`：消息和操作语义版本。
- `schemaVersion = 3`：首个包含同步表的目标数据库版本。
- `payloadFormatVersion = 1`：实体 payload 格式。
- `syncGroupId`、`deviceId`、`operationId`、`transactionId` 使用 UUIDv7 或安全性等价的全局唯一标识。
- `sequence` 在每个 `sourceDeviceId` 内从 1 开始严格递增，不能复用。
- 相同 `operationId` 与相同内容重复到达是幂等成功；相同 ID 对应不同内容是 `replay_detected`。

协议只保证 V1 精确兼容。未知协议、schema、payload 版本、实体或操作类型必须在写数据库前拒绝。

## 3. 操作格式

```json
{
  "protocolVersion": 1,
  "schemaVersion": 3,
  "payloadFormatVersion": 1,
  "operationId": "0199...",
  "syncGroupId": "0199...",
  "sourceDeviceId": "0199...",
  "sequence": 42,
  "transactionId": "0199...",
  "entityType": "todo",
  "entityId": "0199...",
  "operationType": "upsert",
  "fieldGroup": "content",
  "payload": {"title": "完成 EchoDay", "localDate": "2026-09-09"},
  "timestamp": {
    "physicalMillisUtc": 1788915600000,
    "logicalCounter": 3,
    "deviceId": "0199..."
  },
  "causalCursor": {"device-a": 41, "device-b": 18},
  "createdAtUtc": "2026-09-09T01:00:00.000Z"
}
```

操作类型：

- `upsert`：修改一个非删除字段组。
- `delete`：仅用于 `deletion` 字段组。
- `restore`：仅用于 `deletion` 字段组。
- `relationAdd`：为 TODO–标签关系创建唯一 add dot。
- `relationRemove`：移除创建时已经观察到的 add dots。

一个用户动作涉及多表时，所有操作共用 `transactionId` 并在同一 SQLite 事务内写入。重复规则与例外必须以完整事务验证和应用。

## 4. 因果游标与 HLC

`causalCursor` 是 `deviceId → 已观察到的最大连续 sequence`。若操作 B 的游标在 A 的来源设备上大于等于 A.sequence，则 A happens-before B；同一设备更小的 sequence 也天然先于更大的 sequence。两边都没有观察到对方时才算并发。

每个操作同时携带混合逻辑时钟：

1. 比较 UTC 物理毫秒；
2. 再比较逻辑计数器；
3. 最后按 `deviceId` 字典序稳定决胜。

HLC 只为并发分支选择确定的当前版本。因果后继永远覆盖因果前驱，即使设备墙上时钟倒退。收到远端 HLC 后必须先推进本地 HLC，再生成新的本地操作。

主机和客户端只接受每个来源设备的连续序列；发现缺口返回 `sequence_gap` 并从最后确认游标重拉，不能跳过缺口继续提交。

## 5. 合并与冲突

1. 不同实体直接合并。
2. 同一实体不同字段组独立选取因果最大操作。
3. 同组存在因果关系时采用因果后继。
4. 同组存在多个并发最大操作时，HLC 较大者成为当前值；所有其他最大操作写入冲突记录。
5. 删除状态由 `deletion` 字段组独立决定。
6. 当前删除与其他字段组的当前编辑并发时，删除无条件优先；编辑 payload 写入可恢复冲突。
7. 显式 `restore` 只有成为 `deletion` 组当前因果最大值后才恢复实体。
8. 已被因果后继覆盖的历史值不是冲突，不反复提示用户。

冲突记录必须包含胜负 operation ID、实体、字段组、失败 payload、创建时间和处理状态。用户选择恢复失败文本时，应创建一个新的本地操作或新实体，不能改写历史操作。

## 6. TODO–标签 observed-remove 关系

TODO–标签不是简单的最后写入胜出集合：

- 每次添加生成唯一 `relationAdd` operation，operation ID 即 add dot。
- 删除时发送 `observedAddOperationIds`，只移除当前设备已经看到的 add dots。
- 与删除并发、尚未被观察到的新 add 保留。
- 删除 TODO 或标签时，在同一事务生成关系删除操作。
- 日志压缩前，活动 add dots 必须保存在 schema v3 的关系 dot 表；不能仅保留 `todo_tags` 当前集合。

## 7. 批次与同步顺序

批次包含发送设备、同步组、发送方游标和最多 1000 条操作。一次会话顺序固定为：

```text
认证并校验协议
→ 客户端 push 连续本地操作
→ 主机事务应用并返回确认游标
→ 客户端 pull 主机缺失操作
→ 客户端事务应用并 ack
→ 双方比较各来源设备游标
→ 完全一致后报告已同步
```

中断后从已确认的每设备游标续传。初次同步可以传完整快照，但快照落库后必须生成同步基线和关系 dots，不能继续使用 JSON 备份的“同 ID 跳过”规则。

## 8. 路由基线

```text
GET  /v1/info
POST /v1/pair/prepare
POST /v1/pair/status
POST /v1/session/challenge
POST /v1/session/open
POST /v1/sync/devices
POST /v1/sync/push
POST /v1/sync/pull
POST /v1/sync/ack
POST /v1/sync/snapshot
POST /v1/sync/events
```

所有数据端点都使用带签名 body 的 POST。配对获批的 `pair/status` 响应返回同步组 ID、主机设备登记信息和短期会话；客户端必须再次核对二维码内的同步组与 TLS 指纹。`sync/devices` 只向已认证设备返回当前未撤销设备的公钥登记，用于验证经主机中继的原始操作。`events` 是有界长轮询，不是永久连接，其响应同时携带当前游标和主机发出的 `syncRequested` 标记。客户端完成一轮同步并提交 `ack` 后，主机清除该设备的待同步标记并更新最后成功同步时间。HTTP 状态只表达传输层结果，客户端逻辑以结构化错误码为准；DTO 不得改变本文件的因果和冲突语义。

## 9. 错误码

| 错误码 | 含义 | 默认处理 |
| --- | --- | --- |
| `invalid_request` | JSON 或请求结构无效 | 拒绝，不重试原请求 |
| `protocol_incompatible` | 协议或 payload 版本不支持 | 提示升级 |
| `schema_incompatible` | 数据库 schema 不支持 | 提示升级/迁移 |
| `unauthorized` | 会话或签名无效 | 重新认证 |
| `replay_detected` | ID 复用或 nonce 重放 | 终止会话并记安全事件 |
| `device_revoked` | 设备已撤销 | 清除会话，不自动重配 |
| `invite_expired` | 邀请过期或已使用 | 重新生成邀请 |
| `sequence_gap` | 来源序列不连续 | 从确认游标重拉 |
| `payload_too_large` | 解压后请求或字段超限 | 拒绝 |
| `batch_too_large` | 操作数超过 1000 | 缩小批次重试 |
| `validation_failed` | 实体、引用或字段校验失败 | 拒绝整个事务 |
| `conflict` | 已合并但产生用户冲突 | 展示冲突入口 |
| `internal` | 未预期主机错误 | 保留本地更改并稍后重试 |

## 10. 输入限制

- gzip 解压后单请求最多 10 MiB。
- 单批最多 1000 条操作。
- JSON 最大嵌套 32 层。
- 标识符最多 256 个 Unicode code units。
- 单字符串最多 100000 个 Unicode code units；S2 对标题、备注等字段继续采用更小的业务限制。
- 所有时间戳使用 UTC ISO-8601；所属日期保持 `YYYY-MM-DD`。
- payload 只允许 JSON null、布尔、数值、字符串、数组和字符串键对象。
- 未知实体、枚举、路径字段、可执行内容和跨同步组操作全部拒绝。

对应参考实现位于 `lib/src/features/sync/domain/`，其收敛测试是后续实现不得破坏的可执行规范。
