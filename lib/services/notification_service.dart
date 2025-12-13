import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

/// Top-level function to handle background messages
/// MUST be a top-level function (not inside a class)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📱 Background message received: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  
  // You can show local notification here if needed
  // The system will automatically show FCM notification
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize FCM and local notifications for logged-in user
  /// Call this after successful login
  Future<void> initialize() async {
    if (_initialized) {
      print('⚠️ NotificationService already initialized');
      return;
    }

    try {
      // 1. Initialize local notifications first
      await _initializeLocalNotifications();

      // 2. Request notification permissions
      final settings = await _requestPermissions();
      
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        print('❌ Notification permission denied');
        return;
      }

      print('✅ Notification permission granted');

      // 3. Get and save FCM token
      await _setupFCMToken();

      // 4. Setup message handlers
      _setupMessageHandlers();

      _initialized = true;
      print('🔔 NotificationService initialized successfully');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  /// Initialize flutter_local_notifications
  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  /// Create high importance notification channel for Android
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'high_importance_channel', // Must match AndroidManifest.xml
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Request notification permissions from user
  Future<NotificationSettings> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
      announcement: false,
    );

    print('📬 Notification permission status: ${settings.authorizationStatus}');
    return settings;
  }

  /// Get FCM token and save to Firestore
  Future<void> _setupFCMToken() async {
    try {
      final token = await _messaging.getToken();
      
      if (token != null) {
        await _saveTokenToFirestore(token);
        print('📱 FCM Token obtained and saved');
      } else {
        print('⚠️ Failed to get FCM token');
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM Token refreshed');
        _saveTokenToFirestore(newToken);
      });
    } catch (e) {
      print('❌ Error setting up FCM token: $e');
    }
  }

  /// Save FCM token to current user's Firestore document
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        print('⚠️ No user logged in, cannot save token');
        return;
      }

      await _firestore.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ FCM token saved to Firestore for user: ${user.uid}');
    } catch (e) {
      print('❌ Error saving token to Firestore: $e');
    }
  }

  /// Setup message handlers for different app states
  void _setupMessageHandlers() {
    // 1. Foreground messages (app is open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground message received');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      
      // Show local notification when app is in foreground
      _showLocalNotification(message);
    });

    // 2. Background messages (app is in background but not killed)
    // Handled by firebaseMessagingBackgroundHandler at top level

    // 3. Terminated state (app was killed and opened by notification tap)
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('🚀 App opened from terminated state by notification');
        _handleNotificationTap(message);
      }
    });

    // 4. Background/inactive state notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 Notification tapped (app was in background)');
      _handleNotificationTap(message);
    });
  }

  /// Show local notification (for foreground messages)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      // Show on lock screen
      visibility: NotificationVisibility.public,
      ticker: 'New notification',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('👆 Handling notification tap');
    print('Data: ${message.data}');
    
    // Navigate to appropriate screen based on notification type
    final type = message.data['type'];
    
    switch (type) {
      case 'dinner_vote':
        print('Navigate to dinner voting screen');
        // TODO: Implement navigation
        break;
      case 'washing_reminder':
      case 'washing_complete':
        print('Navigate to washing booking screen');
        // TODO: Implement navigation
        break;
      default:
        print('Navigate to notifications screen');
    }
  }

  /// Called when local notification is tapped
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Local notification tapped: ${response.payload}');
    // Handle local notification tap
  }

  /// Delete FCM token from Firestore (call on logout)
  Future<void> deleteToken() async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        print('⚠️ No user logged in, cannot delete token');
        return;
      }

      // Delete FCM token from Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': FieldValue.delete(),
      });

      // Delete token from FCM
      await _messaging.deleteToken();

      _initialized = false;
      print('🗑️ FCM token deleted successfully');
    } catch (e) {
      print('❌ Error deleting token: $e');
    }
  }

  /// Cleanup - call on logout
  Future<void> cleanup() async {
    await deleteToken();
    _initialized = false;
    print('🧹 NotificationService cleaned up');
  }

  // ==================== NOTIFICATION SENDING METHODS ====================

  /// Send dinner vote notification to all students
  Future<void> sendDinnerVoteNotification(String dishName) async {
    try {
      // Get all students
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      if (studentsSnapshot.docs.isEmpty) {
        print('No students found to send notifications');
        return;
      }

      // Get current time
      final now = DateTime.now();
      final votingDeadline = DateTime(now.year, now.month, now.day, 18, 0); // 6 PM
      final hoursLeft = votingDeadline.difference(now).inHours;
      final minutesLeft = votingDeadline.difference(now).inMinutes % 60;

      String timeLeftMessage = '';
      if (hoursLeft > 0) {
        timeLeftMessage = 'Vote within $hoursLeft hour${hoursLeft > 1 ? 's' : ''}!';
      } else if (minutesLeft > 0) {
        timeLeftMessage = 'Only $minutesLeft minute${minutesLeft > 1 ? 's' : ''} left!';
      } else {
        timeLeftMessage = 'Vote now!';
      }

      final notificationData = {
        'title': '🍽️ Dinner Voting is Open!',
        'body': 'Today\'s dinner: $dishName. $timeLeftMessage Voting closes at 6 PM.',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'dinner_vote',
        'dishName': dishName,
        'read': false,
      };

      int successCount = 0;
      // Store notification for each student
      for (var student in studentsSnapshot.docs) {
        try {
          // Add to user's notifications subcollection
          await _firestore
              .collection('users')
              .doc(student.id)
              .collection('notifications')
              .add(notificationData);

          // Also add to general notifications collection for easy querying
          await _firestore
              .collection('notifications')
              .add({
                ...notificationData,
                'studentId': student.id,
                'studentName': student.data()['fullName'] ?? 'Unknown',
              });

          successCount++;
        } catch (e) {
          print('Error sending notification to ${student.id}: $e');
        }
      }

      print('✅ Dinner voting notifications sent to $successCount/${studentsSnapshot.docs.length} students');
      print('📌 Dish: $dishName');
      print('⏰ Deadline: 6:00 PM');
    } catch (e) {
      print('❌ Error sending dinner vote notifications: $e');
      rethrow;
    }
  }

  // Send dinner voting reminder notification (30 minutes before closing)
  Future<void> sendDinnerVotingReminderNotification(String dishName) async {
    try {
      // Get all students who haven't voted yet
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Get today's vote
      final voteSnapshot = await _firestore
          .collection('dinner_votes')
          .where('date', isEqualTo: Timestamp.fromDate(today))
          .limit(1)
          .get();

      if (voteSnapshot.docs.isEmpty) return;
      
      final voteId = voteSnapshot.docs.first.id;
      
      // Get all students
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      // Get students who have already voted
      final votedStudentsSnapshot = await _firestore
          .collection('dinner_votes')
          .doc(voteId)
          .collection('responses')
          .get();

      final votedStudentIds = votedStudentsSnapshot.docs.map((doc) => doc.id).toSet();

      final notificationData = {
        'title': '⏰ Dinner Voting Reminder!',
        'body': 'Only 30 minutes left to vote for today\'s dinner: $dishName. Vote closes at 6 PM!',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'dinner_vote_reminder',
        'dishName': dishName,
        'read': false,
      };

      int reminderCount = 0;
      // Send reminder only to students who haven't voted
      for (var student in studentsSnapshot.docs) {
        if (!votedStudentIds.contains(student.id)) {
          try {
            await _firestore
                .collection('users')
                .doc(student.id)
                .collection('notifications')
                .add(notificationData);
            reminderCount++;
          } catch (e) {
            print('Error sending reminder to ${student.id}: $e');
          }
        }
      }

      print('📢 Dinner voting reminders sent to $reminderCount students');
    } catch (e) {
      print('Error sending dinner voting reminder: $e');
    }
  }

  // Send washing machine completion notification to specific student
  Future<void> sendWashingCompletionNotification(String studentId, String timeSlot) async {
    final notificationData = {
      'title': 'Washing Complete! 🎉',
      'body': 'Your washing machine time slot ($timeSlot) has ended. Please collect your laundry.',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'washing_complete',
      'timeSlot': timeSlot,
      'read': false,
    };

    // Store notification for the student
    await _firestore
        .collection('users')
        .doc(studentId)
        .collection('notifications')
        .add(notificationData);

    // Also add to a general notifications collection for easy querying
    await _firestore
        .collection('notifications')
        .add({
          ...notificationData,
          'studentId': studentId,
        });

    print('Washing completion notification sent to student: $studentId for time: $timeSlot');
  }

  // Send reminder notification 10 minutes before washing time
  Future<void> sendWashingReminderNotification(String studentId, String timeSlot) async {
    final notificationData = {
      'title': 'Washing Machine Reminder ⏰',
      'body': 'Your washing machine slot starts in 10 minutes ($timeSlot). Please be ready!',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'washing_reminder',
      'timeSlot': timeSlot,
      'read': false,
    };

    // Store notification for the student
    await _firestore
        .collection('users')
        .doc(studentId)
        .collection('notifications')
        .add(notificationData);

    print('Washing reminder notification sent to student: $studentId for time: $timeSlot');
  }

  // Send notification to other students when someone books a laundry slot
  Future<void> sendLaundryBookingNotification({
    required String bookerName,
    required String date,
    required String time,
    required String excludeUserId,
  }) async {
    try {
      // Get all students except the one who booked
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      if (studentsSnapshot.docs.isEmpty) {
        print('No students found to send laundry booking notifications');
        return;
      }

      final notificationData = {
        'title': '🧺 Laundry Slot Booked',
        'body': '$bookerName booked the washing machine for $date at $time. Book your slot now!',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'laundry_booking',
        'bookerName': bookerName,
        'date': date,
        'time': time,
        'read': false,
      };

      int successCount = 0;
      for (var student in studentsSnapshot.docs) {
        // Skip the student who made the booking
        if (student.id == excludeUserId) continue;

        try {
          // Add to user's notifications subcollection
          await _firestore
              .collection('users')
              .doc(student.id)
              .collection('notifications')
              .add(notificationData);

          successCount++;
        } catch (e) {
          print('Error sending laundry notification to ${student.id}: $e');
        }
      }

      print('✅ Laundry booking notifications sent to $successCount students');
      print('📌 Booked by: $bookerName for $date at $time');
    } catch (e) {
      print('❌ Error sending laundry booking notifications: $e');
      rethrow;
    }
  }
}
