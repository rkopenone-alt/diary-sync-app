$ErrorActionPreference = "Stop"

$flutter = "C:\Users\flutter\bin\flutter.bat"
if (-Not (Test-Path $flutter)) {
    Write-Error "Flutter compiler not found at $flutter"
    exit 1
}

Write-Host "Enabling Windows Desktop support..."
& $flutter config --enable-windows-desktop

Write-Host "Generating native Android and Windows project files..."
if (Test-Path "temp_flutter") { Remove-Item "temp_flutter" -Recurse -Force }
& $flutter create --platforms=android,windows temp_flutter

Write-Host "Integrating platform folders..."
Copy-Item "temp_flutter\android", "temp_flutter\windows" ".\" -Recurse -Force
Remove-Item "temp_flutter" -Recurse -Force

Write-Host "Fetching Flutter pub dependencies..."
& $flutter pub get

Write-Host "-------------------------------------------"
Write-Host "Building Android APK..."
try {
    & $flutter build apk --release
} catch {
    Write-Host "Failed to build APK. Please check if your Android SDK is installed." -ForegroundColor Red
}

Write-Host "-------------------------------------------"
Write-Host "Building Windows EXE..."
try {
    & $flutter build windows --release
} catch {
    Write-Host "Failed to build Windows. Please check if Visual Studio C++ build tools are installed." -ForegroundColor Red
}

Write-Host "-------------------------------------------"
Write-Host "Build attempt finished! Output files are located in build/app/outputs/flutter-apk/ and build/windows/runner/Release/ if successful." -ForegroundColor Green
