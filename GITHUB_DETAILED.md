# 🚀 超详细：GitHub Actions 获取 APK 完整步骤

## 📋 准备工作（5 分钟）

### 1. 安装 Git
1. 访问：https://git-scm.com/download/win
2. 下载 Git for Windows
3. 一路点击"下一步"（全部使用默认设置即可）
4. 安装完成后重启电脑

### 2. 确认 Git 已安装
打开命令提示符（CMD），输入：
```bash
git --version
```
如果显示版本号，说明安装成功。

### 3. 配置 Git 用户信息（如果还没配置）
```bash
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
```

---

## 📂 推送代码到 GitHub（5 分钟）

### 步骤 1：进入项目目录
```bash
cd C:\Users\Administrator\.openclaw\workspace-coding_bot\private_memo_app
```

### 步骤 2：初始化 Git 仓库
```bash
git init
```

### 步骤 3：添加所有文件
```bash
git add .
```

### 步骤 4：提交文件
```bash
git commit -m "Initial commit: Private Memo App v1.0.0"
```

### 步骤 5：创建 GitHub 仓库
1. 打开浏览器，访问：https://github.com/new
2. 填写：
   - Repository name: `private-memo-app`
   - Description: `Private Memo App - 密码本、纪念日、证书管理`
   - 选择：Public（公开）
3. 点击 "Create repository"

### 步骤 6：推送代码
```bash
# 替换 YOUR_USERNAME 为你的 GitHub 用户名
git remote add origin https://github.com/YOUR_USERNAME/private-memo-app.git
git branch -M main
git push -u origin main
```

**第一次推送时会要求输入：**
- GitHub 用户名
- GitHub 密码（不是账号密码！）

---

## 🏗️ GitHub Actions 自动构建（2-3 分钟）

### 步骤 1：等待自动触发
推送代码后，GitHub 会自动触发 Actions 构建。

### 步骤 2：查看构建进度
1. 打开浏览器，访问：https://github.com/YOUR_USERNAME/private-memo-app
2. 点击 "Actions" 标签
3. 点击第一个工作流运行（应该显示绿色圆点）

### 步骤 3：等待构建完成
- 构建 = 编译 APK
- 时间：2-3 分钟
- 状态：
  - 🟡 黄色圆点 = 正在构建
  - 🟢 绿色圆点 = 构建成功

---

## 📥 下载 APK（1 分钟）

### 步骤 1：获取 APK
构建成功后：

**方法 A：从 Releases 下载**
1. 在仓库页面，点击 "Releases"
2. 找到 "v1.0.0"
3. 下载 `app-release.apk`

**方法 B：从 Actions 下载**
1. 在 Actions 页面，点击工作流运行
2. 点击 "Artifacts"
3. 下载 `release-apk`

---

## 📱 安装到手机

### 步骤 1：传输 APK
将下载的 APK 文件传输到手机：
- 通过微信/QQ 发送给自己
- 通过 USB 传输
- 通过云盘

### 步骤 2：安装
1. 打开 APK 文件
2. 如果提示"未知来源"，允许安装
3. 点击"安装"
4. 等待安装完成

### 步骤 3：首次使用
1. 打开应用
2. 设置主密码
3. 启用生物识别（指纹/面容）
4. 开始使用

---

## ⚠️ 常见问题解决

### 问题 1：git: 'init' 不是内部或外部命令
**解决：** Git 未正确安装或未添加到 PATH
- 重新安装 Git
- 重启电脑
- 检查环境变量

### 问题 2：git: 'remote' 不是内部或外部命令
**解决：** git init 未执行
- 先运行：`git init`
- 再运行：`git remote add origin ...`

### 问题 3：推送时需要输入密码
**解决：**
- 使用 GitHub 密码，不是账号密码
- 如果忘记了，在 GitHub 设置中重置
- 或使用 Personal Access Token

### 问题 4：GitHub Actions 构建失败
**可能原因：**
1. 代码未正确推送
   - 检查：https://github.com/YOUR_USERNAME/private-memo-app
2. pubspec.yaml 配置错误
   - 检查代码是否完整
3. 网络问题
   - 检查网络连接

### 问题 5：APK 安装失败
**可能原因：**
1. 未开启"未知来源"安装
   - 设置 → 安全 → 允许安装未知来源应用
2. Android 版本过低
   - 需要 Android 5.0 (Lollipop) 或更高
3. APK 文件损坏
   - 重新下载

---

## 💡 小技巧

### 提高下载速度
- 使用手机热点
- 避免高峰期下载

### 加快构建速度
- 等待网络稳定时推送
- 确保代码无错误

### 备份 APK
- 下载后保存到云盘
- 避免重复下载

---

## 📊 总耗时估算

| 步骤 | 预计时间 |
|------|----------|
| 安装 Git | 5 分钟 |
| 配置 Git | 1 分钟 |
| 推送代码 | 5 分钟 |
| GitHub Actions 构建 | 2-3 分钟 |
| 下载 APK | 1 分钟 |
| 安装到手机 | 1 分钟 |
| **总计** | **15-16 分钟** |

---

## ✅ 检查清单

- [ ] Git 已安装并配置
- [ ] 代码已推送到 GitHub
- [ ] Actions 构建成功
- [ ] APK 已下载
- [ ] APK 已安装到手机

---

**准备好了吗？开始吧！** 🎉