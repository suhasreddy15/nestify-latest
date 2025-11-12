import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart'; // Uncomment after running: flutter pub get
import 'package:nestify/firebase_options.dart';
import 'package:nestify/screens/owner_dashboard.dart';
import 'package:nestify/services/auth_service.dart';
import 'package:nestify/services/theme_service.dart';
import 'package:nestify/screens/student_login.dart';
import 'package:nestify/screens/student_register.dart';
import 'package:nestify/screens/owner_login.dart';
import 'package:nestify/screens/welcome_screen.dart';
import 'package:nestify/screens/student_dashboard.dart';
import 'package:nestify/screens/student_complaint_screen.dart';
import 'package:nestify/screens/owner_complaint_list_screen.dart';
import 'package:nestify/screens/community_chat_screen.dart';
import 'package:nestify/screens/owner_dinner_voting_setup_screen.dart';
import 'package:nestify/screens/student_dinner_voting_screen.dart';
import 'package:nestify/screens/washing_booking_screen.dart';
import 'package:nestify/screens/owner_bookings_screen.dart';
import 'package:nestify/screens/student_profile_screen.dart';
import 'package:nestify/screens/owner_student_details_screen.dart';
import 'package:nestify/screens/owner_students_list_screen.dart';
import 'package:nestify/screens/owner_payment_management_screen.dart';
import 'package:nestify/screens/student_payment_history_screen.dart';
import 'package:nestify/screens/owner_setup_screen.dart';
import 'package:nestify/services/owner_service.dart';
import 'package:nestify/services/washing_booking_service.dart';
import 'package:nestify/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Register background message handler for FCM
  // MUST be registered before runApp()
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // DON'T start notification checker here - it will start after login
  // This prevents errors when no user is authenticated
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const MyApp(),
    ),
  );
}

// Global timer reference to prevent multiple instances
Timer? _notificationTimer;

// Background task to check washing booking and dinner voting notifications
void startNotificationChecker() {
  // Don't start if already running
  if (_notificationTimer != null && _notificationTimer!.isActive) {
    print('🔔 Notification checker already running');
    return;
  }
  
  final washingService = WashingBookingService();
  
  // Check every minute
  _notificationTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
    try {
      // Check washing machine notifications
      await washingService.checkAndSendCompletionNotifications();
      await washingService.checkAndSendReminderNotifications();
      
      // Check dinner voting reminder (sent at 5:30 PM)
      await washingService.checkAndSendDinnerVotingReminder();
    } catch (e) {
      print('❌ Error checking notifications: $e');
    }
  });
  
  print('🔔 Notification checker started - Running every minute');
}

// Stop notification checker (call on logout)
void stopNotificationChecker() {
  if (_notificationTimer != null) {
    _notificationTimer!.cancel();
    _notificationTimer = null;
    print('🔕 Notification checker stopped');
  }
}

// Initialize FCM notifications for logged-in user
void _initializeNotificationsForUser() {
  NotificationService().initialize().catchError((error) {
    print('❌ Failed to initialize notifications: $error');
  });
}

// Cleanup notifications on logout
Future<void> _cleanupNotifications() async {
  try {
    await NotificationService().cleanup();
  } catch (e) {
    print('❌ Error cleaning up notifications: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    
    return MaterialApp(
      title: 'Nestify',
      themeMode: themeService.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // textTheme: GoogleFonts.poppinsTextTheme(), // Uncomment after running: flutter pub get
        fontFamily: 'Poppins', // Will work once google_fonts is installed
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        StudentLoginScreen.routeName: (context) => const StudentLoginScreen(),
        StudentRegisterScreen.routeName: (context) => const StudentRegisterScreen(),
        OwnerLoginScreen.routeName: (context) => const OwnerLoginScreen(),
        WelcomeScreen.routeName: (context) => const WelcomeScreen(),
        StudentDashboardScreen.routeName: (context) =>
            const StudentDashboardScreen(),
        OwnerDashboardScreen.routeName: (context) => const OwnerDashboardScreen(),
        StudentComplaintScreen.routeName: (context) =>
            const StudentComplaintScreen(),
        OwnerComplaintListScreen.routeName: (context) =>
            const OwnerComplaintListScreen(),
        CommunityChatScreen.routeName: (context) => const CommunityChatScreen(),
        '/owner/dinner-voting-setup': (context) =>
            const DinnerVotingSetupScreen(),
        '/student/dinner-voting': (context) => const DinnerVotingScreen(),
        '/student/washing-booking': (context) => const WashingBookingScreen(),
        '/owner/bookings': (context) => const OwnerBookingsScreen(),
        '/student/profile': (context) => const StudentProfileScreen(),
        '/owner/student-details': (context) =>
            const OwnerStudentDetailsScreen(),
        '/owner/students': (context) => const OwnerStudentsListScreen(),
        '/owner/payments': (context) => const OwnerPaymentManagementScreen(),
        '/student/payments': (context) => const StudentPaymentHistoryScreen(),
        OwnerSetupScreen.routeName: (context) => const OwnerSetupScreen(),
      },
    );
  }
}

/// AuthWrapper provides persistent login functionality
/// 
/// How it works:
/// 1. Uses StreamBuilder with Firebase Auth's authStateChanges() stream
/// 2. Firebase Auth automatically persists user sessions locally
/// 3. When app starts, if user previously logged in, stream emits User object
/// 4. If user is logged out, stream emits null
/// 5. This allows automatic re-authentication without re-entering credentials
/// 
/// Flow:
/// - App Launch → Check Firebase Auth → User found? → Go to Dashboard
/// - App Launch → Check Firebase Auth → No user? → Show Welcome/Login
/// - User Logout → Firebase Auth cleared → Stream emits null → Show Welcome
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.user, // This stream enables persistent login!
      builder: (context, userSnapshot) {
        // Show loading while checking authentication state
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Checking authentication...'),
                ],
              ),
            ),
          );
        }

        // User is authenticated (persistent login active!)
        if (userSnapshot.hasData) {
          // Start background notification checker for authenticated user
          startNotificationChecker();
          
          // Initialize FCM notifications for logged-in user
          _initializeNotificationsForUser();
          
          return FutureBuilder<UserRole?>(
            future: authService.getUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (roleSnapshot.hasData) {
                final role = roleSnapshot.data;
                if (role == UserRole.owner) {
                  // Check if owner has completed setup
                  return FutureBuilder<bool>(
                    future: OwnerService().isOwnerSetupComplete(),
                    builder: (context, setupSnapshot) {
                      if (setupSnapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }
                      
                      if (setupSnapshot.hasData && setupSnapshot.data == true) {
                        return const OwnerDashboardScreen();
                      } else {
                        return const OwnerSetupScreen();
                      }
                    },
                  );
                } else {
                  return const StudentDashboardScreen();
                }
              } else {
                // If no role found, default to student dashboard
                // This handles cases where user document doesn't exist yet
                return const StudentDashboardScreen();
              }
            },
          );
        }

        // No user authenticated - show welcome/login screen
        // User will see this when:
        // 1. First time opening app (never logged in)
        // 2. After clicking logout
        // 3. Session expired (rare with Firebase Auth)
        stopNotificationChecker();
        _cleanupNotifications(); // Cleanup FCM token and listeners
        return const WelcomeScreen();
      },
    );
  }
}
