@echo off
setlocal
echo =======================================================
echo          FoodBridge - Push to GitHub
echo =======================================================
echo.

:: Add MinGit to PATH for this session
set "PATH=C:\src\flutter\bin\mingit\cmd;C:\src\flutter\bin\mingit\mingw64\libexec\git-core;%PATH%"

cd /d "%~dp0"

echo Target Repository:
echo   https://github.com/prakhyat798/food-bridge-.git
echo.
echo Current Git Branch:
git branch --show-current
echo.

echo Pushing project and installable APK to origin main...
echo.

git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo =======================================================
    echo    SUCCESS! FoodBridge has been pushed to GitHub!
    echo    View your repo at:
    echo      https://github.com/prakhyat798/food-bridge-
    echo =======================================================
) else (
    echo.
    echo =======================================================
    echo    Push failed or requires credentials.
    echo    If prompted for GitHub login, complete the sign-in
    echo    in the browser or enter your Personal Access Token.
    echo =======================================================
)

echo.
pause
