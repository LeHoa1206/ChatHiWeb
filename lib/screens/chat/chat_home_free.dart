import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../../services/chat_service.dart';
import '../../utils/migration_helper.dart';

import 'chat_room_premium.dart';
import 'chat_test_screen.dart';
import 'premium_features_screen.dart';
import 'chat_settings_screen.dart';
import 'search_users_screen.dart';
import '../../widgets/chat/premium_banner.dart';

class ChatHomeFree extends StatefulWidget {
  const ChatHomeFree({super.key});

  @override
  State<ChatHomeFree> createState() => _ChatHomeFreeState();
}

class _ChatHomeFreeState extends State<ChatHomeFree> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runMigrationIfNeeded();
    });
  }

  Future<void> _runMigrationIfNeeded() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      print('Running migration for user: ${user.uid}');
      await MigrationHelper.fixUserConversationsMembers(user.uid);
      
      // Also sync conversations from main collection
      await _syncConversationsFromMain(user.uid);
    }
  }

  // Sync conversations from main collection to userConversations
  Future<void> _syncConversationsFromMain(String userId) async {
    try {
      // Get all conversations where user is a member
      final conversationsSnapshot = await _firestore
          .collection('conversations')
          .where('members', arrayContains: userId)
          .get();

      for (var doc in conversationsSnapshot.docs) {
        final conversationData = doc.data();
        final conversationId = doc.id;

        // Check if this conversation exists in userConversations
        final userConvDoc = await _firestore
            .collection('userConversations')
            .doc(userId)
            .collection('conversations')
            .doc(conversationId)
            .get();

        if (!userConvDoc.exists) {
          // Add missing conversation to userConversations
          await _firestore
              .collection('userConversations')
              .doc(userId)
              .collection('conversations')
              .doc(conversationId)
              .set({
            'conversationId': conversationId,
            'type': conversationData['type'] ?? 'group',
            'name': conversationData['name'],
            'avatarUrl': conversationData['avatarUrl'],
            'members': conversationData['members'] ?? [],
            'unreadCount': 0,
            'isPinned': false,
            'isMuted': false,
            'lastMessage': conversationData['lastMessage'],
            'lastMessageAt': conversationData['lastMessageAt'],
          });
          
          print('Added missing conversation: $conversationId');
        }
      }
    } catch (e) {
      print('Sync error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HIWEB',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Search Users
          IconButton(
            icon: const Icon(Icons.person_search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchUsersScreen(),
                ),
              );
            },
            tooltip: 'Tìm kiếm người dùng',
          ),
          
          // Premium Features
          IconButton(
            icon: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.diamond, color: Colors.amber);
                },
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PremiumFeaturesScreen(),
                ),
              );
            },
          ),
          
          // Test button
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatTestScreen(),
                ),
              );
            },
          ),
          
          // Theme toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode 
                      ? Icons.light_mode 
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          
          // Profile menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  _showProfileDialog();
                  break;
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatSettingsScreen(),
                    ),
                  );
                  break;
                case 'logout':
                  _logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Hồ sơ'),
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
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Premium Banner
          const PremiumBanner(),
          
          // Conversations List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getUserConversations(user?.uid ?? ''),
              builder: (context, snapshot) {
                print('DEBUG: StreamBuilder state: ${snapshot.connectionState}');
                print('DEBUG: Has data: ${snapshot.hasData}');
                print('DEBUG: Docs count: ${snapshot.data?.docs.length ?? 0}');
                print('DEBUG: User ID: ${user?.uid}');

                if (snapshot.hasError) {
                  print('DEBUG: StreamBuilder error: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi: ${snapshot.error}',
                          style: TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Refresh
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Đang tải...',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Text(
                      'Không có dữ liệu',
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                print('DEBUG: All docs: ${docs.map((d) => d.data()).toList()}');

                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có cuộc trò chuyện nào',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Nhấn nút + để bắt đầu chat',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Hiển thị tất cả conversations (không filter)
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    // Debug info cho mỗi doc
                    print('DEBUG: Doc $index: $data');
                    print('DEBUG: unreadCount for ${data['name']}: ${data['unreadCount']}');
                    print('DEBUG: lastMessageAt: ${data['lastMessageAt']}');
              
                    return FutureBuilder<String>(
                      future: _getConversationDisplayName(data, user?.uid ?? ''),
                      builder: (context, nameSnapshot) {
                        final displayName = nameSnapshot.data ?? 'Chat';
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor,
                              child: Text(
                                displayName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              displayName,
                              style: TextStyle(
                                fontWeight: (data['unreadCount'] ?? 0) > 0 
                                    ? FontWeight.bold 
                                    : FontWeight.w500,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              data['lastMessage'] ?? 'Chưa có tin nhắn',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: (data['unreadCount'] ?? 0) > 0 
                                    ? Colors.black87 
                                    : Colors.black54,
                                fontWeight: (data['unreadCount'] ?? 0) > 0 
                                    ? FontWeight.w500 
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Thời gian
                                if (data['lastMessageAt'] != null)
                                  Text(
                                    _formatTimeAgo((data['lastMessageAt'] as Timestamp).toDate()),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: (data['unreadCount'] ?? 0) > 0 
                                          ? Colors.blue[600] 
                                          : Colors.grey[600],
                                      fontWeight: (data['unreadCount'] ?? 0) > 0 
                                          ? FontWeight.w500 
                                          : FontWeight.normal,
                                    ),
                                  )
                                else if (data['createdAt'] != null)
                                  Text(
                                    _formatTimeAgo((data['createdAt'] as Timestamp).toDate()),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                // Badge số tin nhắn chưa đọc
                                if ((data['unreadCount'] ?? 0) > 0)
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${data['unreadCount']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatRoomPremium(
                                    conversationId: doc.id,
                                    conversationName: displayName,
                                    members: List<String>.from(data['members'] ?? []),
                                  ),
                                ),
                              );
                            },
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showChatOptions,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  void _showNewChatDialog() {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo phòng chat mới'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tên phòng chat',
            prefixIcon: Icon(Icons.chat),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await _createChatRoom(nameController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  Future<void> _createChatRoom(String name) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) {
      print('DEBUG: User is null');
      return;
    }

    print('DEBUG: Creating chat room with user: ${user.uid}');

    try {
      String conversationId = await _chatService.createGroupConversation(
        name: name,
        memberIds: [user.uid],
        creatorId: user.uid,
      );

      print('DEBUG: Chat room created with ID: $conversationId');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tạo phòng chat "$name"'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      print('DEBUG: Error creating chat room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tạo phòng chat: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showProfileDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hồ sơ của tôi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Người dùng',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: user?.online == true ? AppTheme.successColor : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user?.online == true ? 'Đang online' : 'Offline',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  // Get display name for conversation
  Future<String> _getConversationDisplayName(Map<String, dynamic> data, String currentUserId) async {
    final type = data['type'] as String? ?? 'group';
    
    if (type == 'private') {
      // For private chat, show the other user's name
      final members = List<String>.from(data['members'] ?? []);
      final otherUserId = members.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
      
      if (otherUserId.isNotEmpty) {
        try {
          final userDoc = await _firestore.collection('users').doc(otherUserId).get();
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            return userData['name'] as String? ?? 'Unknown User';
          }
        } catch (e) {
          print('Error getting user name: $e');
        }
      }
      return 'Chat riêng';
    } else {
      // For group chat, use the group name
      return data['name'] as String? ?? 'Nhóm chat';
    }
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Bắt đầu cuộc trò chuyện',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_search,
                  color: AppTheme.primaryColor,
                ),
              ),
              title: const Text('Tìm kiếm người dùng'),
              subtitle: const Text('Chat 1-1 với người dùng khác'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchUsersScreen(),
                  ),
                );
              },
            ),
            
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.group_add,
                  color: Colors.green,
                ),
              ),
              title: const Text('Tạo nhóm chat'),
              subtitle: const Text('Tạo nhóm với nhiều thành viên'),
              onTap: () {
                Navigator.pop(context);
                _showNewChatDialog();
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}