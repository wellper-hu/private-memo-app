# 快速部署指南 - 获取 APK

## 方案一：GitHub Actions 自动构建（推荐）

### 步骤 1：安装 Git
1. 访问 https://git-scm.com/download/win
2. 下载并安装 Git

### 步骤 2：初始化仓库
```bash
# Windows 双击运行
init-github.bat

# 或命令行
cd private_memo_app
git init
git add .
git commit -m "Initial commit"
```

### 步骤 3：创建 GitHub 仓库
1. 访问 https://github.com/new
2. 输入仓库名：`private-memo-app`
3. 选择 Public（公开）
4. 点击 "Create repository"

### 步骤 4：推送代码
```bash
# 替换 YOUR_USERNAME 为你的 GitHub 用户名
git remote add origin https://github.com/YOUR_USERNAME/private-memo-app.git
git branch -M main
git push -u origin main
```

### 步骤 5：获取 APK
1. 等待 2-3 分钟（GitHub Actions 自动构建）
2. 访问仓库页面 → Actions 标签
3. 等待构建完成（绿色 ✓）
4. 访问 Releases 页面
5. 下载 `app-release.apk`

---

## 方案二：本地构建（需要 Flutter）

### 步骤 1：安装 Flutter
1. 访问 https://flutter.dev/docs/get-started/install/windows
2. 下载 Flutter SDK
3. 解压到 `C:\src\flutter`
4. 添加到 PATH：`C:\src\flutter\bin`

### 步骤 2：安装 Android Studio
1. 下载 Android Studio
2. 安装 Android SDK
3. 配置环境变量

### 步骤 3：构建 APK
```bash
cd private_memo_app
flutter pub get
flutter build apk --release
```

### 步骤 4：获取 APK
APK 位置：`build/app/outputs/flutter-apk/app-release.apk`

---

## 方案三：使用在线构建服务

### Codemagic（推荐）
1. 访问 https://codemagic.io
2. 使用 GitHub 账号登录
3. 导入仓库
4. 点击 "Start build"
5. 下载生成的 APK

### Appcircle
1. 访问 https://appcircle.io
2. 注册账号
3. 连接 GitHub 仓库
4. 配置构建
5. 下载 APK

---

## 安装 APK

### Android 手机安装步骤
1. 将 APK 文件传输到手机
2. 打开文件管理器，找到 APK
3. 点击安装
4. 如果提示"未知来源"，请允许安装
5. 完成安装

### 首次使用
1. 打开应用
2. 设置主密码
3. 启用生物识别（可选）
4. 开始使用

---

## 常见问题

### Q: GitHub Actions 构建失败？
A: 检查以下几点：
- pubspec.yaml 是否正确
- 依赖版本是否兼容
- GitHub Secrets 是否配置

### Q: APK 安装失败？
A: 可能原因：
- 未开启"未知来源"安装
- APK 签名问题
- Android 版本不兼容

### Q: 如何更新应用？
A: 重新构建 APK 并安装，数据会自动保留。

---

## 需要帮助？

如有问题，请查看：
- README.md - 详细安装说明
- BUILD_GUIDE.md - 打包指南
- GitHub Issues - 问题反馈

---

**推荐方案**：使用 GitHub Actions，最简单快捷！