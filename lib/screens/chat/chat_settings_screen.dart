import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';

class ChatSettingsScreen extends StatefulWidget {
  const ChatSettingsScreen({super.key});

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _readReceiptsEnabled = true;
  bool _typingIndicatorEnabled = true;
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Cài đặt Chat',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader('🎨 Giao diện'),
          _buildThemeCard(),
          _buildFontSizeCard(),
          
          const SizedBox(height: 24),
          
          // Notifications Section
          _buildSectionHeader('🔔 Thông báo'),
          _buildNotificationCard(),
          
          const SizedBox(height: 24),
          
          // Privacy Section
          _buildSectionHeader('🔒 Quyền riêng tư'),
          _buildPrivacyCard(),
          
          const SizedBox(height: 24),
          
          // Chat Features Section
          _buildSectionHeader('💬 Tính năng Chat'),
          _buildChatFeaturesCard(),
          
          const SizedBox(height: 24),
          
          // About Section
          _buildSectionHeader('ℹ️ Thông tin'),
          _buildAboutCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return SwitchListTile(
                  title: const Text('Chế độ tối'),
                  subtitle: const Text('Bật/tắt giao diện tối'),
                  secondary: Icon(
                    themeProvider.isDarkMode 
                        ? Icons.dark_mode 
                        : Icons.light_mode,
                    color: AppTheme.primaryColor,
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(
                Icons.palette,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Chủ đề màu sắc'),
              subtitle: const Text('Tùy chỉnh màu sắc giao diện'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showColorThemeDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.text_fields,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Kích thước chữ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Xem trước: Đây là tin nhắn mẫu',
              style: TextStyle(fontSize: _fontSize),
            ),
            
            const SizedBox(height: 16),
            
            Slider(
              value: _fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 6,
              label: '${_fontSize.round()}px',
              onChanged: (value) {
                setState(() {
                  _fontSize = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Thông báo'),
              subtitle: const Text('Nhận thông báo tin nhắn mới'),
              secondary: const Icon(
                Icons.notifications,
                color: AppTheme.primaryColor,
              ),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            
            SwitchListTile(
              title: const Text('Âm thanh'),
              subtitle: const Text('Phát âm thanh khi có tin nhắn'),
              secondary: const Icon(
                Icons.volume_up,
                color: AppTheme.primaryColor,
              ),
              value: _soundEnabled,
              onChanged: _notificationsEnabled ? (value) {
                setState(() {
                  _soundEnabled = value;
                });
              } : null,
            ),
            
            SwitchListTile(
              title: const Text('Rung'),
              subtitle: const Text('Rung khi có tin nhắn mới'),
              secondary: const Icon(
                Icons.vibration,
                color: AppTheme.primaryColor,
              ),
              value: _vibrationEnabled,
              onChanged: _notificationsEnabled ? (value) {
                setState(() {
                  _vibrationEnabled = value;
                });
              } : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Xác nhận đã đọc'),
              subtitle: const Text('Hiển thị khi tin nhắn đã được đọc'),
              secondary: const Icon(
                Icons.done_all,
                color: AppTheme.primaryColor,
              ),
              value: _readReceiptsEnabled,
              onChanged: (value) {
                setState(() {
                  _readReceiptsEnabled = value;
                });
              },
            ),
            
            SwitchListTile(
              title: const Text('Hiển thị đang nhập'),
              subtitle: const Text('Cho phép người khác thấy bạn đang nhập'),
              secondary: const Icon(
                Icons.edit,
                color: AppTheme.primaryColor,
              ),
              value: _typingIndicatorEnabled,
              onChanged: (value) {
                setState(() {
                  _typingIndicatorEnabled = value;
                });
              },
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(
                Icons.block,
                color: Colors.red,
              ),
              title: const Text('Danh sách chặn'),
              subtitle: const Text('Quản lý người dùng bị chặn'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🚫 Tính năng sẽ được cập nhật!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatFeaturesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(
                FontAwesomeIcons.download,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Tự động tải media'),
              subtitle: const Text('Tự động tải ảnh và video'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showMediaDownloadDialog();
              },
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(
                Icons.backup,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Sao lưu chat'),
              subtitle: const Text('Sao lưu tin nhắn lên cloud'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('☁️ Tính năng sao lưu sẽ được cập nhật!')),
                );
              },
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(
                Icons.delete_sweep,
                color: Colors.red,
              ),
              title: const Text('Xóa tất cả chat'),
              subtitle: const Text('Xóa toàn bộ lịch sử trò chuyện'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showDeleteAllChatsDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(
                Icons.info,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Phiên bản'),
              subtitle: const Text('Chat App Premium v1.0.0'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(
                Icons.help,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Trợ giúp & Hỗ trợ'),
              subtitle: const Text('Liên hệ đội ngũ hỗ trợ'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📞 Liên hệ: support@chatapp.com')),
                );
              },
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              title: const Text('Đánh giá ứng dụng'),
              subtitle: const Text('Để lại đánh giá 5 sao cho chúng tôi'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('⭐ Cảm ơn bạn đã sử dụng Chat App!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showColorThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn chủ đề màu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildColorOption('Xanh dương', AppTheme.primaryColor),
            _buildColorOption('Tím', Colors.purple),
            _buildColorOption('Xanh lá', Colors.green),
            _buildColorOption('Cam', Colors.orange),
            _buildColorOption('Hồng', Colors.pink),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(String name, Color color) {
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(name),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🎨 Đã chọn chủ đề $name')),
        );
      },
    );
  }

  void _showMediaDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tự động tải media'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Luôn luôn'),
              value: 'always',
              groupValue: 'wifi',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Chỉ khi có WiFi'),
              value: 'wifi',
              groupValue: 'wifi',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Không bao giờ'),
              value: 'never',
              groupValue: 'wifi',
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllChatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Cảnh báo'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tất cả cuộc trò chuyện? '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ Tính năng xóa sẽ được cập nhật!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }
}