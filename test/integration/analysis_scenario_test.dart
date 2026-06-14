import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:claude_project/services/phishing_service.dart';
import 'package:claude_project/services/tos_service.dart';
import 'package:claude_project/services/activity_service.dart';

// 시나리오: 사용자가 의심 문자를 받고 피싱 탐지 → 약관 분석 → 통계 확인
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('시나리오: 피싱 탐지 → 약관 분석 → 활동 통계 조회', () async {
    // 1. 피싱 탐지 실행
    const suspiciousText =
        '[무료] 당첨되셨습니다! 즉시 계좌 정보를 입력하세요. http://bit.ly/win123';
    final phishingResult = await PhishingService.analyze(suspiciousText);

    expect(phishingResult.level, PhishingLevel.danger);
    expect(phishingResult.detectedKeywords, isNotEmpty);

    // 2. 탐지 결과 기록
    await ActivityService.recordPhishingScan(isDanger: true);

    // 3. 약관 분석 (mock 데이터 사용)
    final tosReport = TosService.mockReport();
    expect(tosReport.dangerCount, greaterThan(0));
    expect(tosReport.clauses, isNotEmpty);

    // 4. 약관 분석 기록
    await ActivityService.recordTosAnalysis();

    // 5. 통계 확인
    final stats = await ActivityService.getStats();
    expect(stats.tosCount, greaterThanOrEqualTo(1));
    expect(stats.phishingCount, greaterThanOrEqualTo(1));
    expect(stats.phishingBlocked, greaterThanOrEqualTo(1));
    expect(stats.hasActivity, isTrue);
  });
}
