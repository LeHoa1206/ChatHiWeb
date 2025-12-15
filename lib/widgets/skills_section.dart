import 'package:flutter/material.dart';
import 'glassmorphic_container.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/theme.dart';

class SkillsSection extends StatefulWidget {
  const SkillsSection({super.key});

  @override
  State<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  final List<SkillData> skills = [
    SkillData('Flutter', FontAwesomeIcons.flutter, 95, AppTheme.primaryColor),
    SkillData('Dart', Icons.code, 90, AppTheme.secondaryColor),
    SkillData('Firebase', FontAwesomeIcons.fire, 85, Colors.orange),
    SkillData('UI/UX', FontAwesomeIcons.figma, 88, Colors.purple),
    SkillData('Git', FontAwesomeIcons.git, 82, Colors.red),
    SkillData('API Integration', FontAwesomeIcons.server, 87, Colors.green),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      skills.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1500 + (index * 200)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
    }).toList();

    // Start animations with delay
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].forward();
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      child: Column(
        children: [
          // Section Title
          Text(
            'KỸ NĂNG',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Những công nghệ tôi thành thạo',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          
          const SizedBox(height: 60),
          
          // Skills Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.2,
            ),
            itemCount: skills.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _animations[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animations[index].value,
                    child: _buildSkillCard(skills[index], index),
                  );
                },
              );
            },
          ),
          
          const SizedBox(height: 60),
          
          // Additional Skills
          _buildAdditionalSkills(),
        ],
      ),
    );
  }

  Widget _buildSkillCard(SkillData skill, int index) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: double.infinity,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          skill.color.withOpacity(0.5),
          skill.color.withOpacity(0.2),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with glow effect
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: skill.color.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: skill.color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              skill.icon,
              size: 30,
              color: skill.color,
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Skill name
          Text(
            skill.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Progress bar
          AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Column(
                children: [
                  Text(
                    '${(skill.percentage * _animations[index].value).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: skill.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (skill.percentage / 100) * _animations[index].value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: [skill.color, skill.color.withOpacity(0.6)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalSkills() {
    final additionalSkills = [
      'State Management (Bloc, Provider, Riverpod)',
      'REST API & GraphQL',
      'SQLite & Hive Database',
      'Push Notifications',
      'App Store & Play Store Publishing',
      'CI/CD with GitHub Actions',
    ];

    return Column(
      children: [
        Text(
          'Kỹ năng khác',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 30),
        
        Wrap(
          spacing: 15,
          runSpacing: 15,
          children: additionalSkills.map((skill) {
            return GlassmorphicContainer(
              width: null,
              height: 40,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderGradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.3),
                  AppTheme.secondaryColor.withOpacity(0.3),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  skill,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class SkillData {
  final String name;
  final IconData icon;
  final int percentage;
  final Color color;

  SkillData(this.name, this.icon, this.percentage, this.color);
}