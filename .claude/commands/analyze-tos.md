# /analyze-tos

약관 텍스트를 입력받아 위험 조항을 분석합니다.

## 사용법

```
/analyze-tos <약관 텍스트 또는 파일 경로>
```

## 동작

1. 입력된 약관 텍스트를 4000자 기준으로 청킹
2. `lib/services/tos_service.dart`의 `TosService.analyze()` 로직 기준으로 분석
3. 위험(danger) / 주의(warning) / 안전(safe) 3단계로 분류
4. 위험 조항 목록과 요약을 출력

## 출력 예시

```
📋 약관 분석 결과
요약: 총 2건의 위험 조항이 발견되었습니다.

🔴 위험 | 제3조 | 개인정보 제3자 제공
   수집된 개인정보가 제휴사에 제공될 수 있습니다.

🟡 주의 | 제7조 | 일방적 서비스 변경
   사전 공지 없이 서비스가 중단될 수 있습니다.
```

## 관련 파일

- `lib/services/tos_service.dart` — 분석 로직
- `lib/services/claude_service.dart` — Claude API 클라이언트
- `test/tos_service_test.dart` — 파싱 단위 테스트
