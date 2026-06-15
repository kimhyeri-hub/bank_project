# Guardian AI — Flutter 디렉토리 구조

> 전략: **Layered Architecture** (레이어별 묶음)  
> 상태 관리: **Provider** (ChangeNotifier)  
> 레이어 원칙: Presentation → Application → Domain → Data

---

## 구조 한 눈에 보기

```
guardian_ai/
│
├── lib/
│   ├── main.dart                          # 앱 진입점, MultiProvider 루트
│   ├── app.dart                           # MaterialApp, 테마, 라우터 연결
│   │
│   ├── presentation/                      # [Layer 1] UI · Screen · Widget
│   │   ├── screens/
│   │   │   ├── onboarding_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── tos_input_screen.dart
│   │   │   ├── tos_result_screen.dart
│   │   │   ├── phishing_screen.dart
│   │   │   └── history_screen.dart
│   │   ├── widgets/                       # 재사용 공통 위젯
│   │   │   ├── risk_badge.dart
│   │   │   ├── danger_alert_dialog.dart
│   │   │   └── loading_overlay.dart
│   │   └── theme/
│   │       └── app_theme.dart             # 다크/라이트 테마 토큰
│   │
│   ├── application/                       # [Layer 2] ViewModel · UseCase
│   │   └── view_models/
│   │       ├── tos_notifier.dart
│   │       ├── phishing_notifier.dart
│   │       └── history_notifier.dart
│   │
│   ├── domain/                            # [Layer 3] Entity · Service · Rule
│   │   ├── entities/                      # 순수 데이터 모델 (외부 의존 없음)
│   │   │   ├── tos_report.dart
│   │   │   ├── phishing_result.dart
│   │   │   └── analysis_history.dart
│   │   └── services/                      # 핵심 비즈니스 규칙 (순수 Dart)
│   │       ├── tos_prompt.dart            # 약관 분석 프롬프트 설계
│   │       ├── tos_parser.dart            # API 응답 → TosReport 파싱
│   │       ├── url_analyzer.dart          # URL 구조 분석
│   │       ├── url_expander.dart          # 단축 URL 추적
│   │       ├── smishing_patterns.dart     # 한국어 스미싱 패턴 DB
│   │       └── risk_scorer.dart           # 종합 위험 점수 산출
│   │
│   └── data/                              # [Layer 4] Repository · API · DB
│       ├── repositories/                  # 데이터 소스 추상화 · 조율
│       │   ├── tos_repository.dart        # 청킹 + API 호출 + 결과 병합
│       │   ├── phishing_repository.dart
│       │   └── history_repository.dart
│       ├── api/                           # 외부 API 클라이언트
│       │   ├── claude_client.dart
│       │   ├── tos_ai_service.dart
│       │   ├── phishing_ai_service.dart
│       │   └── virustotal_client.dart
│       └── local/                         # 로컬 저장소 (슬라이드 기준)
│           ├── local_db.dart              # SQLite 초기화 · CRUD
│           └── cache_service.dart         # 입력 해시 기반 응답 캐싱
│
├── test/
│   ├── domain/
│   │   ├── tos_parser_test.dart
│   │   └── url_analyzer_test.dart
│   ├── application/
│   │   └── tos_notifier_test.dart
│   └── integration/
│       └── claude_api_test.dart           # 수동 실행 전용
│
├── .vscode/
│   └── extensions.json                    # 권장 확장 프로그램
│
├── prompts/                               # Claude 프롬프트 로컬 백업
│   ├── tos_analysis.txt
│   └── phishing_context.txt
│
├── .env                                   # API 키 (Git 제외)
├── .env.example                           # 키 없는 템플릿 (Git 포함)
├── .gitignore
└── pubspec.yaml
```

---

## 레이어별 역할 요약

| 레이어 | 경로 | 역할 | 외부 의존 |
|--------|------|------|---------|
| Presentation | `lib/presentation/` | 화면 렌더링, 사용자 입력 수신 | Flutter SDK |
| Application | `lib/application/` | 상태 관리, 흐름 조율 | Provider |
| Domain | `lib/domain/` | 비즈니스 규칙, 핵심 로직 | **없음** (순수 Dart) |
| Data | `lib/data/` | API 호출, DB 읽기/쓰기 | http, sqflite |

---

## 의존 방향 규칙

```
Presentation → Application → Domain ← Data
                              (Entity)
```

- 위에서 아래로만 의존. **역방향 금지**
- `Domain`은 아무것도 import하지 않는다 → 단위 테스트가 가장 쉬운 레이어
- `Data`는 `Domain`의 Entity만 참조 가능

---

## Provider 연결 구조 (`main.dart`)

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        // [Data] Repository
        Provider(create: (_) => ClaudeClient()),
        Provider(create: (_) => LocalDb()),
        Provider(create: (ctx) => TosRepository(ctx.read())),
        Provider(create: (ctx) => PhishingRepository(ctx.read())),
        Provider(create: (ctx) => HistoryRepository(ctx.read())),

        // [Application] ViewModel
        ChangeNotifierProvider(create: (ctx) => TosNotifier(ctx.read())),
        ChangeNotifierProvider(create: (ctx) => PhishingNotifier(ctx.read())),
        ChangeNotifierProvider(create: (ctx) => HistoryNotifier(ctx.read())),
      ],
      child: const MyApp(),
    ),
  );
}
```

---

## 파일 네이밍 규칙

| 종류 | 규칙 | 예시 |
|------|------|------|
| Screen | `*_screen.dart` | `tos_screen.dart` |
| ViewModel | `*_notifier.dart` | `tos_notifier.dart` |
| Entity | `*_result/report/history.dart` | `tos_report.dart` |
| Domain Service | 역할 명사 | `tos_parser.dart` |
| Repository | `*_repository.dart` | `tos_repository.dart` |
| API Client | `*_client/service.dart` | `claude_client.dart` |
| Test | 대상 파일명 + `_test.dart` | `tos_parser_test.dart` |

> 모든 파일명은 **snake_case**. Flutter 공식 컨벤션.

---

*연관 문서: `docs/architecture.md`, `ADR-0002-state-management-provider.md`*
