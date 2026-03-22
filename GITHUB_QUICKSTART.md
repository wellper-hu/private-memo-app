# 🚀 超简单：3 分钟获取 APK

## 步骤 1：安装 Git（5 分钟）
1. 访问：https://git-scm.com/download/win
2. 下载并安装
3. 一路点击"下一步"

## 步骤 2：初始化仓库（2 分钟）
```bash
# 进入项目目录
cd C:\Users\Administrator\.openclaw\workspace-coding_bot\private_memo_app

# 运行初始化脚本
init-github.bat
```

按提示：
- 输入你的 GitHub 用户名
- 输入你的邮箱
- 输入密码

## 步骤 3：推送代码（1 分钟）
```bash
# 替换 YOUR_USERNAME 为你的 GitHub 用户名
git remote add origin https://github.com/YOUR_USERNAME/private-memo-app.git
git branch -M main
git push -u origin main
```

## 步骤 4：获取 APK（2-3 分钟）
1. 打开浏览器访问：https://github.com/YOUR_USERNAME/private-memo-app
2. 等待 2-3 分钟
3. 在 "Actions" 标签页查看构建进度
4. 构建完成后，在 "Releases" 页面下载 APK

---

## 📱 安装到手机
1. 将 APK 文件传输到手机
2. 打开 APK 文件
3. 点击"安装"
4. 完成安装

---

## ⚠️ 常见问题

### Q: Git 提示需要配置用户名和邮箱？
A: 运行以下命令配置：
```bash
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
```

### Q: 推送代码时需要输入密码？
A: 使用你的 GitHub 密码，不是账号密码。如果忘记了，在 GitHub 设置中重置。

### Q: Actions 构建失败？
A: 检查：
- 代码是否正确推送到 GitHub
- GitHub Actions 是否有权限访问仓库

### Q: APK 下载后无法安装？
A: 可能原因：
- 未开启"未知来源"安装
- Android 版本过低（需要 Android 5.0+）

---

## 💡 小提示
- 下载速度慢？可以使用手机热点
- 构建需要 2-3 分钟
- APK 大约 10-20MB
- 数据会自动保留，不需要担心

---

**总耗时：约 10-15 分钟**

准备好了吗？开始吧！🎉