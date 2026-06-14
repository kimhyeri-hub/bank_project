import 'dart:convert';
import 'claude_service.dart';

enum RiskLevel { danger, warning, safe }

class RiskClause {
  final RiskLevel level;
  final String title;
  final String clause;
  final String description;

  const RiskClause({
    required this.level,
    required this.title,
    required this.clause,
    required this.description,
  });

  factory RiskClause.fromJson(Map<String, dynamic> json) {
    final levelStr = (json['level'] as String? ?? 'safe').toLowerCase();
    final level = switch (levelStr) {
      'danger' => RiskLevel.danger,
      'warning' => RiskLevel.warning,
      _ => RiskLevel.safe,
    };
    return RiskClause(
      level: level,
      title: json['title'] as String? ?? '알 수 없는 조항',
      clause: json['clause'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class TosReport {
  final String summary;
  final List<RiskClause> clauses;

  const TosReport({required this.summary, required this.clauses});

  int get dangerCount => clauses.where((c) => c.level == RiskLevel.danger).length;
  int get warningCount => clauses.where((c) => c.level == RiskLevel.warning).length;
}

class TosService {
  static const _chunkSize = 4000;

  static const _systemPrompt = '''
당신은 약관 분석 전문가입니다. 사용자가 제공한 약관 텍스트를 분석하여 위험 조항을 찾아내세요.

반드시 아래 JSON 형식으로만 응답하세요:
{
  "summary": "전체 요약 (1-2문장)",
  "clauses": [
    {
      "level": "danger|warning|safe",
      "title": "조항 제목",
      "clause": "조항 번호 또는 위치",
      "description": "사용자에게 미치는 영향 설명 (한국어)"
    }
  ]
}

level 기준:
- danger: 개인정보 제3자 제공, 사업자 면책, 일방적 계약 변경 등 사용자에게 매우 불리한 조항
- warning: 자동 갱신, 서비스 중단 가능, 부분 면책 등 주의가 필요한 조항
- safe: 표준적이고 사용자에게 불리하지 않은 조항

JSON 외 다른 텍스트는 절대 출력하지 마세요.
''';

  static Future<TosReport> analyze(String text) async {
    final chunks = _chunk(text);
    if (chunks.length == 1) {
      return _analyzeChunk(chunks[0]);
    }
    return _analyzeMultipleChunks(chunks);
  }

  static List<String> _chunk(String text) {
    if (text.length <= _chunkSize) return [text];

    final chunks = <String>[];
    // 조항 단위로 분할 (빈 줄 또는 '제N조' 기준)
    final pattern = RegExp(r'(?=제\d+조)|(?:\n\n+)');
    final parts = text.split(pattern);

    var current = StringBuffer();
    for (final part in parts) {
      if (current.length + part.length > _chunkSize && current.isNotEmpty) {
        chunks.add(current.toString().trim());
        current = StringBuffer();
      }
      current.write(part);
    }
    if (current.isNotEmpty) chunks.add(current.toString().trim());

    return chunks.isEmpty ? [text] : chunks;
  }

  static Future<TosReport> _analyzeChunk(String chunk) async {
    final raw = await ClaudeService.complete(
      systemPrompt: _systemPrompt,
      userMessage: '다음 약관을 분석해주세요:\n\n$chunk',
      maxTokens: 1500,
    );
    return _parse(raw);
  }

  static Future<TosReport> _analyzeMultipleChunks(List<String> chunks) async {
    final futures = chunks.map((c) => _analyzeChunk(c));
    final reports = await Future.wait(futures);

    final allClauses = <RiskClause>[];
    final summaries = <String>[];

    for (final r in reports) {
      allClauses.addAll(r.clauses);
      if (r.summary.isNotEmpty) summaries.add(r.summary);
    }

    // 중복 제거 (같은 title)
    final seen = <String>{};
    final unique = allClauses.where((c) => seen.add(c.title)).toList();

    final dangerCount = unique.where((c) => c.level == RiskLevel.danger).length;
    final summary = dangerCount > 0
        ? '총 $dangerCount건의 위험 조항이 발견되었습니다. 반드시 확인하세요.'
        : summaries.isNotEmpty
            ? summaries.first
            : '분석이 완료되었습니다.';

    return TosReport(summary: summary, clauses: unique);
  }

  // 테스트용 공개 래퍼
  static TosReport parseForTest(String raw) => _parse(raw);
  static List<String> chunkForTest(String text) => _chunk(text);

  static TosReport _parse(String raw) {
    try {
      final jsonStr = _extractJson(raw);
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final clauses = (data['clauses'] as List<dynamic>? ?? [])
          .map((e) => RiskClause.fromJson(e as Map<String, dynamic>))
          .toList();
      return TosReport(
        summary: data['summary'] as String? ?? '',
        clauses: clauses,
      );
    } catch (_) {
      return const TosReport(
        summary: '약관 파싱 중 오류가 발생했습니다.',
        clauses: [],
      );
    }
  }

  static String _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end == -1) return text;
    return text.substring(start, end + 1);
  }

  // API 키 없을 때 사용할 목 데이터
  static TosReport mockReport() => const TosReport(
        summary: '총 2건의 위험 조항이 발견되었습니다. 개인정보 제3자 제공 및 사업자 면책 조항을 확인하세요.',
        clauses: [
          RiskClause(
            level: RiskLevel.danger,
            title: '개인정보 제3자 제공',
            clause: '제3조',
            description: '수집된 개인정보가 제휴사 등 제3자에게 제공될 수 있습니다.',
          ),
          RiskClause(
            level: RiskLevel.warning,
            title: '일방적 서비스 변경·중단',
            clause: '제7조',
            description: '사전 공지 없이 서비스가 변경되거나 중단될 수 있습니다.',
          ),
          RiskClause(
            level: RiskLevel.danger,
            title: '사업자 손해배상 면책',
            clause: '제12조',
            description: '서비스 이용 중 발생한 손해에 대해 회사는 책임을 지지 않습니다.',
          ),
          RiskClause(
            level: RiskLevel.safe,
            title: '해지 및 환불 정책',
            clause: '제15조',
            description: '서비스 해지 시 잔여 기간에 비례하여 환불이 진행됩니다.',
          ),
        ],
      );
}
