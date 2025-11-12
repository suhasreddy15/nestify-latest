# Flutter v1 Embedding Fix Script (PowerShell)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Fixing Flutter v1 Embedding Issues" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Cleaning Flutter project..." -ForegroundColor Yellow
flutter clean

Write-Host ""
Write-Host "Step 2: Removing pubspec.lock..." -ForegroundColor Yellow
if (Test-Path "pubspec.lock") {
    Remove-Item "pubspec.lock" -Force
    Write-Host "Removed pubspec.lock" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 3: Getting latest Flutter packages..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "Step 4: Upgrading all dependencies..." -ForegroundColor Yellow
flutter pub upgrade

Write-Host ""
Write-Host "Step 5: Cleaning Android build..." -ForegroundColor Yellow
if (Test-Path "android\.gradle") {
    Remove-Item "android\.gradle" -Recurse -Force
    Write-Host "Removed .gradle folder" -ForegroundColor Green
}
if (Test-Path "android\build") {
    Remove-Item "android\build" -Recurse -Force
    Write-Host "Removed android/build folder" -ForegroundColor Green
}
if (Test-Path "android\app\build") {
    Remove-Item "android\app\build" -Recurse -Force
    Write-Host "Removed android/app/build folder" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 6: Getting packages again..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Fix Complete! Now you can run:" -ForegroundColor Green
Write-Host "  flutter run -d chrome" -ForegroundColor White
Write-Host "  OR" -ForegroundColor White
Write-Host "  flutter run -d windows" -ForegroundColor White
Write-Host "  OR" -ForegroundColor White
Write-Host "  flutter run" -ForegroundColor White -NoNewline
Write-Host " (for Android)" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

