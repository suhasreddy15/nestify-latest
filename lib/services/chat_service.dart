import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nestify/models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Send a message to the community chat
  Future<void> sendMessage(String message) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      if (message.trim().isEmpty) {
        throw Exception('Message cannot be empty');
      }

      // Get user's display name from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final senderName = userData?['fullName'] ?? user.email?.split('@')[0] ?? 'Student';

      await _firestore.collection('community_chat').add({
        'message': message.trim(),
        'senderName': senderName,
        'senderId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get stream of chat messages ordered by timestamp
  Stream<List<ChatMessage>> getChatMessages() {
    return _firestore
        .collection('community_chat')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return ChatMessage.fromFirestore(doc);
            } catch (e) {
              // Skip messages with invalid data
              return null;
            }
          })
          .where((message) => message != null)
          .cast<ChatMessage>()
          .toList();
    });
  }

  // Get limited messages (for initial load)
  Stream<List<ChatMessage>> getRecentMessages({int limit = 50}) {
    return _firestore
        .collection('community_chat')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map((doc) {
            try {
              return ChatMessage.fromFirestore(doc);
            } catch (e) {
              return null;
            }
          })
          .where((message) => message != null)
          .cast<ChatMessage>()
          .toList();
      
      // Reverse to show oldest first
      return messages.reversed.toList();
    });
  }

  // Delete a message (optional - only if user is the sender)
  Future<void> deleteMessage(String messageId, String senderId) async {
    try {
      final user = currentUser;
      if (user == null || user.uid != senderId) {
        throw Exception('Unauthorized to delete this message');
      }

      await _firestore.collection('community_chat').doc(messageId).delete();
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  // Get message count
  Future<int> getMessageCount() async {
    try {
      final snapshot = await _firestore.collection('community_chat').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
