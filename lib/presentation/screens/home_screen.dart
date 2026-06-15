import 'package:flutter/material.dart';
import '../theme/app_them.dart';
import '../../services/activity_service.dart';
import '../../services/history_service.dart';
import '../../services/notification_service.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int tabIndex)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ActivityStats? _stats;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadUnread();
  }

  Future<void> _loadStats() async {
    final stats = await ActivityService.getStats();
    if (mounted) setState(() => _stats = stats);
  }

  Future<void> _loadUnread() async {
    final count = await NotificationService.getUnreadCount();
    if (mounted) setState(() => _unreadCount = count);
  }

  Future<void> _openNotifications(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
    _loadUnread();
  }

  void _openTosHistory(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => const HistoryScreen(filterType: HistoryType.tos, title: '약관 분석 기록'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildActivityCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('빠른 실행'),
            const SizedBox(height: 12),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildSectionTitle('서비스 안내'),
            const SizedBox(height: 12),
            _buildInfoCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF1565C0)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shield, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Guardian AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _openNotifications(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
                    ),
                    if (_unreadCount > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Color(0xFFFF5252), shape: BoxShape.circle),
                          child: Text(
                            '$_unreadCount',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '안녕하세요 👋',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '오늘도 안전한 하루 되세요.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    final stats = _stats;
    final hasActivity = stats != null && stats.hasActivity;

    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: hasActivity ? _buildStatsRow(stats) : _buildEmptyActivity(),
        ),
      ),
    );
  }

  Widget _buildStatsRow(ActivityStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('나의 활동', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 16),
        Builder(builder: (context) => Row(
          children: [
            _buildStatItem(
              icon: Icons.description_outlined,
              color: const Color(0xFFE65100),
              bg: const Color(0xFFFFF3E0),
              value: '${stats.tosCount}회',
              label: '약관 분석',
              onTap: () => _openTosHistory(context),
            ),
            const SizedBox(width: 12),
            _buildStatItem(
              icon: Icons.security_outlined,
              color: const Color(0xFFC62828),
              bg: const Color(0xFFFFEBEE),
              value: '${stats.phishingCount}회',
              label: '피싱 검사',
            ),
            const SizedBox(width: 12),
            _buildStatItem(
              icon: Icons.block,
              color: AppTheme.safeColor,
              bg: const Color(0xFFE8F5E9),
              value: '${stats.phishingBlocked}건',
              label: '위협 차단',
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required Color bg,
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyActivity() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.shield_outlined, color: AppTheme.primaryColor, size: 28),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('아직 활동이 없어요', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              SizedBox(height: 4),
              Text('약관 분석이나 피싱 탐지를 시작해보세요.\n사용할수록 내 활동 기록이 쌓입니다.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _ActionItem(icon: Icons.description_outlined, label: '약관\n분석', color: const Color(0xFFE65100), bg: const Color(0xFFFFF3E0), tabIndex: 1),
      _ActionItem(icon: Icons.security_outlined, label: '피싱\n탐지', color: const Color(0xFFC62828), bg: const Color(0xFFFFEBEE), tabIndex: 2),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: actions.map((a) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: a == actions.last ? 0 : 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => widget.onNavigateToTab?.call(a.tabIndex),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: a.bg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(a.icon, color: a.color, size: 26),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      a.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInfoCard() {
    final items = [
      _InfoItem(icon: Icons.description_outlined, text: '복잡한 금융 약관을 AI가 요약하고 위험 조항을 찾아드립니다.'),
      _InfoItem(icon: Icons.security_outlined, text: '피싱 문자·URL을 즉시 분석해 사기 피해를 예방합니다.'),
      _InfoItem(icon: Icons.lock_outline, text: '입력한 데이터는 서버에 저장되지 않습니다.'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: items.map((item) => Padding(
            padding: EdgeInsets.only(bottom: item == items.last ? 0 : 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EAF6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.icon, color: AppTheme.primaryColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.text,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final int tabIndex;
  const _ActionItem({required this.icon, required this.label, required this.color, required this.bg, required this.tabIndex});
}

class _InfoItem {
  final IconData icon;
  final String text;
  const _InfoItem({required this.icon, required this.text});
}
