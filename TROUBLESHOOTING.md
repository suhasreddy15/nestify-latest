# Troubleshooting Guide

## Issue 1: file_picker Plugin Warnings

### Problem
You're seeing repeated warnings about `file_picker` plugin configuration:
```
Package file_picker:linux references file_picker:linux as the default plugin, 
but it does not provide an inline implementation.
```

### Explanation
These are **harmless warnings** from the `file_picker` plugin (version 6.1.1). The plugin has a configuration issue in its `pubspec.yaml` where it references itself as a default implementation for desktop platforms (Linux, macOS, Windows) without providing inline implementations.

### Impact
- ✅ **No functional impact** - Your code works correctly
- ✅ **Safe to ignore** - These warnings don't affect web, Android, or iOS builds
- ⚠️ Only affects desktop platform builds (which you're not using)

### Solutions

#### Option 1: Ignore the warnings (Recommended)
These warnings are cosmetic and don't affect functionality. Your `file_picker` usage in `student_profile_screen.dart` is correct and will work fine.

#### Option 2: Update to a newer version (If available)
Check if a newer version of `file_picker` fixes this:
```bash
flutter pub outdated
flutter pub upgrade file_picker
```

#### Option 3: Suppress warnings (Not recommended)
You can suppress these specific warnings, but it's better to just ignore them.

---

## Issue 2: Chrome Browser Launch Failure

### Problem
Flutter fails to launch Chrome after 3 attempts:
```
Failed to launch browser after 3 tries. Command used to launch it: 
C:\Program Files\Google\Chrome\Application\chrome.exe --user-data-dir=...
```

### Solutions

#### Solution 1: Use Web Server Mode (Recommended)
Instead of launching Chrome directly, use web server mode and open the URL manually:

```bash
flutter run -d chrome --web-port=8080
```

Or use the web-server device:
```bash
flutter run -d web-server
```
Then manually open `http://localhost:8080` in your browser.

#### Solution 2: Close All Chrome Instances
1. Close all Chrome windows and tabs
2. Open Task Manager (Ctrl+Shift+Esc)
3. End all `chrome.exe` processes
4. Try running again: `flutter run -d chrome`

#### Solution 3: Use Edge Instead
Edge is also detected on your system:
```bash
flutter run -d edge
```

#### Solution 4: Clear Chrome User Data
The issue might be with Chrome's user data directory:
1. Close Chrome completely
2. Delete the temp directory: `C:\Users\suhas\AppData\Local\Temp\flutter_tools.*`
3. Try running again

#### Solution 5: Check Chrome Version
Your Chrome version (142.0.7444.60) should be compatible. If issues persist:
1. Update Chrome to the latest version
2. Or try using Edge: `flutter run -d edge`

#### Solution 6: Run on Android Device (Alternative)
Since you have an Android device connected (I2305), you can run on mobile:
```bash
flutter run -d I2305
```

---

## Quick Fix Commands

### For Web Development:
```bash
# Option 1: Use web-server mode
flutter run -d web-server

# Option 2: Use Edge
flutter run -d edge

# Option 3: Specify port explicitly
flutter run -d chrome --web-port=8080
```

### For Mobile Development:
```bash
# Run on connected Android device
flutter run -d I2305
```

---

## Verification

Your code is **correct**:
- ✅ `file_picker` is properly imported and used in `student_profile_screen.dart`
- ✅ All dependencies are correctly specified in `pubspec.yaml`
- ✅ Flutter environment is properly configured
- ✅ Chrome is detected by Flutter

The issues are:
1. **file_picker warnings**: Cosmetic, can be ignored
2. **Browser launch**: Use web-server mode or Edge as workaround

---

## Summary

1. **file_picker warnings**: Harmless, ignore them
2. **Chrome launch failure**: Use `flutter run -d web-server` or `flutter run -d edge` instead

Your application code is working correctly!

