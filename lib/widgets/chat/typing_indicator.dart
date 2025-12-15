import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class TypingIndicator extends StatelessWidget {
  final AnimationController controller;
  final List<String> users;

  const TypingIndicator({
    super.key,
    required this.controller,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          CircleAvatar(
            radius: 12,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              users.first.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Typing text
          Text(
            _getTypingText(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Animated dots
          _buildTypingDots(),
        ],
      ),
    );
  }

  String _getTypingText() {
    if (users.length == 1) {
      return '${users.first} đang nhập';
    } else if (users.length == 2) {
      return '${users.first} và ${users.last} đang nhập';
    } else {
      return '${users.first} và ${users.length - 1} người khác đang nhập';
    }
  }

  Widget _buildTypingDots() {
    return Row(
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final animationValue = (controller.value + index * 0.2) % 1.0;
            final opacity = (animationValue < 0.5) 
                ? animationValue * 2 
                : (1.0 - animationValue) * 2;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: Opacity(
                opacity: opacity.clamp(0.3, 1.0),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}