# /check-phishing

URL 또는 문자 메시지 내용을 입력받아 피싱 여부를 판정합니다.

## 사용법

```
/check-phishing <URL 또는 문자 내용>
```

## 동작

1. `lib/services/phishing_service.dart`의 `PhishingService.analyze()` 로직 기준으로 판정
2. 위험 키워드 및 의심 도메인 탐지 (로컬 1차 분석)
3. Claude API 설정 시 문맥 분석 추가 (2차)
4. danger / warning / safe 판정 및 감지된 키워드 목록 출력

## 위험 판정 기준

| 조건 | 판정 |
|------|------|
| 위험 키워드 2개 이상 또는 단축 URL 포함 | 🔴 danger |
| 위험 키워드 1개 | 🟡 warning |
| 해당 없음 | 🟢 safe |

## 출력 예시

```
🔴 피싱 탐지 결과: 위험
피싱 가능성이 높습니다. 링크를 클릭하거나 개인정보를 입력하지 마세요.

감지된 키워드: [무료, 당첨, bit.ly]
```

## 관련 파일

- `lib/services/phishing_service.dart` — 탐지 로직
- `test/phishing_service_test.dart` — 단위 테스트
