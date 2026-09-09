# EchoDay V1.0.1（S8）发布验收记录

> 状态：本地发布门禁通过，等待 GitHub Release 验证
> 最近更新：2026-09-09
> 发布门禁来源：[PLAN_Sync.md](PLAN_Sync.md#s8v101-发布验收)

## 已通过

| 验收项 | 环境与结果 |
| --- | --- |
| 静态分析 | `flutter analyze`：0 问题 |
| 自动化回归 | 195 项通过；gov.cn 实时测试与 10k 重型基准默认跳过，二者另行显式执行 |
| Windows 桌面集成 | Windows 11 x64（10.0.26200）：启动、快速退出、Debug/Release 构建通过 |
| Windows 便携包 | 解压启动、VC++ 本地运行库、用户数据库与程序目录分离、卸载模拟通过 |
| Android API 矩阵 | AOSP API 24、29、34、36 的紧凑核心流程全部通过 |
| 小米真机 | 小米 15 Pro / Android API 35 / ARM64：安装、启动、任务核心流程、时区保持、gov.cn 节假日联网均通过；10k 本地任务插入 178ms、搜索 205ms、70 天浏览 196ms |
| Tailscale 与离线恢复 | 小米 15 Pro 与主 PC 已完成扫码、配对、飞行模式离线编辑和恢复收敛 |
| 10,000 条同步 | Windows 本机完整 HTTPS/证书固定/签名/pull/ack：基线生成 22.616 秒；首次同步 11.994 秒、30 批；100 条增量 0.531 秒、1 批 |
| 同步鲁棒性 | 错误墙上时钟、乱序、重复操作、游标倒退、断网、请求重放、无效协议、压缩后超限、过深 JSON、无效 UTF-8 均有通过测试 |
| 正式签名与升级 | 现有正式密钥可构建并验证 APK v2/v3 与 AAB 签名；API 36 已验证从 `0.1.0+1` 原地覆盖升级，首次安装时间保持不变、应用正常启动；APK `minSdk=24`、`targetSdk=36` |

10k 测试由 `ECHODAY_SYNC_PERFORMANCE_TEST=1` 显式启用，避免普通 CI 每次增加约两分钟运行时间。该测试在优化前发现 100 条增量需 13.3 秒；将游标改为数据库聚合、重复操作改为批量查询，并只物化本批受影响实体后，降至 1 秒内。

## 本次发布验收豁免

以下项目因当前没有第二台实体 Windows PC，由项目方于 2026-09-09 明确决定暂时放弃测试。它们不阻断 V1.0.1 发布，也不代表已经通过；取得额外设备后按 [多 PC 互联测试指南](TEST_MULTI_PC_SYNC.md) 补测：

- 第二台实体 Windows PC 的 PC-PC 配对、传输与三机收敛。
- 实体 PC-PC 在真实局域网及 Tailscale 异地网络中的传输。
- 真实 PC 休眠、重启和网络切换后的服务恢复。

对应协议、传输、离线收敛和生命周期恢复逻辑已经由本机双数据库 HTTPS 集成测试及故障注入测试覆盖。

## 最终发布门禁

- [x] 版本提升至 `1.0.1+2`。
- [x] README、隐私政策、备份指南、Android Data Safety 与发布说明更新为正式状态。
- [x] 重新运行最终静态分析、全量自动化与 Windows 启动门禁。
- [x] 生成 V1.0.1 Windows ZIP、Android APK/AAB，并完成签名与敏感内容扫描。
- [x] 验证 `0.1.0+1` 到最终 `1.0.1+2` 的正式签名覆盖升级。
- [ ] 创建并验证 GitHub `V1.0.1` Release 及全部下载附件。

最终本地产物 SHA-256：

| 文件 | SHA-256 |
| --- | --- |
| `EchoDay-v1.0.1-windows-x64-portable.zip` | `f3160fbf83343b586ff9903254d7eafd089a5a66475f2aaa14f47d66bb2653f7` |
| `EchoDay-v1.0.1-android-universal.apk` | `6329a823296c763916f2c8f6620aa3ea1b8979cfd2e142d9bab27a7ec4c6dd20` |
| `EchoDay-v1.0.1-android-arm64-v8a.apk` | `4609578388dbda3c365f408595b20058b9b2aebb04f6d017d40dc98a67d75f46` |
| `EchoDay-v1.0.1-android.aab` | `fed57b1b4cde8b104d9acca9c406244a689839c925614ad61e3371ae0f68ec2d` |

## 已知非阻断维护项

- `mobile_scanner 7.4.0` 在 Flutter 3.47.2 下可正常构建，但会提示其尚未迁移到 Built-in Kotlin；升级 Flutter 前必须复查插件版本。

Release 曾提示缺少间接引用的 `CupertinoIcons` 字体，现已显式加入标准字体依赖并确认三类图标字体均被正确打包和 tree-shaking。
