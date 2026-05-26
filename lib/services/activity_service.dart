import 'package:shared_preferences/shared_preferences.dart';

class ActivityService {
  static const _keyTosCount = 'tos_count';
  static const _keyPhishingCount = 'phishing_count';
  static const _keyPhishingBlocked = 'phishing_blocked';

  static Future<void> recordTosAnalysis() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyTosCount) ?? 0;
    await prefs.setInt(_keyTosCount, current + 1);
  }

  static Future<void> recordPhishingScan({required bool isDanger}) async {
    final prefs = await SharedPreferences.getInstance();
    final scans = prefs.getInt(_keyPhishingCount) ?? 0;
    await prefs.setInt(_keyPhishingCount, scans + 1);
    if (isDanger) {
      final blocked = prefs.getInt(_keyPhishingBlocked) ?? 0;
      await prefs.setInt(_keyPhishingBlocked, blocked + 1);
    }
  }

  static Future<ActivityStats> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    return ActivityStats(
      tosCount: prefs.getInt(_keyTosCount) ?? 0,
      phishingCount: prefs.getInt(_keyPhishingCount) ?? 0,
      phishingBlocked: prefs.getInt(_keyPhishingBlocked) ?? 0,
    );
  }
}

class ActivityStats {
  final int tosCount;
  final int phishingCount;
  final int phishingBlocked;

  const ActivityStats({
    required this.tosCount,
    required this.phishingCount,
    required this.phishingBlocked,
  });

  bool get hasActivity => tosCount > 0 || phishingCount > 0;
}
