
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
      debugShowCheckedModeBanner: false, // Removes debug banner
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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userSnapshot.hasData) {
          startNotificationChecker();
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
                  return const OwnerDashboardScreen();
                } else {
                  return const StudentDashboardScreen();
                }
              } else {
                // If no role is found, something is wrong with the user's data.
                // It's safer to log them out and show an error.
                return const RoleErrorScreen();
              }
            },
          );
        }

        // No user authenticated - show welcome screen
        stopNotificationChecker();
        _cleanupNotifications();
        return const WelcomeScreen();
      },
    );
  }
}

/// A screen to show when a user's role cannot be determined.
/// This is a failsafe to prevent users from getting stuck.
class RoleErrorScreen extends StatelessWidget {
  const RoleErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Error Loading Profile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'We couldn\'t determine your user role. This might be a temporary issue. Please try signing out and signing back in.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                onPressed: () async {
                  await AuthService().signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
