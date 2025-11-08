import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String id;
  final String title;
  final String description;
  final String studentId;
  final String studentEmail;
  final DateTime timestamp;
  final String status; // 'pending' or 'resolved'

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.studentId,
    required this.studentEmail,
    required this.timestamp,
    required this.status,
  });

  // Create a Complaint from Firestore document
  factory Complaint.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Complaint(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      studentId: data['studentId'] ?? '',
      studentEmail: data['studentEmail'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }

  // Convert Complaint to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'studentId': studentId,
      'studentEmail': studentEmail,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
    };
  }

  // Create a copy with updated fields
  Complaint copyWith({
    String? id,
    String? title,
    String? description,
    String? studentId,
    String? studentEmail,
    DateTime? timestamp,
    String? status,
  }) {
    return Complaint(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      studentId: studentId ?? this.studentId,
      studentEmail: studentEmail ?? this.studentEmail,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}
