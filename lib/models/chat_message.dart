import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String message;
  final String senderName;
  final String senderId;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.message,
    required this.senderName,
    required this.senderId,
    required this.timestamp,
  });

  // Create a ChatMessage from Firestore document
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Handle null timestamp (occurs when message is just created)
    DateTime messageTime;
    if (data['timestamp'] != null) {
      messageTime = (data['timestamp'] as Timestamp).toDate();
    } else {
      messageTime = DateTime.now();
    }
    
    return ChatMessage(
      id: doc.id,
      message: data['message'] ?? '',
      senderName: data['senderName'] ?? 'Unknown',
      senderId: data['senderId'] ?? '',
      timestamp: messageTime,
    );
  }

  // Convert ChatMessage to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'senderName': senderName,
      'senderId': senderId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
