# 🏗️ Nestify - Architecture Diagram

## System Overview

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                    NESTIFY                                          │
│                          Smart PG Management System                                 │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              FLUTTER APPLICATION                                    │
│                            (Cross-Platform Mobile App)                              │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                           PRESENTATION LAYER                                 │   │
│  │                              (Screens/UI)                                    │   │
│  │                                                                              │   │
│  │   ┌──────────────────────┐           ┌──────────────────────┐               │   │
│  │   │    STUDENT PORTAL    │           │     OWNER PORTAL     │               │   │
│  │   │                      │           │                      │               │   │
│  │   │  • Login/Register    │           │  • Login             │               │   │
│  │   │  • Dashboard         │           │  • Dashboard         │               │   │
│  │   │  • Profile           │           │  • Student Mgmt      │               │   │
│  │   │  • Community Chat    │           │  • Payment Dashboard │               │   │
│  │   │  • Dinner Voting     │           │  • Complaint Mgmt    │               │   │
│  │   │  • Washing Booking   │           │  • Dinner Setup      │               │   │
│  │   │  • Complaints        │           │  • Booking Mgmt      │               │   │
│  │   │  • Payment History   │           │  • Settings          │               │   │
│  │   │  • Notifications     │           │                      │               │   │
│  │   └──────────────────────┘           └──────────────────────┘               │   │
│  │                                                                              │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                        │                                            │
│                                        ▼                                            │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                           BUSINESS LOGIC LAYER                               │   │
│  │                              (Services)                                      │   │
│  │                                                                              │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐    │   │
│  │  │AuthService  │ │ChatService  │ │PaymentSvc   │ │NotificationService  │    │   │
│  │  │             │ │             │ │             │ │                     │    │   │
│  │  │• Sign In    │ │• Send Msg   │ │• Add Payment│ │• Push Notifications │    │   │
│  │  │• Sign Up    │ │• Get Stream │ │• Gen Receipt│ │• Local Notifications│    │   │
│  │  │• Google Auth│ │• Delete Msg │ │• Get History│ │• FCM Handling       │    │   │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────────────┘    │   │
│  │                                                                              │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐    │   │
│  │  │ComplaintSvc │ │DinnerVoteSvc│ │WashingBookSvc│ │StudentProfileSvc   │    │   │
│  │  │             │ │             │ │             │ │                     │    │   │
│  │  │• Create     │ │• Create Vote│ │• Book Slot  │ │• Get Profile        │    │   │
│  │  │• Resolve    │ │• Submit Vote│ │• Cancel     │ │• Update Profile     │    │   │
│  │  │• Get List   │ │• Close Vote │ │• Get Slots  │ │• Upload Photo       │    │   │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────────────┘    │   │
│  │                                                                              │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌──────────────────────────────────────┐   │   │
│  │  │OwnerService │ │ThemeService │ │        CloudinaryService             │   │   │
│  │  │             │ │             │ │                                      │   │   │
│  │  │• Setup      │ │• Dark/Light │ │• Image Upload & Optimization        │   │   │
│  │  │• Validate   │ │• Theme Mode │ │• Receipt Image Storage              │   │   │
│  │  └─────────────┘ └─────────────┘ └──────────────────────────────────────┘   │   │
│  │                                                                              │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                        │                                            │
│                                        ▼                                            │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │                              DATA LAYER                                      │   │
│  │                              (Models)                                        │   │
│  │                                                                              │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │   │
│  │  │ ChatMessage │ │  Complaint  │ │ DinnerVote  │ │   Payment   │            │   │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘            │   │
│  │                                                                              │   │
│  │  ┌─────────────────────────────────────────────────────────────────────┐    │   │
│  │  │                        WashingBooking                                │    │   │
│  │  └─────────────────────────────────────────────────────────────────────┘    │   │
│  │                                                                              │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        │ HTTPS/WebSocket
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              FIREBASE BACKEND                                        │
│                                                                                      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐  │
│  │   Firebase      │  │   Cloud         │  │   Firebase      │  │   Firebase     │  │
│  │   Auth          │  │   Firestore     │  │   Storage       │  │   Messaging    │  │
│  │                 │  │                 │  │                 │  │                │  │
│  │  • Email/Pass   │  │  • users        │  │  • receipts/    │  │  • FCM Tokens  │  │
│  │  • Google Sign  │  │  • owners       │  │  • documents/   │  │  • Push Notifs │  │
│  │  • Session Mgmt │  │  • complaints   │  │                 │  │  • Background  │  │
│  │                 │  │  • payments     │  │                 │  │    Messaging   │  │
│  │                 │  │  • dinner_votes │  │                 │  │                │  │
│  │                 │  │  • community_   │  │                 │  │                │  │
│  │                 │  │    chat         │  │                 │  │                │  │
│  │                 │  │  • washing_     │  │                 │  │                │  │
│  │                 │  │    bookings     │  │                 │  │                │  │
│  │                 │  │  • notifications│  │                 │  │                │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  └────────────────┘  │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           EXTERNAL SERVICES                                          │
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────┐    │
│  │                              CLOUDINARY                                      │    │
│  │                        (Image Optimization CDN)                              │    │
│  │                                                                              │    │
│  │  • Receipt Image Uploads    • Auto Image Optimization    • CDN Delivery     │    │
│  └─────────────────────────────────────────────────────────────────────────────┘    │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📱 User Flow Diagram

