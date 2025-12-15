import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChatAppDemo());
}

class ChatAppDemo extends StatelessWidget {
  const ChatAppDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Chat App Demo - Siêu Xịn Xò',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const DemoHomeScreen(),
          );
        },
      ),
    );
  }
}

class DemoHomeScreen extends StatelessWidget {
  const DemoHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chat_bubble_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Title
                      const Text(
                        'HIWEB',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Features
                      const Text(
                        '🔥 Tính năng đỉnh cao:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildFeature('💬', 'Chat real-time với Firebase'),
                      _buildFeature('📸', 'Gửi ảnh, video, file'),
                      _buildFeature('🎤', 'Voice messages'),
                      _buildFeature('📹', 'Video call'),
                      _buildFeature('📌', 'Ghim tin nhắn'),
                      _buildFeature('👥', 'Group chat'),
                      _buildFeature('🔔', 'Push notifications'),
                      _buildFeature('🌙', 'Dark/Light theme'),
                      
                      const SizedBox(height: 32),
                      
                      // Firebase Config Notice
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.warningColor.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppTheme.warningColor,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Cần cấu hình Firebase',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.warningColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Để sử dụng đầy đủ tính năng, vui lòng:\n'
                              '1. Tạo Firebase project\n'
                              '2. Cập nhật firebase_options.dart\n'
                              '3. Bật Authentication, Firestore, Storage',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Theme Toggle
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Theme: '),
                              Switch(
                                value: themeProvider.isDarkMode,
                                onChanged: (value) {
                                  themeProvider.toggleTheme();
                                },
                              ),
                              Text(themeProvider.isDarkMode ? 'Dark' : 'Light'),
                            ],
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Demo Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Vui lòng cấu hình Firebase để sử dụng đầy đủ tính năng!',
                                ),
                                backgroundColor: AppTheme.warningColor,
                              ),
                            );
                          },
                          child: const Text(
                            'Bắt đầu Chat (Cần Firebase)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}