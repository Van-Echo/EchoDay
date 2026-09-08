# EchoDay Android 发布指南

## 1. 本机正式签名

首次发布前执行一次：

```powershell
.\tool\setup_android_signing.ps1
```

脚本会生成：

- `%USERPROFILE%\.echoday\android-signing\echoday-upload.jks`
- `%USERPROFILE%\.echoday\android-signing\EchoDay-Android-signing-credentials.txt`
- 被 Git 忽略的 `android/key.properties`

请把前两个文件一起保存到至少两个安全位置。密钥或密码丢失后，将无法用同一签名向现有安装提供覆盖升级。不要提交、发送或截图公开这三个文件。

## 2. 构建发布产物

```powershell
.\tool\package_android.ps1 -BuildAppBundle
```

输出位于 `dist/android/`：

- `EchoDay-v0.1.0-android-universal.apk`：GitHub 直接下载，兼容 ARMv7、ARM64 和 x86_64。
- `EchoDay-v0.1.0-android-arm64-v8a.apk`：现代 ARM64 手机，文件更小。
- `EchoDay-v0.1.0-android.aab`：应用商店上传包，不能直接安装。
- `EchoDay-v0.1.0-android.sha256`：前三个文件的 SHA-256。

脚本会验证 APK 签名、AAB JAR 签名，并扫描归档条目，阻止数据库、备份和签名材料进入发布目录。

## 3. 首次从旧测试版迁移

早期测试 APK 使用 Flutter Debug 密钥；v0.1.0 正式候选包使用 EchoDay 独立密钥。Android 不允许不同签名的 APK 直接覆盖安装。

迁移步骤：

1. 在旧测试版中导出 JSON 备份。
2. 确认备份文件可见且大小正常。
3. 卸载旧测试版。
4. 安装正式签名 APK。
5. 导入 JSON 备份并检查任务、标签、分类和设置。

完成这一次迁移后，只要后续版本持续使用同一 EchoDay 密钥，就能正常覆盖升级并保留本地数据库。

## 4. GitHub Actions Secret

仓库需要配置以下 Actions Secret：

- `ANDROID_KEYSTORE_BASE64`：`echoday-upload.jks` 的 Base64 内容。
- `ANDROID_STORE_PASSWORD`
- `ANDROID_KEY_ALIAS`（当前为 `echoday`）
- `ANDROID_KEY_PASSWORD`

在 PowerShell 中可生成 Base64 文本：

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$env:USERPROFILE\.echoday\android-signing\echoday-upload.jks"))
```

不要把输出粘贴到 Issue、提交记录或普通仓库变量中，只能保存为加密的 Actions Secret。

## 5. 发布检查

- 更新 `pubspec.yaml` 的版本名和 version code。
- 执行 `.\tool\quality.ps1`。
- 生成发布包并核对 SHA-256。
- 在至少一台 ARM64 真机清洁安装并启动。
- 使用同一正式签名的旧候选包做覆盖升级测试。
- 验证中英文、深浅主题、横竖屏、备份恢复和节假日更新。
- 核对 `PRIVACY.md`、Data Safety、AGPLv3 和发布说明。
- 上传 APK 时同时上传 `.sha256`；AAB 仅用于支持它的应用商店。
