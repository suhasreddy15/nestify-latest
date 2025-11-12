# 🔄 Persistent Login Flow Diagram

## Complete Authentication Flow with Persistent Login

```
╔═══════════════════════════════════════════════════════════════╗
║                     USER OPENS APP                             ║
║                                                                ║
║  main() → Firebase.initializeApp() → runApp(MyApp())          ║
╚═══════════════════════════════════════════════════════════════╝
                              │
                              ▼
┌───────────────────────────────────────────────────────────────┐
│                        AuthWrapper                             │
│                 (Persistent Login Controller)                  │
│                                                                │
│  StreamBuilder<User?>(                                        │
│    stream: authService.user, ← authStateChanges()            │
│  )                                                            │
│                                                                │
│  📱 Checks: Local storage for encrypted auth token            │
└─────────────────────┬─────────────────────────────────────────┘
                      │
                      │ [Firebase Auth Checks Local Storage]
                      │
        ┌─────────────┴─────────────┐
        │                           │
    [Token Found]             [No Token]
        │                           │
        ▼                           ▼
┌──────────────────┐      ┌──────────────────┐
│ Token Valid?     │      │  Welcome Screen  │
│ Check with       │      │                  │
│ Firebase Server  │      │ • Login as Owner │
└────┬─────────────┘      │ • Login as       │
     │                    │   Student        │
     │                    └──────────────────┘
     │                           │
┌────┴────┐                      │
│         │                      │ [User Clicks Login]
│         │                      │
▼         ▼                      ▼
[Valid]  [Expired]     ┌──────────────────┐
│         │            │   Login Screen   │
│         │            │                  │
│         │            │ • Email          │
│         │            │ • Password       │
│         │            │ • [Login Button] │
│         │            └────────┬─────────┘
│         │                     │
│         │                     ▼
│         │            ┌──────────────────┐
│         │            │ Firebase Auth    │
│         │            │ signInWithEmail  │
│         │            │                  │
│         │            │ ✅ Save Token    │
│         │            │    to Local      │
│         │            │    Storage       │
│         │            └────────┬─────────┘
│         │                     │
│         │            ┌────────┴─────────┐
│         │            │ authStateChanges │
│         │            │ emits User       │
│         └────────────┴────────┬─────────┘
│                               │
└───────────────────────────────┘
                │
                ▼
┌───────────────────────────────────────────────────────────────┐
│                   USER AUTHENTICATED ✅                        │
│                                                                │
│  • Firebase Auth token stored (encrypted)                     │
│  • Session valid for 60+ days                                 │
│  • Auto-refresh enabled                                       │
└───────────────────────┬───────────────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────────────┐
│                  Fetch User Role from Firestore               │
│                                                                │
│  users/{userId} → { role: "owner" | "student" }               │
└──────────┬────────────────────────────────┬───────────────────┘
           │                                │
    [Owner Role]                     [Student Role]
           │                                │
           ▼                                ▼
┌──────────────────────┐         ┌──────────────────────┐
│  Owner Dashboard     │         │  Student Dashboard   │
│                      │         │                      │
│  • Home (Stats)      │         │  • Home              │
│  • Complaints        │         │  • Chat              │
│  • Dinner Voting     │         │  • Voting            │
│  • Students          │         │  • Washing           │
│  • Payments          │         │                      │
│                      │         │  🔔 Notifications    │
│  ⚙️  Settings        │         │  👤 Profile (top)    │
│  🚪 Logout           │         │  🚪 Logout           │
└──────────────────────┘         └──────────────────────┘
           │                                │
           │ [User Uses App]                │
           │ [Closes App]                   │ [Closes App]
           │                                │
           └────────────────┬───────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│                      APP CLOSED                                │
│                                                                │
│  📱 Token remains in local storage (encrypted)                │
│  🔒 Session persists                                          │
╚═══════════════════════════════════════════════════════════════╝

           [TIME PASSES - HOURS, DAYS, WEEKS]

┌───────────────────────────────────────────────────────────────┐
│                   USER REOPENS APP                             │
│                                                                │
│  📱 AuthWrapper checks local storage                          │
╚═══════════════════════════════════════════════════════════════╝
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│                  Token Found & Valid ✅                        │
│                                                                │
│  • No login required!                                         │
│  • authStateChanges() emits User                             │
│  • Fetches role from Firestore                               │
│  • Shows appropriate dashboard                               │
└───────────────────────────────────────────────────────────────┘
                            │
                            ▼
                    [User sees Dashboard]
                    [Persistent Login SUCCESS! 🎉]


═══════════════════════════════════════════════════════════════

                       LOGOUT FLOW

═══════════════════════════════════════════════════════════════

┌───────────────────────────────────────────────────────────────┐
│                  User Clicks Logout Button                     │
└───────────────────────┬───────────────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────────────┐
│                 Confirmation Dialog                            │
│                                                                │
│  "Are you sure you want to logout?"                           │
│                                                                │
│         [Cancel]           [Logout]                           │
└──────────┬──────────────────────┬────────────────────────────┘
           │                      │
      [Cancel]                [Logout]
           │                      │
           ▼                      ▼
   [Stay Logged In]    ┌──────────────────────┐
                       │  AuthService         │
                       │  .signOut()          │
                       │                      │
                       │  • Clear token       │
                       │  • Clear cache       │
                       │  • Sign out Google   │
                       └──────────┬───────────┘
                                  │
                                  ▼
                       ┌──────────────────────┐
                       │ authStateChanges()   │
                       │ emits NULL           │
                       └──────────┬───────────┘
                                  │
                                  ▼
                       ┌──────────────────────┐
                       │ AuthWrapper          │
                       │ detects null         │
                       │                      │
                       │ • Stop notifications │
                       │ • Clear state        │
                       └──────────┬───────────┘
                                  │
                                  ▼
                       ┌──────────────────────┐
                       │  Welcome Screen      │
                       │                      │
                       │  🔐 Login Required   │
                       └──────────────────────┘
```

