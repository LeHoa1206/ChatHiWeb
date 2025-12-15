import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatelessWidget {
  final AnimationController controller;

  const AnimatedBackground({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPainter(controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;

  BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Gradient background
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF0A0A0A),
        const Color(0xFF1A1A2E),
        const Color(0xFF16213E),
      ],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Floating particles
    _drawParticles(canvas, size);
  }

  void _drawParticles(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final x = (size.width * (i * 0.1 + animationValue * 0.5)) % size.width;
      final y = (size.height * (i * 0.07 + animationValue * 0.3)) % size.height;
      final radius = 1.0 + (i % 3).toDouble();

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Floating geometric shapes
    _drawGeometricShapes(canvas, size);
  }

  void _drawGeometricShapes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6C63FF).withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      final centerX = size.width * (0.2 + i * 0.2);
      final centerY = size.height * (0.3 + (i % 2) * 0.4);
      final radius = 50 + i * 20;
      
      final rotationAngle = animationValue * 2 * math.pi + i * math.pi / 3;
      
      canvas.save();
      canvas.translate(centerX, centerY);
      canvas.rotate(rotationAngle);
      
      // Draw hexagon
      final path = Path();
      for (int j = 0; j < 6; j++) {
        final angle = j * math.pi / 3;
        final x = radius * math.cos(angle);
        final y = radius * math.sin(angle);
        
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}