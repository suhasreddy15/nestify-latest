# 📱 Push Notifications - Complete Flow Diagram

## 🔄 End-to-End Notification System

```
╔═══════════════════════════════════════════════════════════════╗
║                    INITIAL SETUP & LOGIN                       ║
╚═══════════════════════════════════════════════════════════════╝

[App Launch] → main.dart
      │
      ├─ Firebase.initializeApp() ✅
      ├─ FirebaseMessaging.onBackgroundMessage() registered ✅
      └─ runApp(MyApp())
            │
            └─ AuthWrapper
                  │
                  └─ StreamBuilder<User?>(authStateChanges)
                        │
                  ┌─────┴─────┐
                  │           │
           [No User]     [User Exists]
                  │           │
                  ▼           ▼
          WelcomeScreen   _initializeNotificationsForUser()
                                │
                                ▼
                    NotificationService.initialize()
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
        ▼                       ▼                       ▼
[_initializeLocal      [_requestPermissions]   [_setupFCMToken]
 Notifications]                │                       │
        │                      │                       │
        │              ┌───────┴────────┐              │
        │              │                │              │
        │         [Granted]        [Denied]            │
        │              │                │              │
        │              │           [Return]            │
        │              ▼                               │
        │     [Continue Setup]                         │
        │              │                               │
        └──────────────┼───────────────────────────────┘
                       │
                       ▼
            [Get FCM Token from Firebase]
                       │
                       ▼
              [Save to Firestore]
              users/{userId}/fcmToken
                       │
                       ▼
           [Setup Message Handlers]
           ├─ onMessage (foreground)
           ├─ onBackgroundMessage
           ├─ getInitialMessage
           └─ onMessageOpenedApp
                       │
                       ▼
              [Listen for Token Refresh]
                       │
                       ▼
                  [READY! ✅]


╔═══════════════════════════════════════════════════════════════╗
║                  NOTIFICATION SENDING FLOW                     ║
╚═══════════════════════════════════════════════════════════════╝

[Trigger: Owner creates dinner vote / Booking time approaches]
                       │
                       ▼
        [Dinner Vote Service / Washing Service]
                       │
                       ▼
          [Get Student FCM Token from Firestore]
             users/{studentId}/fcmToken
                       │
                       ▼
              [Send via Firebase Cloud Messaging]
              POST to fcm.googleapis.com
              {
                to: "fcmToken",
                notification: { title, body },
                data: { type, metadata },
                android: { priority: "high" }
              }
                       │
                       ▼
              [Firebase FCM Server]
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
   [Student's    [Student's     [Student's
    Device 1]     Device 2]      Device 3]
        │              │              │
        └──────────────┼──────────────┘
                       │
              [Notification Received]


╔═══════════════════════════════════════════════════════════════╗
║              NOTIFICATION RECEIVING - APP STATES              ║
╚═══════════════════════════════════════════════════════════════╝

            [Notification Arrives at Device]
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
  [FOREGROUND]   [BACKGROUND]   [TERMINATED]
  (App Open)     (Minimized)    (App Killed)
        │              │              │
        ▼              ▼              ▼


┌─────────────────────────────────────────────────────────────┐
│                     FOREGROUND STATE                         │
│                  (User is using app)                         │
└─────────────────────────────────────────────────────────────┘

Firebase sends notification
        ↓
FirebaseMessaging.onMessage.listen()
        ↓
[Callback triggered in NotificationService]
        ↓
_showLocalNotification(message)
        ↓
FlutterLocalNotificationsPlugin.show()
        ↓
┌─────────────────────────────────┐
│  📱 NOTIFICATION APPEARS         │
│  ┌───────────────────────────┐  │
│  │ 🔔 Dinner Voting Open     │  │
│  │ Vote for today's dinner!  │  │
│  │ Closes at 6 PM            │  │
│  └───────────────────────────┘  │
│                                  │
│  • Shows at top of screen        │
│  • Appears in notification bar   │
│  • Shows on lock screen          │
│  • Can tap to open               │
└─────────────────────────────────┘


┌─────────────────────────────────────────────────────────────┐
│                    BACKGROUND STATE                          │
│              (App is minimized/in background)                │
└─────────────────────────────────────────────────────────────┘

Firebase sends notification
        ↓
firebaseMessagingBackgroundHandler()
[Top-level function in main.dart]
        ↓
System processes notification
        ↓
Android notification channel: high_importance_channel
        ↓
┌─────────────────────────────────┐
│  📱 SYSTEM NOTIFICATION          │
│  ┌───────────────────────────┐  │
│  │ 🧺 Washing Complete       │  │
│  │ Your laundry is ready!    │  │
│  │ Please collect it now     │  │
│  └───────────────────────────┘  │
│                                  │
│  • Shows in notification drawer  │
│  • Shows on lock screen          │
│  • Vibrates phone                │
│  • Plays sound                   │
│  • Tap to open app               │
└─────────────────────────────────┘


┌─────────────────────────────────────────────────────────────┐
│                    TERMINATED STATE                          │
│              (App was completely closed)                     │
└─────────────────────────────────────────────────────────────┘

Firebase sends notification
        ↓
System receives notification
        ↓
Android displays notification immediately
        ↓
┌─────────────────────────────────┐
│  📱 SYSTEM NOTIFICATION          │
│  ┌───────────────────────────┐  │
│  │ ⏰ Washing Reminder       │  │
│  │ Your slot starts in 10    │  │
│  │ minutes. Be ready!        │  │
│  └───────────────────────────┘  │
│                                  │
│  • Shows in notification drawer  │
│  • Shows on lock screen          │
│  • Stored until user taps        │
└─────────────────────────────────┘
        ↓
[User taps notification]
        ↓
Android launches app
        ↓
FirebaseMessaging.getInitialMessage()
        ↓
[App opens with notification data]
        ↓
_handleNotificationTap(message)
        ↓
[Navigate to relevant screen]


╔═══════════════════════════════════════════════════════════════╗
║                    NOTIFICATION TAP HANDLING                   ║
╚═══════════════════════════════════════════════════════════════╝

[User taps notification]
        │
        ├─ From Foreground: onDidReceiveNotificationResponse
        ├─ From Background: FirebaseMessaging.onMessageOpenedApp
        └─ From Terminated: FirebaseMessaging.getInitialMessage
        │
        └─ All route to: _handleNotificationTap(message)
                       │
                       ▼
              [Parse notification data]
              type = message.data['type']
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
  [dinner_vote]  [washing_*]   [complaint]
        │              │              │
        ▼              ▼              ▼
  Navigate to    Navigate to    Navigate to
  Voting Screen  Washing Screen Complaints
        │              │              │
        └──────────────┼──────────────┘
                       │
                       ▼
            [Screen opens with context]


╔═══════════════════════════════════════════════════════════════╗
║                    LOCK SCREEN NOTIFICATIONS                   ║
╚═══════════════════════════════════════════════════════════════╝

Phone is locked (screen off)
        ↓
Notification arrives
        ↓
┌─────────────────────────────────────────────────────────────┐
│                    🔒 LOCK SCREEN                             │
│                                                               │
│                    [10:30 AM]                                 │
│                    Monday, Nov 11                             │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 🔔 NESTIFY                              Just now    │    │
│  │ ─────────────────────────────────────────────────   │    │
│  │ 🍽️ Dinner Voting Open                              │    │
│  │ Vote for today's dinner! Closes at 6 PM            │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                               │
│  • Swipe to open app                                         │
│  • Shows even when locked                                    │
│  • Visibility: PUBLIC (visible to all)                       │
│  • Screen turns on briefly                                   │
│  • LED indicator blinks (if available)                       │
└─────────────────────────────────────────────────────────────┘

Configuration in AndroidManifest.xml:
  android:showWhenLocked="true"
  android:turnScreenOn="true"

Configuration in NotificationDetails:
  visibility: NotificationVisibility.public


╔═══════════════════════════════════════════════════════════════╗
║                      LOGOUT & CLEANUP                          ║
╚═══════════════════════════════════════════════════════════════╝

[User clicks Logout button]
        │
        ▼
[Confirmation dialog: "Are you sure?"]
        │
   [User confirms]
        │
        ▼
AuthService.signOut()
        │
        ├─ Firebase Auth sign out
        └─ Google Sign-In sign out (if used)
        │
        ▼
[Auth state changes to null]
        │
        ▼
AuthWrapper detects logout (userSnapshot has NO data)
        │
        ├─ stopNotificationChecker()
        └─ _cleanupNotifications()
                │
                ▼
        NotificationService.cleanup()
                │
        ┌───────┴───────┐
        │               │
        ▼               ▼
[Delete Token    [Delete Token
 from Firestore]  from FCM]
        │               │
        ▼               ▼
users/{userId}   FCM.deleteToken()
fcmToken: DELETED
        │               │
        └───────┬───────┘
                │
                ▼
        [Stop all listeners]
                │
                ▼
        _initialized = false
                │
                ▼
        [WelcomeScreen shown]
                │
                ▼
        [Cleanup Complete! ✅]


╔═══════════════════════════════════════════════════════════════╗
║                   TOKEN REFRESH FLOW                           ║
╚═══════════════════════════════════════════════════════════════╝

[Scenarios that trigger token refresh:]
├─ App reinstall
├─ Clear app data
├─ Token expires (rare)
└─ Firebase internal refresh (automatic)
        │
        ▼
FirebaseMessaging.onTokenRefresh.listen()
        │
        ▼
[New token generated]
        │
        ▼
_saveTokenToFirestore(newToken)
        │
        ▼
[Update Firestore]
users/{userId} {
  fcmToken: "new_token_here",
  fcmTokenUpdatedAt: Timestamp.now()
}
        │
        ▼
[Token Updated! ✅]
[Notifications continue working seamlessly]


╔═══════════════════════════════════════════════════════════════╗
║                 NOTIFICATION PRIORITY & DELIVERY               ║
╚═══════════════════════════════════════════════════════════════╝

                [Notification Priority]
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
    [HIGH]         [DEFAULT]        [LOW]
        │               │               │
        ▼               ▼               ▼
• Delivered        • Normal        • Batched
  immediately        delivery      • Delayed
• Vibration        • No sound      • Low priority
• Sound            • Standard      • Background
• Heads-up           display         only
• Lock screen
• Full screen
  (optional)

Our Implementation: HIGH PRIORITY ✅
├─ android.priority: "high"
├─ Importance.high
├─ Shows on lock screen
├─ Vibrates + sound
└─ Immediate delivery


╔═══════════════════════════════════════════════════════════════╗
║               NOTIFICATION CHANNEL ARCHITECTURE                ║
╚═══════════════════════════════════════════════════════════════╝

[Android Notification Channels]
        │
        └─ high_importance_channel (Our Main Channel)
            │
            ├─ Name: "High Importance Notifications"
            ├─ Description: "Important notifications from Nestify"
            ├─ Importance: HIGH
            ├─ Sound: ✅ Enabled (system default)
            ├─ Vibration: ✅ Enabled
            ├─ Badge: ✅ Enabled (shows count)
            ├─ Lock Screen: ✅ Public (shows all content)
            └─ LED: ✅ Enabled (if device supports)

[User Can Customize Per Channel:]
├─ Enable/disable sound
├─ Change vibration pattern
├─ Show/hide on lock screen
└─ Priority level

Note: Channels are permanent once created.
Changes require app reinstall or new channel ID.
```

