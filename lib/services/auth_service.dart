
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum UserRole { owner, student }

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Make GoogleSignIn nullable and initialize it lazily
  GoogleSignIn? _googleSignIn;

  // Stream that provides real-time authentication state
  Stream<User?> get user => _auth.authStateChanges();
  
  // Get current user synchronously (for immediate checks)
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithGoogle() async {
    // Initialize GoogleSignIn only when this method is called
    _googleSignIn ??= GoogleSignIn();
    
    final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    if (googleAuth == null) {
      throw FirebaseAuthException(
        code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
        message: 'Could not retrieve Google auth token.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      final userDocRef = _firestore.collection('users').doc(user.uid);
      final doc = await userDocRef.get();

      // If the user is signing in for the first time, create their document
      if (!doc.exists) {
        await userDocRef.set({
          'role': 'student', // Default role for Google Sign-In
          'email': user.email,
          'fullName': user.displayName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    return userCredential;
  }

  Future<void> ensureOwnerRole(User user) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);
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

  Future<UserCredential> registerOwner(
    String email,
    String password,
  ) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'role': 'owner',
      'email': email,
      'fullName': 'Owner',
    });

    return userCredential;
  }

  Future<UserRole?> getUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('role')) {
          String roleString = data['role'];
          return roleString == 'owner' ? UserRole.owner : UserRole.student;
        }
      }
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      
      // Also sign out from Google, if it was used
      await _googleSignIn?.signOut();
      
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Error during sign out: $e');
      rethrow;
    }
  }
}
