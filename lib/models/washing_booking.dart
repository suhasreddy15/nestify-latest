import 'package:cloud_firestore/cloud_firestore.dart';

class WashingBooking {
  final String id;
  final String studentId;
  final String studentName;
  final DateTime date;
  final String time;
  final DateTime timestamp;
  final bool notificationSent;
  final bool reminderSent;
  final bool completed;

  WashingBooking({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.time,
    required this.timestamp,
    this.notificationSent = false,
    this.reminderSent = false,
    this.completed = false,
  });

  factory WashingBooking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WashingBooking(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      notificationSent: data['notificationSent'] ?? false,
      reminderSent: data['reminderSent'] ?? false,
      completed: data['completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'date': Timestamp.fromDate(date),
      'time': time,
      'timestamp': Timestamp.fromDate(timestamp),
      'notificationSent': notificationSent,
      'reminderSent': reminderSent,
      'completed': completed,
    };
  }

  // Helper to get date without time for comparison
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);
  
  // Helper to get the end time of the booking (assuming 2-hour slots)
  DateTime get endDateTime {
    final timeParts = time.split(' ');
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    final minute = int.parse(hourMinute[1]);
    final isPM = timeParts[1] == 'PM';
    
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;
    
    // Add 2 hours for washing duration
    final startTime = DateTime(date.year, date.month, date.day, hour, minute);
    return startTime.add(const Duration(hours: 2));
  }
  
  // Check if booking time has passed
  bool get hasEnded => DateTime.now().isAfter(endDateTime);
}
