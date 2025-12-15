import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class MessageStatusIndicator extends StatelessWidget {
  final bool isSent;
  final bool isDelivered;
  final bool isRead;
  final bool isMe;

  const MessageStatusIndicator({
    super.key,
    required this.isSent,
    required this.isDelivered,
    required this.isRead,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    if (!isMe) return const SizedBox.shrink();

    IconData icon;
    Color color;

    if (isRead) {
      icon = Icons.done_all;
      color = AppTheme.primaryColor;
    } else if (isDelivered) {
      icon = Icons.done_all;
      color = Colors.grey[600]!;
    } else if (isSent) {
      icon = Icons.done;
      color = Colors.grey[600]!;
    } else {
      icon = Icons.access_time;
      color = Colors.grey[400]!;
    }

    return Icon(
      icon,
      size: 14,
      color: color,
    );
  }
}

class TypingDots extends StatefulWidget {
  final Color color;
  final double size;

  const TypingDots({
    super.key,
    this.color = AppTheme.primaryColor,
    this.size = 4.0,
  });

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: 0.4 + (_animations[index].value * 0.6),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color,
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