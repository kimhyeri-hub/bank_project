# [디버깅] 피싱 탐지 점수 로직과 테스트 기대값 불일치

**발생일**: 2026-06-02  
**영향 범위**: `PhishingService._analyzeLocally`, `test/phishing_service_test.dart`

---

## 증상

`flutter test` 실행 시 피싱 탐지 단위 테스트 2개 실패:

```
Expected: PhishingLevel:<PhishingLevel.danger>
  Actual: PhishingLevel:<PhishingLevel.safe>

Expected: PhishingLevel:<PhishingLevel.warning>
  Actual: PhishingLevel:<PhishingLevel.safe>
```

실패한 케이스:
- `'확인하세요 http://bit.ly/win123'` → `safe` (기대: `danger`)
- `'계좌 잔액을 확인하세요.'` → `safe` (기대: `warning`)

---

## 원인 분석

점수 기반 로직의 임계값 문제였다.

```dart
// 문제가 된 코드
final score = (foundKeywords.length * 2 + foundDomains.length * 3).clamp(0, 10);
final level = score >= 7 ? danger : score >= 4 ? warning : safe;
```

- `bit.ly` 1개 → score = 0×2 + 1×3 = **3** → `safe`  (임계값 4 미달)
- `계좌` 1개  → score = 1×2 + 0×3 = **2** → `safe`  (임계값 4 미달)

`bit.ly` 같은 단축 URL 하나만 있어도 경고 이상이어야 하는데,  
숫자를 단순 곱해 더하는 방식은 단독 위험 요소를 제대로 반영하지 못했다.

---

## 해결

규칙 기반 분기로 변경. 숫자 연산 대신 조건을 명확하게 표현:

```dart
// 수정 후
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
```

원래 화면 코드(`phishing_screen.dart`)의 분기 로직을 서비스 레이어로 그대로 옮긴 것이 정답이었다.

---

## 교훈

1. **로직을 이관할 때 동작 검증을 먼저 한다.** 기존 화면의 분기 로직을 서비스로 추출하면서 점수 기반으로 바꿨는데, 테스트를 먼저 작성했다면 바로 잡을 수 있었다.

2. **단독 위험 요소는 점수가 낮더라도 최소 레벨을 보장해야 한다.** 단축 URL은 그 자체로 의심 신호이므로, 곱셈 합산이 아닌 "단축 URL이 있으면 무조건 danger" 규칙이 더 직관적이다.

3. **테스트 실패 메시지를 믿어라.** `safe` vs `danger`처럼 큰 차이가 나면 로직 자체를 의심해야 한다.
