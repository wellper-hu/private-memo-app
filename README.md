# 私密备忘录 - 安装说明

## 项目简介

私密备忘录是一款超高安全性的个人信息管理应用，采用 Flutter 开发，支持 Android 和 iOS 平台。

## 功能特性

- 🔐 **密码本**：安全存储账号密码，支持分类和收藏
- 🎂 **纪念日**：记录重要日期，支持农历和公历，自动提醒
- 📜 **证书管理**：管理各类证书有效期，过期提醒
- 💰 **还款提醒**：记录借款还款，进度追踪
- ⏰ **有效期提醒**：食品、药品、证件等有效期管理

## 安全特性

- ✅ SQLCipher 数据库加密
- ✅ AES-256 数据加密
- ✅ 生物识别认证（指纹/面容）
- ✅ 本地存储，不上传云端
- ✅ 应用锁屏保护

## 环境要求

### 开发环境

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android SDK (API 21+)
- Xcode 14+ (iOS)

### 运行环境

- Android 5.0+ (API 21+)
- iOS 12.0+

## 安装步骤

### 1. 克隆项目

```bash
cd private_memo_app
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 运行应用

#### Android

```bash
# 连接设备或启动模拟器
flutter devices

# 运行应用
flutter run
```

#### iOS

```bash
# 确保已配置 Xcode
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# 运行应用
flutter run
```

## 打包发布

### Android APK

```bash
# 生成发布版 APK
flutter build apk --release

# 输出路径：build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Google Play)

```bash
# 生成 AAB 文件
flutter build appbundle --release

# 输出路径：build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
# 生成 iOS 发布包
flutter build ios --release

# 使用 Xcode 打开项目并归档
open ios/Runner.xcworkspace
```

## 项目结构

```
private_memo_app/
├── android/              # Android 平台代码
├── ios/                  # iOS 平台代码
├── lib/                  # Dart 源代码
│   ├── database/         # 数据库服务
│   │   └── database_helper.dart
│   ├── models/           # 数据模型
│   │   ├── memo_item.dart
│   │   ├── anniversary_item.dart
│   │   ├── certificate_item.dart
│   │   ├── repayment_item.dart
│   │   └── expiry_item.dart
│   ├── screens/          # 页面
│   │   ├── home_screen.dart
│   │   ├── password_screen.dart
│   │   ├── anniversary_screen.dart
│   │   ├── certificate_screen.dart
│   │   ├── repayment_screen.dart
│   │   └── expiry_screen.dart
│   └── main.dart         # 应用入口
├── assets/               # 静态资源
│   ├── images/
│   ├── icons/
│   └── fonts/
├── pubspec.yaml          # 项目配置
└── README.md             # 项目说明
```

## 依赖说明

主要依赖包：

| 包名 | 版本 | 用途 |
|------|------|------|
| sqflite_sqlcipher | ^2.1.0 | 加密数据库 |
| flutter_secure_storage | ^9.0.0 | 安全存储 |
| local_auth | ^2.1.8 | 生物识别 |
| flutter_local_notifications | ^16.3.0 | 本地通知 |
| image_picker | ^1.0.7 | 图片选择 |
| google_mlkit_text_recognition | ^0.11.0 | OCR 识别 |
| intl | ^0.18.1 | 国际化 |
| lunar | ^1.0.0 | 农历计算 |

## 配置说明

### Android 配置

在 `android/app/build.gradle` 中配置：

```gradle
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
    
    signingConfigs {
        release {
            keyAlias 'your_key_alias'
            keyPassword 'your_key_password'
            storeFile file('your_keystore.jks')
            storePassword 'your_store_password'
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### iOS 配置

在 `ios/Runner/Info.plist` 中添加权限：

```xml
<key>NSFaceIDUsageDescription</key>
<string>需要使用面容识别来保护您的数据</string>
<key>NSCameraUsageDescription</key>
<string>需要使用相机来拍摄证书照片</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册来选择图片</string>
```

## 常见问题

### 1. 数据库初始化失败

确保设备有足够的存储空间，并且应用有存储权限。

### 2. 生物识别不可用

检查设备是否支持指纹/面容识别，并在系统设置中已录入生物信息。

### 3. 通知不显示

Android 需要开启通知权限，iOS 需要在设置中允许通知。

### 4. 图片选择失败

检查应用是否有相机和存储权限。

## 更新日志

### v1.0.0 (2026-03-22)

- ✨ 初始版本发布
- 🔐 密码本功能
- 🎂 纪念日管理
- 📜 证书管理
- 💰 还款提醒
- ⏰ 有效期提醒
- 🔒 数据库加密
- 👆 生物识别认证

## 技术支持

如有问题，请联系开发团队。

## 许可证

本项目采用 MIT 许可证。