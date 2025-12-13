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

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0+
- Firebase account

### Installation

1. **Clone and install**
   ```bash
   git clone https://github.com/suhasreddy15/nestify.git
   cd nestify
   flutter pub get
   ```

2. **Firebase setup**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```

3. **Run the app**
   ```bash
   flutter run -d chrome    # Web
   flutter run              # Android/iOS
   ```

   Or use the PowerShell script:
   ```powershell
   .\run.ps1
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
# Firebase
firebase_core: ^3.15.2
firebase_auth: ^5.7.0
cloud_firestore: ^5.6.12
firebase_storage: ^12.4.10
firebase_messaging: ^15.2.10

# UI & Utilities
google_sign_in: ^6.3.0
pdf: ^3.11.0
file_picker: ^8.3.7
intl: ^0.19.0
cloudinary_public: ^0.23.1    # Image optimization
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

For detailed feature guides:
- [Community Chat](COMMUNITY_CHAT_FEATURE.md)
- [Complaint System](COMPLAINT_FEATURE.md)
- [Dinner Voting](DINNER_VOTING_FEATURE.md)
- [Washing Machine Booking](WASHING_BOOKING_FEATURE.md)
- [Student Profile](STUDENT_PROFILE_FEATURE.md)
- [Payment Management](PAYMENT_MANAGEMENT_README.md)
- [Push Notifications](PUSH_NOTIFICATIONS_QUICKSTART.md)
- [Recent Fixes](LAUNDRY_BOOKING_FIX.md)
- [Troubleshooting](TROUBLESHOOTING.md)

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

For issues or questions:
- Open an issue on [GitHub](https://github.com/suhasreddy15/nestify/issues)
- Check [Troubleshooting Guide](TROUBLESHOOTING.md)

---

<div align="center">

**Made with ❤️ using Flutter**

⭐ Star this repo if you find it helpful!

[Report Bug](https://github.com/suhasreddy15/nestify/issues) • [Request Feature](https://github.com/suhasreddy15/nestify/issues)

</div>
