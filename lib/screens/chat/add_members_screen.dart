import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';

class AddMembersScreen extends StatefulWidget {
  final String conversationId;
  final List<String> currentMembers;

  const AddMembersScreen({
    super.key,
    required this.conversationId,
    required this.currentMembers,
  });

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedUsers = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  Future<void> _loadAllUsers() async {
    setState(() => _isLoading = true);
    
    try {
      final snapshot = await _firestore.collection('users').get();
      final users = snapshot.docs
          .map((doc) => {
                'uid': doc.id,
                ...doc.data(),
              })
          .where((user) => 
              user['uid'] != null && 
              user['uid'].toString().isNotEmpty &&
              !widget.currentMembers.contains(user['uid']))
          .toList();
      
      setState(() {
        _searchResults = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải danh sách người dùng: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _searchUsers(String query) {
    if (query.isEmpty) {
      _loadAllUsers();
      return;
    }

    setState(() {
      _searchResults = _searchResults
          .where((user) =>
              (user['name'] as String? ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (user['email'] as String? ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _addSelectedMembers() async {
    if (_selectedUsers.isEmpty) return;
    
    // Validate conversationId
    if (widget.conversationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi: ID cuộc trò chuyện không hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Filter out empty user IDs
      final validUserIds = _selectedUsers.where((id) => id.isNotEmpty).toList();
      
      if (validUserIds.isEmpty) {
        throw Exception('Không có user ID hợp lệ');
      }

      // Get conversation details first
      final conversationDoc = await _firestore
          .collection('conversations')
          .doc(widget.conversationId)
          .get();
      
      if (!conversationDoc.exists) {
        throw Exception('Cuộc trò chuyện không tồn tại');
      }

      final conversationData = conversationDoc.data() as Map<String, dynamic>;

      // Add members to conversation
      await _firestore
          .collection('conversations')
          .doc(widget.conversationId)
          .update({
        'members': FieldValue.arrayUnion(validUserIds),
      });

      // Add conversation to each new member's userConversations
      for (String userId in validUserIds) {
        await _firestore
            .collection('userConversations')
            .doc(userId)
            .collection('conversations')
            .doc(widget.conversationId)
            .set({
          'conversationId': widget.conversationId,
          'type': conversationData['type'] ?? 'group',
          'name': conversationData['name'],
          'avatarUrl': conversationData['avatarUrl'],
          'members': conversationData['members'], // Thêm members array
          'unreadCount': 0,
          'isPinned': false,
          'isMuted': false,
          'lastMessage': conversationData['lastMessage'],
          'lastMessageAt': conversationData['lastMessageAt'],
        });
      }

      // Send system message
      await _firestore
          .collection('conversations')
          .doc(widget.conversationId)
          .collection('messages')
          .add({
        'senderId': 'system',
        'senderName': 'System',
        'content': 'Đã thêm ${validUserIds.length} thành viên mới vào nhóm',
        'type': 'system',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context, _selectedUsers);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm ${_selectedUsers.length} thành viên'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi thêm thành viên: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm thành viên'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        actions: [
          if (_selectedUsers.isNotEmpty)
            TextButton(
              onPressed: _isLoading ? null : _addSelectedMembers,
              child: Text(
                'Thêm (${_selectedUsers.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên hoặc email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: _searchUsers,
            ),
          ),

          // Selected users count
          if (_selectedUsers.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đã chọn ${_selectedUsers.length} người',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Không tìm thấy người dùng nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          final isSelected = _selectedUsers.contains(user['uid']);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedUsers.add(user['uid']);
                                  } else {
                                    _selectedUsers.remove(user['uid']);
                                  }
                                });
                              },
                              secondary: CircleAvatar(
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  (user['name'] as String? ?? 'U')
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                user['name'] as String? ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                user['email'] as String? ?? '',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              activeColor: AppTheme.primaryColor,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}