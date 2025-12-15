import 'package:flutter/material.dart';

void main() {
  runApp(const SimplePortfolioApp());
}

class SimplePortfolioApp extends StatelessWidget {
  const SimplePortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio - Lê Hòa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const SimpleHomePage(),
    );
  }
}

class SimpleHomePage extends StatelessWidget {
  const SimpleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Image
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ),
              ),
              child: const Icon(
                Icons.person,
                size: 80,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Name
            const Text(
              'LÊ HÒA',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            const Text(
              'Frontend Developer',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white70,
              ),
            ),
            
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
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Xem Dự Án',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                
                const SizedBox(width: 20),
                
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Liên Hệ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}