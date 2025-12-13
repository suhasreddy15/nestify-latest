import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CloudinaryService {
  // Cloudinary credentials
  static const String cloudName = 'difixpzlr';
  static const String uploadPreset = 'nestify_receipts';

  final CloudinaryPublic _cloudinary = CloudinaryPublic(cloudName, uploadPreset);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Upload an image to Cloudinary
  Future<String> uploadImageToCloudinary({
    required Uint8List fileBytes,
    required String fileName,
    String folder = 'nestify',
  }) async {
    try {
      print('📤 Uploading image to Cloudinary...');
      
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          fileBytes,
          identifier: fileName,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      print('✅ Cloudinary image upload successful!');
      print('🔗 URL: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      print('❌ Cloudinary image upload failed: $e');
      throw Exception('Failed to upload image to Cloudinary: $e');
    }
  }

  /// Upload a file (PDF, etc.) to Cloudinary using Auto resource type
  Future<String> uploadFileToCloudinary({
    required Uint8List fileBytes,
    required String fileName,
    String folder = 'nestify',
  }) async {
    try {
      print('📤 Uploading file to Cloudinary...');
      
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          fileBytes,
          identifier: fileName,
          folder: folder,
          resourceType: CloudinaryResourceType.Auto,
        ),
      );

      print('✅ Cloudinary file upload successful!');
      print('🔗 URL: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      print('❌ Cloudinary file upload failed: $e');
      throw Exception('Failed to upload file to Cloudinary: $e');
    }
  }

  /// Upload Aadhaar document (supports images and PDFs) - all to Cloudinary
  Future<String> uploadAadhaarDocument({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final String fileExtension = fileName.split('.').last.toLowerCase();
    final bool isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension);

    String downloadUrl;

    if (isImage) {
      // Images use Image resource type for optimization
      print('🖼️ Uploading Aadhaar image to Cloudinary...');
      downloadUrl = await uploadImageToCloudinary(
        fileBytes: fileBytes,
        fileName: fileName,
        folder: 'nestify/aadhaar/${user.uid}',
      );
    } else {
      // PDFs and other files use Auto resource type
      print('📄 Uploading Aadhaar document to Cloudinary...');
      downloadUrl = await uploadFileToCloudinary(
        fileBytes: fileBytes,
        fileName: fileName,
        folder: 'nestify/aadhaar/${user.uid}',
      );
    }

    // Update Firestore with the URL
    await _firestore.collection('users').doc(user.uid).update({
      'aadhaarUrl': downloadUrl,
      'aadhaarFileName': fileName,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('✅ Aadhaar document uploaded and saved to profile');
    return downloadUrl;
  }

  /// Upload profile picture (always uses Cloudinary for optimization)
  Future<String> uploadProfilePicture({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    print('👤 Uploading profile picture to Cloudinary...');
    final downloadUrl = await uploadImageToCloudinary(
      fileBytes: fileBytes,
      fileName: fileName,
      folder: 'nestify/profiles/${user.uid}',
    );

    // Update Firestore with the URL - use consistent field name
    await _firestore.collection('users').doc(user.uid).update({
      'profilePicUrl': downloadUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('✅ Profile picture uploaded and saved');
    return downloadUrl;
  }

  /// Delete Aadhaar document reference from Firestore
  Future<void> deleteAadhaarDocument() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    print('🗑️ Removing Aadhaar document reference...');

    await _firestore.collection('users').doc(user.uid).update({
      'aadhaarUrl': FieldValue.delete(),
      'aadhaarFileName': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('✅ Aadhaar document reference removed');
  }

  /// Delete profile picture reference from Firestore
  Future<void> deleteProfilePicture() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    print('🗑️ Removing profile picture reference...');

    await _firestore.collection('users').doc(user.uid).update({
      'profilePicUrl': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('✅ Profile picture reference removed');
  }
}
