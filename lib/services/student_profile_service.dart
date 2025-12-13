import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cloudinary_service.dart';

class StudentProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

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

  // Upload Aadhaar file to Cloudinary/Firebase Storage
  Future<String> uploadAadhaarFile({
    required Uint8List fileBytes,
    required String fileName,
    required String fileExtension,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    print('🚀 Starting Aadhaar upload...');
    print('📝 File: $fileName');
    print('📊 Size: ${fileBytes.length} bytes (${(fileBytes.length / 1024 / 1024).toStringAsFixed(2)} MB)');

    try {
      // Use Cloudinary service for upload (with Firebase fallback)
      final downloadUrl = await _cloudinaryService.uploadAadhaarDocument(
        fileBytes: fileBytes,
        fileName: fileName,
      );

      print('✅ Aadhaar upload completed successfully!');
      return downloadUrl;
    } catch (e) {
      print('❌ Aadhaar upload failed: $e');
      throw Exception('Failed to upload Aadhaar document: $e');
    }
  }

  // Delete Aadhaar file
  Future<void> deleteAadhaarFile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _cloudinaryService.deleteAadhaarDocument();
      print('✅ Aadhaar document deleted successfully');
    } catch (e) {
      print('❌ Error deleting Aadhaar document: $e');
      throw Exception('Failed to delete Aadhaar document: $e');
    }
  }

  // Upload Profile Picture
  Future<String> uploadProfilePicture({
    required Uint8List fileBytes,
    required String fileName,
    required String fileExtension,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    print('🚀 Starting profile picture upload...');
    print('📝 File: $fileName');
    print('📊 Size: ${fileBytes.length} bytes (${(fileBytes.length / 1024 / 1024).toStringAsFixed(2)} MB)');

    try {
      // Use Cloudinary service for upload (with Firebase fallback)
      final downloadUrl = await _cloudinaryService.uploadProfilePicture(
        fileBytes: fileBytes,
        fileName: fileName,
      );

      print('✅ Profile picture upload completed successfully!');
      return downloadUrl;
    } catch (e) {
      print('❌ Profile picture upload failed: $e');
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // Delete Profile Picture
  Future<void> deleteProfilePicture() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _cloudinaryService.deleteProfilePicture();
      print('✅ Profile picture deleted successfully');
    } catch (e) {
      print('❌ Error deleting profile picture: $e');
      throw Exception('Failed to delete profile picture: $e');
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
