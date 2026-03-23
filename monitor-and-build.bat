@echo off
chcp 65001 >nul
echo ========================================
echo Private Memo App - 自动监控与打包
echo ========================================
echo.
echo 当前状态：Flutter SDK 下载中 (13.4%% 已完成)
echo 预计剩余时间：约 26 分钟
echo.
echo 脚本将定期检查下载进度，完成后自动打包 APK
echo.
echo 按任意键开始监控...
pause >nul
echo.
echo 开始监控...
echo.

:check
call "C:\src\flutter\bin\flutter.bat" doctor -v >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Flutter SDK 已下载完成！
    echo.
    echo 开始打包 APK...
    call "C:\src\flutter\bin\flutter.bat" clean
    call "C:\src\flutter\bin\flutter.bat" pub get
    call "C:\src\flutter\bin\flutter.bat" build apk --release
    echo.
    echo ========================================
    echo 打包完成！
    echo ========================================
    echo.
    echo APK 文件位置：
    echo %~dp0\build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo 文件大小：
    dir "%~dp0\build\app\outputs\flutter-apk\app-release.apk" | findstr "app-release.apk"
    echo.
    pause
    exit /b 0
)

echo [INFO] Flutter SDK 仍在下载中...
timeout /t 60 /nobreak >nul
goto check
