# docs/testing.md — Guardian AI 테스트 규약

---

## 1. 테스트 구조

```
test/
├── pii_test.dart           # PII 탐지 엔진 단위 테스트
├── tos_parser_test.dart    # 약관 응답 파싱 단위 테스트
└── phishing_test.dart      # URL 분석 유틸리티 단위 테스트
```

---

## 2. 전체 테스트 실행

```bash
flutter test
```

특정 파일만:
```bash
flutter test test/pii_test.dart
```

커버리지 리포트:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html   # macOS
```

---

## 3. 단위 테스트 작성 규약

### 파일 위치
- `lib/features/pii/pii_detector.dart` → `test/pii_test.dart`
- 1:1 대응 원칙. 테스트 파일은 `test/` 하위에 동일 경로 미러링.

### 테스트 케이스 명명

```dart
// 형식: test('given [입력 조건], when [동작], then [기대 결과]', ...)
test('given 전화번호 포함 텍스트, when detectPii 호출, then 전화번호 마스킹됨', () {
  final result = detectPii('연락처: 010-1234-5678 입니다');
  expect(result.masked, contains('010-****-****'));
});
```

### 필수 테스트 케이스 목록

**PII 탐지 (`test/pii_test.dart`)**

| 케이스 | 입력 | 기대 결과 |
|------|------|---------|
| 전화번호 탐지 | `010-1234-5678` | `010-****-****` |
| 이메일 탐지 | `test@example.com` | `t***@***.com` (부분 마스킹) |
| 주민번호 탐지 | `900101-1234567` | `900101-*******` |
| 신용카드 탐지 | `1234-5678-9012-3456` | `****-****-****-3456` |
| PII 없는 텍스트 | `안녕하세요 반갑습니다` | 변경 없음 |
| 복합 PII | 전화 + 이메일 혼합 | 모두 마스킹 |

**약관 파서 (`test/tos_parser_test.dart`)**

| 케이스 | 입력 | 기대 결과 |
|------|------|---------|
| 정상 JSON 파싱 | API 응답 샘플 | `TosReport` 객체 반환 |
| 위험 레벨 분류 | risk_level 8 | `RiskLabel.danger` |
| 빈 조항 목록 | `risk_clauses: []` | 빈 리스트, 예외 없음 |
| 잘못된 JSON | 불완전한 문자열 | 파싱 예외 처리 후 `null` 반환 |

**URL 분석 (`test/phishing_test.dart`)**

| 케이스 | 입력 | 기대 결과 |
|------|------|---------|
| 정상 도메인 | `https://naver.com` | risk_score ≤ 3 |
| HTTP 사용 | `http://login-bank.com` | risk_score 가산 |
| 긴급 문구 | `"지금 바로 클릭"` | urgency 플래그 true |
| 기관 사칭 | `"국세청"` 포함 문자 | impersonation 플래그 true |
| 단축 URL | `bit.ly/xxxxx` | expand 시도 후 평가 |

---

## 4. 통합 테스트 (API 연동)

실제 Claude API를 호출하는 통합 테스트는 비용이 발생하므로 **수동으로만 실행**.

```bash
# 통합 테스트 파일 위치 (자동 CI 제외)
test/integration/claude_api_test.dart
```

실행:
```bash
flutter test test/integration/claude_api_test.dart
```

최소 검증 항목:
- [ ] 약관 샘플 텍스트 500자 → API 응답 수신 및 파싱 성공
- [ ] 피싱 문자 샘플 → 위험 판정 응답 수신
- [ ] API 오류 시 graceful fallback 동작

---

## 5. 위젯 테스트

```bash
flutter test test/widget_test.dart
```

핵심 위젯 테스트 항목:
- PII 마스킹 화면: 입력 → 결과 텍스트 업데이트 확인
- 위험 뱃지(`risk_badge.dart`): 레벨별 색상 올바른지 확인
- 경고 다이얼로그: 위험 판정 시 표시 여부

---

## 6. 사용성 테스트 체크리스트 (14주차)

```markdown
테스터: ____________  날짜: ____________

[ ] 앱 설치 후 온보딩 3단계 혼자 완료
[ ] PII 마스킹: 본인 전화번호 입력 → 마스킹 결과 확인
[ ] 약관 분석: 카카오톡 약관 붙여넣기 → 위험 조항 확인
[ ] 피싱 탐지: 제공된 스미싱 샘플 입력 → 위험 경고 확인
[ ] 전체 흐름에서 막히거나 헷갈린 지점:
    →
[ ] 가장 유용했던 기능:
    →
[ ] 개선 요청:
    →
```

결과 정리: `docs/usability_feedback.md`에 취합.
