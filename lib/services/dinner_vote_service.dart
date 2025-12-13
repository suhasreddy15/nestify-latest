import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/dinner_vote.dart';
import 'notification_service.dart';

class DinnerVoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  // Create a new dinner vote (Owner only)
  Future<void> createDinnerVote(String dishName) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if voting already exists for today
    final existingVote = await getTodayVote();
    if (existingVote != null) {
      throw Exception('Voting already exists for today!');
    }

    // Set voting deadline: if created before 5 PM, deadline is 6 PM today
    // If created after 5 PM, give 1 hour for voting
    final fivePM = DateTime(now.year, now.month, now.day, 17, 0);
    final sixPM = DateTime(now.year, now.month, now.day, 18, 0);
    
    DateTime votingDeadline;
    if (now.isBefore(fivePM)) {
      votingDeadline = sixPM; // Standard 6 PM deadline
    } else {
      votingDeadline = now.add(const Duration(hours: 1)); // 1 hour from now
    }

    final voteData = {
      'dishName': dishName,
      'date': Timestamp.fromDate(today),
      'createdAt': Timestamp.fromDate(now),
      'votingDeadline': Timestamp.fromDate(votingDeadline),
      'yesCount': 0,
      'noCount': 0,
      'isActive': true,
      'reminderSent': false,
      'ownerId': _auth.currentUser?.uid,
    };

    await _firestore.collection('dinner_votes').add(voteData);

    // Send push notifications to all students immediately
    try {
      await _notificationService.sendDinnerVoteNotification(dishName);
      print('✅ Dinner voting created for: $dishName');
      print('📢 Notifications sent to all students');
      print('⏰ Voting deadline: $votingDeadline');
    } catch (e) {
      print('⚠️ Voting created but notification failed: $e');
      // Don't throw - voting was created successfully
    }
  }

  // Get today's dinner vote
  Future<DinnerVote?> getTodayVote() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('dinner_votes')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .where('date', isLessThan: Timestamp.fromDate(tomorrow))
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return DinnerVote.fromFirestore(snapshot.docs.first);
  }

  // Check if voting is still open based on deadline stored in vote document
  bool isVotingOpenForVote(Map<String, dynamic>? voteData) {
    if (voteData == null) return false;
    
    // Check if manually closed
    final isActive = voteData['isActive'] ?? true;
    if (!isActive) return false;
    
    // Check deadline
    final deadlineTimestamp = voteData['votingDeadline'] as Timestamp?;
    if (deadlineTimestamp != null) {
      final deadline = deadlineTimestamp.toDate();
      return DateTime.now().isBefore(deadline);
    }
    
    // Fallback to 6 PM if no deadline stored
    final now = DateTime.now();
    final votingDeadline = DateTime(now.year, now.month, now.day, 18, 0);
    return now.isBefore(votingDeadline);
  }

  // Legacy method - check if voting is still open (before 6 PM)
  bool isVotingOpen() {
    final now = DateTime.now();
    final votingDeadline = DateTime(now.year, now.month, now.day, 18, 0); // 6 PM
    return now.isBefore(votingDeadline);
  }

  // Check if voting is open for a specific vote ID
  Future<bool> isVotingOpenById(String voteId) async {
    final doc = await _firestore.collection('dinner_votes').doc(voteId).get();
    if (!doc.exists) return false;
    return isVotingOpenForVote(doc.data());
  }

  // Submit a vote (Student only)
  Future<void> submitVote(String voteId, String vote) async {
    // Check if voting is still open for this specific vote
    final isOpen = await isVotingOpenById(voteId);
    if (!isOpen) {
      throw Exception('Voting is closed!');
    }

    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get student name from users collection
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final studentName = userDoc.data()?['fullName'] ?? 'Unknown Student';

    // Check if student has already voted
    final existingVote = await hasUserVoted(voteId);
    if (existingVote != null) {
      throw Exception('You have already voted!');
    }

    // Add vote response to subcollection
    final responseData = VoteResponse(
      studentId: user.uid,
      studentName: studentName,
      vote: vote,
      timestamp: DateTime.now(),
    ).toMap();

    await _firestore
        .collection('dinner_votes')
        .doc(voteId)
        .collection('responses')
        .doc(user.uid)
        .set(responseData);

    // Update vote counts
    await _updateVoteCounts(voteId);
  }

  // Check if current user has voted
  Future<VoteResponse?> hasUserVoted(String voteId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection('dinner_votes')
        .doc(voteId)
        .collection('responses')
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;
    return VoteResponse.fromFirestore(doc);
  }

  // Update vote counts
  Future<void> _updateVoteCounts(String voteId) async {
    final responses = await _firestore
        .collection('dinner_votes')
        .doc(voteId)
        .collection('responses')
        .get();

    int yesCount = 0;
    int noCount = 0;

    for (var doc in responses.docs) {
      final vote = doc.data()['vote'];
      if (vote == 'yes') {
        yesCount++;
      } else if (vote == 'no') {
        noCount++;
      }
    }

    await _firestore.collection('dinner_votes').doc(voteId).update({
      'yesCount': yesCount,
      'noCount': noCount,
    });
  }

  // Get all vote responses for a specific vote (Owner only)
  Stream<List<VoteResponse>> getVoteResponses(String voteId) {
    return _firestore
        .collection('dinner_votes')
        .doc(voteId)
        .collection('responses')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => VoteResponse.fromFirestore(doc)).toList());
  }

  // Get voting history (Owner only)
  Stream<List<DinnerVote>> getVotingHistory() {
    return _firestore
        .collection('dinner_votes')
        .orderBy('date', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DinnerVote.fromFirestore(doc)).toList());
  }

  // Close voting (automatically called or manual)
  Future<void> closeVoting(String voteId) async {
    await _firestore.collection('dinner_votes').doc(voteId).update({
      'isActive': false,
    });
  }
}
