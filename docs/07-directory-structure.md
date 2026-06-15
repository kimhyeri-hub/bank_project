# Guardian AI — Flutter 디렉토리 구조

> 전략: **Presentation + Services 2계층**
> 상태 관리: **StatefulWidget + setState** (Provider는 ADR-0002에서 검토 후 보류)
> 레이어 원칙: Presentation → Services → Claude API (단방향)

---

## 구조 한 눈에 보기

```
lib/
│
├── main.dart                              # 앱 진입점
├── app.dart                               # MaterialApp, 테마, 하단 네비게이션
│
├── presentation/                          # [Layer 1] UI · Screen
│   ├── screens/
│   │   ├── home_screen.dart               # 홈 — 활동 요약 대시보드
│   │   ├── tos_screen.dart                # 약관 분석 — PDF 업로드 / URL / 텍스트 입력
│   │   ├── phishing_screen.dart           # 피싱 탐지 — URL·문자·이메일 입력
│   │   ├── notifications_screen.dart      # 공지사항 목록
│   │   └── history_screen.dart            # 분석 이력 목록
│   └── theme/
│       └── app_them.dart                  # 다크/라이트 테마 토큰
│
└── services/                              # [Layer 2] API 호출 · 로컬 분석 · 로컬 저장
    ├── claude_service.dart                # Claude API 공통 HTTP 클라이언트 (complete, isConfigured)
    ├── tos_service.dart                   # 약관 분석 — 4,000자 청킹 + 프롬프트 + JSON 파싱 + mock
    ├── phishing_service.dart              # 피싱 1차(로컬 키워드/URL) + 2차(Claude) 판정
    ├── document_service.dart              # PDF 바이트 → 텍스트 추출 (syncfusion_flutter_pdf)
    ├── web_file_picker.dart               # 웹 파일 선택 진입점 (조건부 export)
    ├── web_file_picker_web.dart           # 웹 구현체
    ├── web_file_picker_stub.dart          # 비-웹 플랫폼 스텁
    ├── history_service.dart               # 분석 이력 저장/조회 (shared_preferences, 최대 20건)
    ├── activity_service.dart              # 사용 통계 (분석/검사 횟수)
    └── notification_service.dart          # 공지사항 데이터 및 읽음 상태

test/
├── widget_test.dart                       # 화면 렌더링 위젯 테스트
├── tos_service_test.dart                  # 약관 분석 단위 테스트
├── phishing_service_test.dart             # 피싱 판정 단위 테스트
└── integration/
    └── analysis_scenario_test.dart        # 분석 전체 흐름 통합 테스트

.env / .env.example                        # API 키 (Git 제외 / 템플릿)
.gitignore
pubspec.yaml
```

---

## 레이어별 역할 요약

| 레이어 | 경로 | 역할 | 외부 의존 |
|--------|------|------|---------|
| Presentation | `lib/presentation/` | 화면 렌더링, 사용자 입력 수신, `setState`로 상태 관리 | Flutter SDK |
| Services | `lib/services/` | API 호출, 로컬 판정/분석, 로컬 저장 | `http`, `shared_preferences`, `syncfusion_flutter_pdf`, `file_picker` |

각 기능의 결과 모델(`TosReport`, `PhishingResult` 등)과 핵심 로직(청킹, 파싱, 점수 산출)은
별도 도메인 파일로 분리하지 않고 해당 Service 파일 내부에 함께 정의합니다.

---

## 의존 방향 규칙

```
Presentation → Services → Claude API
```

- Presentation은 필요한 Service를 직접 생성/호출한다 (`setState`로 결과 반영)
- Services는 Presentation을 참조하지 않는다 (역방향 금지)
- Services 간 단방향 참조는 허용 (예: `tos_service` → `claude_service`)

---

## 파일 네이밍 규칙

| 종류 | 규칙 | 예시 |
|------|------|------|
| Screen | `*_screen.dart` | `tos_screen.dart` |
| Service | `*_service.dart` | `tos_service.dart` |
| 조건부 export (웹/비웹) | `*_web.dart` / `*_stub.dart` | `web_file_picker_web.dart` |
| Test | 대상 파일명 + `_test.dart` | `tos_service_test.dart` |

> 모든 파일명은 **snake_case**. Flutter 공식 컨벤션.

---

*연관 문서: `docs/architecture.md` (레이어/데이터 흐름 상세), `.planning/decisions/ADR-0002-state-management.md` (상태 관리 결정 근거)*
