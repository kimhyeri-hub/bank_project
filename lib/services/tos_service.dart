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
당신은 'Guardian AI: The Last Fortress'의 약관 분석 엔진입니다.
거대 기업(카드사·은행·플랫폼 등)과 개인 소비자 사이의 권력 비대칭을 파헤쳐,
마케팅 문구 뒤에 숨겨진 소비자 불리 조항을 찾아내는 것이 당신의 임무입니다.

다음 패턴을 특히 우선적으로 탐지하세요:
- 일방적 권리 변경·축소: "평생 무료", "혜택 유지" 등을 약속하면서도 회사의 경영 상황,
  제휴사 사정 등을 이유로 언제든 일방적으로 변경·축소·중단할 수 있다고 명시한 조항
- 정보 블랙박스: 환율, 수수료, 운용 방식 등 핵심 조건을 본 약관이 아닌 타사·계열사 약관에
  위임하여 사용자가 실제 조건을 확인하기 어렵게 만드는 조항
- 리스크 전가: 환율 변동, 수수료, 손해 등 회사가 통제 가능한 위험을 사용자에게 떠넘기는 조항
- 개인정보 제3자 제공, 사업자 면책 등 사용자에게 매우 불리한 일반 조항

반드시 아래 JSON 형식으로만 응답하세요:
{
  "summary": "전체 요약 (1-2문장)",
  "clauses": [
    {
      "level": "danger|warning|safe",
      "title": "이모지와 [카테고리]로 시작하는 조항 제목. 예: '⚠️ [독점 기업의 권리 남용 위험] 일방적 혜택 축소 조항'",
      "clause": "조항 번호 또는 위치",
      "description": "기업과 개인 사이의 권력 비대칭을 짚어주는 핵심 설명 (한국어, 1~2문장, 핵심만 간결하게)"
    }
  ]
}

title에 사용할 카테고리 이모지·태그 예시 (상황에 맞게 새로 만들어도 됨):
- ⚠️ [독점 기업의 권리 남용 위험]
- 🕵️ [정보 블랙박스]
- 💸 [소비자 리스크 독박]

level 기준:
- danger: 개인정보 제3자 제공, 사업자 면책, 일방적 계약 변경, 리스크 전가 등 사용자에게 매우 불리한 조항
- warning: 자동 갱신, 정보 블랙박스, 부분 면책 등 주의가 필요한 조항
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
      maxTokens: 2000,
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

  // API 키 없을 때, PDF 업로드 데모용으로 사용할 목 데이터
  static TosReport pdfDemoReport() => const TosReport(
        summary: '총 3건의 위험 조항이 발견되었습니다. 부가서비스 일방적 변경, 외화계좌 정보 위임, '
            '무승인 결제 환율 리스크를 확인하세요.',
        clauses: [
          RiskClause(
            level: RiskLevel.danger,
            title: '⚠️ [독점 기업의 권리 남용 위험] 일방적 부가서비스 축소·변경권',
            clause: '카드이용약관 (부가서비스의 변경 및 제공중단)',
            description: '3년간 부가서비스를 유지한다고 안내하지만, 경영상 사정이나 제휴사 변경 시 사전 고지만으로 '
                '즉시 축소·변경할 수 있어, 사용자만 계약 의무를 계속 지는 비대칭 구조입니다.',
          ),
          RiskClause(
            level: RiskLevel.warning,
            title: '🕵️ [정보 블랙박스] 외화결제계좌 운용 정보의 타사 약관 위임',
            clause: '외화결제계좌 이용약관 (운용 통화·환율·수수료 기준)',
            description: '환율·수수료 등 핵심 조건이 이 약관이 아닌 별도의 신한은행 외화예금 약관에 위임되어, '
                '실제 비용 구조를 한 곳에서 확인할 수 없습니다.',
          ),
          RiskClause(
            level: RiskLevel.danger,
            title: '💸 [소비자 리스크 독박] 무승인 결제 시 2중 환전 및 환율 리스크 전가',
            clause: '카드이용약관 (해외 무승인거래 결제 처리 방식)',
            description: '무승인 거래는 국제브랜드사 환율과 신한은행 고시 환율이 이중으로 적용되어, 환차 손실 '
                '리스크를 사용자가 그대로 떠안고 회사는 책임지지 않습니다.',
          ),
        ],
      );

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
