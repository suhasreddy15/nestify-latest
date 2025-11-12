import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OwnerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if the current owner has completed their setup
  Future<bool> isOwnerSetupComplete() async {
    User? user = _auth.currentUser;
    if (user == null) return false;

    try {
      DocumentSnapshot doc = await _firestore
          .collection('owners')
          .doc(user.uid)
          .get();
      
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return false;

      // Check if all required fields are present and not empty
      return data.containsKey('pgName') &&
          data.containsKey('address') &&
          data.containsKey('contactNumber') &&
          data['pgName']?.toString().isNotEmpty == true &&
          data['address']?.toString().isNotEmpty == true &&
          data['contactNumber']?.toString().isNotEmpty == true;
    } catch (e) {
      print('Error checking owner setup: $e');
      return false;
    }
  }

  /// Save owner setup information
  Future<void> saveOwnerSetup({
    required String pgName,
    required String address,
    required String contactNumber,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    await _firestore.collection('owners').doc(user.uid).set({
      'userId': user.uid,
      'email': user.email,
      'pgName': pgName,
      'address': address,
      'contactNumber': contactNumber,
      'setupCompletedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get owner details
  Future<Map<String, dynamic>?> getOwnerDetails() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      DocumentSnapshot doc = await _firestore
          .collection('owners')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error getting owner details: $e');
    }
    return null;
  }

  /// Update owner information
  Future<void> updateOwnerInfo({
    String? pgName,
    String? address,
    String? contactNumber,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    Map<String, dynamic> updates = {};
    if (pgName != null) updates['pgName'] = pgName;
    if (address != null) updates['address'] = address;
    if (contactNumber != null) updates['contactNumber'] = contactNumber;
    
    if (updates.isNotEmpty) {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('owners').doc(user.uid).update(updates);
    }
  }
}
