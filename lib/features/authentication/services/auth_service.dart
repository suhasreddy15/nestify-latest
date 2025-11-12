
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { owner, student }

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> ensureOwnerRole(User user) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);
    // This will create the document if it doesn't exist, or update it if it does.
    // The merge option prevents overwriting other fields if the document already exists.
    await userDocRef.set({
      'role': 'owner',
      'email': user.email,
    }, SetOptions(merge: true));
  }

  Future<UserCredential> registerStudent(
    String email,
    String password,
    String fullName,
  ) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'role': 'student',
      'fullName': fullName,
      'email': email,
    });

    return userCredential;
  }

  Future<UserRole?> getUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        // Check if data is not null and contains the role key
        if (data != null && data.containsKey('role')) {
          String roleString = data['role'];
          return roleString == 'owner' ? UserRole.owner : UserRole.student;
        }
      }
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
