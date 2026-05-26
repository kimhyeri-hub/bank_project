import 'package:flutter/material.dart';
import '../theme/app_them.dart';

class PiiScreen extends StatefulWidget {
  const PiiScreen({super.key});

  @override
  State<PiiScreen> createState() => _PiiScreenState();
}

class _PiiScreenState extends State<PiiScreen> {
  final _controller = TextEditingController();
  String? _result;

  static const _exampleText = '홍길동 씨의 주민번호는 901212-1234567이며, 연락처는 010-1234-5678입니다. 이메일은 hong@example.com입니다.';

  void _mask() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    var masked = text
        .replaceAll(RegExp(r'\d{6}-\d{7}'), '******-*******')
        .replaceAll(RegExp(r'01[0-9]-\d{3,4}-\d{4}'), '010-****-****')
        .replaceAll(RegExp(r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}'), '****@****.***');

    setState(() => _result = masked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('PII 마스킹'),
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
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF1565C0), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '주민등록번호, 전화번호, 이메일 등 개인정보를 자동으로 감지하여 마스킹합니다.',
              style: TextStyle(fontSize: 12, color: Color(0xFF1565C0), height: 1.4),
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
          const Text('텍스트 입력', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 6,
            decoration: const InputDecoration(hintText: '마스킹할 텍스트를 입력하세요...', hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _controller.text = _exampleText,
            child: const Text('예시 텍스트 불러오기', style: TextStyle(fontSize: 12, color: AppTheme.primaryLight, decoration: TextDecoration.underline)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _mask,
              icon: const Icon(Icons.shield, size: 18),
              label: const Text('개인정보 마스킹'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.safeColor.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppTheme.safeColor, size: 18),
              const SizedBox(width: 8),
              const Text('마스킹 완료', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.safeColor)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(_result!, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.6)),
          ),
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
