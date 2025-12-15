import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio - Lê Hòa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const PortfolioHome(),
    );
  }
}

class PortfolioHome extends StatefulWidget {
  const PortfolioHome({super.key});

  @override
  State<PortfolioHome> createState() => _PortfolioHomeState();
}

class _PortfolioHomeState extends State<PortfolioHome>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return CustomPaint(
                painter: BackgroundPainter(_backgroundController.value),
                size: Size.infinite,
              );
            },
          ),
          
          // Main Content
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroSection(),
                _buildAboutSection(),
                _buildSkillsSection(),
                _buildContactSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Image with floating animation
            AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingAnimation.value),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0A0A0A),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 30),
            
            // Name with gradient text
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
              ).createShader(bounds),
              child: const Text(
                'LÊ HÒA',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Animated typing text
            const TypewriterText(),
            
            const SizedBox(height: 40),
            
            // Description
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: const Text(
                'Tôi là một Frontend Developer đam mê tạo ra những trải nghiệm web đẹp mắt, '
                'chức năng và thân thiện với người dùng. Với hơn 3 năm kinh nghiệm.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.6,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // CTA Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGlassButton('Xem Projects', Icons.work, () {}),
                const SizedBox(width: 20),
                _buildGlassButton('Liên Hệ', Icons.message, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton(String text, IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      child: Column(
        children: [
          const Text(
            'VỀ TÔI',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 60),
          const Text(
            'Tôi là một lập trình viên full-stack đầy nhiệt huyết với hơn 3 năm kinh nghiệm '
            'trong việc tạo ra các giải pháp kỹ thuật số. Tôi chuyên về React, JavaScript '
            'và các công nghệ web hiện đại.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('50+', 'Projects'),
              _buildStatCard('3+', 'Years Exp'),
              _buildStatCard('100%', 'Satisfied'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    final skills = ['React', 'JavaScript', 'Flutter', 'UI/UX', 'Node.js', 'Firebase'];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      child: Column(
        children: [
          const Text(
            'KỸ NĂNG',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            children: skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      child: Column(
        children: [
          const Text(
            'LIÊN HỆ',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Hãy cùng tạo ra điều gì đó tuyệt vời!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Gửi Tin Nhắn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TypewriterText extends StatefulWidget {
  const TypewriterText({super.key});

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;
  String _currentText = '';
  
  final List<String> _texts = [
    'Frontend Developer 🚀',
    'UI/UX Designer ✨',
    'React Specialist 📱',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _startTyping();
  }

  void _startTyping() async {
    while (mounted) {
      String targetText = _texts[_currentIndex];
      
      // Type text
      for (int i = 0; i <= targetText.length; i++) {
        if (!mounted) return;
        setState(() {
          _currentText = targetText.substring(0, i);
        });
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      await Future.delayed(const Duration(milliseconds: 2000));
      
      // Delete text
      for (int i = targetText.length; i >= 0; i--) {
        if (!mounted) return;
        setState(() {
          _currentText = targetText.substring(0, i);
        });
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
      _currentIndex = (_currentIndex + 1) % _texts.length;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Text(
        _currentText,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white70,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;

  BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Gradient background
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0A0A0A),
        Color(0xFF1A1A2E),
        Color(0xFF16213E),
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
      final radius = 50.0 + i * 20.0;
      
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