```
                                    ┌───────────────┐
                                    │ Welcome Screen│
                                    └───────┬───────┘
                                            │
                        ┌───────────────────┴───────────────────┐
                        │                                       │
                        ▼                                       ▼
               ┌────────────────┐                     ┌────────────────┐
               │  Student Path  │                     │   Owner Path   │
               └────────┬───────┘                     └────────┬───────┘
                        │                                      │
            ┌───────────┴───────────┐                          │
            │                       │                          │
            ▼                       ▼                          ▼
    ┌───────────────┐       ┌───────────────┐         ┌───────────────┐
    │Student Login  │       │Student Register│         │  Owner Login  │
    │(Email/Google) │       │               │         │               │
    └───────┬───────┘       └───────┬───────┘         └───────┬───────┘
            │                       │                         │
            └───────────┬───────────┘                         │
                        │                                     │
                        ▼                                     ▼
            ┌───────────────────────┐             ┌───────────────────────┐
            │   Student Dashboard   │             │    Owner Dashboard    │
            │                       │             │                       │
            │  ┌─────────────────┐  │             │  ┌─────────────────┐  │
            │  │ 🏠 Home         │  │             │  │ 🏠 Home         │  │
            │  │ 💬 Chat         │  │             │  │ 📋 Complaints   │  │
            │  │ 🍽️ Dinner Vote  │  │             │  │ 🍽️ Dinner Setup │  │
            │  │ 🧺 Laundry      │  │             │  │ 👥 Students     │  │
            │  │ 📋 Complaints   │  │             │  │ 💰 Payments     │  │
            │  └─────────────────┘  │             │  └─────────────────┘  │
            │                       │             │                       │
            │  Quick Actions:       │             │  Quick Actions:       │
            │  • View Profile       │             │  • View Bookings      │
            │  • Payment History    │             │  • Manage Students    │
            │  • Notifications      │             │  • Settings           │
            │  • View Receipts      │             │  • Payment Reports    │
            └───────────────────────┘             └───────────────────────┘
```

---

## 🗄️ Firestore Database Schema

