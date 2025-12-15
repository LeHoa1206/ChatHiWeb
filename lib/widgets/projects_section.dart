import 'package:flutter/material.dart';
import 'glassmorphic_container.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/theme.dart';

class ProjectsSection extends StatefulWidget {
  const ProjectsSection({super.key});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  int selectedCategory = 0;
  
  final List<String> categories = ['Tất cả', 'Mobile App', 'Web App', 'UI/UX'];
  
  final List<ProjectData> projects = [
    ProjectData(
      title: 'E-Commerce App',
      description: 'Ứng dụng mua sắm trực tuyến với UI hiện đại, thanh toán an toàn và quản lý đơn hàng thông minh.',
      image: 'assets/images/project1.jpg',
      technologies: ['Flutter', 'Firebase', 'Stripe'],
      category: 'Mobile App',
      color: Colors.blue,
      githubUrl: 'https://github.com',
      liveUrl: 'https://demo.com',
    ),
    ProjectData(
      title: 'Social Media Dashboard',
      description: 'Dashboard quản lý mạng xã hội với analytics real-time và automation tools.',
      image: 'assets/images/project2.jpg',
      technologies: ['Flutter Web', 'Chart.js', 'REST API'],
      category: 'Web App',
      color: Colors.purple,
      githubUrl: 'https://github.com',
      liveUrl: 'https://demo.com',
    ),
    ProjectData(
      title: 'Fitness Tracker',
      description: 'Ứng dụng theo dõi sức khỏe với AI coaching và community features.',
      image: 'assets/images/project3.jpg',
      technologies: ['Flutter', 'ML Kit', 'HealthKit'],
      category: 'Mobile App',
      color: Colors.green,
      githubUrl: 'https://github.com',
      liveUrl: 'https://demo.com',
    ),
    ProjectData(
      title: 'Banking App UI',
      description: 'Thiết kế UI/UX cho ứng dụng ngân hàng với focus vào security và user experience.',
      image: 'assets/images/project4.jpg',
      technologies: ['Figma', 'Principle', 'After Effects'],
      category: 'UI/UX',
      color: Colors.orange,
      githubUrl: 'https://github.com',
      liveUrl: 'https://demo.com',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      child: Column(
        children: [
          // Section Title
          Text(
            'DỰ ÁN',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Những dự án tôi đã thực hiện',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          
          const SizedBox(height: 60),
          
          // Category Filter
          _buildCategoryFilter(),
          
          const SizedBox(height: 40),
          
          // Projects Grid
          _buildProjectsGrid(),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: categories.asMap().entries.map((entry) {
        int index = entry.key;
        String category = entry.value;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCategory = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: selectedCategory == index
                  ? AppTheme.primaryGradient
                  : null,
              border: Border.all(
                color: selectedCategory == index
                    ? Colors.transparent
                    : Colors.white.withOpacity(0.3),
              ),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: Colors.white,
                fontWeight: selectedCategory == index
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProjectsGrid() {
    List<ProjectData> filteredProjects = selectedCategory == 0
        ? projects
        : projects.where((p) => p.category == categories[selectedCategory]).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 30,
        mainAxisSpacing: 30,
        childAspectRatio: 0.8,
      ),
      itemCount: filteredProjects.length,
      itemBuilder: (context, index) {
        return _buildProjectCard(filteredProjects[index]);
      },
    );
  }

  Widget _buildProjectCard(ProjectData project) {
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
          project.color.withOpacity(0.5),
          project.color.withOpacity(0.2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Image
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                colors: [
                  project.color.withOpacity(0.3),
                  project.color.withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.phone_android,
              size: 60,
              color: project.color,
            ),
          ),
          
          // Project Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Text(
                    project.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Technologies
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: project.technologies.map((tech) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: project.color.withOpacity(0.2),
                        ),
                        child: Text(
                          tech,
                          style: TextStyle(
                            fontSize: 10,
                            color: project.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const Spacer(),
                  
                  // Action Buttons
                  Row(
                    children: [
                      _buildActionButton(
                        FontAwesomeIcons.github,
                        () {},
                      ),
                      const SizedBox(width: 10),
                      _buildActionButton(
                        Icons.launch,
                        () {},
                      ),
                      const Spacer(),
                      Icon(
                        Icons.favorite_border,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ProjectData {
  final String title;
  final String description;
  final String image;
  final List<String> technologies;
  final String category;
  final Color color;
  final String githubUrl;
  final String liveUrl;

  ProjectData({
    required this.title,
    required this.description,
    required this.image,
    required this.technologies,
    required this.category,
    required this.color,
    required this.githubUrl,
    required this.liveUrl,
  });
}