import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Create private conversation
  Future<String> createPrivateConversation(String currentUserId, String otherUserId) async {
    try {
      // Check if conversation already exists
      QuerySnapshot existingConversation = await _firestore
          .collection('conversations')
          .where('type', isEqualTo: 'private')
          .where('members', arrayContains: currentUserId)
          .get();

      for (var doc in existingConversation.docs) {
        List<String> members = List<String>.from((doc.data() as Map<String, dynamic>)['members']);
        if (members.contains(otherUserId) && members.length == 2) {
          return doc.id;
        }
      }

      // Create new conversation
      String conversationId = _uuid.v4();
      ConversationModel conversation = ConversationModel(
        id: conversationId,
        type: ConversationType.private,
        members: [currentUserId, otherUserId],
        adminIds: [],
        isDeleted: false,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .set(conversation.toFirestore());

      // Add to user conversations
      await _addToUserConversations(currentUserId, conversationId, conversation);
      await _addToUserConversations(otherUserId, conversationId, conversation);

      return conversationId;
    } catch (e) {
      throw Exception('Lỗi tạo cuộc trò chuyện: ${e.toString()}');
    }
  }

  // Create group conversation
  Future<String> createGroupConversation({
    required String name,
    required List<String> memberIds,
    required String creatorId,
    String? avatarUrl,
  }) async {
    try {
      String conversationId = _uuid.v4();
      ConversationModel conversation = ConversationModel(
        id: conversationId,
        type: ConversationType.group,
        name: name,
        avatarUrl: avatarUrl,
        members: memberIds,
        adminIds: [creatorId],
        isDeleted: false,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .set(conversation.toFirestore());

      // Add to all members' user conversations
      for (String memberId in memberIds) {
        await _addToUserConversations(memberId, conversationId, conversation);
      }

      return conversationId;
    } catch (e) {
      throw Exception('Lỗi tạo nhóm chat: ${e.toString()}');
    }
  }

  // Add conversation to user conversations
  Future<void> _addToUserConversations(
    String userId,
    String conversationId,
    ConversationModel conversation,
  ) async {
    await _firestore
        .collection('userConversations')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .set({
      'conversationId': conversationId,
      'type': conversation.type.toString().split('.').last,
      'name': conversation.name,
      'avatarUrl': conversation.avatarUrl,
      'members': conversation.members, // Thêm members array
      'unreadCount': 0,
      'isPinned': false,
      'isMuted': false,
      'lastMessage': conversation.lastMessage,
      'lastMessageAt': conversation.lastMessageAt != null 
          ? Timestamp.fromDate(conversation.lastMessageAt!) 
          : null,
    });
  }

  // Send message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    String? content,
    required MessageType type,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? fileType,
    Map<String, dynamic>? fileMetadata,
    String? replyToMessageId,
  }) async {
    try {
      // Get sender name from users collection
      String senderName = 'Unknown';
      try {
        final userDoc = await _firestore.collection('users').doc(senderId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          senderName = userData['name'] as String? ?? 'Unknown';
        }
      } catch (e) {
        print('Error getting sender name: $e');
      }

      String messageId = _uuid.v4();
      MessageModel message = MessageModel(
        id: messageId,
        senderId: senderId,
        senderName: senderName,
        content: content,
        type: type,
        fileUrl: fileUrl,
        fileName: fileName,
        fileSize: fileSize,
        fileType: fileType,
        fileMetadata: fileMetadata,
        isPinned: false,
        seenBy: [senderId],
        isDeleted: false,
        createdAt: DateTime.now(),
        replyToMessageId: replyToMessageId,
        isEdited: false,
      );

      // Add message to conversation
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .set(message.toFirestore());

      // Update conversation last message
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'lastMessage': content ?? _getMessagePreview(type, fileName),
        'lastMessageType': type.toString().split('.').last,
        'lastMessageSender': senderId,
        'lastMessageAt': FieldValue.serverTimestamp(),
      });

      // Update user conversations
      await _updateUserConversationsLastMessage(
        conversationId,
        content ?? _getMessagePreview(type, fileName),
        senderId,
      );
    } catch (e) {
      throw Exception('Lỗi gửi tin nhắn: ${e.toString()}');
    }
  }

  String _getMessagePreview(MessageType type, String? fileName) {
    switch (type) {
      case MessageType.image:
        return '📷 Hình ảnh';
      case MessageType.file:
        return '📎 ${fileName ?? 'Tệp đính kèm'}';
      case MessageType.audio:
        return '🎤 Tin nhắn thoại';
      case MessageType.video:
        return '🎥 Video';
      default:
        return 'Tin nhắn';
    }
  }

  // Update user conversations last message
  Future<void> _updateUserConversationsLastMessage(
    String conversationId,
    String lastMessage,
    String senderId,
  ) async {
    try {
      // Get conversation members
      DocumentSnapshot conversationDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (conversationDoc.exists) {
        List<String> members = List<String>.from(
          (conversationDoc.data() as Map<String, dynamic>)['members']
        );

        // Update for all members
        for (String memberId in members) {
          Map<String, dynamic> updates = {
            'lastMessage': lastMessage,
            'lastMessageAt': FieldValue.serverTimestamp(),
          };

          // Increase unread count for other members
          if (memberId != senderId) {
            updates['unreadCount'] = FieldValue.increment(1);
          }

          await _firestore
              .collection('userConversations')
              .doc(memberId)
              .collection('conversations')
              .doc(conversationId)
              .update(updates);
        }
      }
    } catch (e) {
      print('Lỗi cập nhật user conversations: $e');
    }
  }

  // Get user conversations
  Stream<QuerySnapshot> getUserConversations(String userId) {
    return _firestore
        .collection('userConversations')
        .doc(userId)
        .collection('conversations')
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  // Get conversation messages
  Stream<QuerySnapshot> getConversationMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  // Mark messages as seen
  Future<void> markMessagesAsSeen(String conversationId, String userId) async {
    try {
      // Get recent messages (last 50) and check which ones user hasn't seen
      QuerySnapshot recentMessages = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      // Update each message that user hasn't seen
      WriteBatch batch = _firestore.batch();
      for (var doc in recentMessages.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> seenBy = List<String>.from(data['seenBy'] ?? []);
        if (!seenBy.contains(userId)) {
          seenBy.add(userId);
          batch.update(doc.reference, {'seenBy': seenBy});
        }
      }
      await batch.commit();

      // Reset unread count
      await _firestore
          .collection('userConversations')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .update({'unreadCount': 0});
    } catch (e) {
      print('Lỗi đánh dấu tin nhắn đã đọc: $e');
    }
  }

  // Pin/Unpin message
  Future<void> togglePinMessage(String conversationId, String messageId) async {
    try {
      DocumentSnapshot messageDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .get();

      if (messageDoc.exists) {
        bool currentPinStatus = (messageDoc.data() as Map<String, dynamic>)['isPinned'] ?? false;
        
        await _firestore
            .collection('conversations')
            .doc(conversationId)
            .collection('messages')
            .doc(messageId)
            .update({'isPinned': !currentPinStatus});

        if (!currentPinStatus) {
          // Add to pinned messages
          await _firestore
              .collection('conversations')
              .doc(conversationId)
              .collection('pinnedMessages')
              .doc(messageId)
              .set({
            'messageId': messageId,
            'pinnedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Remove from pinned messages
          await _firestore
              .collection('conversations')
              .doc(conversationId)
              .collection('pinnedMessages')
              .doc(messageId)
              .delete();
        }
      }
    } catch (e) {
      throw Exception('Lỗi ghim tin nhắn: ${e.toString()}');
    }
  }

  // Delete message
  Future<void> deleteMessage(String conversationId, String messageId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({'isDeleted': true});
    } catch (e) {
      throw Exception('Lỗi xóa tin nhắn: ${e.toString()}');
    }
  }

  // Edit message
  Future<void> editMessage(String conversationId, String messageId, String newContent) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({
        'content': newContent,
        'isEdited': true,
        'editedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi chỉnh sửa tin nhắn: ${e.toString()}');
    }
  }

  // Get conversation details
  Future<ConversationModel?> getConversation(String conversationId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (doc.exists) {
        return ConversationModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi lấy thông tin cuộc trò chuyện: ${e.toString()}');
    }
  }

  // Add member to group
  Future<void> addMemberToGroup(String conversationId, String userId) async {
    try {
      // Get conversation details first
      ConversationModel? conversation = await getConversation(conversationId);
      if (conversation == null) {
        throw Exception('Cuộc trò chuyện không tồn tại');
      }

      // Add member to conversation
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'members': FieldValue.arrayUnion([userId])
      });

      // Add to user conversations
      await _addToUserConversations(userId, conversationId, conversation);

      // Send system message
      await sendMessage(
        conversationId: conversationId,
        senderId: 'system',
        content: 'Thành viên mới đã được thêm vào nhóm',
        type: MessageType.text,
      );
    } catch (e) {
      throw Exception('Lỗi thêm thành viên: ${e.toString()}');
    }
  }

  // Remove member from group
  Future<void> removeMemberFromGroup(String conversationId, String userId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'members': FieldValue.arrayRemove([userId])
      });

      // Remove from user conversations
      await _firestore
          .collection('userConversations')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .delete();
    } catch (e) {
      throw Exception('Lỗi xóa thành viên: ${e.toString()}');
    }
  }

  // Add reaction to message
  Future<void> addReaction(String conversationId, String messageId, String userId, String emoji) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .collection('reactions')
          .doc('${userId}_$emoji')
          .set({
        'messageId': messageId,
        'userId': userId,
        'emoji': emoji,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi thêm reaction: ${e.toString()}');
    }
  }

  // Remove reaction from message
  Future<void> removeReaction(String conversationId, String messageId, String userId, String emoji) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .collection('reactions')
          .doc('${userId}_$emoji')
          .delete();
    } catch (e) {
      throw Exception('Lỗi xóa reaction: ${e.toString()}');
    }
  }

  // Get reactions for message
  Stream<QuerySnapshot> getMessageReactions(String conversationId, String messageId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .collection('reactions')
        .snapshots();
  }

  // Get pinned messages
  Stream<QuerySnapshot> getPinnedMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('pinnedMessages')
        .orderBy('pinnedAt', descending: false)
        .snapshots();
  }
}