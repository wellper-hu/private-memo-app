#!/bin/bash

echo "===================================="
echo "   GitHub 仓库初始化脚本"
echo "===================================="
echo ""

# 检查 git 是否安装
if ! command -v git &> /dev/null; then
    echo "[错误] 未安装 Git，请先安装 Git"
    echo "下载地址: https://git-scm.com/download/win"
    exit 1
fi

# 配置 Git（请修改为你的信息）
echo "[1/5] 配置 Git..."
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 初始化仓库
echo "[2/5] 初始化 Git 仓库..."
git init

# 添加所有文件
echo "[3/5] 添加文件到仓库..."
git add .

# 提交
echo "[4/5] 提交更改..."
git commit -m "Initial commit: Private Memo App v1.0.0"

# 添加远程仓库（请替换为你的仓库地址）
echo "[5/5] 添加远程仓库..."
echo ""
echo "请在 GitHub 上创建新仓库，然后运行："
echo ""
echo "  git remote add origin https://github.com/YOUR_USERNAME/private-memo-app.git"
echo "  git branch -M main"
echo "  git push -u origin main"
echo ""
echo "或者使用 GitHub CLI："
echo ""
echo "  gh repo create private-memo-app --public --source=. --remote=origin --push"
echo ""

echo "===================================="
echo "   初始化完成！"
echo "===================================="
echo ""
echo "下一步："
echo "1. 在 GitHub 创建仓库"
echo "2. 推送代码到 GitHub"
echo "3. GitHub Actions 会自动构建 APK"
echo "4. 在 Releases 页面下载 APK"
echo ""
