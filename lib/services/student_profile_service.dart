import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StudentProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current student profile
  Future<Map<String, dynamic>?> getStudentProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  // Update student profile
  Future<void> updateStudentProfile({
    required String fullName,
    required String phone,
    required String roomNumber,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(user.uid).update({
      'fullName': fullName,
      'phone': phone,
      'roomNumber': roomNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Upload Aadhaar file to Firebase Storage
  Future<String> uploadAadhaarFile({
    required Uint8List fileBytes,
    required String fileName,
    required String fileExtension,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Create a reference to the file location
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String storagePath = 'aadhaar_documents/${user.uid}/$timestamp.$fileExtension';
    final Reference ref = _storage.ref().child(storagePath);

    // Set metadata
    final metadata = SettableMetadata(
      contentType: _getContentType(fileExtension),
      customMetadata: {
        'uploadedBy': user.uid,
        'originalFileName': fileName,
      },
    );

    // Upload the file
    final UploadTask uploadTask = ref.putData(fileBytes, metadata);
    final TaskSnapshot snapshot = await uploadTask;

    // Get download URL
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    // Update Firestore with the download URL
    await _firestore.collection('users').doc(user.uid).update({
      'aadhaarUrl': downloadUrl,
      'aadhaarFileName': fileName,
      'aadhaarUploadedAt': FieldValue.serverTimestamp(),
    });

    return downloadUrl;
  }

  // Get content type based on file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  // Delete Aadhaar file
  Future<void> deleteAadhaarFile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();

    if (data != null && data['aadhaarUrl'] != null) {
      try {
        // Delete from Storage
        final String url = data['aadhaarUrl'];
        final Reference ref = _storage.refFromURL(url);
        await ref.delete();
      } catch (e) {
        print('Error deleting file from storage: $e');
      }

      // Remove from Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'aadhaarUrl': FieldValue.delete(),
        'aadhaarFileName': FieldValue.delete(),
        'aadhaarUploadedAt': FieldValue.delete(),
      });
    }
  }

  // Get all students (for owner)
  Stream<List<Map<String, dynamic>>> getAllStudents() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .orderBy('fullName')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['uid'] = doc.id;
              return data;
            }).toList());
  }

  // Get specific student details (for owner)
  Future<Map<String, dynamic>?> getStudentDetails(String studentId) async {
    final doc = await _firestore.collection('users').doc(studentId).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        data['uid'] = doc.id;
        return data;
      }
    }
    return null;
  }
}
