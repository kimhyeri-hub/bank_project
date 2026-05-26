import 'package:shared_preferences/shared_preferences.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String date;
  final NotificationType type;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.type,
  });
}

enum NotificationType { update, security, notice }

class NotificationService {
  static const _keyReadIds = 'read_notification_ids';

  static final List<AppNotification> announcements = [
    AppNotification(
      id: 'n003',
      title: '피싱 탐지 기능 강화',
      body: '최신 금융사기 패턴을 반영하여 피싱 탐지 정확도를 높였습니다. 의심스러운 문자나 링크는 바로 검사해보세요.',
      date: '2025.05.26',
      type: NotificationType.update,
    ),
    AppNotification(
      id: 'n002',
      title: '개인정보 보호 주의 안내',
      body: '최근 금융기관을 사칭한 문자 피싱이 증가하고 있습니다. 출처가 불명확한 링크는 클릭하지 마세요.',
      date: '2025.05.20',
      type: NotificationType.security,
    ),
    AppNotification(
      id: 'n001',
      title: 'Guardian AI 서비스 시작',
      body: 'Guardian AI가 출시되었습니다. 약관 분석과 피싱 탐지 기능으로 여러분의 금융 생활을 안전하게 지켜드립니다.',
      date: '2025.05.01',
      type: NotificationType.notice,
    ),
  ];

  static Future<Set<String>> _getReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyReadIds)?.toSet() ?? {};
  }

  static Future<void> markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyReadIds, announcements.map((n) => n.id).toList());
  }

  static Future<int> getUnreadCount() async {
    final readIds = await _getReadIds();
    return announcements.where((n) => !readIds.contains(n.id)).length;
  }

  static Future<List<(AppNotification, bool)>> getWithReadState() async {
    final readIds = await _getReadIds();
    return announcements.map((n) => (n, readIds.contains(n.id))).toList();
  }
}
