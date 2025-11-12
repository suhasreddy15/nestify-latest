# How to Run Nestify Flutter Project

## Quick Start - Follow These Steps:

### Step 1: Open Terminal in Your IDE
- Press `Alt + F12` or go to **View → Tool Windows → Terminal**
- Make sure you're in the `D:\Nestify` directory

### Step 2: Install Flutter Dependencies
```cmd
flutter pub get
```
This will download all required packages (Firebase, Flutter SDK, etc.)

### Step 3: Check Available Devices
```cmd
flutter devices
```
You should see available devices like:
- Chrome (web)
- Windows (windows)
- Android emulator (if running)
- Connected Android device (if plugged in)

### Step 4: Run the Project

**Option A - Run on Chrome (Easiest for testing):**
```cmd
flutter run -d chrome
```

**Option B - Run on Windows Desktop:**
```cmd
flutter run -d windows
```

**Option C - Run on Android:**
Make sure Android emulator is running or device is connected, then:
```cmd
flutter run -d <your-android-device-id>
```

**Option D - Let Flutter choose the device:**
```cmd
flutter run
```

### Step 5: Alternative - Use IDE Run Button
1. Click the **Run** icon (green play button) in the toolbar
2. Or press **Shift + F10**
3. Select your device from the dropdown if prompted

---

## Troubleshooting

### If you get dependency errors:
```cmd
flutter clean
flutter pub get
```

### If Flutter command is not found:
1. Make sure Flutter SDK is installed
2. Check with: `flutter doctor`
3. If not installed, visit: https://docs.flutter.dev/get-started/install

### If Firebase errors occur:
- Ensure `firebase_options.dart` is properly configured
- Check that `google-services.json` exists in `android/app/`
- Run `flutterfire configure` if needed

### Common Issues:
- **"No devices found"**: Start an emulator or connect a device
- **Build fails**: Try `flutter clean` then `flutter pub get`
- **Hot reload not working**: Press `r` in terminal or `R` for hot restart

---

## Your App Features:

Once running, your Nestify app includes:
- 🔐 **Authentication** (Student/Owner login)
- 👥 **Community Chat**
- 📝 **Complaint Management**
- 🍽️ **Dinner Voting System**
- 🧺 **Washing Machine Booking**
- 👤 **Student Profile Management**
- 💳 **Payment Management & History**

### Default Routes:
- Welcome Screen (if not logged in)
- Student Dashboard (for students)
- Owner Dashboard (for owners)

---

## Quick Commands Reference:

```cmd
# Get dependencies
flutter pub get

# Clean build
flutter clean

# Check Flutter installation
flutter doctor

# List devices
flutter devices

# Run app
flutter run

# Run on specific device
flutter run -d chrome
flutter run -d windows
flutter run -d <device-id>

# Build release APK (Android)
flutter build apk --release

# Build Windows executable
flutter build windows --release
```

---

## Next Steps After Running:

1. **Test Authentication**: Try logging in as both student and owner
2. **Test Firebase**: Check if data is syncing correctly
3. **Test Features**: Navigate through all screens to verify functionality
4. **Check Console**: Monitor for any errors or warnings

**Need help?** Check the other documentation files:
- `TROUBLESHOOTING.md`
- `IMPLEMENTATION_SUMMARY.md`
- Feature-specific docs (CHAT_QUICKSTART.md, etc.)

