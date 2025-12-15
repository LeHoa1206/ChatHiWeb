import 'package:cloud_firestore/cloud_firestore.dart';

class ReactionModel {
  final String id;
  final String messageId;
  final String userId;
  final String emoji;
  final DateTime createdAt;

  ReactionModel({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'messageId': messageId,
      'userId': userId,
      'emoji': emoji,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ReactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReactionModel(
      id: doc.id,
      messageId: data['messageId'] ?? '',
      userId: data['userId'] ?? '',
      emoji: data['emoji'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}