```
nestifymega (Firebase Project)
│
├── 📁 users/
│   └── {userId}
│       ├── fullName: string
│       ├── email: string
│       ├── role: "student" | "owner"
│       ├── phone: string
│       ├── roomNumber: string
│       ├── fcmToken: string
│       ├── profileImageUrl: string
│       ├── createdAt: timestamp
│       └── 📁 notifications/
│           └── {notificationId}
│               ├── title: string
│               ├── message: string
│               ├── type: string
│               ├── read: boolean
│               └── timestamp: timestamp
│
├── 📁 owners/
│   └── {ownerId}
│       ├── pgName: string
│       ├── address: string
│       ├── contactNumber: string
│       └── setupComplete: boolean
│
├── 📁 complaints/
│   └── {complaintId}
│       ├── title: string
│       ├── description: string
│       ├── studentId: string
│       ├── studentEmail: string
│       ├── status: "pending" | "resolved"
│       └── timestamp: timestamp
│
├── 📁 payments/
│   └── {paymentId}
│       ├── studentId: string
│       ├── studentName: string
│       ├── amount: number
│       ├── month: string
│       ├── year: number
│       ├── receiptUrl: string
│       ├── paymentDate: timestamp
│       └── createdBy: string
│
├── 📁 community_chat/
│   └── {messageId}
│       ├── message: string
│       ├── senderName: string
│       ├── senderId: string
│       └── timestamp: timestamp
│
├── 📁 dinner_votes/
│   └── {voteId}
│       ├── dish: string
│       ├── date: timestamp
│       ├── status: "active" | "closed"
│       ├── yesCount: number
│       ├── noCount: number
│       ├── createdBy: string
│       └── 📁 votes/
│           └── {voterId}
│               └── vote: "yes" | "no"
│
└── 📁 washing_bookings/
    └── {bookingId}
        ├── studentId: string
        ├── studentName: string
        ├── date: timestamp
        ├── timeSlot: string
        ├── machineNumber: number
        └── status: "active" | "completed" | "cancelled"
```

---

## 🔄 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                  DATA FLOW                                       │
└─────────────────────────────────────────────────────────────────────────────────┘

                    ┌─────────────────────────────────────────┐
                    │              USER ACTIONS               │
                    │   (Tap, Swipe, Input, Submit, etc.)     │
                    └──────────────────┬──────────────────────┘
                                       │
                                       ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│                              SCREENS (UI Layer)                                   │
│                                                                                   │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐ │
│  │  Dashboard │  │   Chat     │  │  Payments  │  │ Complaints │  │  Booking   │ │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘ │
│        │               │               │               │               │         │
└────────┼───────────────┼───────────────┼───────────────┼───────────────┼─────────┘
         │               │               │               │               │
         ▼               ▼               ▼               ▼               ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│                            SERVICES (Business Logic)                              │
│                                                                                   │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐ │
│  │ AuthService│  │ChatService │  │PaymentSvc  │  │ComplaintSvc│  │BookingSvc  │ │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘ │
│        │               │               │               │               │         │
│        │   ┌───────────┴───────────────┴───────────────┴───────────────┘         │
│        │   │                                                                      │
│        ▼   ▼                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                    Firebase SDK (firestore, auth, storage)                   │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                   │
└──────────────────────────────────────────────────────────────────────────────────┘
                                       │
                                       │ HTTPS / Websocket (Real-time)
                                       ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│                              FIREBASE CLOUD                                       │
│                                                                                   │
│     ┌─────────────────────────────────────────────────────────────────────────┐  │
│     │                        Cloud Firestore                                   │  │
│     │                    (NoSQL Real-time Database)                            │  │
│     │                                                                          │  │
│     │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │  │
│     │  │  users   │ │complaints│ │ payments │ │  chats   │ │ bookings │      │  │
│     │  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘      │  │
│     └─────────────────────────────────────────────────────────────────────────┘  │
│                                       │                                           │
│                                       │ Real-time Sync                            │
│                                       ▼                                           │
│     ┌─────────────────────────────────────────────────────────────────────────┐  │
│     │                      StreamBuilder / SnapshotListener                    │  │
│     │                         (Live Data Updates)                              │  │
│     └─────────────────────────────────────────────────────────────────────────┘  │
│                                                                                   │
└──────────────────────────────────────────────────────────────────────────────────┘
                                       │
                                       │ Push Notifications
                                       ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│                         FIREBASE CLOUD MESSAGING (FCM)                            │
