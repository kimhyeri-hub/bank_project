import 'package:flutter/material.dart';
import '../theme/app_them.dart';
import '../../services/activity_service.dart';

class PhishingScreen extends StatefulWidget {
  const PhishingScreen({super.key});

  @override
  State<PhishingScreen> createState() => _PhishingScreenState();
}

class _PhishingScreenState extends State<PhishingScreen> {
  final _controller = TextEditingController();
  _ScanResult? _result;

  Future<void> _scan() async {
    final text = _controller.text.trim().toLowerCase();
    if (text.isEmpty) return;

    final dangerKeywords = ['무료', '당첨', '클릭', '즉시', '긴급', '계좌', '비밀번호 입력', '확인 요망'];
    final suspiciousDomains = ['bit.ly', 'tinyurl', 'goo.gl', '.xyz', '.ru', '.tk'];

    final foundDanger = dangerKeywords.where((k) => text.contains(k)).toList();
    final foundDomain = suspiciousDomains.where((d) => text.contains(d)).toList();

    _ScanLevel level;
    String summary;

    if (foundDanger.length >= 2 || foundDomain.isNotEmpty) {
      level = _ScanLevel.danger;
      summary = '피싱 가능성이 높습니다. 링크를 클릭하거나 개인정보를 입력하지 마세요.';
    } else if (foundDanger.isNotEmpty) {
      level = _ScanLevel.warning;
      summary = '의심스러운 내용이 포함되어 있습니다. 주의가 필요합니다.';
    } else {
      level = _ScanLevel.safe;
      summary = '분석 결과 위험 요소가 발견되지 않았습니다.';
    }

    await ActivityService.recordPhishingScan(isDanger: level == _ScanLevel.danger);
    setState(() => _result = _ScanResult(level: level, summary: summary, keywords: [...foundDanger, ...foundDomain]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('피싱 탐지'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBanner(),
            const SizedBox(height: 16),
            _buildInputCard(),
            const SizedBox(height: 16),
            if (_result != null) _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.dangerColor, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'URL, 문자 메시지, 이메일 내용을 붙여넣어 피싱 여부를 확인하세요.',
              style: TextStyle(fontSize: 12, color: AppTheme.dangerColor, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('URL 또는 메시지 입력', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '의심되는 URL이나 문자 내용을 붙여넣으세요...',
              hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              prefixIcon: Padding(padding: EdgeInsets.only(bottom: 56), child: Icon(Icons.link, color: AppTheme.textSecondary)),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _controller.text = '[무료] 당첨되셨습니다! 즉시 클릭하여 계좌 정보를 입력하세요. http://bit.ly/win123',
            child: const Text('예시 피싱 문자 불러오기', style: TextStyle(fontSize: 12, color: AppTheme.primaryLight, decoration: TextDecoration.underline)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _scan,
              icon: const Icon(Icons.security, size: 18),
              label: const Text('피싱 탐지 시작'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final r = _result!;
    final configs = {
      _ScanLevel.danger: (AppTheme.dangerColor, const Color(0xFFFFEBEE), Icons.dangerous, '위험'),
      _ScanLevel.warning: (AppTheme.warningColor, const Color(0xFFFFF8E1), Icons.warning_amber, '주의'),
      _ScanLevel.safe: (AppTheme.safeColor, const Color(0xFFE8F5E9), Icons.verified_user, '안전'),
    };
    final (color, bg, icon, label) = configs[r.level]!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('판정: $label', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
                  const SizedBox(height: 2),
                  const Text('분석 완료', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 14),
          Text(r.summary, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.5)),
          if (r.keywords.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text('감지된 키워드', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: r.keywords.map((k) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(k, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

enum _ScanLevel { danger, warning, safe }

class _ScanResult {
  final _ScanLevel level;
  final String summary;
  final List<String> keywords;
  const _ScanResult({required this.level, required this.summary, required this.keywords});
}
