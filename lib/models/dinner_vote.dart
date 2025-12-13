import 'package:cloud_firestore/cloud_firestore.dart';

class DinnerVote {
  final String id;
  final String dishName;
  final DateTime date;
  final DateTime createdAt;
  final DateTime? votingDeadline;
  final int yesCount;
  final int noCount;
  final bool isActive;

  DinnerVote({
    required this.id,
    required this.dishName,
    required this.date,
    required this.createdAt,
    this.votingDeadline,
    required this.yesCount,
    required this.noCount,
    required this.isActive,
  });

  factory DinnerVote.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DinnerVote(
      id: doc.id,
      dishName: data['dishName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      votingDeadline: data['votingDeadline'] != null 
          ? (data['votingDeadline'] as Timestamp).toDate() 
          : null,
      yesCount: data['yesCount'] ?? 0,
      noCount: data['noCount'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }
  
  // Check if voting is still open
  bool get isVotingOpen {
    if (!isActive) return false;
    
    if (votingDeadline != null) {
      return DateTime.now().isBefore(votingDeadline!);
    }
    
    // Fallback: 6 PM deadline
    final now = DateTime.now();
    final deadline = DateTime(now.year, now.month, now.day, 18, 0);
    return now.isBefore(deadline);
  }

  Map<String, dynamic> toMap() {
    return {
      'dishName': dishName,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'votingDeadline': votingDeadline != null ? Timestamp.fromDate(votingDeadline!) : null,
      'yesCount': yesCount,
      'noCount': noCount,
      'isActive': isActive,
    };
  }
}

class VoteResponse {
  final String studentId;
  final String studentName;
  final String vote; // 'yes' or 'no'
  final DateTime timestamp;

  VoteResponse({
    required this.studentId,
    required this.studentName,
    required this.vote,
    required this.timestamp,
  });

  factory VoteResponse.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VoteResponse(
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      vote: data['vote'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'vote': vote,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
