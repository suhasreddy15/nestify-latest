
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nestify/firebase_options.dart';
import 'package:nestify/screens/owner_dashboard.dart';
import 'package:nestify/services/auth_service.dart';
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
import 'package:nestify/screens/owner_payment_management_screen.dart';
import 'package:nestify/screens/student_payment_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nestify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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
        '/owner/payments': (context) => const OwnerPaymentManagementScreen(),
        '/student/payments': (context) => const StudentPaymentHistoryScreen(),
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
                // If no role found, default to student dashboard
                // This handles cases where user document doesn't exist yet
                return const StudentDashboardScreen();
              }
            },
          );
        }

        return const WelcomeScreen();
      },
    );
  }
}
