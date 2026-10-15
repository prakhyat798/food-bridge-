@echo off
set "PATH=%LOCALAPPDATA%\Microsoft\WinGet\Packages\OpenJS.NodeJS.LTS_Microsoft.Winget.Source_8wekyb3d8bbwe\node-v24.20.0-win-x64;%PATH%"
cd /d "%~dp0website"
echo ==============================================
echo    FoodBridge - Deploy Website to Vercel
echo ==============================================
echo.
echo Deploying static website to production...
echo.
call vercel deploy --prod --yes
echo.
echo ==============================================
echo Deployment completed!
echo ==============================================
pause
