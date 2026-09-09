# EchoDay V1.0.1 发布说明

EchoDay V1.0.1 是首个提供 Windows 与 Android 多端同步的稳定版本。应用仍保持本地优先，不要求 EchoDay 账号，也不依赖项目方托管的云服务器。

## 主要更新

- 一台 Windows PC 可作为同步组中的主机，Windows 与 Android 设备可作为客户端。
- 支持局域网、Tailscale IP、MagicDNS、二维码、完整连接码和 `.echoday-pair` 临时配对文件。
- 使用 HTTPS、TLS 证书指纹固定、Ed25519 设备身份、短期会话、人工校验码和防重放 nonce 保护连接。
- 支持离线编辑、增量同步、确定性冲突合并、冲突版本恢复和设备撤销。
- Windows 主机支持设备备注、主动同步请求、登录启动、托盘运行与网络恢复。
- Windows 可设置默认备份目录、每日自动备份及保留数量。
- 同步异常不会阻止查看、新增或修改本地任务。

## 下载与安装

- Windows 10/11 x64：下载 `EchoDay-v1.0.1-windows-x64-portable.zip`，完整解压后运行 `EchoDay.exe`。
- 大多数现代 Android 手机：下载 `EchoDay-v1.0.1-android-arm64-v8a.apk`。
- 不确定 Android CPU 架构时：下载 `EchoDay-v1.0.1-android-universal.apk`。
- `EchoDay-v1.0.1-android.aab` 仅用于应用商店发布，普通用户无需下载。

便携包和 APK 均可直接使用，不需要安装 Flutter、Visual Studio、Android Studio 或 Google Play 服务。请使用同目录的 `.sha256` 文件核对下载完整性。

## 数据与隐私

- EchoDay 不提供开发者托管的云同步，也不接收或中转任务数据。
- 异地同步使用用户自己的 Tailscale 网络，Tailscale 由用户自行安装、登录和维护。
- 设备私钥、连接凭据、数据库和备份文件不会进入发行包，也不会进入普通 JSON 导出。
- 升级或更换签名不同的早期测试包前，请先导出 JSON 备份。

## 已知限制与验收说明

- 同步组必须只有一台 Windows 主机；主机在线且 EchoDay Server 服务运行时，客户端才能立即同步。
- Android 不常驻后台，仅在打开应用、回到前台或手动操作时同步。
- 本版已通过 Windows 主 PC 与小米 15 Pro 的 Tailscale、离线编辑和恢复收敛真机测试。
- 因当前没有第二台实体 Windows PC，实体 PC-PC、三机收敛及真实 PC 休眠/重启/网络切换测试由项目方决定暂时放弃，不代表这些场景已通过；后续按 [多 PC 互联测试指南](TEST_MULTI_PC_SYNC.md) 补测。

## 许可

本项目采用 [GNU Affero General Public License v3.0](../LICENSE)，SPDX 标识为 `AGPL-3.0-only`。