│                                                                                   │
│    ┌────────────────┐     ┌────────────────┐     ┌────────────────┐              │
│    │ Foreground Msg │     │ Background Msg │     │ Terminated Msg │              │
│    └────────┬───────┘     └────────┬───────┘     └────────┬───────┘              │
│             │                      │                      │                       │
│             └──────────────────────┴──────────────────────┘                       │
│                                    │                                              │
│                                    ▼                                              │
│                    ┌───────────────────────────────┐                              │
│                    │  Local Notification Display   │                              │
│                    │  (flutter_local_notifications)│                              │
│                    └───────────────────────────────┘                              │
│                                                                                   │
└──────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📦 Package Dependencies Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              DEPENDENCIES MAP                                    │
└─────────────────────────────────────────────────────────────────────────────────┘

                           ┌───────────────────────┐
                           │     NESTIFY APP       │
                           │      (pubspec.yaml)   │
                           └───────────┬───────────┘
                                       │
       ┌───────────────────────────────┼───────────────────────────────┐
       │                               │                               │
       ▼                               ▼                               ▼
┌──────────────┐              ┌──────────────┐               ┌──────────────┐
│   FIREBASE   │              │     UI       │               │   UTILITIES  │
│   PACKAGES   │              │   PACKAGES   │               │   PACKAGES   │
└──────┬───────┘              └──────┬───────┘               └──────┬───────┘
       │                             │                              │
       ▼                             ▼                              ▼
┌──────────────────┐   ┌───────────────────────┐   ┌────────────────────────────┐
│ firebase_core    │   │ flutter               │   │ intl                       │
│ firebase_auth    │   │ cupertino_icons       │   │ url_launcher               │
│ cloud_firestore  │   │ google_fonts          │   │ path_provider              │
│ firebase_storage │   │ provider              │   │ file_picker                │
│ firebase_messaging│   │                       │   │                            │
└──────────────────┘   └───────────────────────┘   └────────────────────────────┘

       │                             │                              │
       ▼                             ▼                              ▼
┌──────────────────┐   ┌───────────────────────┐   ┌────────────────────────────┐
│ AUTHENTICATION   │   │    STATE MANAGEMENT   │   │      PDF & PRINTING        │
│                  │   │                       │   │                            │
│ google_sign_in   │   │ provider (ChangeNotif)│   │ pdf                        │
└──────────────────┘   └───────────────────────┘   │ printing                   │
                                                   └────────────────────────────┘
       │
       ▼                                                            │
┌──────────────────────────────────────────────────────────────────┐
│                      NOTIFICATIONS                                │
│                                                                   │
│ firebase_messaging        flutter_local_notifications            │
│ (Push Notifications)      (Local Notification Display)           │
└──────────────────────────────────────────────────────────────────┘

       │
       ▼
