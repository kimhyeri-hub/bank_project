import 'claude_service.dart';

enum PhishingLevel { danger, warning, safe }

class PhishingResult {
  final PhishingLevel level;
  final String summary;
  final List<String> detectedKeywords;
  final int score;

  const PhishingResult({
    required this.level,
    required this.summary,
    required this.detectedKeywords,
    required this.score,
  });
}

class PhishingService {
  static const _dangerKeywords = [
    '무료', '당첨', '즉시', '긴급', '계좌', '비밀번호', '인증번호', '개인정보',
    '클릭하세요', '확인 요망', '지금 바로', '입력하세요', '공짜', '이벤트 당첨',
    '국세청', '금융감독원', '경찰청', '검찰', '법원', '건강보험',
  ];

  static const _suspiciousDomains = [
    'bit.ly', 'tinyurl', 'goo.gl', 'short.ly', 'ow.ly',
    '.xyz', '.ru', '.tk', '.ml', '.ga', '.cf',
  ];

  static const _systemPrompt = '''
당신은 피싱/스미싱 탐지 전문가입니다. 입력된 문자 메시지나 URL을 분석하여 피싱 여부를 판단하세요.

아래 JSON 형식으로만 응답하세요:
{
  "score": 0~10 사이 정수 (위험도, 높을수록 위험),
  "level": "danger|warning|safe",
  "summary": "판단 근거 요약 (한국어, 1-2문장)",
  "keywords": ["감지된 위험 요소 목록"]
}

판단 기준:
- danger (score 7~10): 명백한 피싱 패턴, 기관 사칭, 링크 클릭 유도 + 개인정보 요구
- warning (score 4~6): 의심스러운 요소 있으나 확실하지 않음
- safe (score 0~3): 위험 요소 없음

JSON 외 텍스트는 절대 출력하지 마세요.
''';

  static Future<PhishingResult> analyze(String input) async {
    final localResult = _analyzeLocally(input);

    if (!ClaudeService.isConfigured) {
      return localResult;
    }

    try {
      final raw = await ClaudeService.complete(
        systemPrompt: _systemPrompt,
        userMessage: '다음 내용의 피싱 여부를 분석해주세요:\n\n$input',
        maxTokens: 512,
      );
      return _parseWithFallback(raw, localResult);
    } catch (_) {
      return localResult;
    }
  }

  static PhishingResult _analyzeLocally(String input) {
    final lower = input.toLowerCase();

    final foundKeywords = _dangerKeywords
        .where((k) => input.contains(k))
        .toList();
    final foundDomains = _suspiciousDomains
        .where((d) => lower.contains(d))
        .toList();

    final all = [...foundKeywords, ...foundDomains];

    final PhishingLevel level;
    final int score;
    if (foundKeywords.length >= 2 || foundDomains.isNotEmpty) {
      level = PhishingLevel.danger;
      score = (8 + foundKeywords.length + foundDomains.length).clamp(0, 10);
    } else if (foundKeywords.isNotEmpty) {
      level = PhishingLevel.warning;
      score = 5;
    } else {
      level = PhishingLevel.safe;
      score = 1;
    }

    final summary = switch (level) {
      PhishingLevel.danger => '피싱 가능성이 높습니다. 링크를 클릭하거나 개인정보를 입력하지 마세요.',
      PhishingLevel.warning => '의심스러운 내용이 포함되어 있습니다. 주의가 필요합니다.',
      PhishingLevel.safe => '분석 결과 위험 요소가 발견되지 않았습니다.',
    };

    return PhishingResult(
      level: level,
      summary: summary,
      detectedKeywords: all,
      score: score,
    );
  }

  static PhishingResult _parseWithFallback(
    String raw,
    PhishingResult fallback,
  ) {
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start == -1 || end == -1) return fallback;

      // dart:convert 없이 간단 파싱 — JSON 직접 파싱
      final import = raw.substring(start, end + 1);
      // 정규식으로 필드 추출
      final scoreMatch = RegExp(r'"score"\s*:\s*(\d+)').firstMatch(import);
      final levelMatch = RegExp(r'"level"\s*:\s*"(\w+)"').firstMatch(import);
      final summaryMatch = RegExp(r'"summary"\s*:\s*"([^"]+)"').firstMatch(import);
      final keywordsMatch = RegExp(r'"keywords"\s*:\s*\[([^\]]*)\]').firstMatch(import);

      final score = int.tryParse(scoreMatch?.group(1) ?? '') ?? fallback.score;
      final levelStr = levelMatch?.group(1) ?? '';
      final level = switch (levelStr) {
        'danger' => PhishingLevel.danger,
        'warning' => PhishingLevel.warning,
        _ => PhishingLevel.safe,
      };
      final summary = summaryMatch?.group(1) ?? fallback.summary;
      final keywordsRaw = keywordsMatch?.group(1) ?? '';
      final keywords = keywordsRaw
          .split(',')
          .map((s) => s.trim().replaceAll('"', ''))
          .where((s) => s.isNotEmpty)
          .toList();

      return PhishingResult(
        level: level,
        summary: summary,
        detectedKeywords: keywords.isNotEmpty ? keywords : fallback.detectedKeywords,
        score: score.clamp(0, 10),
      );
    } catch (_) {
      return fallback;
    }
  }

  static bool hasUrl(String text) =>
      RegExp(r'https?://\S+|bit\.ly/\S+').hasMatch(text);

  static bool hasSuspiciousDomain(String text) =>
      _suspiciousDomains.any((d) => text.toLowerCase().contains(d));
}
