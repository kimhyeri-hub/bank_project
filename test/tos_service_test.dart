import 'package:flutter_test/flutter_test.dart';
import 'package:claude_project/services/tos_service.dart';

void main() {
  group('TosService 파싱 및 청킹', () {
    test('given 정상 JSON, when _parse, then TosReport 반환', () {
      const raw = '''
{
  "summary": "2건의 위험 조항이 있습니다.",
  "clauses": [
    {"level": "danger", "title": "개인정보 제3자 제공", "clause": "제3조", "description": "제3자 제공 가능"},
    {"level": "safe", "title": "환불 정책", "clause": "제15조", "description": "표준 환불"}
  ]
}''';
      final report = TosService.parseForTest(raw);
      expect(report.summary, contains('위험'));
      expect(report.clauses.length, 2);
      expect(report.clauses.first.level, RiskLevel.danger);
      expect(report.dangerCount, 1);
      expect(report.warningCount, 0);
    });

    test('given 잘못된 JSON, when _parse, then 빈 결과 반환', () {
      final report = TosService.parseForTest('이건 JSON이 아님');
      expect(report.clauses, isEmpty);
    });

    test('given 4000자 이하 텍스트, when chunk, then 1개 청크', () {
      final text = 'a' * 3000;
      final chunks = TosService.chunkForTest(text);
      expect(chunks.length, 1);
    });

    test('given 4000자 초과 텍스트, when chunk, then 여러 청크', () {
      final text = List.generate(10, (i) => '제${i + 1}조 내용입니다. ${'x' * 600}').join('\n\n');
      final chunks = TosService.chunkForTest(text);
      expect(chunks.length, greaterThan(1));
      for (final c in chunks) {
        expect(c.length, lessThanOrEqualTo(4100));
      }
    });

    test('given mockReport, when dangerCount, then 2 반환', () {
      final report = TosService.mockReport();
      expect(report.dangerCount, 2);
      expect(report.clauses, isNotEmpty);
    });
  });
}