┌──────────────────────────────────────────────────────────────────┐
│                      EXTERNAL SERVICES                            │
│                                                                   │
│ cloudinary_public         (Image Upload & CDN)                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Feature Module Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           FEATURE MODULES                                        │
└─────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────────┐
│ 🔐 AUTHENTICATION MODULE                                                          │
│                                                                                   │
│  ┌─────────────┐    ┌─────────────────┐    ┌─────────────────────────────────┐  │
│  │   Screens   │    │    Services     │    │         Firebase                │  │
│  │             │───▶│                 │───▶│                                 │  │
│  │ • welcome   │    │ • AuthService   │    │ • Firebase Auth                 │  │
│  │ • login     │    │ • OwnerService  │    │ • Firestore (users, owners)     │  │
│  │ • register  │    │                 │    │ • Google Sign-In                │  │
│  └─────────────┘    └─────────────────┘    └─────────────────────────────────┘  │
│                                                                                   │
└──────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────────┐
│ 💬 COMMUNITY CHAT MODULE                                                          │
│                                                                                   │
│  ┌─────────────┐    ┌─────────────────┐    ┌─────────────────────────────────┐  │
│  │   Screens   │    │    Services     │    │         Firebase                │  │
│  │             │───▶│                 │───▶│                                 │  │
│  │ • chat      │    │ • ChatService   │    │ • Firestore (community_chat)    │  │
│  │   screen    │    │                 │    │ • Real-time Streams             │  │
│  └─────────────┘    └─────────────────┘    └─────────────────────────────────┘  │
│                              │                                                    │
│                              ▼                                                    │
│                     ┌─────────────────┐                                          │
│                     │     Models      │                                          │
│                     │ • ChatMessage   │                                          │
│                     └─────────────────┘                                          │
│                                                                                   │
└──────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────────┐
│ 💰 PAYMENT MANAGEMENT MODULE                                                      │
│                                                                                   │
│  ┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐  │
│  │      Screens        │    │      Services       │    │      Firebase       │  │
│  │                     │───▶│                     │───▶│                     │  │
│  │ • payment_mgmt      │    │ • PaymentService    │    │ • Firestore         │  │
│  │ • payment_dashboard │    │ • CloudinaryService │    │   (payments)        │  │
│  │ • payment_history   │    │                     │    │ • Cloudinary CDN    │  │
│  │ • receipt_history   │    │                     │    │   (receipt images)  │  │
│  └─────────────────────┘    └─────────────────────┘    └─────────────────────┘  │
│                                      │                                           │
│                                      ▼                                           │
│                           ┌─────────────────┐                                    │
│                           │     Models      │                                    │
│                           │   • Payment     │                                    │
│                           └─────────────────┘                                    │
│                                                                                   │
└──────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────────┐
│ 📋 COMPLAINT MANAGEMENT MODULE                                                    │
│                                                                                   │
│  ┌──────────────────────┐    ┌────────────────────┐    ┌──────────────────────┐ │
│  │       Screens        │    │      Services      │    │      Firebase        │ │
│  │                      │───▶│                    │───▶│                      │ │
│  │ • student_complaint  │    │ • ComplaintService │    │ • Firestore          │ │
│  │ • owner_complaint    │    │                    │    │   (complaints)       │ │
│  └──────────────────────┘    └────────────────────┘    └──────────────────────┘ │
│                                       │                                          │
│                                       ▼                                          │
│                            ┌─────────────────┐                                   │
│                            │     Models      │                                   │
│                            │  • Complaint    │                                   │
│                            └─────────────────┘                                   │
│                                                                                   │
└──────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────────┐
│ 🍽️ DINNER VOTING MODULE                                                          │
│                                                                                   │
│  ┌──────────────────────┐    ┌────────────────────┐    ┌──────────────────────┐ │
│  │       Screens        │    │      Services      │    │      Firebase        │ │
│  │                      │───▶│                    │───▶│                      │ │
│  │ • student_voting     │    │ • DinnerVoteService│    │ • Firestore          │ │
│  │ • owner_setup        │    │                    │    │   (dinner_votes)     │ │
│  └──────────────────────┘    └────────────────────┘    └──────────────────────┘ │
│                                       │                                          │
│                                       ▼                                          │
│                            ┌─────────────────┐                                   │
│                            │     Models      │                                   │
│                            │  • DinnerVote   │                                   │
│                            └─────────────────┘                                   │
│                                                                                   │
└──────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────────┐
│ 🧺 WASHING MACHINE BOOKING MODULE                                                 │
│                                                                                   │
│  ┌──────────────────────┐    ┌──────────────────────┐  ┌──────────────────────┐ │
│  │       Screens        │    │       Services       │  │      Firebase        │ │
│  │                      │───▶│                      │──│                      │ │
│  │ • washing_booking    │    │• WashingBookingService│  │ • Firestore          │ │
│  │ • owner_bookings     │    │                      │  │   (washing_bookings) │ │
│  └──────────────────────┘    └──────────────────────┘  └──────────────────────┘ │
│                                       │                                          │
│                                       ▼                                          │
│                            ┌─────────────────┐                                   │
│                            │     Models      │                                   │
│                            │• WashingBooking │                                   │
│                            └─────────────────┘                                   │
│                                                                                   │
└──────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────────┐
│ 🔔 NOTIFICATION MODULE                                                            │
│                                                                                   │
│  ┌──────────────────────┐    ┌──────────────────────┐  ┌──────────────────────┐ │
│  │       Screens        │    │       Services       │  │      Firebase        │ │
│  │                      │───▶│                      │──│                      │ │
│  │ • notifications      │    │• NotificationService │  │ • FCM                │ │
│  │   screen             │    │                      │  │ • Firestore          │ │
│  └──────────────────────┘    └──────────────────────┘  │   (notifications)    │ │
│                                                        └──────────────────────┘ │
│                                                                                   │
└──────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🏛️ Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         CLEAN ARCHITECTURE OVERVIEW                              │
└─────────────────────────────────────────────────────────────────────────────────┘

                    ┌───────────────────────────────────────┐
                    │                                       │
                    │          📱 PRESENTATION              │
                    │                                       │
                    │   Flutter Widgets & State Management  │
                    │                                       │
                    │   • MaterialApp                       │
                    │   • Screens (StatefulWidget)          │
                    │   • Provider (ThemeService)           │
                    │   • StreamBuilder (Real-time UI)      │
                    │                                       │
                    └─────────────────┬─────────────────────┘
                                      │
                                      │ depends on
                                      ▼
                    ┌───────────────────────────────────────┐
                    │                                       │
                    │           ⚙️ BUSINESS LOGIC           │
                    │                                       │
                    │      Services & Use Cases             │
                    │                                       │
                    │   • AuthService                       │
                    │   • ChatService                       │
                    │   • PaymentService                    │
                    │   • ComplaintService                  │
                    │   • DinnerVoteService                 │
                    │   • WashingBookingService             │
                    │   • NotificationService               │
                    │                                       │
                    └─────────────────┬─────────────────────┘
                                      │
                                      │ depends on
                                      ▼
                    ┌───────────────────────────────────────┐
                    │                                       │
                    │            📊 DATA LAYER              │
                    │                                       │
                    │      Models & Firebase SDK            │
                    │                                       │
                    │   • ChatMessage                       │
                    │   • Complaint                         │
                    │   • DinnerVote                        │
                    │   • Payment                           │
                    │   • WashingBooking                    │
                    │                                       │
                    │   Firebase SDK:                       │
                    │   • FirebaseAuth                      │
                    │   • FirebaseFirestore                 │
                    │   • FirebaseStorage                   │
                    │   • FirebaseMessaging                 │
                    │                                       │
                    └───────────────────────────────────────┘
