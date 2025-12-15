import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../utils/app_theme.dart';
import 'message_status_indicator.dart';

class MessageBubblePremium extends StatelessWidget {
  final String messageId;
  final Map<String, dynamic> data;
  final bool isMe;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  const MessageBubblePremium({
    super.key,
    required this.messageId,
    required this.data,
    required this.isMe,
    this.isSelected = false,
    this.onLongPress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = data['content'] as String? ?? '';
    final type = data['type'] as String? ?? 'text';
    final createdAt = data['createdAt'];
    final senderName = data['senderName'] as String? ?? 'Unknown';
    final isPinned = data['isPinned'] as bool? ?? false;
    final reactions = data['reactions'] as Map<String, dynamic>? ?? {};

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  senderName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            
            Flexible(
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 4),
                      child: Text(
                        senderName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  
                  Container(
                    decoration: BoxDecoration(
                      gradient: isMe ? AppTheme.chatBubbleGradient : null,
                      color: isMe ? null : Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                      border: isSelected 
                          ? Border.all(color: AppTheme.primaryColor, width: 2)
                          : Border.all(color: Colors.grey[200]!, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isPinned)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.push_pin,
                                        size: 14,
                                        color: isMe ? Colors.white70 : AppTheme.primaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Đã ghim',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isMe ? Colors.white70 : AppTheme.primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              
                              _buildMessageContent(type, content, context),
                              
                              const SizedBox(height: 4),
                              
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatTime(createdAt),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe ? Colors.white70 : Colors.grey[600],
                                    ),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.done_all,
                                      size: 14,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        if (reactions.isNotEmpty)
                          Positioned(
                            bottom: -8,
                            right: 8,
                            child: _buildReactions(reactions),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            if (isMe) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(String type, String content, BuildContext context) {
    switch (type) {
      case 'image':
        return _buildImageMessage(content);
      case 'file':
        return _buildFileMessage(content);
      case 'audio':
        return _buildAudioMessage(content);
      case 'video':
        return _buildVideoMessage(content);
      default:
        return _buildTextMessage(content);
    }
  }

  Widget _buildTextMessage(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 14,
        color: isMe ? Colors.white : Colors.black87,
        height: 1.3,
      ),
    );
  }

  Widget _buildImageMessage(String content) {
    // Check if it's base64 data or URL
    final imageData = data['imageData'] as String?;
    
    if (imageData != null && imageData.startsWith('data:image')) {
      // Base64 image
      final base64String = imageData.split(',')[1];
      final bytes = base64Decode(base64String);
      
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          bytes,
          width: 200,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 200,
            height: 150,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          ),
        ),
      );
    } else {
      // Network image
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: content,
          width: 200,
          height: 150,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 200,
            height: 150,
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 200,
            height: 150,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          ),
        ),
      );
    }
  }

  Widget _buildFileMessage(String fileName) {
    final fileType = data['fileType'] as String? ?? '';
    final fileSize = data['fileSize'] as int? ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFileIcon(fileType),
            color: AppTheme.primaryColor,
            size: 32,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _getFileSizeString(fileSize),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.download,
            color: Colors.grey[600],
            size: 20,
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileType) {
    if (fileType.contains('image')) {
      return Icons.image;
    } else if (fileType.contains('video')) {
      return Icons.video_file;
    } else if (fileType.contains('audio')) {
      return Icons.audio_file;
    } else if (fileType.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (fileType.contains('word') || fileType.contains('document')) {
      return Icons.description;
    } else if (fileType.contains('excel') || fileType.contains('spreadsheet')) {
      return Icons.table_chart;
    } else if (fileType.contains('powerpoint') || fileType.contains('presentation')) {
      return Icons.slideshow;
    } else if (fileType.contains('zip') || fileType.contains('rar')) {
      return Icons.archive;
    } else {
      return Icons.insert_drive_file;
    }
  }

  String _getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  Widget _buildAudioMessage(String audioUrl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_arrow,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            'Voice Message',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoMessage(String videoUrl) {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.play_circle_fill,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildReactions(Map<String, dynamic> reactions) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              '${entry.key} ${entry.value}',
              style: const TextStyle(fontSize: 12),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    
    try {
      final dateTime = timestamp.toDate();
      return timeago.format(dateTime, locale: 'vi');
    } catch (e) {
      return '';
    }
  }
}