# 私密备忘录 - 项目总览

## 📱 应用名称
**私密备忘录** (Private Memo)

## 🎯 核心功能

### 1. 密码本 🔐
- 安全存储账号密码
- 支持分类和收藏
- 一键复制账号密码
- 密码显示/隐藏切换
- 本地加密存储

### 2. 纪念日 🎂
- 记录重要日期
- 支持公历和农历
- 自动计算距离天数
- 到期提醒
- 重复纪念日

### 3. 证书管理 📜
- 管理各类证书
- 过期检测
- 存放位置记录
- 到期提醒

### 4. 还款提醒 💰
- 记录借款还款
- 进度追踪
- 逾期提醒
- 金额统计
- 还款方式记录

### 5. 有效期提醒 ⏰
- 食品、药品、证件等
- 分类管理
- 多类型支持
- 提前提醒

## 🔒 安全特性

- **数据库加密**：SQLCipher AES-256 加密
- **数据加密**：AES-256 算法
- **生物识别**：指纹/面容识别认证
- **本地存储**：不上传云端
- **应用锁屏**：防止误触

## 📁 项目结构

```
private_memo_app/
├── android/              # Android 平台配置
├── ios/                  # iOS 平台配置
├── lib/
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
│   ├── services/         # 业务服务
│   │   ├── auth_service.dart
│   │   └── encryption_service.dart
│   └── main.dart         # 应用入口
├── pubspec.yaml          # 项目配置
├── README.md             # 安装说明
├── BUILD_GUIDE.md        # 打包指南
├── run.bat               # Windows 启动脚本
└── run.sh                # Linux/Mac 启动脚本
```

## 🚀 快速开始

### Windows
```bash
# 双击运行
run.bat

# 或命令行
cd private_memo_app
flutter pub get
flutter run
```

### Linux/Mac
```bash
# 添加执行权限
chmod +x run.sh

# 运行
./run.sh

# 或命令行
cd private_memo_app
flutter pub get
flutter run
```

## 📦 打包发布

### Android APK
```bash
flutter build apk --release
```
输出：`build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle
```bash
flutter build appbundle --release
```
输出：`build/app/outputs/bundle/release/app-release.aab`

### iOS
```bash
flutter build ios --release
```

## 🔧 技术栈

- **框架**：Flutter 3.0+
- **语言**：Dart
- **数据库**：SQLCipher（加密 SQLite）
- **加密**：AES-256
- **存储**：flutter_secure_storage
- **认证**：local_auth（生物识别）
- **通知**：flutter_local_notifications
- **UI**：Material 3

## 📋 依赖包

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
| equatable | ^2.0.5 | 对象比较 |

## 🎨 界面特性

- Material 3 设计语言
- 暗色模式支持
- 响应式布局
- 流畅动画
- 直观的交互

## 📊 数据库设计

### 密码本表
```sql
CREATE TABLE passwords (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  username TEXT NOT NULL,
  password TEXT NOT NULL,
  url TEXT,
  category TEXT,
  notes TEXT,
  isFavorite INTEGER DEFAULT 0,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL
)
```

### 纪念日表
```sql
CREATE TABLE anniversaries (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  date TEXT NOT NULL,
  repeatDays INTEGER DEFAULT 365,
  notes TEXT,
  isReminderEnabled INTEGER DEFAULT 1,
  lastReminderDate TEXT,
  reminderOffsetDays INTEGER
)
```

### 其他表结构类似，支持加密存储

## 📝 开发计划

### v1.0.0 (已完成)
- ✅ 密码本
- ✅ 纪念日
- ✅ 证书管理
- ✅ 还款提醒
- ✅ 有效期提醒
- ✅ 数据库加密
- ✅ 生物识别认证

### v1.1.0 (计划中)
- 📋 OCR 识别密码
- 📋 云同步（可选）
- 📋 备份恢复
- 📋 数据导出
- 📋 深色模式优化

### v1.2.0 (计划中)
- 📋 Widget 小部件
- 📋 桌面端支持
- 📋 智能提醒
- 📋 搜索功能增强

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 📧 联系方式

如有问题，请联系开发团队。

---

**版本**: 1.0.0
**更新时间**: 2026-03-22
**开发状态**: 已完成 ✅