```

---

## 📁 File Structure Overview

```
nestify/
│
├── 📱 lib/
│   │
│   ├── 🚀 main.dart                 # App entry point, routing, theme
│   │
│   ├── 🔥 firebase_options.dart     # Firebase configuration (auto-generated)
│   │
│   ├── 📊 models/                   # Data Models
│   │   ├── chat_message.dart        # Community chat message model
│   │   ├── complaint.dart           # Complaint model
│   │   ├── dinner_vote.dart         # Dinner voting model
│   │   ├── payment.dart             # Payment record model
│   │   └── washing_booking.dart     # Washing machine booking model
│   │
│   ├── ⚙️ services/                 # Business Logic Layer
│   │   ├── auth_service.dart        # Authentication (Email, Google)
│   │   ├── chat_service.dart        # Community chat operations
│   │   ├── cloudinary_service.dart  # Image upload to Cloudinary
│   │   ├── complaint_service.dart   # Complaint CRUD operations
│   │   ├── dinner_vote_service.dart # Dinner voting operations
│   │   ├── notification_service.dart# Push & local notifications
│   │   ├── owner_service.dart       # Owner-specific operations
│   │   ├── payment_service.dart     # Payment & receipt generation
│   │   ├── student_profile_service.dart # Student profile management
│   │   ├── theme_service.dart       # Dark/Light theme management
│   │   └── washing_booking_service.dart # Laundry booking operations
│   │
│   └── 🎨 screens/                  # UI Layer (Presentation)
│       │
│       ├── 🏠 Common
│       │   ├── welcome_screen.dart
│       │   ├── community_chat_screen.dart
│       │   └── notifications_screen.dart
│       │
│       ├── 👨‍🎓 Student Screens
│       │   ├── student_login.dart
│       │   ├── student_register.dart
│       │   ├── student_dashboard.dart
│       │   ├── student_profile_screen.dart
│       │   ├── student_complaint_screen.dart
│       │   ├── student_dinner_voting_screen.dart
│       │   ├── student_payment_history_screen.dart
│       │   └── student_receipt_history_screen.dart
│       │
│       ├── 🏢 Owner Screens
│       │   ├── owner_login.dart
│       │   ├── owner_dashboard.dart
│       │   ├── owner_setup_screen.dart
│       │   ├── owner_settings_screen.dart
│       │   ├── owner_students_list_screen.dart
│       │   ├── owner_student_details_screen.dart
│       │   ├── owner_complaint_list_screen.dart
│       │   ├── owner_dinner_voting_setup_screen.dart
│       │   ├── owner_payment_management_screen.dart
│       │   ├── owner_payment_dashboard_screen.dart
│       │   └── owner_bookings_screen.dart
│       │
│       └── 🧺 Shared Feature Screens
│           └── washing_booking_screen.dart
│
├── 🔧 Configuration Files
│   ├── pubspec.yaml                 # Dependencies
│   ├── firebase.json                # Firebase project config
│   ├── firestore.rules              # Firestore security rules
│   ├── firestore.indexes.json       # Firestore indexes
│   └── storage.rules                # Firebase Storage security rules
│
└── 📱 Platform Specific
    ├── android/                     # Android configuration
    ├── ios/                         # iOS configuration
    ├── web/                         # Web configuration
    ├── windows/                     # Windows configuration
    ├── macos/                       # macOS configuration
    └── linux/                       # Linux configuration
