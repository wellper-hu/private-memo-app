@echo off
chcp 65001 >nul
echo ====================================
echo    私密备忘录 - 快速启动
echo ====================================
echo.

:: 检查 Flutter 是否安装
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到 Flutter，请先安装 Flutter SDK
    echo 下载地址: https://flutter.dev/docs/get-started/install/windows
    pause
    exit /b 1
)

:: 进入项目目录
cd /d "%~dp0"

:: 安装依赖
echo [1/3] 安装依赖包...
flutter pub get
if %errorlevel% neq 0 (
    echo [错误] 依赖安装失败
    pause
    exit /b 1
)

:: 运行应用
echo.
echo [2/3] 启动应用...
echo.
flutter run

pause
