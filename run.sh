#!/bin/bash

echo "===================================="
echo "   私密备忘录 - 快速启动"
echo "===================================="
echo ""

# 检查 Flutter 是否安装
if ! command -v flutter &> /dev/null; then
    echo "[错误] 未找到 Flutter，请先安装 Flutter SDK"
    echo "下载地址: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# 进入项目目录
cd "$(dirname "$0")"

# 安装依赖
echo "[1/3] 安装依赖包..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "[错误] 依赖安装失败"
    exit 1
fi

# 运行应用
echo ""
echo "[2/3] 启动应用..."
echo ""
flutter run
