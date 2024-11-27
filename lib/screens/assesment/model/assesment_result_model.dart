import 'package:cloud_firestore/cloud_firestore.dart';

class AssessmentResult {
  final String userId;
  final int totalScore;
  final bool isDepressed;
  final DateTime submittedAt;
  final List<int> answers;

  AssessmentResult({
    required this.userId,
    required this.totalScore,
    required this.isDepressed,
    required this.submittedAt,
    required this.answers,
  });

  factory AssessmentResult.fromMap(Map<String, dynamic> map) {
    return AssessmentResult(
      userId: map['userId'] as String,
      totalScore: map['totalScore'] as int,
      isDepressed: map['isDepressed'] as bool,
      submittedAt: (map['submittedAt'] as Timestamp).toDate(),
      answers: List<int>.from(map['answers']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalScore': totalScore,
      'isDepressed': isDepressed,
      'submittedAt': submittedAt,
      'answers': answers,
    };
  }
}
