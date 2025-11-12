# Notification System - Authentication Flow

## 🔄 System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         APP LAUNCH                               │
│                    Firebase Initialized                          │
│                  ❌ NO Notification Checker                      │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                      WELCOME SCREEN                              │
│              "Login as Owner / Student"                          │
│                                                                   │
│  Status: ❌ No background tasks                                 │
│  Firebase Auth: ❌ Not authenticated                            │
│  Notification Timer: ❌ NULL                                     │
└──────────┬───────────────────────────────┬──────────────────────┘
           │                               │
     [Login as Owner]              [Login as Student]
           │                               │
           ▼                               ▼
┌──────────────────────┐          ┌──────────────────────┐
│   OWNER DASHBOARD    │          │  STUDENT DASHBOARD   │
│                      │          │                      │
│ ✅ Authenticated     │          │ ✅ Authenticated     │
│ ✅ Timer STARTED     │          │ ✅ Timer STARTED     │
│ ✅ Notifications ON  │          │ ✅ Notifications ON  │
└──────────────────────┘          └──────────────────────┘
           │                               │
           └───────────┬───────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │  NOTIFICATION CHECKER        │
        │  Timer.periodic(1 minute)    │
        │                              │
        │  Every minute checks:        │
        │  • Washing completion        │
        │  • Washing reminder          │
        │  • Dinner vote reminder      │
        └──────────────────────────────┘
                       │
                [User Clicks Logout]
                       │
                       ▼
        ┌──────────────────────────────┐
        │   stopNotificationChecker()  │
        │   Timer.cancel()             │
        │   _notificationTimer = null  │
        └──────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │      WELCOME SCREEN          │
        │   ❌ Timer STOPPED           │
        │   ❌ Clean State             │
        └──────────────────────────────┘
```

## 🎯 Key Functions

### `startNotificationChecker()`
**When:** Called automatically when user logs in  
**Where:** AuthWrapper detects `userSnapshot.hasData`  
**What:** Creates Timer.periodic that runs every 1 minute  
**Safety:** Checks if already running to prevent duplicates  

### `stopNotificationChecker()`
**When:** Called automatically when user logs out  
**Where:** AuthWrapper detects `!userSnapshot.hasData`  
**What:** Cancels timer and sets to null  
**Safety:** Null check before cancelling  

## 🔐 Authentication States

| State | Timer Status | Firestore Access | Notifications |
|-------|-------------|------------------|---------------|
| **App Launch** | ❌ Not Started | ❌ None | ❌ None |
| **Welcome Screen** | ❌ Stopped | ❌ None | ❌ None |
| **Logging In...** | ❌ Not Started | ⏳ Authenticating | ❌ None |
| **✅ Logged In (Owner)** | ✅ **Running** | ✅ **Full Access** | ✅ **Active** |
| **✅ Logged In (Student)** | ✅ **Running** | ✅ **Full Access** | ✅ **Active** |
| **Logging Out...** | 🔄 Stopping | 🔄 Cleaning Up | 🔄 Finalizing |
| **Logged Out** | ❌ Stopped | ❌ None | ❌ None |

## 🛡️ Protection Mechanisms

### 1. **Duplicate Prevention**
```dart
if (_notificationTimer != null && _notificationTimer!.isActive) {
  return; // Already running
}
```

### 2. **Safe Cancellation**
```dart
if (_notificationTimer != null) {
  _notificationTimer!.cancel();
  _notificationTimer = null;
}
```

### 3. **Error Isolation**
```dart
try {
  await washingService.checkAndSendCompletionNotifications();
} catch (e) {
  print('Error: $e'); // Doesn't crash app
}
```

## 📱 Real-World Scenarios

### Scenario 1: First Time User
```
1. Opens app → Welcome screen (no tasks running)
2. Clicks "Login as Student"
3. Enters credentials
4. ✅ Login successful
5. AuthWrapper detects login → startNotificationChecker()
6. Student dashboard shown with active notifications
```

### Scenario 2: Existing User (Auto-Login)
```
1. Opens app → Loading screen
2. AuthWrapper checks Firebase Auth
3. User already logged in → startNotificationChecker()
4. Dashboard shown immediately
5. Notifications working from start
```

### Scenario 3: User Logs Out
```
1. User in dashboard (timer running)
2. Clicks "Logout" button
3. AuthService.signOut() called
4. AuthWrapper detects logout → stopNotificationChecker()
5. Welcome screen shown (no background tasks)
```

### Scenario 4: Session Timeout
```
1. User inactive for long time
2. Firebase session expires
3. AuthWrapper stream detects no user
4. stopNotificationChecker() called automatically
5. User redirected to welcome screen
```

## ⚡ Performance Optimization

### Memory Management
- **Before:** Timer runs continuously, even without user
- **After:** Timer only runs when needed (active user)
- **Savings:** ~100% reduction in unnecessary background work

### Network Efficiency
- **Before:** Firestore queries fail repeatedly (no auth)
- **After:** Queries only run when authenticated
- **Savings:** Zero failed queries, reduced bandwidth

### Battery Impact
- **Before:** Background task drains battery on idle screen
- **After:** No background tasks when logged out
- **Savings:** Better battery life when app is idle

## 🧪 Testing Commands

### Test Welcome Screen
```
1. Logout if logged in
2. Should see welcome screen
3. Console should show: "🔕 Notification checker stopped"
4. No Firestore errors in console
```

### Test Login
```
1. Click "Login as Student/Owner"
2. Enter credentials
3. Console should show: "🔔 Notification checker started"
4. Verify timer is running every minute
```

### Test Logout
```
1. While logged in, check console
2. Click logout
3. Console should show: "🔕 Notification checker stopped"
4. Welcome screen appears
```

## 🎓 Best Practices Applied

✅ **Singleton Pattern** - Only one timer instance  
✅ **Reactive Programming** - Responds to auth state changes  
✅ **Clean Architecture** - Separation of concerns  
✅ **Error Handling** - Graceful failure recovery  
✅ **Resource Management** - Proper cleanup on exit  
✅ **User-Centric** - Only runs when user needs it  

---

**Implementation Date:** November 11, 2025  
**Status:** ✅ Production Ready  
**Impact:** Critical - Fixes authentication errors
