# 🏠 Nestify - Smart PG Management System

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A comprehensive mobile application for managing PG (Paying Guest) accommodations with real-time features and seamless user experience.**

[Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Tech Stack](#-tech-stack) • [Contributing](#-contributing)

</div>

---

## ✨ Features

### 👨‍💼 For PG Owners

- 🏢 **Dashboard Management** - Centralized control panel for all PG operations
- 📋 **Complaint Management** - View and resolve student complaints with status tracking
- 🍽️ **Dinner Voting Setup** - Create daily dinner polls with multiple menu options
- 🧺 **Washing Bookings** - Monitor washing machine booking schedules
- 👥 **Student Management** - View student profiles, documents, and verification status
- 💳 **Payment Management** - Record payments and auto-generate PDF receipts
  - Professional receipt generation with PG branding
  - Firebase Storage integration for receipt storage
  - Payment history tracking with detailed records

### 🎓 For Students

- 📱 **Mobile-Optimized Dashboard** - Clean grid layout with intuitive icons
- 📝 **Complaint System** - Submit and track complaints with status updates
- 💬 **Community Chat** - Real-time messaging with all residents
- 🗳️ **Dinner Voting** - Vote for daily dinner preferences
- ⏰ **Washing Machine Booking** - Reserve time slots for washing machine usage
- 👤 **Profile Management** - Update personal information and upload Aadhaar documents
- 💰 **Payment History** - View payment records and download receipts
  - Total amount paid summary
  - Downloadable PDF receipts
  - Payment date tracking

---

## 🎯 Key Highlights

| Feature | Description |
|---------|-------------|
| 🔐 **Dual Authentication** | Separate login flows for owners and students |
| ⚡ **Real-time Updates** | Firebase Firestore for instant data synchronization |
| 📄 **Document Management** | Secure Aadhaar upload with Firebase Storage |
| 🧾 **Receipt Generation** | Automated PDF receipt creation with professional formatting |
| 🎨 **Material Design 3** | Modern, beautiful UI with gradient cards and animations |
| 📱 **Responsive Layout** | Optimized for mobile devices with grid-based navigation |
| 🔔 **Push Notifications** | Firebase Cloud Messaging for important updates |

---

## 📱 Screenshots

<div align="center">

### Student Dashboard
Grid-based mobile-friendly interface with 6 key features

### Owner Dashboard  
Comprehensive management cards for all PG operations

### Payment Management
Professional PDF receipt generation with Firebase Storage

</div>

---

## 🚀 Installation

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 2.19 or higher
- Android Studio / VS Code with Flutter extensions
- Firebase account with project setup

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/suhasreddy15/nestify.git
   cd nestify
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add Android/iOS/Web apps to your Firebase project
   - Download `google-services.json` (Android) and place in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`
   - Run FlutterFire CLI:
     ```bash
     flutterfire configure
     ```

4. **Enable Firebase Services**
   - Authentication (Email/Password & Google Sign-In)
   - Cloud Firestore
   - Firebase Storage
   - Cloud Messaging (optional)

5. **Run the app**
   ```bash
   # For web
   flutter run -d chrome
   
   # For Android
   flutter run -d <device-id>
   
   # For iOS
   flutter run -d <device-id>
   ```

---

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Material Design 3** - Modern design system
- **Dart** - Programming language

### Backend & Services
- **Firebase Authentication** - User authentication & authorization
- **Cloud Firestore** - NoSQL real-time database
- **Firebase Storage** - File storage for documents and receipts
- **Firebase Cloud Messaging** - Push notifications

### Key Packages
```yaml
firebase_core: ^2.32.0
firebase_auth: ^4.20.0
cloud_firestore: ^4.17.5
firebase_storage: ^11.7.7
firebase_messaging: ^14.9.4
google_sign_in: ^6.3.0
pdf: ^3.10.8                    # PDF receipt generation
printing: ^5.13.1               # PDF printing utilities
path_provider: ^2.1.2           # File system paths
file_picker: ^6.2.1             # File selection
url_launcher: ^6.3.1            # Open URLs/files
intl: ^0.19.0                   # Date formatting
```

---

## 📂 Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
├── models/                      # Data models
│   └── payment.dart
├── screens/                     # UI screens
│   ├── welcome_screen.dart
│   ├── student_login.dart
│   ├── student_register.dart
│   ├── student_dashboard.dart
│   ├── student_profile_screen.dart
│   ├── student_payment_history_screen.dart
│   ├── owner_login.dart
│   ├── owner_dashboard.dart
│   ├── owner_payment_management_screen.dart
│   ├── owner_student_details_screen.dart
│   └── ... (other feature screens)
└── services/                    # Business logic
    ├── auth_service.dart
    ├── payment_service.dart
    ├── student_profile_service.dart
    └── notification_service.dart
```

---

## 🔥 Firebase Collections

### Users Collection
```javascript
users/{userId}
  - email: string
  - fullName: string
  - role: "student" | "owner"
  - phoneNumber: string (optional)
  - roomNumber: string (optional)
  - aadhaarUrl: string (optional)
  - createdAt: timestamp
```

### Payments Collection
```javascript
payments/{paymentId}
  - studentId: string
  - studentName: string
  - studentEmail: string
  - amount: number
  - paymentDate: timestamp
  - receiptUrl: string
  - createdBy: string
  - createdAt: timestamp
  - roomNumber: string
```

### Other Collections
- `complaints` - Student complaints with status tracking
- `dinnerVoting` - Daily dinner polls and votes
- `washingBookings` - Washing machine time slot reservations
- `messages` - Community chat messages

---

## 🎨 Features in Detail

### Payment Management System
- **Owner Side:**
  - Select student from dropdown
  - Enter payment amount
  - Choose payment date
  - Auto-generate professional PDF receipt
  - Upload to Firebase Storage
  - View payment history with search/filter

- **Student Side:**
  - View all payments with dates
  - Total paid amount summary card
  - Download PDF receipts
  - Payment status indicators

### Student Profile System
- Personal information management
- Aadhaar document upload (PDF/Image)
- Document verification by owner
- Profile picture support
- Real-time profile updates

### Complaint System
- Submit complaints with descriptions
- Real-time status tracking (Pending/In Progress/Resolved)
- Owner dashboard for complaint management
- Status update notifications

---

## 🚦 Getting Started for Developers

### Running in Development Mode
```bash
flutter run --debug
```

### Building for Production
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

---

## 📖 Documentation

Detailed documentation for specific features:
- [Payment Management Guide](PAYMENT_MANAGEMENT_README.md)
- Firebase Security Rules (see Firebase Console)
- API Documentation (coming soon)

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

- **Suhas Reddy** - [@suhasreddy15](https://github.com/suhasreddy15)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Material Design team for design guidelines
- All contributors and supporters

---

## 📞 Support

For support, email your-email@example.com or open an issue in the repository.

---

<div align="center">

**Made with ❤️ using Flutter**

⭐ Star this repo if you find it helpful!

[Report Bug](https://github.com/suhasreddy15/nestify/issues) • [Request Feature](https://github.com/suhasreddy15/nestify/issues)

</div>
