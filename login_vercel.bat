@echo off
set "PATH=%LOCALAPPDATA%\Microsoft\WinGet\Packages\OpenJS.NodeJS.LTS_Microsoft.Winget.Source_8wekyb3d8bbwe\node-v24.20.0-win-x64;%PATH%"
echo ==============================================
echo       Vercel CLI - Interactive Login
echo ==============================================
echo.
echo Please select your provider (GitHub, GitLab, Email, etc.)
echo.
call vercel login
echo.
pause
