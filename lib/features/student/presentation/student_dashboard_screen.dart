
import 'package:flutter/material.dart';
import 'package:nestify/features/authentication/services/auth_service.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  static const routeName = '/student/dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 48),
            const SizedBox(height: 12),
            Text(
              'Welcome to Nestify! Your dashboard goes here.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => AuthService().signOut(),
              child: const Text('Log out'),
            )
          ],
        ),
      ),
    );
  }
}
