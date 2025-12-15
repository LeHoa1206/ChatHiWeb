import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../utils/app_theme.dart';

class PremiumFeaturesScreen extends StatelessWidget {
  const PremiumFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '✨ Tính năng Premium',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body: AnimationLimiter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            AnimationConfiguration.staggeredList(
              position: 0,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildHeader(),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Features Grid
            ...List.generate(_premiumFeatures.length, (index) {
              return AnimationConfiguration.staggeredList(
                position: index + 1,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildFeatureCard(_premiumFeatures[index]),
                  ),
                ),
              );
            }),
            
            const SizedBox(height: 32),
            
            // Upgrade Button
            AnimationConfiguration.staggeredList(
              position: _premiumFeatures.length + 1,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildUpgradeButton(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/logo.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.diamond,
                  size: 60,
                  color: Colors.white,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chat App Premium',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Trải nghiệm chat đỉnh cao nhất với các tính năng siêu xịn xò!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(PremiumFeature feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: feature.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              feature.icon,
              color: feature.color,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: feature.isAvailable ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              feature.isAvailable ? 'Có sẵn' : 'Sắp có',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Bạn đã sử dụng phiên bản Premium miễn phí!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rocket_launch,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              'Nâng cấp Premium ngay!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumFeature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isAvailable;

  PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.isAvailable = true,
  });
}

final List<PremiumFeature> _premiumFeatures = [
  PremiumFeature(
    icon: FontAwesomeIcons.video,
    title: 'Video Call HD',
    description: 'Gọi video chất lượng cao với hiệu ứng đẹp mắt',
    color: Colors.blue,
    isAvailable: false,
  ),
  PremiumFeature(
    icon: FontAwesomeIcons.microphone,
    title: 'Voice Messages',
    description: 'Ghi âm và gửi tin nhắn thoại với chất lượng crystal clear',
    color: Colors.green,
    isAvailable: false,
  ),
  PremiumFeature(
    icon: FontAwesomeIcons.image,
    title: 'Media Sharing',
    description: 'Chia sẻ ảnh, video không giới hạn với tốc độ siêu nhanh',
    color: Colors.purple,
  ),
  PremiumFeature(
    icon: FontAwesomeIcons.thumbtack,
    title: 'Pin Messages',
    description: 'Ghim tin nhắn quan trọng để dễ dàng tìm kiếm sau này',
    color: Colors.orange,
  ),
  PremiumFeature(
    icon: FontAwesomeIcons.reply,
    title: 'Smart Reply',
    description: 'Trả lời tin nhắn thông minh với giao diện đẹp mắt',
    color: Colors.teal,
  ),
  PremiumFeature(
    icon: FontAwesomeIcons.magnifyingGlass,
    title: 'Advanced Search',
    description: 'Tìm kiếm tin nhắn siêu nhanh với bộ lọc thông minh',
    color: Colors.indigo,
    isAvailable: false,
  ),
  PremiumFeature(
    icon: FontAwesomeIcons.heart,
    title: 'Message Reactions',
    description: 'Thả tim, like và emoji reactions cho tin nhắn',
    color: Colors.red,
    isAvailable: false,
  ),
  PremiumFeature(
    icon: FontAwesomeIcons.forward,
    title: 'Message Forwarding',
    description: 'Chuyển tiếp tin nhắn đến nhiều cuộc trò chuyện cùng lúc',
    color: Colors.cyan,
  ),
  PremiumFeature(
    icon: FontAwesomeIcons.userGroup,
    title: 'Group Management',
    description: 'Quản lý nhóm chat với quyền admin và member',
    color: Colors.brown,
  ),
  PremiumFeature(
    icon: FontAwesomeIcons.palette,
    title: 'Custom Themes',
    description: 'Tùy chỉnh giao diện với hàng trăm theme đẹp mắt',
    color: Colors.pink,
    isAvailable: false,
  ),
];