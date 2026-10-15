$ErrorActionPreference = 'Stop'

Write-Host "Setting up Flutter..."
$flutterDir = "C:\src\flutter"
$flutterZip = "C:\src\flutter.zip"

if (-not (Test-Path "$flutterDir\bin\flutter.bat")) {
    if (-not (Test-Path $flutterZip)) {
        Write-Host "Downloading Flutter SDK..."
        curl.exe -L -C - -o $flutterZip "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.47.5-stable.zip"
    }
    Write-Host "Extracting Flutter SDK using tar..."
    tar.exe -xf $flutterZip -C "C:\src"
}

$flutterBin = "$flutterDir\bin\flutter.bat"
$dartBin = "$flutterDir\bin\dart.bat"

# Set environment paths for this session
$env:PATH = "$flutterDir\bin;$env:PATH"

Write-Host "Running flutter create to generate Android files..."
& $flutterBin create .

Write-Host "Resolving dependencies..."
& $flutterBin pub get

Write-Host "Building APK... This will take a few minutes."
& $flutterBin build apk --release

if (Test-Path "build\app\outputs\flutter-apk\app-release.apk") {
    Write-Host "Copying APK to Desktop..."
    Copy-Item -Path "build\app\outputs\flutter-apk\app-release.apk" -Destination "c:\Users\prakhyat\Desktop\FoodBridge.apk" -Force
    Write-Host "APK successfully built and saved to Desktop!"
} else {
    Write-Host "APK build failed. Check the logs above."
}
