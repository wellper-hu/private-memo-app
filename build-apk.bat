@echo off
echo ========================================
echo Private Memo App - APK 打包脚本
echo ========================================
echo.
echo 正在初始化 Flutter 环境...
cd /d "%~dp0"
call "C:\src\flutter\bin\flutter.bat" doctor
echo.
echo 正在获取依赖...
call "C:\src\flutter\bin\flutter.bat" pub get
echo.
echo 正在清理构建...
call "C:\src\flutter\bin\flutter.bat" clean
echo.
echo 正在构建 APK (Release 模式)...
call "C:\src\flutter\bin\flutter.bat" build apk --release
echo.
echo ========================================
echo 构建完成！
echo ========================================
echo.
echo APK 文件位置：
echo %~dp0\build\app\outputs\flutter-apk\app-release.apk
echo.
pause
