import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/chat_service.dart';

class PinnedMessagesBar extends StatelessWidget {
  final String conversationId;
  final ChatService chatService;

  const PinnedMessagesBar({
    super.key,
    required this.conversationId,
    required this.chatService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: chatService.getPinnedMessages(conversationId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            border: Border(
              bottom: BorderSide(color: Colors.amber[200]!),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.push_pin, color: Colors.amber[700], size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${snapshot.data!.docs.length} tin nhắn được ghim',
                  style: TextStyle(
                    color: Colors.amber[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _showPinnedMessages(context, snapshot.data!.docs),
                child: Text(
                  'Xem',
                  style: TextStyle(color: Colors.amber[700]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPinnedMessages(BuildContext context, List<QueryDocumentSnapshot> pinnedDocs) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.push_pin, color: Colors.amber[700]),
                const SizedBox(width: 8),
                const Text(
                  'Tin nhắn được ghim',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: pinnedDocs.length,
                itemBuilder: (context, index) {
                  final pinnedData = pinnedDocs[index].data() as Map<String, dynamic>;
                  final messageId = pinnedData['messageId'];
                  
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('conversations')
                        .doc(conversationId)
                        .collection('messages')
                        .doc(messageId)
                        .get(),
                    builder: (context, messageSnapshot) {
                      if (!messageSnapshot.hasData) {
                        return const ListTile(
                          title: Text('Đang tải...'),
                        );
                      }

                      final messageData = messageSnapshot.data!.data() as Map<String, dynamic>?;
                      if (messageData == null) {
                        return const ListTile(
                          title: Text('Tin nhắn đã bị xóa'),
                        );
                      }

                      return Card(
                        child: ListTile(
                          title: Text(
                            messageData['content'] ?? 'Tin nhắn không có nội dung',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'Ghim lúc: ${_formatTime((pinnedData['pinnedAt'] as Timestamp?)?.toDate())}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.push_pin_outlined),
                            onPressed: () {
                              chatService.togglePinMessage(conversationId, messageId);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}