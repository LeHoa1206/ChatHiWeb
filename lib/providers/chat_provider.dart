import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  List<ConversationModel> _conversations = [];
  ConversationModel? _currentConversation;
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;
  
  List<ConversationModel> get conversations => _conversations;
  ConversationModel? get currentConversation => _currentConversation;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load user conversations
  void loadUserConversations(String userId) {
    _chatService.getUserConversations(userId).listen((snapshot) {
      _conversations = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ConversationModel(
          id: data['conversationId'],
          type: ConversationType.values.firstWhere(
            (e) => e.toString().split('.').last == data['type'],
            orElse: () => ConversationType.private,
          ),
          name: data['name'],
          avatarUrl: data['avatarUrl'],
          members: [], // Will be loaded when needed
          adminIds: [], // Will be loaded when needed
          lastMessage: data['lastMessage'],
          lastMessageAt: data['lastMessageAt']?.toDate(),
          isDeleted: false,
          createdAt: DateTime.now(),
        );
      }).toList();
      notifyListeners();
    });
  }

  // Load conversation messages
  void loadConversationMessages(String conversationId) {
    _chatService.getConversationMessages(conversationId).listen((snapshot) {
      _messages = snapshot.docs.map((doc) {
        return MessageModel.fromFirestore(doc);
      }).toList();
      notifyListeners();
    });
  }

  // Set current conversation
  Future<void> setCurrentConversation(String conversationId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentConversation = await _chatService.getConversation(conversationId);
      loadConversationMessages(conversationId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create private conversation
  Future<String?> createPrivateConversation(String currentUserId, String otherUserId) async {
    try {
      _error = null;
      return await _chatService.createPrivateConversation(currentUserId, otherUserId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Create group conversation
  Future<String?> createGroupConversation({
    required String name,
    required List<String> memberIds,
    required String creatorId,
    String? avatarUrl,
  }) async {
    try {
      _error = null;
      return await _chatService.createGroupConversation(
        name: name,
        memberIds: memberIds,
        creatorId: creatorId,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Send text message
  Future<bool> sendTextMessage(String conversationId, String senderId, String content) async {
    try {
      _error = null;
      await _chatService.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        content: content,
        type: MessageType.text,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Send image message
  Future<bool> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String fileUrl,
    required String fileName,
    required int fileSize,
    Map<String, dynamic>? fileMetadata,
  }) async {
    try {
      _error = null;
      await _chatService.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        type: MessageType.image,
        fileUrl: fileUrl,
        fileName: fileName,
        fileSize: fileSize,
        fileType: 'image',
        fileMetadata: fileMetadata,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Send file message
  Future<bool> sendFileMessage({
    required String conversationId,
    required String senderId,
    required String fileUrl,
    required String fileName,
    required int fileSize,
    required String fileType,
  }) async {
    try {
      _error = null;
      await _chatService.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        type: MessageType.file,
        fileUrl: fileUrl,
        fileName: fileName,
        fileSize: fileSize,
        fileType: fileType,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Send audio message
  Future<bool> sendAudioMessage({
    required String conversationId,
    required String senderId,
    required String fileUrl,
    required int fileSize,
    int? duration,
  }) async {
    try {
      _error = null;
      await _chatService.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        type: MessageType.audio,
        fileUrl: fileUrl,
        fileName: 'voice_message.m4a',
        fileSize: fileSize,
        fileType: 'audio/m4a',
        fileMetadata: duration != null ? {'duration': duration} : null,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Mark messages as seen
  Future<void> markMessagesAsSeen(String conversationId, String userId) async {
    try {
      await _chatService.markMessagesAsSeen(conversationId, userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Pin/Unpin message
  Future<bool> togglePinMessage(String conversationId, String messageId) async {
    try {
      _error = null;
      await _chatService.togglePinMessage(conversationId, messageId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete message
  Future<bool> deleteMessage(String conversationId, String messageId) async {
    try {
      _error = null;
      await _chatService.deleteMessage(conversationId, messageId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Edit message
  Future<bool> editMessage(String conversationId, String messageId, String newContent) async {
    try {
      _error = null;
      await _chatService.editMessage(conversationId, messageId, newContent);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Add member to group
  Future<bool> addMemberToGroup(String conversationId, String userId) async {
    try {
      _error = null;
      await _chatService.addMemberToGroup(conversationId, userId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Remove member from group
  Future<bool> removeMemberFromGroup(String conversationId, String userId) async {
    try {
      _error = null;
      await _chatService.removeMemberFromGroup(conversationId, userId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearCurrentConversation() {
    _currentConversation = null;
    _messages.clear();
    notifyListeners();
  }
}