import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize FCM
  Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      // Get FCM token
      String? token = await _messaging.getToken();
      if (token != null) {
        await saveTokenToFirestore(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(saveTokenToFirestore);
    }
  }

  // Save FCM token to Firestore
  Future<void> saveTokenToFirestore(String token) async {
    // This is a simplified version - you should save to the user's document
    // In production, save token to the authenticated user's document
    print('FCM Token: $token');
    // TODO: Implement token storage in user document
  }

  // Send dinner vote notification to all students
  Future<void> sendDinnerVoteNotification(String dishName) async {
    // Get all student FCM tokens
    final studentsSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    // In a production app, you would use Firebase Cloud Functions or a backend service
    // to send notifications. For now, we'll store the notification in Firestore
    // and use a trigger or manual process to send them.
    
    final notificationData = {
      'title': 'Dinner Voting Open!',
      'body': 'Today\'s dinner: $dishName. Vote before 6 PM!',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'dinner_vote',
      'dishName': dishName,
    };

    // Store notification for each student
    for (var student in studentsSnapshot.docs) {
      await _firestore
          .collection('users')
          .doc(student.id)
          .collection('notifications')
          .add(notificationData);
    }

    print('Notifications sent to ${studentsSnapshot.docs.length} students');
  }

  // Handle foreground messages
  void setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  // Handle background messages
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
  }
}
