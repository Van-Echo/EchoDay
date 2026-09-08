# EchoDay Android A7 发布候选审计

审计日期：2026-09-08  
版本：v0.1.0+1  
包名：`com.vanecho.echoday`

## 结论

A7 的本地发布工程与正式候选产物已经完成。尚未执行会清除当前手机测试版数据的一次性签名迁移，也尚未把产物上传到 GitHub Release；因此 A7 仍处于“本地 RC 完成、外部分发待验收”状态。

## 正式签名

- 创建 EchoDay 独立 RSA 4096 上传密钥，别名 `echoday`，有效期 10,000 天。
- 密钥与密码保存在 `%USERPROFILE%\.echoday\android-signing`，不位于 Git 工作区。
- 本机 `android/key.properties` 已被 `android/.gitignore` 明确忽略。
- Gradle Release 构建只接受正式签名配置；缺少配置时直接失败，不再回退到 Debug 密钥。
- 证书 DN：`CN=Wan Yikou (Van Echo), OU=EchoDay, O=EchoDay, C=CN`。
- 证书 SHA-256：`1daf075896057e20cb1124ed60b11a9edfc5162f2345b72a2ecde6d956b624fa`。

密钥和凭据文件必须一起长期备份。审计文件不记录密码或密钥内容。

## 发布产物

| 文件 | 大小 | SHA-256 |
| --- | ---: | --- |
| `EchoDay-v0.1.0-android-universal.apk` | 80,650,475 B | `eb8e8d96a09f516940a80db0a1f9f57fd4c802ab16e738e5b6f32e1dc9affd9d` |
| `EchoDay-v0.1.0-android-arm64-v8a.apk` | 35,190,081 B | `bbe846fc3176d748b0cf8ec3b2783b29c0d43534ca24e1b7c9052e7e0532a78d` |
| `EchoDay-v0.1.0-android.aab` | 77,920,307 B | `6335ea99449db6e94720832806323efa9a6c6e0ded55080c9d7c8d984f8ab28e` |

APK 均通过 `apksigner verify --verbose --print-certs`，确认使用 v2/v3 签名且签名者唯一。AAB 通过非 strict `jarsigner -verify`；自签上传证书不具备公共 CA 信任链属于 Android 上传密钥的正常情况。

## 数据与秘密检查

`tool/package_android.ps1` 在复制产物前遍历 APK/AAB 归档条目，拒绝以下内容：

- `key.properties`、JKS 或 keystore。
- SQLite / DB 用户数据库。
- EchoDay JSON 备份、安全备份或签名凭据文件。

本次三个产物均通过扫描。运行时数据库位于 Android 应用私有目录，不会被 Flutter 构建打入 APK。

## 发布工程

- `tool/setup_android_signing.ps1`：一次性、安全生成本机上传密钥及 Gradle 配置。
- `tool/package_android.ps1`：构建、签名验证、隐私内容扫描、重命名和 SHA-256 生成。
- `.github/workflows/android-release.yml`：从 GitHub Actions Secret 注入签名，构建 APK/AAB，校验并上传构建产物；标签或手动指定现有标签时可附加到 GitHub Release。
- `PRIVACY.md`：中英文隐私政策。
- `docs/ANDROID_DATA_SAFETY.md`：应用商店 Data Safety 填写基线。
- `docs/ANDROID_RELEASE_GUIDE.md`：密钥保管、构建、迁移和发布步骤。
- `docs/RELEASE_NOTES_ANDROID_v0.1.0.md`：Android v0.1.0 发布说明。

## 待完成的外部验收

1. 当前小米 15 Pro 安装的是早期 Debug 签名测试包。应先导出 JSON，确认备份后卸载，再安装正式签名包并恢复；不同签名无法直接覆盖。
2. 以同一正式密钥构建更高 version code 的内部候选，验证覆盖升级、数据库迁移和本地数据保留。
3. 在 GitHub 仓库配置四项 Android 签名 Secret，运行 Android release workflow，并把 APK 与校验文件附加到现有 `V0.1.0` Release。
4. 若进入 Google Play，再完成开发者身份验证、Play App Signing、Data Safety 和内部测试轨道。
