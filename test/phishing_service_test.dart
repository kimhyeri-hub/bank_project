import 'package:flutter_test/flutter_test.dart';
import 'package:claude_project/services/phishing_service.dart';

void main() {
  group('PhishingService 로컬 분석', () {
    test('given 위험 키워드 2개 이상, when analyze, then danger 판정', () async {
      final result = await PhishingService.analyze(
        '[무료] 당첨되셨습니다! 즉시 계좌 정보를 입력하세요.',
      );
      expect(result.level, PhishingLevel.danger);
      expect(result.detectedKeywords, isNotEmpty);
    });

    test('given 단축 URL 포함, when analyze, then danger 판정', () async {
      final result = await PhishingService.analyze(
        '확인하세요 http://bit.ly/win123',
      );
      expect(result.level, PhishingLevel.danger);
    });

    test('given 위험 키워드 1개, when analyze, then warning 판정', () async {
      final result = await PhishingService.analyze('계좌 잔액을 확인하세요.');
      expect(result.level, PhishingLevel.warning);
    });

    test('given 안전한 텍스트, when analyze, then safe 판정', () async {
      final result = await PhishingService.analyze('오늘 날씨가 맑습니다. 좋은 하루 되세요.');
      expect(result.level, PhishingLevel.safe);
      expect(result.score, lessThanOrEqualTo(3));
    });

    test('given URL 포함 텍스트, when hasUrl, then true 반환', () {
      expect(PhishingService.hasUrl('http://example.com 클릭'), isTrue);
      expect(PhishingService.hasUrl('링크 없음'), isFalse);
    });
  });
}
