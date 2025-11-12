import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/washing_booking.dart';
import 'notification_service.dart';

class WashingBookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  // Create a new washing booking
  Future<void> createBooking(DateTime date, String time) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if slot is already booked
    final isBooked = await isSlotBooked(date, time);
    if (isBooked) {
      throw Exception('This time slot is already booked. Please choose another time.');
    }

    // Get student name from users collection
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final studentName = userDoc.data()?['fullName'] ?? 'Unknown Student';

    // Create booking
    final bookingData = WashingBooking(
      id: '',
      studentId: user.uid,
      studentName: studentName,
      date: date,
      time: time,
      timestamp: DateTime.now(),
    ).toMap();

    await _firestore.collection('washing_bookings').add(bookingData);
  }

  // Check if a specific slot is already booked
  Future<bool> isSlotBooked(DateTime date, String time) async {
    final dateOnly = DateTime(date.year, date.month, date.day);

    // Get all bookings and filter in Dart to avoid complex query
    final snapshot = await _firestore
        .collection('washing_bookings')
        .where('time', isEqualTo: time)
        .get();

    // Check if any booking matches the date
    for (var doc in snapshot.docs) {
      final booking = WashingBooking.fromFirestore(doc);
      if (booking.dateOnly.isAtSameMomentAs(dateOnly)) {
        return true;
      }
    }

    return false;
  }

  // Get current student's bookings
  Stream<List<WashingBooking>> getStudentBookings() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('washing_bookings')
        .where('studentId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          
          // Filter upcoming bookings in Dart instead of Firestore
          return snapshot.docs
              .map((doc) => WashingBooking.fromFirestore(doc))
              .where((booking) => 
                booking.date.isAfter(today) || 
                booking.dateOnly.isAtSameMomentAs(today))
              .toList()
            ..sort((a, b) {
              final dateCompare = a.date.compareTo(b.date);
              if (dateCompare != 0) return dateCompare;
              return a.time.compareTo(b.time);
            });
        });
  }

  // Get all bookings (for owner)
  Stream<List<WashingBooking>> getAllBookings() {
    return _firestore
        .collection('washing_bookings')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          
          // Filter upcoming bookings in Dart
          return snapshot.docs
              .map((doc) => WashingBooking.fromFirestore(doc))
              .where((booking) => 
                booking.date.isAfter(today) || 
                booking.dateOnly.isAtSameMomentAs(today))
              .toList()
            ..sort((a, b) {
              final dateCompare = a.date.compareTo(b.date);
              if (dateCompare != 0) return dateCompare;
              return a.time.compareTo(b.time);
            });
        });
  }

  // Get bookings for a specific date
  Stream<List<WashingBooking>> getBookingsByDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);

    return _firestore
        .collection('washing_bookings')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          // Filter bookings for the specific date in Dart
          return snapshot.docs
              .map((doc) => WashingBooking.fromFirestore(doc))
              .where((booking) => booking.dateOnly.isAtSameMomentAs(dateOnly))
              .toList()
            ..sort((a, b) => a.time.compareTo(b.time));
        });
  }

  // Delete a booking (student can cancel their own booking)
  Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection('washing_bookings').doc(bookingId).delete();
  }

  // Get booking count for a specific date (for owner statistics)
  Future<int> getBookingCountForDate(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final nextDay = dateOnly.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('washing_bookings')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dateOnly))
        .where('date', isLessThan: Timestamp.fromDate(nextDay))
        .get();

    return snapshot.docs.length;
  }

  // Check and send notifications for completed bookings
  Future<void> checkAndSendCompletionNotifications() async {
    final now = DateTime.now();
    
    // Get all bookings that have ended but notification not sent
    final snapshot = await _firestore
        .collection('washing_bookings')
        .where('completed', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      final booking = WashingBooking.fromFirestore(doc);
      
      // Check if booking time has ended
      if (booking.hasEnded && !booking.notificationSent) {
        // Send completion notification
        await _notificationService.sendWashingCompletionNotification(
          booking.studentId,
          booking.time,
        );
        
        // Mark as notification sent and completed
        await _firestore.collection('washing_bookings').doc(doc.id).update({
          'notificationSent': true,
          'completed': true,
        });
        
        print('Sent completion notification for booking ${doc.id}');
      }
    }
  }

  // Check and send reminder notifications (10 minutes before)
  Future<void> checkAndSendReminderNotifications() async {
    final now = DateTime.now();
    final in10Minutes = now.add(const Duration(minutes: 10));
    
    // Get all bookings
    final snapshot = await _firestore
        .collection('washing_bookings')
        .where('reminderSent', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      final booking = WashingBooking.fromFirestore(doc);
      
      // Parse booking start time
      final timeParts = booking.time.split(' ');
      final hourMinute = timeParts[0].split(':');
      int hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);
      final isPM = timeParts[1] == 'PM';
      
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      
      final bookingStartTime = DateTime(
        booking.date.year,
        booking.date.month,
        booking.date.day,
        hour,
        minute,
      );
      
      // Check if booking is within 10 minutes
      if (bookingStartTime.isAfter(now) && 
          bookingStartTime.isBefore(in10Minutes) &&
          !booking.reminderSent) {
        
        // Send reminder notification
        await _notificationService.sendWashingReminderNotification(
          booking.studentId,
          booking.time,
        );
        
        // Mark as reminder sent
        await _firestore.collection('washing_bookings').doc(doc.id).update({
          'reminderSent': true,
        });
        
        print('Sent reminder notification for booking ${doc.id}');
      }
    }
  }

  // Check and send dinner voting reminder (30 minutes before deadline)
  Future<void> checkAndSendDinnerVotingReminder() async {
    final now = DateTime.now();
    final reminderTime = DateTime(now.year, now.month, now.day, 17, 30); // 5:30 PM
    final reminderEndTime = reminderTime.add(const Duration(minutes: 2));
    
    // Check if it's time to send reminder (between 5:30 and 5:32 PM)
    if (now.isAfter(reminderTime) && now.isBefore(reminderEndTime)) {
      final today = DateTime(now.year, now.month, now.day);
      
      // Check if today's vote exists and reminder not sent
      final voteSnapshot = await _firestore
          .collection('dinner_votes')
          .where('date', isEqualTo: Timestamp.fromDate(today))
          .where('reminderSent', isEqualTo: false)
          .limit(1)
          .get();

      if (voteSnapshot.docs.isNotEmpty) {
        final voteDoc = voteSnapshot.docs.first;
        final dishName = voteDoc.data()['dishName'] ?? 'Today\'s dinner';
        
        // Send reminder notification
        await _notificationService.sendDinnerVotingReminderNotification(dishName);
        
        // Mark reminder as sent
        await _firestore
            .collection('dinner_votes')
            .doc(voteDoc.id)
            .update({'reminderSent': true});
        
        print('Sent dinner voting reminder notification');
      }
    }
  }

  // Start periodic check for notifications (call this from main app)
  Stream<void> startNotificationChecker() async* {
    while (true) {
      await Future.delayed(const Duration(minutes: 1));
      await checkAndSendCompletionNotifications();
      await checkAndSendReminderNotifications();
      await checkAndSendDinnerVotingReminder();
      yield null;
    }
  }
}