```

---

## 🔐 Security Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           SECURITY LAYERS                                        │
└─────────────────────────────────────────────────────────────────────────────────┘

                    ┌───────────────────────────────────────┐
                    │        🔐 AUTHENTICATION              │
                    │                                       │
                    │  • Firebase Authentication            │
                    │  • Email/Password                     │
                    │  • Google Sign-In                     │
                    │  • Session Management                 │
                    │  • Persistent Login State             │
                    │                                       │
                    └─────────────────┬─────────────────────┘
                                      │
                                      ▼
                    ┌───────────────────────────────────────┐
                    │        🛡️ AUTHORIZATION               │
                    │                                       │
                    │  • Role-based Access Control          │
                    │    - Owner Role                       │
                    │    - Student Role                     │
                    │  • User-specific Data Access          │
                    │  • Route Protection                   │
                    │                                       │
                    └─────────────────┬─────────────────────┘
                                      │
                                      ▼
                    ┌───────────────────────────────────────┐
                    │      📜 FIRESTORE SECURITY RULES      │
                    │                                       │
                    │  • Document-level Access Control      │
                    │  • Field-level Validation             │
                    │  • Request Authentication Check       │
                    │  • Owner/Student Specific Rules       │
                    │                                       │
                    └─────────────────┬─────────────────────┘
                                      │
                                      ▼
                    ┌───────────────────────────────────────┐
                    │      📁 STORAGE SECURITY RULES        │
                    │                                       │
                    │  • Authenticated Upload Only          │
                    │  • User-specific Folders              │
                    │  • File Type Validation               │
                    │  • Size Limits                        │
                    │                                       │
                    └───────────────────────────────────────┘
```

---

