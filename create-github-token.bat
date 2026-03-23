@echo off
echo ========================================
echo GitHub Token 创建脚本
echo ========================================
echo.
echo 请按照以下步骤操作：
echo.
echo 1. 打开浏览器，访问：https://github.com/settings/tokens/new
echo 2. 填写：
echo    - Note: private-memo-app
echo    - Expiration: No expiration
echo    - Select scopes: 勾选 "repo"（完整仓库访问权限）
echo 3. 点击 "Generate token"
echo 4. 复制生成的 Token（格式类似：ghp_xxxxxxxxxxxx）
echo 5. 把 Token 发给小编
echo.
echo 然后小编会用这个 Token 创建仓库并推送代码。
echo.
pause