---

## 📊 **Data Flow Summary**

### **1. Token Storage:**
```
Device → FCM → Token → NotificationService → Firestore
                                               ↓
                                    users/{userId}/fcmToken
```

### **2. Notification Sending:**
```
Owner/System → Get Token → Send to FCM → FCM Routes → Device
                   ↓                                      ↓
              From Firestore                        Shows Notification
```

### **3. Notification Receipt:**
```
Device Receives → Check App State → Route to Handler → Display
                         ↓
        ├─ Foreground: Local notification
        ├─ Background: System notification
        └─ Terminated: System notification
```

### **4. Cleanup:**
```
Logout → Auth Change → AuthWrapper → Cleanup → Delete Token
                                        ↓
                                  Firestore + FCM
```

---

## 🎯 **Key Integration Points**

| Component | File | Responsibility |
|-----------|------|----------------|
| **Background Handler** | main.dart | Handle terminated/background messages |
| **Initialization** | AuthWrapper | Start notifications after login |
| **Cleanup** | AuthWrapper | Stop notifications on logout |
| **Token Management** | NotificationService | Save/delete/refresh tokens |
| **Message Handling** | NotificationService | Process all notification types |
| **Permissions** | NotificationService | Request & check permissions |
| **Local Display** | NotificationService | Show foreground notifications |

---

**Status:** ✅ Complete Implementation  
**Last Updated:** November 11, 2025  
**Architecture:** Production-Ready
