# /run-tests

프로젝트의 모든 테스트를 실행하고 결과를 요약합니다.

## 사용법

```
/run-tests
/run-tests unit        # 단위 테스트만
/run-tests integration # 통합 테스트만
```

## 동작

1. `flutter test` 실행
2. 실패한 테스트 목록과 원인 출력
3. 커버리지 요약 (가능한 경우)

## 실행 명령

```bash
# 전체
flutter test

# 단위 테스트만
flutter test test/phishing_service_test.dart test/tos_service_test.dart test/widget_test.dart

# 통합 테스트만
flutter test test/integration/analysis_scenario_test.dart
```

## 현재 테스트 파일

| 파일 | 테스트 수 | 종류 |
|------|---------|------|
| `test/widget_test.dart` | 1 | 위젯 |
| `test/phishing_service_test.dart` | 5 | 단위 |
| `test/tos_service_test.dart` | 5 | 단위 |
| `test/integration/analysis_scenario_test.dart` | 1 | 통합 |

총 **12개** 테스트.

## 관련 문서

- `docs/testing.md` — 테스트 규약 및 케이스 목록
