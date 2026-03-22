# 私密备忘录 - Android 打包配置

## 生成签名密钥

```bash
keytool -genkey -v -keystore private-memo-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias private-memo
```

密钥信息：
- 密钥库密码：`PrivateMemo2026!`
- 密钥别名：`private-memo`
- 密钥密码：`PrivateMemo2026!`

## 配置签名

将密钥文件放在 `android/app/private-memo-key.jks`

创建 `android/key.properties`：

```properties
storePassword=PrivateMemo2026!
keyPassword=PrivateMemo2026!
keyAlias=private-memo
storeFile=private-memo-key.jks
```

## Gradle 配置

在 `android/app/build.gradle` 中添加：

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

## ProGuard 规则

创建 `android/app/proguard-rules.pro`：

```proguard
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# SQLCipher
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }

# Encryption
-keep class com.pointyspoon.** { *; }

# Local Auth
-keep class androidx.biometric.** { *; }

# Notifications
-keep class com.dexterous.** { *; }
```

## 构建命令

### 调试版本

```bash
flutter build apk --debug
```

### 发布版本

```bash
flutter build apk --release
```

### App Bundle (Google Play)

```bash
flutter build appbundle --release
```

## 输出文件

- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## 应用信息

- 应用名称：私密备忘录
- 包名：com.example.private_memo
- 版本号：1.0.0
- 版本代码：1
- 最低 SDK：21 (Android 5.0)
- 目标 SDK：34 (Android 14)