---

## 🔑 Key Components

### **1. Firebase Auth Token**
```
Location: Device Secure Storage (Encrypted)
Lifespan: 60+ days (auto-refreshed)
Content: {
  userId: "abc123",
  email: "student@example.com",
  exp: 1234567890,
  iat: 1234567890
}
```

### **2. authStateChanges() Stream**
```dart
Stream<User?> get user => _auth.authStateChanges();

// Emits:
// - User object when logged in (including after app restart)
// - null when logged out
```

### **3. AuthWrapper**
```dart
// Single source of truth for navigation
StreamBuilder<User?>(
  stream: authService.user,
  builder: (context, snapshot) {
    if (snapshot.hasData) return Dashboard();
    return WelcomeScreen();
  }
)
```

---

## 📊 State Transitions

```
┌─────────────┐   Login    ┌─────────────┐
│   Not       ├──────────►│   Logged    │
│   Logged In │            │   In        │
│             │◄───────────┤             │
└─────────────┘   Logout   └─────────────┘

States:
• Not Logged In → Token: ❌ | Screen: Welcome
• Logged In     → Token: ✅ | Screen: Dashboard
```

---

## ⏱️ Timeline Example

```
Day 0, 10:00 AM
│ User logs in
│ Token saved
└─► Dashboard shown

Day 0, 11:00 AM
│ User closes app
└─► Token remains in storage

Day 1, 9:00 AM
│ User reopens app
│ Token found & valid
└─► Dashboard shown (no login!)

Day 7, 3:00 PM
│ User reopens app
│ Token still valid
└─► Dashboard shown (still no login!)

Day 30, 8:00 PM
│ User clicks Logout
│ Token cleared
└─► Welcome screen shown

Day 30, 8:05 PM
│ User reopens app
│ No token found
└─► Welcome screen (must login)
```

---

## 🔐 Security Flow

```
Local Storage (Device)          Firebase Servers
       │                              │
       │  1. Check Token              │
       ├────────────────────────────►│
       │                              │
       │                          2. Validate
       │                              │
       │  3. Return User or null      │
       │◄────────────────────────────┤
       │                              │
       │  4. Auto-refresh if needed   │
       │◄───────────────────────────►│
       │                              │
```

---

## 🎯 Success Indicators

✅ **App Launch:** Goes directly to dashboard (if logged in)  
✅ **Token Refresh:** Happens automatically in background  
✅ **Logout:** Immediately clears session and shows welcome  
✅ **Role Check:** Firestore role fetched correctly  
✅ **Notifications:** Start automatically after persistent login  

---

**Implementation Status:** ✅ Complete  
**Date:** November 11, 2025  
**Production Ready:** Yes
