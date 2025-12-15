import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, file, audio, video, system }

class MessageModel {
  final String id;
  final String senderId;
  final String? senderName;
  final String? content;
  final MessageType type;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? fileType;
  final Map<String, dynamic>? fileMetadata;
  final bool isPinned;
  final List<String> seenBy;
  final bool isDeleted;
  final DateTime createdAt;
  final String? replyToMessageId;
  final bool isEdited;
  final DateTime? editedAt;

  MessageModel({
    required this.id,
    required this.senderId,
    this.senderName,
    this.content,
    required this.type,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.fileType,
    this.fileMetadata,
    required this.isPinned,
    required this.seenBy,
    required this.isDeleted,
    required this.createdAt,
    this.replyToMessageId,
    required this.isEdited,
    this.editedAt,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'],
      content: data['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => MessageType.text,
      ),
      fileUrl: data['fileUrl'],
      fileName: data['fileName'],
      fileSize: data['fileSize'],
      fileType: data['fileType'],
      fileMetadata: data['fileMetadata'],
      isPinned: data['isPinned'] ?? false,
      seenBy: List<String>.from(data['seenBy'] ?? []),
      isDeleted: data['isDeleted'] ?? false,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      replyToMessageId: data['replyToMessageId'],
      isEdited: data['isEdited'] ?? false,
      editedAt: data['editedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.toString().split('.').last,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileType': fileType,
      'fileMetadata': fileMetadata,
      'isPinned': isPinned,
      'seenBy': seenBy,
      'isDeleted': isDeleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'replyToMessageId': replyToMessageId,
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? content,
    MessageType? type,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? fileType,
    Map<String, dynamic>? fileMetadata,
    bool? isPinned,
    List<String>? seenBy,
    bool? isDeleted,
    DateTime? createdAt,
    String? replyToMessageId,
    bool? isEdited,
    DateTime? editedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      fileMetadata: fileMetadata ?? this.fileMetadata,
      isPinned: isPinned ?? this.isPinned,
      seenBy: seenBy ?? this.seenBy,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}