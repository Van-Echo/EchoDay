# 丸成 / EchoDay 隐私政策

生效日期：2026-09-08

丸成 / EchoDay 是一款本地优先的日历与 TODO 应用。本版本不提供账号、云同步、广告、分析统计或用户画像功能。

## 数据如何存储

- TODO、分类、标签、设置和节假日缓存保存在用户设备的应用私有目录中。
- 应用不会主动把这些内容上传到开发者服务器或第三方分析服务。
- 用户主动执行 JSON 备份或恢复时，应用通过系统文件选择器读写用户选定的文件；文件位置及后续保管由用户决定。
- 卸载应用通常会删除应用私有目录中的本地数据。建议卸载前先导出 JSON 备份。

## 网络访问

应用仅在以下用户可感知的场景使用网络：

- 用户在设置中主动更新中国法定节假日数据时，访问中华人民共和国中央人民政府网站公开接口。
- 用户点击“关于”页面中的哔哩哔哩或 GitHub 链接时，交由系统浏览器打开对应网页。

本版本不依赖 Google Play Services、Firebase 或其他跟踪 SDK。

## 权限

Android 版声明网络访问权限。备份与恢复使用 Android 系统文件选择器，不请求读取全部存储空间的权限。

## 数据删除与用户权利

用户可在“设置 → 数据备份与恢复 → 清空数据”中清除应用内数据，也可以通过 Android 系统设置清除应用数据或卸载应用。由于数据默认只保存在用户设备上，开发者无法代替用户访问、恢复或删除这些本地数据。

## 开源许可与联系

项目源代码采用 GNU Affero General Public License v3.0（AGPL-3.0-only）。问题或隐私反馈请提交至 [EchoDay Issues](https://github.com/Van-Echo/EchoDay/issues)，或发送邮件至 `wanyikou@qq.com`。

---

# EchoDay Privacy Policy

Effective date: 2026-09-08

EchoDay is an offline-first calendar and TODO application. This version has no account system, cloud sync, advertising, analytics, or user profiling.

- TODOs, categories, tags, preferences, and holiday cache are stored in the app-private area on the user's device.
- EchoDay does not send this content to a developer-operated server or an analytics provider.
- JSON backup and restore only access a file explicitly selected by the user through the system document picker.
- Network access is used when the user requests a Chinese statutory-holiday update, or opens an external link from the About page.
- The Android app does not depend on Google Play Services, Firebase, or a tracking SDK.
- Users can erase app data from EchoDay settings, Android system settings, or by uninstalling the app. Export a JSON backup before uninstalling if the data should be retained.

Privacy questions can be filed at [EchoDay Issues](https://github.com/Van-Echo/EchoDay/issues) or sent to `wanyikou@qq.com`.
