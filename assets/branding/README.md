# EchoDay branding assets

- `echoday_maru_*`: “丸” Logo sources; the white-background version is used for the Windows taskbar and window icon.
- `echoday_cheng_*`: horizontally mirrored “成” Logo sources; the white-background version is used for Android launcher icons.
- `echoday_maru.png` and `echoday_cheng.png`: normalized transparent runtime assets displayed together inside the application.

The Windows ICO contains sizes from 16 to 256 px. Android includes legacy launcher images, adaptive foreground/background resources, and an Android 13 monochrome layer. Adaptive artwork stays inside the standard safe zone.

`*_white_source.png` are the original designer-supplied images. The
`*_white_rounded.svg` / `*.png` variants clip the existing white background to a
rounded square (160/1024 corner radius); they do not redraw or change the logo.
Transparent in-app logos are unchanged. Windows ICO and Android legacy launcher
icons are generated from these rounded variants. Android adaptive icons keep the
system launcher mask.

To regenerate the rounded assets and platform icons:

```powershell
npm install --prefix build/icon-tools --no-save --ignore-scripts @resvg/resvg-js@2.6.2
node tool/generate_rounded_icons.mjs
```
