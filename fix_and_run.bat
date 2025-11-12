@echo off
echo ========================================
echo Fixing Flutter v1 Embedding Issues
echo ========================================
echo.

echo Step 1: Cleaning Flutter project...
call flutter clean

echo.
echo Step 2: Removing pubspec.lock...
if exist pubspec.lock del pubspec.lock

echo.
echo Step 3: Getting latest Flutter packages...
call flutter pub get

echo.
echo Step 4: Upgrading all dependencies...
call flutter pub upgrade

echo.
echo Step 5: Cleaning Android build...
cd android
if exist .gradle rmdir /s /q .gradle
if exist build rmdir /s /q build
if exist app\build rmdir /s /q app\build
cd ..

echo.
echo Step 6: Getting packages again...
call flutter pub get

echo.
echo ========================================
echo Fix Complete! Now you can run:
echo   flutter run -d chrome
echo   OR
echo   flutter run -d windows
echo   OR
echo   flutter run (for Android)
echo ========================================
pause

