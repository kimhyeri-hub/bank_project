# AGENTS.md — Guardian AI AI 협업 정책 파일

> Claude Code 등 AI 에이전트가 이 저장소에서 작업할 때 참고하는 단일 진입점입니다.
> 기획·아키텍처·운영 문서의 위치와, 이 프로젝트에서 AI를 활용하는 방식(슬래시 커맨드 / 암묵지 위키)을 정리합니다.

---

## 1. 프로젝트 개요 & 기획 문서

Guardian AI는 약관 위험 조항 분석 + 피싱 탐지를 제공하는 Flutter 단일 앱입니다 (백엔드 없음, Claude API 직접 호출).

| 문서 | 내용 |
|------|------|
| `.planning/00-vision.md` | 비전 |
| `.planning/01-requirements.md` | 요구사항 (Must/Should/Won't) |
| `.planning/02-wbs.md` | WBS — 작업 분류 체계 |
| `.planning/04-schedule.md` | 6주 일정 |
| `.planning/05-risk-checklist.md` | 리스크 체크리스트 |
| `docs/index.html` | 발표 슬라이드 (WBS·아키텍처·가산점 시각화) |

---

## 2. 아키텍처 & ADR (질의응답 대비)

- `docs/architecture.md` — 레이어 구조(Presentation/Application/Domain/Data), 데이터 흐름, 의존 방향 규칙
- `.planning/decisions/` — ADR 5건
  - ADR-0001 모바일 프레임워크: Flutter
  - ADR-0002 상태 관리: Provider
  - ADR-0003 백엔드: 없음 (Claude API 직접 호출, Privacy First)
  - ADR-0004 인증: 없음 (로컬 전용, 데이터 미수집)
  - ADR-0005 배포 채널: APK 사이드로드

발표 Q&A 시 위 5개 ADR을 우선 숙지할 것.

---

## 3. 개발 환경 / 빌드·배포 / 테스트

| 단계 | 문서 | 핵심 명령 |
|------|------|---------|
| 설치·실행 | `docs/setup.md` | `flutter pub get`, `flutter run --dart-define-from-file=.env.dev` |
| 빌드·배포 | `docs/deploy.md` | `flutter build apk --release` |
| 테스트 | `docs/testing.md` | `flutter test` |
| 보안 체크리스트 | `docs/security.md` | API 키/시크릿/로컬 저장 점검 |

API 키는 코드에 하드코딩하지 않고 `--dart-define-from-file`로만 주입 (`.env.*`는 `.gitignore` 처리).

---

## 4. AI 워크플로우

### 4.1 슬래시 커맨드 (`.claude/commands/`)

반복되는 분석·검증 작업을 슬래시 커맨드로 표준화했습니다.

| 커맨드 | 용도 | 관련 파일 |
|--------|------|----------|
| `/analyze-tos` | 약관 텍스트 청킹 + 위험 조항(🔴🟡🟢) 분석 | `lib/services/tos_service.dart` |
| `/check-phishing` | URL/문자 피싱 판정 (로컬 1차 + Claude 2차) | `lib/services/phishing_service.dart` |
| `/run-tests` | 전체/단위/통합 테스트 실행 및 결과 요약 | `docs/testing.md` |

### 4.2 `lessons/` — 암묵지(tacit knowledge) 위키

디버깅·시행착오에서 얻은 교훈을 코드와 분리해 누적 관리합니다.

- 형식: `lessons/NN-짧은제목.md`
- 구성: 발생일 → 증상 → 원인 분석 → 해결 → 교훈
- 예시: `lessons/01-phishing-score-test-mismatch.md` (피싱 점수 임계값 버그)
- **새 세션 시작 시 AI는 `lessons/` 목록을 먼저 확인**해 과거에 동일한 실수를 반복하지 않습니다.
- 새로운 디버깅/설계 시행착오가 발생하면, 해결 후 같은 형식으로 `lessons/`에 기록합니다.

---

## 5. 작업 규칙

- 커밋 전 `flutter analyze && flutter test` 통과 확인
- 문서를 변경하면 `README.md` / `docs/index.html`의 해당 내용도 함께 갱신
- `.env*`, `*.keystore`, `*.jks`, `android/key.properties`는 절대 커밋하지 않음
