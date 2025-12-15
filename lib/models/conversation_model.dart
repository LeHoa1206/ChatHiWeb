import 'package:cloud_firestore/cloud_firestore.dart';

enum ConversationType { private, group, company }

class ConversationModel {
  final String id;
  final ConversationType type;
  final String? name;
  final String? avatarUrl;
  final List<String> members;
  final List<String> adminIds;
  final String? lastMessage;
  final String? lastMessageType;
  final String? lastMessageSender;
  final DateTime? lastMessageAt;
  final bool isDeleted;
  final DateTime createdAt;

  ConversationModel({
    required this.id,
    required this.type,
    this.name,
    this.avatarUrl,
    required this.members,
    required this.adminIds,
    this.lastMessage,
    this.lastMessageType,
    this.lastMessageSender,
    this.lastMessageAt,
    required this.isDeleted,
    required this.createdAt,
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      id: doc.id,
      type: ConversationType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => ConversationType.private,
      ),
      name: data['name'],
      avatarUrl: data['avatarUrl'],
      members: List<String>.from(data['members'] ?? []),
      adminIds: List<String>.from(data['adminIds'] ?? []),
      lastMessage: data['lastMessage'],
      lastMessageType: data['lastMessageType'],
      lastMessageSender: data['lastMessageSender'],
      lastMessageAt: data['lastMessageAt']?.toDate(),
      isDeleted: data['isDeleted'] ?? false,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.toString().split('.').last,
      'name': name,
      'avatarUrl': avatarUrl,
      'members': members,
      'adminIds': adminIds,
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType,
      'lastMessageSender': lastMessageSender,
      'lastMessageAt': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'isDeleted': isDeleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ConversationModel copyWith({
    String? id,
    ConversationType? type,
    String? name,
    String? avatarUrl,
    List<String>? members,
    List<String>? adminIds,
    String? lastMessage,
    String? lastMessageType,
    String? lastMessageSender,
    DateTime? lastMessageAt,
    bool? isDeleted,
    DateTime? createdAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      members: members ?? this.members,
      adminIds: adminIds ?? this.adminIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageSender: lastMessageSender ?? this.lastMessageSender,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}