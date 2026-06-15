import 'package:flutter/material.dart';
import '../theme/app_them.dart';
import '../../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  final HistoryType filterType;
  final String title;

  const HistoryScreen({super.key, required this.filterType, required this.title});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry>? _entries;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await HistoryService.load();
    final filtered = all.where((e) => e.type == widget.filterType).toList();
    if (mounted) setState(() => _entries = filtered);
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: entries == null
          ? const Center(child: CircularProgressIndicator())
          : entries.isEmpty
              ? _buildEmpty()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _buildCard(entries[i]),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, color: AppTheme.textSecondary, size: 40),
            const SizedBox(height: 12),
            const Text('아직 분석 기록이 없어요', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text(
              widget.filterType == HistoryType.tos
                  ? '약관을 분석하면 여기에 기록이 쌓입니다.'
                  : '피싱 검사를 진행하면 여기에 기록이 쌓입니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(HistoryEntry entry) {
    final levelConfig = {
      'danger': (const Color(0xFFC62828), const Color(0xFFFFEBEE), '위험'),
      'warning': (const Color(0xFFE65100), const Color(0xFFFFF3E0), '주의'),
      'safe': (AppTheme.safeColor, const Color(0xFFE8F5E9), '안전'),
    };
    final (color, bg, label) = levelConfig[entry.riskLevel] ?? levelConfig['safe']!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
                child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              Text(_formatDate(entry.createdAt), style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.input,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            entry.resultSummary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}.${two(dt.month)}.${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}