## 🎨 State Management

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         STATE MANAGEMENT STRATEGY                                │
└─────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────────┐
│                                                                                   │
│   ┌─────────────────────────────────────────────────────────────────────────┐    │
│   │                          Provider Pattern                                │    │
│   │                      (ChangeNotifier + Provider)                         │    │
│   │                                                                          │    │
│   │  Used for: Theme Management (ThemeService)                               │    │
│   │                                                                          │    │
│   │  ┌──────────────┐         ┌──────────────┐         ┌──────────────┐     │    │
│   │  │ ThemeService │────────▶│   Provider   │────────▶│   Widgets    │     │    │
│   │  │(ChangeNotif) │         │              │         │              │     │    │
│   │  └──────────────┘         └──────────────┘         └──────────────┘     │    │
│   │                                                                          │    │
│   └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                   │
│   ┌─────────────────────────────────────────────────────────────────────────┐    │
│   │                      StreamBuilder Pattern                               │    │
│   │                   (Firebase Real-time Streams)                           │    │
│   │                                                                          │    │
│   │  Used for: All Firebase Data (Chat, Complaints, Payments, etc.)          │    │
│   │                                                                          │    │
│   │  ┌──────────────┐         ┌──────────────┐         ┌──────────────┐     │    │
│   │  │  Firestore   │────────▶│StreamBuilder │────────▶│   Widgets    │     │    │
│   │  │   Streams    │         │              │         │  (rebuild)   │     │    │
│   │  └──────────────┘         └──────────────┘         └──────────────┘     │    │
│   │                                                                          │    │
│   └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                   │
│   ┌─────────────────────────────────────────────────────────────────────────┐    │
│   │                    StatefulWidget Pattern                                │    │
│   │                     (Local Component State)                              │    │
│   │                                                                          │    │
│   │  Used for: Form State, Loading Indicators, UI Toggles                    │    │
│   │                                                                          │    │
│   │  ┌──────────────┐         ┌──────────────┐         ┌──────────────┐     │    │
│   │  │   setState   │────────▶│    State     │────────▶│   Widget     │     │    │
│   │  │   (local)    │         │   Object     │         │  (rebuild)   │     │    │
│   │  └──────────────┘         └──────────────┘         └──────────────┘     │    │
│   │                                                                          │    │
│   └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                   │
└──────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🌐 Platform Support

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         MULTI-PLATFORM SUPPORT                                   │
└─────────────────────────────────────────────────────────────────────────────────┘

                              ┌────────────────┐
                              │   NESTIFY      │
                              │   Flutter App  │
                              └───────┬────────┘
                                      │
        ┌─────────────────────────────┼─────────────────────────────┐
        │                             │                             │
        ▼                             ▼                             ▼
┌───────────────┐           ┌───────────────┐           ┌───────────────┐
│   📱 MOBILE   │           │   💻 DESKTOP  │           │    🌐 WEB     │
│               │           │               │           │               │
│  ┌─────────┐  │           │  ┌─────────┐  │           │  ┌─────────┐  │
│  │ Android │  │           │  │ Windows │  │           │  │ Chrome  │  │
│  └─────────┘  │           │  └─────────┘  │           │  │ Firefox │  │
│               │           │               │           │  │ Safari  │  │
│  ┌─────────┐  │           │  ┌─────────┐  │           │  └─────────┘  │
│  │   iOS   │  │           │  │  macOS  │  │           │               │
│  └─────────┘  │           │  └─────────┘  │           │               │
│               │           │               │           │               │
│               │           │  ┌─────────┐  │           │               │
│               │           │  │  Linux  │  │           │               │
│               │           │  └─────────┘  │           │               │
└───────────────┘           └───────────────┘           └───────────────┘

                    Primary Target: Android & iOS Mobile
```

---

## 📊 Summary

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Frontend** | Flutter + Dart | Cross-platform UI |
| **State Management** | Provider + StreamBuilder | Reactive state |
| **Authentication** | Firebase Auth + Google Sign-In | User auth |
| **Database** | Cloud Firestore | NoSQL real-time DB |
| **Storage** | Firebase Storage + Cloudinary | Files & images |
| **Notifications** | FCM + Local Notifications | Push notifications |
| **PDF Generation** | pdf + printing packages | Receipt generation |

---

*Last Updated: December 2024*
*Built with ❤️ using Flutter & Firebase*
