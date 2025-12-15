import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/app_theme.dart';

class ChatInputPremium extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSendMessage;
  final VoidCallback onSendVoice;
  final VoidCallback onPickImage;
  final VoidCallback onPickFile;
  final String? replyToMessage;
  final VoidCallback onCancelReply;

  const ChatInputPremium({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSendMessage,
    required this.onSendVoice,
    required this.onPickImage,
    required this.onPickFile,
    this.replyToMessage,
    required this.onCancelReply,
  });

  @override
  State<ChatInputPremium> createState() => _ChatInputPremiumState();
}

class _ChatInputPremiumState extends State<ChatInputPremium>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showAttachments = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Reply Preview
          if (widget.replyToMessage != null) _buildReplyPreview(),
          
          // Attachments Panel
          if (_showAttachments) _buildAttachmentsPanel(),
          
          // Main Input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attachment Button
                _buildAttachmentButton(),
                
                const SizedBox(width: 8),
                
                // Text Input
                Expanded(
                  child: _buildTextInput(),
                ),
                
                const SizedBox(width: 4),
                
                // Send/Voice Button
                _buildSendButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        border: Border(
          left: BorderSide(
            color: AppTheme.primaryColor,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trả lời tin nhắn',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.replyToMessage ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onCancelReply,
            icon: const Icon(Icons.close, size: 18),
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAttachmentOption(
            icon: FontAwesomeIcons.camera,
            label: 'Camera',
            color: Colors.blue,
            onTap: widget.onPickImage,
          ),
          _buildAttachmentOption(
            icon: FontAwesomeIcons.image,
            label: 'Ảnh',
            color: Colors.green,
            onTap: widget.onPickImage,
          ),
          _buildAttachmentOption(
            icon: FontAwesomeIcons.file,
            label: 'File',
            color: Colors.orange,
            onTap: widget.onPickFile,
          ),
          _buildAttachmentOption(
            icon: FontAwesomeIcons.locationDot,
            label: 'Vị trí',
            color: Colors.red,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📍 Chia sẻ vị trí sẽ được cập nhật!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAttachments = !_showAttachments;
        });
        if (_showAttachments) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _showAttachments 
              ? AppTheme.primaryColor 
              : Colors.grey[200],
          shape: BoxShape.circle,
          border: Border.all(
            color: _showAttachments ? AppTheme.primaryColor : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animationController.value * 0.785, // 45 degrees
              child: Icon(
                Icons.add,
                color: _showAttachments ? Colors.white : Colors.grey[700],
                size: 24,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        maxLines: 5,
        minLines: 1,
        decoration: InputDecoration(
          hintText: 'Nhập tin nhắn...',
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: const TextStyle(fontSize: 16),
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  Widget _buildSendButton() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        final hasText = value.text.trim().isNotEmpty;
        
        return GestureDetector(
          onTap: hasText ? widget.onSendMessage : null,
          onLongPress: !hasText ? _startVoiceRecording : null,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: hasText ? AppTheme.primaryGradient : null,
              color: hasText ? null : Colors.grey[400],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: hasText 
                      ? AppTheme.primaryColor.withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                hasText 
                    ? Icons.send_rounded 
                    : _isRecording 
                        ? Icons.stop 
                        : Icons.mic,
                key: ValueKey(hasText ? 'send' : _isRecording ? 'stop' : 'mic'),
                color: hasText ? Colors.white : Colors.grey[700],
                size: 22,
              ),
            ),
          ),
        );
      },
    );
  }

  void _startVoiceRecording() {
    setState(() {
      _isRecording = true;
    });
    
    // Simulate recording
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
        widget.onSendVoice();
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎤 Đang ghi âm... (Giả lập)'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}