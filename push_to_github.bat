@echo off
setlocal
echo =======================================================
echo          FoodBridge - Push to GitHub
echo =======================================================
echo.

:: Add MinGit to PATH for this session
set "PATH=C:\src\flutter\bin\mingit\cmd;C:\src\flutter\bin\mingit\mingw64\libexec\git-core;%PATH%"

cd /d "%~dp0"

echo Current Git Remote:
git remote -v
echo.
echo Current Git Branch:
git branch --show-current
echo.

echo Make sure you have created the empty repository on GitHub:
echo   https://github.com/new  (Repository name: foodbridge)
echo.
echo Pushing project and installable APK to origin main...
echo.

git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo =======================================================
    echo    SUCCESS! FoodBridge has been pushed to GitHub!
    echo    View your repo at: https://github.com/prakhyat798/foodbridge
    echo =======================================================
) else (
    echo.
    echo =======================================================
    echo    Push failed or requires authentication.
    echo    If you need to create the repo first, go to:
    echo      https://github.com/new
    echo    and name it 'foodbridge' (leave it empty).
    echo =======================================================
)

echo.
pause
