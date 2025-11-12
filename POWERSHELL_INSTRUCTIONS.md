# PowerShell Instructions for Running Nestify

## 🎯 You're Using PowerShell - Here's What To Do:

### ✅ EASIEST METHOD (One Command):

Run this in your PowerShell terminal:

```powershell
.\fix_and_run.ps1
```

**Then after it completes:**

```powershell
flutter run -d chrome
```

---

## 📋 MANUAL METHOD (If you prefer step-by-step):

Copy and paste these commands **one at a time** in PowerShell:

### Step 1: Clean the project
```powershell
flutter clean
```

### Step 2: Remove lock file
```powershell
Remove-Item pubspec.lock -Force
```

### Step 3: Get fresh dependencies
```powershell
flutter pub get
```

### Step 4: Upgrade all packages
```powershell
flutter pub upgrade
```

### Step 5: Clean Android builds (optional but recommended)
```powershell
Remove-Item android\.gradle -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item android\build -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item android\app\build -Recurse -Force -ErrorAction SilentlyContinue
```

### Step 6: Get packages again
```powershell
flutter pub get
```

### Step 7: Run your app!
```powershell
flutter run -d chrome
```

---

## ⚠️ If You Get "Execution Policy" Error:

If you see an error about "execution of scripts is disabled", run this first:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then try running `.\fix_and_run.ps1` again.

---

## 🔧 Quick Commands Reference:

```powershell
# Run the fix script
.\fix_and_run.ps1

# Run on Chrome (easiest for testing)
flutter run -d chrome

# Run on Windows Desktop
flutter run -d windows

# Run on Android (with emulator/device)
flutter run

# See available devices
flutter devices

# Check Flutter installation
flutter doctor
```

---

## 💡 PowerShell vs CMD Differences:

| Action | PowerShell | CMD |
|--------|-----------|-----|
| Run script | `.\fix_and_run.ps1` | `fix_and_run.bat` |
| Delete file | `Remove-Item file` | `del file` |
| Delete folder | `Remove-Item -Recurse folder` | `rmdir /s folder` |

---

## 🚀 What's Next:

1. ✅ Run `.\fix_and_run.ps1` (or the manual commands)
2. ✅ Wait for packages to download
3. ✅ Run `flutter run -d chrome`
4. ✅ Test your app!

---

## 📁 Available Script Files:

- **fix_and_run.ps1** ← Use this for PowerShell
- **fix_and_run.bat** ← Use this for CMD
- Both do the same thing, just different syntax!

---

**You're all set! Just run `.\fix_and_run.ps1` in your PowerShell terminal.** 🎉

