# 🧪 Persistent Login - Testing Checklist

## Quick Test Guide for Developers

### ✅ **Test 1: First Login**
```
Steps:
1. Open app → Should see WelcomeScreen
2. Click "Login as Student"
3. Enter credentials → Click Login
4. Should see StudentDashboard

Expected: ✅ Successful login, shows dashboard
```

### ✅ **Test 2: App Restart (Main Test)**
```
Steps:
1. While logged in (from Test 1)
2. Close app completely (swipe away from recent apps)
3. Reopen app from launcher

Expected: ✅ Goes DIRECTLY to StudentDashboard
Expected: ✅ NO login screen shown
Expected: ✅ Profile picture loads
Expected: ✅ Notifications badge appears
```

### ✅ **Test 3: Device Restart**
```
Steps:
1. Login as student
2. Restart device (power off → power on)
3. Open app

Expected: ✅ Still logged in, shows StudentDashboard
```

### ✅ **Test 4: Logout**
```
Steps:
1. While logged in, click logout button (top-right)
2. Confirm logout in dialog
3. Should see WelcomeScreen
4. Close app
5. Reopen app

Expected: ✅ Shows WelcomeScreen (not logged in)
Expected: ✅ Must login again
```

### ✅ **Test 5: Owner Login Persistence**
```
Steps:
1. Login as owner (owner@nestify.com / password123)
2. Should see OwnerDashboard with statistics
3. Close app
4. Reopen app

Expected: ✅ Goes directly to OwnerDashboard
Expected: ✅ Statistics load correctly
```

### ✅ **Test 6: Role Persistence**
```
Steps:
1. Login as student
2. Close app
3. Reopen → Should see StudentDashboard (4 bottom tabs)
4. Logout
5. Login as owner
6. Close app
7. Reopen → Should see OwnerDashboard (5 bottom tabs)

Expected: ✅ Correct dashboard for each role
```

### ✅ **Test 7: Multiple Days**
```
Steps:
1. Login as student
2. Don't open app for 24-48 hours
3. Open app

Expected: ✅ Still logged in (token valid for 60+ days)
```

### ✅ **Test 8: Network Issues**
```
Steps:
1. Login with internet ON
2. Close app
3. Turn OFF internet/WiFi
4. Open app

Expected: ✅ Still shows dashboard (cached auth)
Expected: ⚠️ Some data may not load (needs network)
```

### ✅ **Test 9: Logout Confirmation**
```
Steps:
1. Click logout button
2. Dialog appears: "Confirm Logout"
3. Click "Cancel"

Expected: ✅ Stays on dashboard (logout cancelled)

Then:
4. Click logout again
5. Click "Logout" in dialog

Expected: ✅ Logs out and shows WelcomeScreen
```

### ✅ **Test 10: Google Sign-In Persistence**
```
Steps:
1. Login using Google Sign-In (if configured)
2. Close app
3. Reopen app

Expected: ✅ Stays logged in (same as email/password)
```

---

## 🎯 **What to Look For**

### **✅ GOOD Signs:**
- App opens directly to dashboard (no login screen)
- Profile picture loads in top-left
- Notification badge shows correct count
- Bottom navigation works
- Console shows: "🔔 Notification checker started"
- No Firebase Auth errors in console

### **❌ BAD Signs:**
- Shows WelcomeScreen after app restart (while logged in)
- Loading spinner forever
- Firebase Auth errors in console
- "Permission denied" errors
- User data doesn't load

---

## 🔧 **Console Messages to Watch**

### **On App Launch (Logged In):**
```
✅ "Checking authentication..."
✅ "🔔 Notification checker started - Running every minute"
✅ No Firebase Auth errors
```

### **On Logout:**
```
✅ "✅ User signed out successfully"
✅ "🔕 Notification checker stopped"
```

### **On Login:**
```
✅ "🔔 Notification checker started"
✅ User role fetched from Firestore
```

---

## 🐛 **Common Issues & Fixes**

### **Issue: Shows login after restart**
**Fix:**
- Check if Firebase is initialized in `main()`
- Verify `firebase_options.dart` exists
- Check internet connection during first login

### **Issue: Stuck on loading screen**
**Fix:**
- Check console for errors
- Verify Firestore security rules allow user reads
- Restart app

### **Issue: Logout doesn't work**
**Fix:**
- Check if AuthService.signOut() is awaited
- Verify AuthWrapper is listening to authStateChanges
- Clear app data and try again

---

## 📊 **Expected Behavior Summary**

| Scenario | Expected Result | Persistent Login? |
|----------|----------------|-------------------|
| **First Open** | WelcomeScreen | ❌ Not logged in |
| **After Login** | StudentDashboard | ✅ Session created |
| **App Restart** | StudentDashboard | ✅ Session persists |
| **Device Restart** | StudentDashboard | ✅ Session persists |
| **After Logout** | WelcomeScreen | ❌ Session cleared |
| **Next Day** | StudentDashboard | ✅ Session persists |
| **Next Week** | StudentDashboard | ✅ Session persists |
| **After 60 Days** | WelcomeScreen | ❌ Token expired |

---

## 🎓 **Quick Debugging Steps**

1. **Open Chrome DevTools** (for Flutter Web) or **Android Studio Logcat**
2. **Filter logs by:** "Firebase Auth" or "AuthWrapper"
3. **Look for:**
   - User authentication state changes
   - Token validation messages
   - Error messages

4. **Test Sign Out:**
   ```
   Click Logout → Check console for:
   "✅ User signed out successfully"
   "🔕 Notification checker stopped"
   ```

5. **Test Sign In:**
   ```
   Login → Check console for:
   "🔔 Notification checker started"
   User role: student/owner
   ```

---

## ✅ **Pass Criteria**

Your persistent login is working correctly if:

✅ User logs in once  
✅ App restart → Still logged in  
✅ Device restart → Still logged in  
✅ Logout → Session cleared  
✅ Reopen after logout → Shows login screen  
✅ No "Permission denied" errors  
✅ Correct dashboard for each role  
✅ Notification system works after persistent login  

---

**Happy Testing!** 🚀

If all tests pass, your persistent login is production-ready!
