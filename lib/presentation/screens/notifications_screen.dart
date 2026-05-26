import 'package:flutter/material.dart';
import '../theme/app_them.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<(AppNotification, bool)> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await NotificationService.getWithReadState();
    if (mounted) setState(() => _items = items);
    await NotificationService.markAllRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('공지사항'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final (notification, isRead) = _items[i];
                return _buildCard(notification, isRead);
              },
            ),
    );
  }

  Widget _buildCard(AppNotification n, bool isRead) {
    final typeConfig = {
      NotificationType.update: (Icons.system_update_outlined, const Color(0xFF1565C0), const Color(0xFFE3F2FD), '업데이트'),
      NotificationType.security: (Icons.security_outlined, const Color(0xFFC62828), const Color(0xFFFFEBEE), '보안'),
      NotificationType.notice: (Icons.campaign_outlined, const Color(0xFF2E7D32), const Color(0xFFE8F5E9), '공지'),
    };
    final (icon, color, bg, label) = typeConfig[n.type]!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isRead ? null : Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
                      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
                    ),
                    const Spacer(),
                    if (!isRead)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                      ),
                    const SizedBox(width: 4),
                    Text(n.date, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(n.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(n.body, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
