import 'package:flutter/material.dart';
import 'dart:ui';

class GlassmorphicContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final AlignmentGeometry alignment;
  final double border;
  final LinearGradient linearGradient;
  final LinearGradient borderGradient;
  final Widget child;

  const GlassmorphicContainer({
    super.key,
    this.width,
    this.height,
    required this.borderRadius,
    required this.blur,
    required this.alignment,
    required this.border,
    required this.linearGradient,
    required this.borderGradient,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          alignment: alignment,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: linearGradient,
            border: Border.all(
              width: border,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}