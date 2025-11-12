import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final double amount;
  final DateTime paymentDate;
  final String receiptUrl;
  final String createdBy;
  final DateTime createdAt;
  final String? roomNumber;
  final String status; // 'paid' or 'pending'
  final String? paymentMethod; // Optional: 'cash', 'online', 'upi', etc.

  Payment({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.amount,
    required this.paymentDate,
    required this.receiptUrl,
    required this.createdBy,
    required this.createdAt,
    this.roomNumber,
    this.status = 'paid', // Default to paid for backward compatibility
    this.paymentMethod,
  });

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      studentEmail: data['studentEmail'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      paymentDate: (data['paymentDate'] as Timestamp).toDate(),
      receiptUrl: data['receiptUrl'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      roomNumber: data['roomNumber'],
      status: data['status'] ?? 'paid',
      paymentMethod: data['paymentMethod'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'amount': amount,
      'paymentDate': Timestamp.fromDate(paymentDate),
      'receiptUrl': receiptUrl,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'roomNumber': roomNumber,
      'status': status,
      'paymentMethod': paymentMethod,
    };
  }
}
