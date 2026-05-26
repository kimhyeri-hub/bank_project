# ADR-0002: 상태 관리 라이브러리 선택 — Provider

- 상태: Accepted
- 날짜: 2026-05-19
- 결정자: Guardian AI 개발자

## 배경

Flutter 앱에서 API 응답 대기 상태(로딩), 분석 결과 데이터, 화면 간 공유 상태를 관리할 방법이 필요하다.  
Flutter에는 `setState`, `Provider`, `Riverpod`, `Bloc` 등 다양한 상태 관리 방식이 존재하며,  
선택에 따라 코드 구조와 학습 비용이 크게 달라진다.

## 고려한 대안

### 대안 A: setState (기본 내장)
- 장점:
  - 별도 패키지 불필요, Flutter 기본 제공
  - 학습 비용 없음
- 단점:
  - 화면 간 상태 공유 불가 (위젯 트리 전파 어려움)
  - API 결과를 여러 화면에서 참조할 때 prop drilling 발생
  - 코드 규모가 커질수록 유지보수 어려움

### 대안 B: Provider
- 장점:
  - Flutter 공식 권장 패키지 (Google 공식 문서 채택)
  - `setState` 대비 화면 간 상태 공유 용이
  - 학습 곡선 낮음 — 공식 예제와 튜토리얼 풍부
  - `ChangeNotifier` + `Consumer` 패턴으로 직관적 코드 작성
- 단점:
  - Riverpod 대비 타입 안전성 낮음
  - 대규모 앱에서 `context` 의존성 문제 발생 가능

### 대안 C: Riverpod
- 장점:
  - Provider의 단점(context 의존성)을 해결한 차세대 패키지
  - 타입 안전, 테스트 용이
  - 비동기 상태 처리(`AsyncValue`)가 내장
- 단점:
  - Provider 대비 학습 곡선 높음 (개념: Provider, StateNotifier, AsyncNotifier 등)
  - 6주 프로젝트에서 학습 비용이 기능 개발 시간을 잠식할 위험

### 대안 D: Bloc (flutter_bloc)
- 장점:
  - 이벤트 기반 구조로 복잡한 상태 흐름 명확하게 표현
  - 대규모 팀 프로젝트에 적합
- 단점:
  - 보일러플레이트 코드 과다 (Event / State / Bloc 클래스 3종 세트)
  - 기능 3개짜리 MVP에 과도한 아키텍처
  - 학습 비용 가장 높음

## 결정

**대안 B: Provider**를 선택한다.

## 이유

- Guardian AI MVP는 기능 3개(PII / 약관 / 피싱) + 히스토리로 구성된 소규모 앱이다. Bloc·Riverpod의 고급 기능이 필요한 복잡도가 아님
- Flutter 공식 문서와 튜토리얼 대부분이 Provider 기반으로 작성되어 있어, 막히는 부분을 빠르게 해결 가능
- 6주 일정에서 상태 관리 학습에 소비할 수 있는 시간은 최대 1일이며, Provider는 그 안에 학습 완료 가능
- 추후 규모 확장 시 Riverpod 마이그레이션 경로가 명확함

## 결과 (예상되는 영향)

긍정:
- 각 기능(PII / 약관 / 피싱)마다 `ChangeNotifier` 1개씩 정의 → 구조 단순하고 명확
- 로딩·결과·에러 상태를 `notifyListeners()`로 UI에 즉시 반영
- 테스트 시 `ChangeNotifier` 단위로 격리 테스트 가능

부정 / 제약:
- context 없는 곳에서 상태 접근 불가 → Service 클래스는 Provider 밖에서 순수 함수로 설계하여 우회
- 앱 규모가 커지면 Riverpod으로 마이그레이션 필요 (MVP 이후 단계)

## 후속 작업

- [ ] `pubspec.yaml`에 `provider: ^6.x` 추가
- [ ] 각 기능별 ChangeNotifier 클래스 정의 (`PiiNotifier`, `TosNotifier`, `PhishingNotifier`)
- [ ] `main.dart`에 `MultiProvider` 루트 설정
- [ ] Provider 공식 튜토리얼 완주 확인 (https://docs.flutter.dev/data-and-backend/state-mgmt/simple)
