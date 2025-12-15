import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/chat/message_bubble_premium.dart';
import '../../widgets/chat/chat_input_premium.dart';
import '../../widgets/chat/typing_indicator.dart';
import '../../services/media_service.dart';
import '../../services/chat_service.dart';
import '../../models/message_model.dart';
import 'add_members_screen.dart';

class ChatRoomPremium extends StatefulWidget {
  final String conversationId;
  final String conversationName;
  final String? avatarUrl;
  final List<String> members;

  const ChatRoomPremium({
    super.key,
    required this.conversationId,
    required this.conversationName,
    this.avatarUrl,
    this.members = const [],
  });

  @override
  State<ChatRoomPremium> createState() => _ChatRoomPremiumState();
}

class _ChatRoomPremiumState extends State<ChatRoomPremium>
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  late AnimationController _fabController;
  late AnimationController _typingController;
  
  bool _isTyping = false;
  String? _replyToMessageId;
  final List<String> _selectedMessages = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _messageController.addListener(_onTyping);
    _scrollToBottom();
    
    // Mark messages as seen when entering chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markMessagesAsSeen();
    });
  }

  Future<void> _markMessagesAsSeen() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      try {
        await _chatService.markMessagesAsSeen(widget.conversationId, user.uid);
      } catch (e) {
        print('Error marking messages as seen: $e');
      }
    }
  }

  @override
  void dispose() {
    _fabController.dispose();
    _typingController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTyping() {
    if (_messageController.text.isNotEmpty && !_isTyping) {
      setState(() => _isTyping = true);
      _updateTypingStatus(true);
    } else if (_messageController.text.isEmpty && _isTyping) {
      setState(() => _isTyping = false);
      _updateTypingStatus(false);
    }
  }

  void _updateTypingStatus(bool typing) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _firestore
          .collection('conversations')
          .doc(widget.conversationId)
          .collection('typing')
          .doc(user.uid)
          .set({
        'isTyping': typing,
        'userName': user.displayName ?? 'Unknown',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: Container(
                color: Colors.grey[50],
                child: Stack(
                  children: [
                    _buildMessagesList(),
                    _buildTypingIndicator(),
                    
                    // Scroll to bottom button
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: AnimatedOpacity(
                        opacity: _isSelectionMode ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: FloatingActionButton(
                          mini: true,
                          onPressed: _scrollToBottom,
                          backgroundColor: AppTheme.primaryColor,
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Message Input - Fixed at bottom
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: _buildMessageInput(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isSelectionMode ? _buildFloatingActions() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          // Avatar with online status
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor,
                backgroundImage: widget.avatarUrl != null
                    ? NetworkImage(widget.avatarUrl!)
                    : null,
                child: widget.avatarUrl == null
                    ? Text(
                        widget.conversationName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversationName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection('conversations')
                      .doc(widget.conversationId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    int memberCount = widget.members.length;
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      final members = List<String>.from(data['members'] ?? []);
                      memberCount = members.length;
                    }
                    
                    return Text(
                      'Online • $memberCount thành viên',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Video call
        IconButton(
          icon: const Icon(FontAwesomeIcons.video),
          onPressed: _startVideoCall,
        ),
        
        // Voice call
        IconButton(
          icon: const Icon(FontAwesomeIcons.phone),
          onPressed: _startVoiceCall,
        ),
        
        // More options
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'search',
              child: ListTile(
                leading: Icon(Icons.search),
                title: Text('Tìm kiếm'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'pinned',
              child: ListTile(
                leading: Icon(Icons.push_pin),
                title: Text('Tin nhắn đã ghim'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'media',
              child: ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Ảnh & Video'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'members',
              child: ListTile(
                leading: Icon(Icons.group),
                title: Text('Thành viên'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Cài đặt'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('conversations')
          .doc(widget.conversationId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingShimmer();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final messages = snapshot.data!.docs;

        return AnimationLimiter(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final doc = messages[index];
              final data = doc.data() as Map<String, dynamic>;
              final isMe = data['senderId'] == 
                  Provider.of<AuthProvider>(context, listen: false).user?.uid;

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Slidable(
                      key: ValueKey(doc.id),
                      startActionPane: ActionPane(
                        motion: const StretchMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) => _replyToMessageAction(doc.id, data),
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            icon: Icons.reply,
                            label: 'Trả lời',
                          ),
                          SlidableAction(
                            onPressed: (_) => _pinMessage(doc.id),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            icon: Icons.push_pin,
                            label: 'Ghim',
                          ),
                        ],
                      ),
                      endActionPane: ActionPane(
                        motion: const StretchMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) => _forwardMessage(doc.id, data),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.forward,
                            label: 'Chuyển tiếp',
                          ),
                          if (isMe)
                            SlidableAction(
                              onPressed: (_) => _deleteMessage(doc.id),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Xóa',
                            ),
                        ],
                      ),
                      child: MessageBubblePremium(
                        messageId: doc.id,
                        data: data,
                        isMe: isMe,
                        isSelected: _selectedMessages.contains(doc.id),
                        onLongPress: () => _toggleMessageSelection(doc.id),
                        onTap: _isSelectionMode 
                            ? () => _toggleMessageSelection(doc.id)
                            : null,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 200,
                        height: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có tin nhắn nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy gửi tin nhắn đầu tiên để bắt đầu cuộc trò chuyện!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('conversations')
          .doc(widget.conversationId)
          .collection('typing')
          .where('isTyping', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final typingUsers = snapshot.data!.docs
            .where((doc) => doc.id != Provider.of<AuthProvider>(context, listen: false).user?.uid)
            .map((doc) => (doc.data() as Map<String, dynamic>)['userName'] as String)
            .toList();

        if (typingUsers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 16,
          left: 16,
          child: TypingIndicator(
            controller: _typingController,
            users: typingUsers,
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return ChatInputPremium(
      controller: _messageController,
      focusNode: _focusNode,
      onSendMessage: _sendMessage,
      onSendVoice: _sendVoiceMessage,
      onPickImage: _pickImage,
      onPickFile: _pickFile,
      replyToMessage: _replyToMessageId,
      onCancelReply: () => setState(() => _replyToMessageId = null),
    );
  }

  Widget _buildFloatingActions() {
    if (!_isSelectionMode) return const SizedBox.shrink();
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "delete",
          onPressed: _deleteSelectedMessages,
          backgroundColor: Colors.red,
          mini: true,
          child: const Icon(Icons.delete, size: 20),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: "forward",
          onPressed: _forwardSelectedMessages,
          backgroundColor: Colors.blue,
          mini: true,
          child: const Icon(Icons.forward, size: 20),
        ),
      ],
    );
  }

  // Action Methods
  void _startVideoCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎥 Video call sẽ được cập nhật trong phiên bản tiếp theo!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _startVoiceCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📞 Voice call sẽ được cập nhật trong phiên bản tiếp theo!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'search':
        _showSearchDialog();
        break;
      case 'pinned':
        _showPinnedMessages();
        break;
      case 'media':
        _showMediaGallery();
        break;
      case 'members':
        _showMembersList();
        break;
      case 'settings':
        _showChatSettings();
        break;
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tìm kiếm tin nhắn'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Nhập từ khóa...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tìm'),
          ),
        ],
      ),
    );
  }

  void _showPinnedMessages() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📌 Tin nhắn đã ghim')),
    );
  }

  void _showMediaGallery() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🖼️ Thư viện ảnh & video')),
    );
  }

  void _showMembersList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.group),
                      const SizedBox(width: 8),
                      StreamBuilder<DocumentSnapshot>(
                        stream: _firestore
                            .collection('conversations')
                            .doc(widget.conversationId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          int memberCount = widget.members.length;
                          if (snapshot.hasData && snapshot.data!.exists) {
                            final data = snapshot.data!.data() as Map<String, dynamic>;
                            final members = List<String>.from(data['members'] ?? []);
                            memberCount = members.length;
                          }
                          
                          return Text(
                            'Thành viên ($memberCount)',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _addMembers,
                        icon: const Icon(Icons.person_add),
                        tooltip: 'Thêm thành viên',
                      ),
                    ],
                  ),
                ),
                
                // Members list
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: _firestore
                        .collection('conversations')
                        .doc(widget.conversationId)
                        .snapshots(),
                    builder: (context, conversationSnapshot) {
                      if (!conversationSnapshot.hasData || !conversationSnapshot.data!.exists) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final conversationData = conversationSnapshot.data!.data() as Map<String, dynamic>;
                      final members = List<String>.from(conversationData['members'] ?? []);
                      
                      if (members.isEmpty) {
                        return const Center(
                          child: Text(
                            'Chưa có thành viên nào',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      
                      return StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('users')
                            .where(FieldPath.documentId, whereIn: members)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text('Không có thành viên nào'),
                            );
                          }
                          
                          final members = snapshot.data!.docs;
                          
                          return ListView.builder(
                            controller: scrollController,
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              final member = members[index];
                              final data = member.data() as Map<String, dynamic>;
                              final isOnline = data['online'] as bool? ?? false;
                              
                              return ListTile(
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppTheme.primaryColor,
                                      child: Text(
                                        (data['name'] as String? ?? 'U')
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isOnline)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Theme.of(context).colorScheme.surface,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                title: Text(
                                  data['name'] as String? ?? 'Unknown',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  isOnline ? 'Đang online' : 'Offline',
                                  style: TextStyle(
                                    color: isOnline ? Colors.green : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: member.id == Provider.of<AuthProvider>(context, listen: false).user?.uid
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'Bạn',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : null,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _addMembers() async {
    try {
      // Get current members from Firestore
      final conversationDoc = await _firestore
          .collection('conversations')
          .doc(widget.conversationId)
          .get();
      
      List<String> currentMembers = [];
      if (conversationDoc.exists) {
        final data = conversationDoc.data() as Map<String, dynamic>;
        currentMembers = List<String>.from(data['members'] ?? []);
      }

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddMembersScreen(
            conversationId: widget.conversationId,
            currentMembers: currentMembers,
          ),
        ),
      );
      
      if (result != null && result is List<String>) {
        // Refresh the conversation data to get updated members list
        setState(() {});
      }
    } catch (e) {
      print('Error getting current members: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi lấy danh sách thành viên: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showChatSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚙️ Cài đặt cuộc trò chuyện')),
    );
  }

  void _replyToMessageAction(String messageId, Map<String, dynamic> data) {
    setState(() {
      _replyToMessageId = messageId;
    });
    _focusNode.requestFocus();
  }

  void _pinMessage(String messageId) {
    _firestore
        .collection('conversations')
        .doc(widget.conversationId)
        .collection('messages')
        .doc(messageId)
        .update({'isPinned': true});
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📌 Đã ghim tin nhắn')),
    );
  }

  void _forwardMessage(String messageId, Map<String, dynamic> data) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('↗️ Chuyển tiếp tin nhắn')),
    );
  }

  void _deleteMessage(String messageId) {
    _firestore
        .collection('conversations')
        .doc(widget.conversationId)
        .collection('messages')
        .doc(messageId)
        .update({'isDeleted': true});
  }

  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (_selectedMessages.contains(messageId)) {
        _selectedMessages.remove(messageId);
        if (_selectedMessages.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMessages.add(messageId);
        _isSelectionMode = true;
      }
    });
  }

  void _deleteSelectedMessages() {
    for (String messageId in _selectedMessages) {
      _deleteMessage(messageId);
    }
    setState(() {
      _selectedMessages.clear();
      _isSelectionMode = false;
    });
  }

  void _forwardSelectedMessages() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('↗️ Chuyển tiếp ${_selectedMessages.length} tin nhắn')),
    );
    setState(() {
      _selectedMessages.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    _messageController.clear();
    _updateTypingStatus(false);

    try {
      // Use ChatService to send message (this will update unreadCount)
      await _chatService.sendMessage(
        conversationId: widget.conversationId,
        senderId: user.uid,
        content: content,
        type: MessageType.text,
        replyToMessageId: _replyToMessageId,
      );

      setState(() => _replyToMessageId = null);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('Lỗi gửi tin nhắn: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _sendVoiceMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎤 Voice message đang được phát triển!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Chọn ảnh'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn ảnh: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final image = await MediaService.pickImage(source: source);
      if (image != null) {
        final bytes = await image.readAsBytes();
        await _sendImageMessage(bytes, image.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi ảnh: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final file = await MediaService.pickFile();
      if (file != null && file.bytes != null) {
        await _sendFileMessage(file.bytes!, file.name, file.extension ?? '');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi file: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _sendImageMessage(Uint8List imageBytes, String fileName) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final userModel = Provider.of<AuthProvider>(context, listen: false).userModel;
    if (user == null) return;

    try {
      await MediaService.sendImageMessage(
        conversationId: widget.conversationId,
        senderId: user.uid,
        senderName: userModel?.name ?? 'Unknown',
        imageBytes: imageBytes,
        fileName: fileName,
        replyTo: _replyToMessageId,
      );

      setState(() => _replyToMessageId = null);
      _scrollToBottom();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📷 Đã gửi ảnh thành công!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi ảnh: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _sendFileMessage(Uint8List fileBytes, String fileName, String fileExtension) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final userModel = Provider.of<AuthProvider>(context, listen: false).userModel;
    if (user == null) return;

    try {
      await MediaService.sendFileMessage(
        conversationId: widget.conversationId,
        senderId: user.uid,
        senderName: userModel?.name ?? 'Unknown',
        fileBytes: fileBytes,
        fileName: fileName,
        fileType: _getFileType(fileExtension),
        replyTo: _replyToMessageId,
      );

      setState(() => _replyToMessageId = null);
      _scrollToBottom();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📎 Đã gửi file thành công!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi file: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  String _getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'image/${extension.toLowerCase()}';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.ms-powerpoint';
      case 'txt':
        return 'text/plain';
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      default:
        return 'application/octet-stream';
    }
  }
}