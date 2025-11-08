import 'package:flutter/material.dart';
import 'owner_login.dart';
import 'student_login.dart';

class WelcomeScreen extends StatelessWidget {
  // A 'routeName' is a good practice for easily referencing the screen
  // from other parts of your app, just like you did in main.dart.
  static const String routeName = '/welcome';

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Using a Padding widget to give some space around the buttons
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            // This centers the buttons vertically on the screen
            mainAxisAlignment: MainAxisAlignment.center,
            // This makes the buttons stretch to fill the width
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // A title for your welcome screen
              const Text(
                'Welcome to Nestify',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please select your role to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48), // Provides space between text and buttons

              // Button for Owner Login
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                // When pressed, this will navigate to the OwnerLoginScreen
                onPressed: () {
                  Navigator.pushNamed(context, OwnerLoginScreen.routeName);
                },
                child: const Text('Login as Owner'),
              ),
              const SizedBox(height: 24), // Provides space between the two buttons

              // Button for Student Login
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                // When pressed, this will navigate to the StudentLoginScreen
                onPressed: () {
                  Navigator.pushNamed(context, StudentLoginScreen.routeName);
                },
                child: const Text('Login as Student'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
