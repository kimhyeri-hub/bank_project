# docs/testing.md — Guardian AI 테스트 규약

---

## 1. 테스트 구조

```
test/
├── widget_test.dart                        # 앱 스모크 테스트
├── phishing_service_test.dart              # 피싱 탐지 단위 테스트
├── tos_service_test.dart                   # 약관 분석 단위 테스트
└── integration/
    └── analysis_scenario_test.dart         # 피싱→약관→통계 시나리오 통합 테스트
```

---

## 2. 전체 테스트 실행

```bash
flutter test
```

특정 파일만:
```bash
flutter test test/phishing_service_test.dart
flutter test test/tos_service_test.dart
flutter test test/integration/analysis_scenario_test.dart
```

---

## 3. 단위 테스트 목록 (총 10개)

### PhishingService (`test/phishing_service_test.dart`) — 5개

| 케이스 | 입력 | 기대 결과 |
|------|------|---------|
| 위험 키워드 2개 이상 | `[무료] 당첨... 계좌 정보 입력` | `PhishingLevel.danger` |
| 단축 URL 포함 | `확인하세요 http://bit.ly/win123` | `PhishingLevel.danger` |
| 위험 키워드 1개 | `계좌 잔액을 확인하세요.` | `PhishingLevel.warning` |
| 안전한 텍스트 | `오늘 날씨가 맑습니다.` | `PhishingLevel.safe`, score ≤ 3 |
| URL 존재 여부 | `http://example.com 클릭` | `hasUrl` → `true` |

### TosService (`test/tos_service_test.dart`) — 5개

| 케이스 | 입력 | 기대 결과 |
|------|------|---------|
| 정상 JSON 파싱 | Claude API 응답 형식 JSON | `TosReport` 반환, dangerCount = 1 |
| 잘못된 JSON | 일반 텍스트 | `clauses` 빈 리스트, 예외 없음 |
| 4000자 이하 청킹 | 3000자 텍스트 | 청크 1개 |
| 4000자 초과 청킹 | 6000자+ 텍스트 | 청크 2개 이상, 각 ≤ 4100자 |
| mockReport 검증 | — | `dangerCount = 2`, `clauses` 비어있지 않음 |

---

## 4. 통합/시나리오 테스트 (`test/integration/`) — 1개

### 시나리오: 피싱 탐지 → 약관 분석 → 활동 통계 조회

1. 스미싱 문자 입력 → `PhishingLevel.danger` 판정 확인
2. `ActivityService.recordPhishingScan` 호출
3. `TosService.mockReport` 실행 → `dangerCount > 0` 확인
4. `ActivityService.recordTosAnalysis` 호출
5. `ActivityService.getStats` → 통계 기록 확인

> SharedPreferences는 `SharedPreferences.setMockInitialValues({})` 로 모킹.

---

## 5. 위젯 테스트 (`test/widget_test.dart`)

앱 실행 후 하단 탭 3개 (`홈`, `약관 분석`, `피싱 탐지`) 렌더링 확인.

---

## 6. Claude API 연동 테스트 (수동)

실제 API 키가 필요하므로 CI에서 제외. `--dart-define`으로 키 주입 후 수동 실행.

```bash
flutter run --dart-define=ANTHROPIC_API_KEY=sk-ant-...
```

검증 항목:
- [ ] 약관 텍스트 입력 → Claude API 응답 수신 및 파싱 성공
- [ ] 피싱 문자 입력 → Claude API 문맥 분석 결과 수신
- [ ] API 오류 시 로컬 분석 결과로 graceful fallback

---

## 7. 사용성 테스트 체크리스트 (14주차)

```
테스터: ____________  날짜: ____________

[ ] 앱 설치 후 온보딩 완료
[ ] 약관 분석: 실제 약관 텍스트 붙여넣기 → 위험 조항 카드 확인
[ ] 피싱 탐지: 스미싱 샘플 입력 → 위험 경고 확인
[ ] 전체 흐름에서 막히거나 헷갈린 지점:
    →
[ ] 가장 유용했던 기능:
    →
[ ] 개선 요청:
    →
```

결과 정리: `docs/usability_feedback.md`에 취합.
