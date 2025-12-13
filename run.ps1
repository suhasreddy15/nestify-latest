# Nestify - Quick Run Script
# Run this script to clean and start the app

Write-Host "🏠 Nestify PG Management App" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

$action = Read-Host "Choose action: [1] Clean & Run, [2] Just Run (default: 2)"

if ($action -eq "1") {
    Write-Host "🧹 Cleaning project..." -ForegroundColor Yellow
    flutter clean
    flutter pub get
    Write-Host "✅ Clean complete!" -ForegroundColor Green
    Write-Host ""
}

Write-Host "🚀 Starting app..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Available devices:" -ForegroundColor Cyan
flutter devices

Write-Host ""
$device = Read-Host "Enter device (chrome/windows/android) [default: chrome]"

if ($device -eq "") { $device = "chrome" }

Write-Host ""
Write-Host "▶️  Running on $device..." -ForegroundColor Green
flutter run -d $device
