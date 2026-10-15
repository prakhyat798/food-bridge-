@echo off
title Launch FoodBridge Android Emulator
echo ===================================================
echo   FoodBridge - Android Emulator Launcher
echo ===================================================
echo.
echo [1/3] Launching Android Phone Window...
start "" "C:\Users\prakhyat\AppData\Local\Android\Sdk\emulator\emulator.exe" -avd "Medium_Phone_API_37.0"

echo [2/3] Waiting for emulator to connect...
"C:\Users\prakhyat\AppData\Local\Android\Sdk\platform-tools\adb.exe" wait-for-device

echo [3/3] Launching FoodBridge App...
timeout /t 3 >nul
"C:\Users\prakhyat\AppData\Local\Android\Sdk\platform-tools\adb.exe" shell monkey -p com.example.foodbridge -c android.intent.category.LAUNCHER 1

echo.
echo ===================================================
echo   SUCCESS! FoodBridge is now open on your screen!
echo ===================================================
timeout /t 5
