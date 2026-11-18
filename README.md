# Han Colors — 中国传统色壁纸（Flutter 双端）

60 种中国传统色 × 6 个程序化渲染模板的极简壁纸 App。全离线、无账号、无字体文件嵌入。

## 环境准备（一次性）

1. 安装 Flutter SDK（stable, >= 3.19）：https://docs.flutter.dev/get-started/install
2. 本机已有 Android SDK（`C:\Users\ASUS\AppData\Local\Android\Sdk`）；编译 Android 还需 JDK 17。
3. iOS 编译只能在 macOS + Xcode 上进行（Windows 无法出 iOS 包）；可用 Codemagic / GitHub Actions macOS runner 做云端打包。

## 初始化与运行

```sh
# 在项目根目录（E:\uiapp\uiapp）执行，补齐平台工程文件。
# 已存在的 MainActivity.java / AppDelegate.swift / AndroidManifest.xml 不会被覆盖。
flutter create --org com.hancolors --project-name han_colors --android-language java --ios-language swift --platforms android,ios .

flutter pub get
flutter run                 # 连接设备或模拟器后
flutter build apk --release # Android 出包
```

## iOS 额外一步

`flutter create` 生成 `ios/Runner/Info.plist` 后，加入相册写入权限说明：

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save your generated wallpapers to Photos.</string>
```

iOS 系统不允许第三方 App 直接设置壁纸：导出的壁纸会存入相册，App 内引导用户手动设置。

## 结构

- `assets/colors.json` — 60 色数据资产（中英名、拼音、HEX、双语短注）
- `lib/engine/` — 渲染引擎：值噪声 fbm、纸纹颗粒、水墨晕染、6 个模板 painter（预览与导出共用）
- `lib/ui/` — 首页色卡 / 编辑器 / 收藏
- `android/.../MainActivity.java` — Java 平台通道：设置壁纸（WallpaperManager）、保存相册（MediaStore）
- `ios/Runner/AppDelegate.swift` — iOS 平台通道：保存相册（Photos framework）

## 渲染管线说明

预览与导出共用同一套 `WallpaperEngine.paint()`，导出用 `PictureRecorder` 以 1440×3116 离屏渲染 PNG。颗粒与水墨边缘来自启动时一次性生成的噪声贴图（`EngineAssets`），运行期零像素级计算。
