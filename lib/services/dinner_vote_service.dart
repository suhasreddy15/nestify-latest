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

    final voteData = {
      'dishName': dishName,
      'date': Timestamp.fromDate(today),
      'createdAt': Timestamp.fromDate(now),
      'yesCount': 0,
      'noCount': 0,
      'isActive': true,
    };

    await _firestore.collection('dinner_votes').add(voteData);

    // Send push notifications to all students
    await _notificationService.sendDinnerVoteNotification(dishName);
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

  // Check if voting is still open (before 6 PM)
  bool isVotingOpen() {
    final now = DateTime.now();
    final votingDeadline = DateTime(now.year, now.month, now.day, 18, 0); // 6 PM
    return now.isBefore(votingDeadline);
  }

  // Submit a vote (Student only)
  Future<void> submitVote(String voteId, String vote) async {
    if (!isVotingOpen()) {
      throw Exception('Voting is closed! Deadline was 6 PM.');
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
