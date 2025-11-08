import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nestify/models/complaint.dart';

class ComplaintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Create a new complaint
  Future<void> createComplaint({
    required String title,
    required String description,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection('complaints').add({
        'title': title,
        'description': description,
        'studentId': user.uid,
        'studentEmail': user.email ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      throw Exception('Failed to create complaint: $e');
    }
  }

  // Get complaints for a specific student
  Stream<List<Complaint>> getStudentComplaints(String studentId) {
    return _firestore
        .collection('complaints')
        .where('studentId', isEqualTo: studentId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Complaint.fromFirestore(doc)).toList();
    });
  }

  // Get all complaints (for owners) with optional status filter
  Stream<List<Complaint>> getAllComplaints({String? statusFilter}) {
    Query query = _firestore.collection('complaints');

    if (statusFilter != null && statusFilter.isNotEmpty) {
      query = query.where('status', isEqualTo: statusFilter);
    }

    return query.orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Complaint.fromFirestore(doc)).toList();
    });
  }

  // Update complaint status
  Future<void> updateComplaintStatus(String complaintId, String status) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update complaint status: $e');
    }
  }

  // Delete a complaint (optional feature)
  Future<void> deleteComplaint(String complaintId) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).delete();
    } catch (e) {
      throw Exception('Failed to delete complaint: $e');
    }
  }

  // Get complaint count by status
  Future<Map<String, int>> getComplaintCounts() async {
    try {
      final allSnapshot = await _firestore.collection('complaints').get();
      final pendingSnapshot = await _firestore
          .collection('complaints')
          .where('status', isEqualTo: 'pending')
          .get();
      final resolvedSnapshot = await _firestore
          .collection('complaints')
          .where('status', isEqualTo: 'resolved')
          .get();

      return {
        'total': allSnapshot.docs.length,
        'pending': pendingSnapshot.docs.length,
        'resolved': resolvedSnapshot.docs.length,
      };
    } catch (e) {
      return {'total': 0, 'pending': 0, 'resolved': 0};
    }
  }
}
