import 'package:cloud_firestore/cloud_firestore.dart';

class WashingBooking {
  final String id;
  final String studentId;
  final String studentName;
  final DateTime date;
  final String time;
  final DateTime timestamp;

  WashingBooking({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.time,
    required this.timestamp,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'date': Timestamp.fromDate(date),
      'time': time,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Helper to get date without time for comparison
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);
}
