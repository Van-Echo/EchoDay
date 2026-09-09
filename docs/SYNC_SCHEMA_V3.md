# EchoDay 同步数据库 Schema v3 设计

> 状态：S0 冻结设计，S2 实施
> 来源版本：公开 schema v1、v2
> 目标版本：schema v3

S0 只冻结迁移结构，不提前修改生产数据库。S2 必须按本文创建 Drift 表、生成 schema 快照并运行从 v1、v2 到 v3 的迁移测试。

## 1. 新增表

### `sync_groups`

- `id TEXT PRIMARY KEY`
- `role TEXT NOT NULL CHECK(role IN ('host','client'))`
- `host_device_id TEXT NOT NULL`
- `protocol_version INTEGER NOT NULL`
- `created_at INTEGER NOT NULL`
- `updated_at INTEGER NOT NULL`

每个数据库最多保留一个活动同步组。角色切换不删除业务数据。

### `sync_devices`

- `device_id TEXT PRIMARY KEY`
- `sync_group_id TEXT NOT NULL REFERENCES sync_groups(id) ON DELETE CASCADE`
- `display_name TEXT NOT NULL`
- `note TEXT NULL`
- `platform TEXT NOT NULL`
- `app_version TEXT NOT NULL`
- `protocol_version INTEGER NOT NULL`
- `public_key TEXT NOT NULL`
- `created_at INTEGER NOT NULL`
- `updated_at INTEGER NOT NULL`
- `last_seen_at INTEGER NULL`
- `revoked_at INTEGER NULL`

索引：`(sync_group_id, revoked_at)`。私钥和长期会话密钥不进入此表。

### `sync_pairing_invites`

- `id TEXT PRIMARY KEY`
- `sync_group_id TEXT NOT NULL REFERENCES sync_groups(id) ON DELETE CASCADE`
- `token_hash TEXT NOT NULL UNIQUE`
- `host_fingerprint TEXT NOT NULL`
- `expires_at INTEGER NOT NULL`
- `attempt_count INTEGER NOT NULL DEFAULT 0`
- `maximum_attempts INTEGER NOT NULL`
- `created_at INTEGER NOT NULL`
- `consumed_at INTEGER NULL`

只保存一次性 token 的哈希。过期、使用成功或失败达到上限后不可复用。

### `sync_changes`

- `operation_id TEXT PRIMARY KEY`
- `sync_group_id TEXT NOT NULL REFERENCES sync_groups(id) ON DELETE CASCADE`
- `source_device_id TEXT NOT NULL REFERENCES sync_devices(device_id)`
- `sequence INTEGER NOT NULL`
- `transaction_id TEXT NOT NULL`
- `entity_type TEXT NOT NULL`
- `entity_id TEXT NOT NULL`
- `operation_type TEXT NOT NULL`
- `field_group TEXT NOT NULL`
- `payload_format_version INTEGER NOT NULL`
- `payload_json TEXT NOT NULL`
- `hlc_physical_ms INTEGER NOT NULL`
- `hlc_logical INTEGER NOT NULL`
- `hlc_device_id TEXT NOT NULL`
- `causal_cursor_json TEXT NOT NULL`
- `created_at INTEGER NOT NULL`
- `applied_at INTEGER NOT NULL`

约束与索引：

- `UNIQUE(source_device_id, sequence)`；
- 拉取索引 `(sync_group_id, source_device_id, sequence)`；
- 实体历史索引 `(sync_group_id, entity_type, entity_id)`；
- 事务索引 `(transaction_id)`。

远端应用不得再次生成新 change；本地业务写和 change 写入必须处于同一事务。

### `sync_entity_versions`

- `sync_group_id TEXT NOT NULL`
- `entity_type TEXT NOT NULL`
- `entity_id TEXT NOT NULL`
- `field_group TEXT NOT NULL`
- `winning_operation_id TEXT NOT NULL`
- `hlc_physical_ms INTEGER NOT NULL`
- `hlc_logical INTEGER NOT NULL`
- `hlc_device_id TEXT NOT NULL`
- `causal_cursor_json TEXT NOT NULL`
- `updated_at INTEGER NOT NULL`
- `PRIMARY KEY(sync_group_id, entity_type, entity_id, field_group)`

该表保存日志压缩后的字段组胜者与因果边界。现有业务表的单一 `revision` 不足以代替它。

### `sync_relation_dots`

- `sync_group_id TEXT NOT NULL`
- `todo_id TEXT NOT NULL`
- `tag_id TEXT NOT NULL`
- `add_operation_id TEXT NOT NULL`
- `added_by_device_id TEXT NOT NULL`
- `added_sequence INTEGER NOT NULL`
- `removed_by_operation_id TEXT NULL`
- `created_at INTEGER NOT NULL`
- `removed_at INTEGER NULL`
- `PRIMARY KEY(sync_group_id, add_operation_id)`

索引：`(sync_group_id, todo_id, tag_id, removed_by_operation_id)`。`todo_tags` 继续作为 UI 查询使用的物化集合，本表才是 observed-remove 的同步真相。

### `sync_cursors`

- `sync_group_id TEXT NOT NULL`
- `peer_device_id TEXT NOT NULL`
- `source_device_id TEXT NOT NULL`
- `acknowledged_sequence INTEGER NOT NULL DEFAULT 0`
- `updated_at INTEGER NOT NULL`
- `PRIMARY KEY(sync_group_id, peer_device_id, source_device_id)`

每设备、每来源的向量游标用于续传、缺口检测和墓碑确认。

### `sync_conflicts`

- `id TEXT PRIMARY KEY`
- `sync_group_id TEXT NOT NULL`
- `entity_type TEXT NOT NULL`
- `entity_id TEXT NOT NULL`
- `field_group TEXT NOT NULL`
- `kind TEXT NOT NULL`
- `winner_operation_id TEXT NOT NULL`
- `loser_operation_id TEXT NOT NULL`
- `losing_payload_json TEXT NOT NULL`
- `created_at INTEGER NOT NULL`
- `resolved_at INTEGER NULL`
- `resolution_operation_id TEXT NULL`

索引：`(sync_group_id, resolved_at, created_at)`。冲突正文只保存在本地数据库，不进入普通日志。

### `sync_runtime_state`

- `key TEXT PRIMARY KEY`
- `value TEXT NOT NULL`
- `updated_at INTEGER NOT NULL`

仅保存本机运行状态，如模式、端口、最后 HLC 与生命周期去重标记。私钥、令牌和会话密钥必须走 `DeviceSecretStore`。

## 2. 迁移路径

### v1 → v3

1. 在迁移前通过 S1 备份服务创建 schema-upgrade 安全备份。
2. 执行现有 v1 → v2 索引迁移。
3. 创建全部同步表、约束与索引。
4. 不修改 TODO、分类、标签、重复规则、节假日和设置数据。
5. 同步保持关闭；首次启用时才生成设备身份和本地同步基线。

### v2 → v3

1. 创建升级前安全备份。
2. 创建同步表、约束与索引。
3. 保持现有业务记录及 `revision` 原值。
4. 不自动把旧记录写成逐条历史 change；首次建组时在事务中建立 snapshot baseline。

迁移失败必须整体回滚并保留备份。数据库 schema 升级本身不得开启监听端口或生成配对凭据。

## 3. 初始基线

首次启用同步时：

1. 创建同步组/加入组前安全备份。
2. 对当前业务表执行完整校验。
3. 为每个字段组生成确定的 baseline operation 或等价快照版本。
4. 为现有 `todo_tags` 生成 relation add dot。
5. 在同一事务写入 entity versions、relation dots 和初始游标。
6. 成功提交后才把同步模式标记为活动。

基线生成中断时可以整笔重试；不得留下“部分实体已有版本、部分没有”的状态。

## 4. 墓碑与压缩

- 业务实体软删除和删除 change 必须保留。
- 有效设备均通过 `sync_cursors` 确认相关来源 sequence 后，墓碑才进入安全窗口。
- 安全窗口 V1 固定至少 30 天；具体清理批次必须可中断和幂等。
- 被撤销设备不再阻塞确认下界。
- 压缩 change 前保留 `sync_entity_versions`、活动 relation dots、未解决冲突及快照所需墓碑。
- 用户手动清空应用数据是独立行为，不等同于同步墓碑压缩。

## 5. 不变量

- 每个来源设备 sequence 连续且唯一。
- operation ID 全局唯一，内容不可变。
- HLC device ID 与 source device ID 相同。
- 一个 transaction 要么完整应用，要么完全不应用。
- `sync_entity_versions.winning_operation_id` 必须能在 change、快照基线或压缩证明中追溯。
- 活动 relation dot 的 TODO 和标签必须存在或保留有效墓碑。
- 设置、节假日缓存和秘密永远不进入 sync changes。

## 6. 快照与测试资产

公开 schema v1、v2 的 Drift JSON 与生成测试代码是不可变迁移基线，登记在 `test/fixtures/migrations/README.md`。S2 完成时必须：

- 生成并提交 `drift_schema_v3.json`；
- 更新 `GeneratedHelper.versions`；
- 覆盖 v1 → v3、v2 → v3 空库和带数据迁移；
- 验证迁移前后业务表逐行一致；
- 验证同步表为空且同步默认关闭；
- 验证迁移失败回滚与安全备份存在。
