# Guardian AI — 질의응답(Q&A) 30문항 대비 문서

> 평가표 "질의응답(5점)" 항목 — ADR 최소 3개 표시, 앱 구조(레이어/디렉토리),
> 개발 환경 설정, 빌드/배포 단계, ADR 기록 기준의 정확한 답변 — 을 모두 커버합니다.
> 발표 직전 `AGENTS.md` §2 (ADR 5개 표)와 함께 한 번 더 훑어보세요.

---

## A. 아키텍처 & ADR (8문항)

**Q1. ADR이 몇 개이고, 각각 무엇을 결정했나요?**
총 5개입니다 (`.planning/decisions/`).
ADR-0001 모바일 프레임워크(Flutter), ADR-0002 상태관리(Provider),
ADR-0003 백엔드(없음, Claude API 직접 호출), ADR-0004 인증(없음, 로컬 전용),
ADR-0005 배포 채널(APK 사이드로드). 5개 모두 2026-05-19에 Accepted.

**Q2. 왜 Flutter를 선택했나요? 다른 대안은 검토했나요?**
ADR-0001에서 Flutter / React Native / Android(Kotlin) / iOS(Swift) /
Kotlin Multiplatform 5가지를 비교했습니다. 1인 개발 + 6주 일정 안에
Android·iOS를 동시 지원해야 한다는 제약 때문에, 단일 코드베이스로
양 OS를 지원하는 Flutter가 유일한 현실적 선택이었습니다.

**Q3. 상태 관리는 Provider라고 들었는데, 실제 코드에도 Provider가 쓰이나요?**
ADR-0002에서는 Provider(`ChangeNotifier`)를 채택했지만, 실제 MVP에서는
화면이 3개(`home/tos/phishing`)뿐이고 화면 간 공유 상태가 적어 `App`
위젯의 `StatefulWidget` + `setState`만으로 충분하다고 판단해 더 단순화했습니다.
ADR이 기록한 "고려한 대안 중 가장 단순한 것을 선택한다"는 원칙(대안 A: setState)에
오히려 더 부합하는 방향으로 MVP 범위를 좁힌 것이며, 화면이 늘어나면
ADR-0002에 기록된 대로 Provider로 마이그레이션할 수 있는 구조입니다.

**Q4. 왜 백엔드 서버를 두지 않았나요?**
ADR-0003에서 (A) 자체 백엔드(Node/Express), (B) Firebase, (C) 서버리스 함수,
(D) 클라이언트에서 Claude API 직접 호출 4가지를 비교했습니다. (D)를 선택한
이유는 ① Privacy First — 사용자의 약관 원문·문자 내용이 우리 서버를
거치지 않고 Claude로만 전송됨, ② 6주 일정에서 서버 운영·인증·배포 비용을
제거, ③ 1인 개발로 서버 코드까지 유지보수할 여력이 없었기 때문입니다.

**Q5. 로그인 기능이 없는데, 의도된 설계인가요?**
네. ADR-0004에서 (A) 인증 없음/로컬 전용, (B) 자체 이메일 로그인,
(C) Firebase 소셜 로그인, (D) Firebase 익명 인증 4가지를 비교했고,
요구사항 문서에 "계정/로그인 시스템"이 Won't Have로 명시되어 있어
(A)를 선택했습니다. 인증 서버가 필요 없어 ADR-0003(백엔드 없음)과도
일치하고, 사용자 식별 정보를 전혀 수집하지 않아 Privacy First 원칙에
가장 부합합니다.

**Q6. 앱을 어떻게 배포하나요? 스토어에는 안 올리나요?**
ADR-0005에서 (A) APK 직접 배포(사이드로드), (B) Google Play 정식 배포,
(C) Firebase App Distribution, (D) TestFlight+APK 병행을 비교했습니다.
졸업 작품 시연의 목적은 "동작하는 앱을 보여주는 것"이라 스토어 심사(3~7일)나
연 $99 비용이 불필요했고, `flutter build apk --release` 한 번으로 즉시
빌드·설치할 수 있는 (A)를 선택했습니다.

**Q7. `docs/architecture.md`에는 Domain/Data 레이어, SQLite, VirusTotal 같은
내용이 있는데 실제 코드에는 없습니다. 왜 다른가요?**
`docs/architecture.md`는 초기 설계 단계에서 그린 "이상적인 목표 구조"이고,
실제 구현은 6주 MVP 범위에 맞춰 단순화했습니다. 예를 들어 SQLite/`local_db`
대신 `shared_preferences`로 최근 20건 히스토리만 저장하고(`HistoryService`),
VirusTotal 연동이나 `cache_service`(중복 호출 방지)는 "향후 계획"으로
README에 명시해 두었습니다. 핵심 의존 방향 원칙(Presentation→Domain
규칙 분리)은 `lib/services/`의 `TosService`/`PhishingService`가 화면과
독립적으로 동작하도록 한 점에서 유지하고 있습니다. 계획과 실제의 차이를
인지하고 있고, 남은 항목은 README "향후 계획"에 기록되어 있습니다.

**Q8. 의존 방향 규칙(Presentation → Application → Domain ← Data)은 실제로
지켜지나요?**
완전한 4계층 분리는 아니지만, 핵심 원칙인 "화면(Presentation)이 비즈니스
로직을 직접 구현하지 않는다"는 지켜집니다. `tos_screen.dart`/`phishing_screen.dart`는
사용자 입력을 받아 `TosService`/`PhishingService`를 호출하고 결과만
렌더링하며, API 호출·청킹·로컬 판정 로직은 전부 `lib/services/*.dart`에
모여 있어 화면과 분리되어 있습니다.

---

## B. 앱 구조 / 디렉토리 (3문항)

**Q9. 앱의 전체 구조(디렉토리)는 어떻게 되어 있나요?**
```
lib/
├── main.dart                # 진입점
├── app.dart                 # MaterialApp + 하단 네비게이션 3탭
├── presentation/
│   ├── screens/             # home, tos, phishing, pii, notifications
│   └── theme/                # 앱 테마(라이트/다크)
└── services/
    ├── claude_service.dart     # Claude API 공통 클라이언트
    ├── tos_service.dart        # 약관 분석 (4,000자 청킹 + Claude)
    ├── phishing_service.dart   # 피싱 탐지 (로컬 1차 + Claude 2차)
    ├── history_service.dart    # 분석 이력 로컬 저장
    ├── activity_service.dart   # 사용 통계
    └── notification_service.dart # 공지사항
```
화면(`presentation/screens`)과 비즈니스 로직(`services`)을 분리한
2-레이어 구조입니다.

**Q10. 화면 전환(네비게이션)은 어떻게 구현했나요?**
`app.dart`의 `_AppState`가 `_currentIndex`를 `setState`로 관리하고,
`BottomNavigationBar`의 `onTap`에서 인덱스를 바꿔 `[HomeScreen, TosScreen,
PhishingScreen]` 리스트에서 해당 화면을 보여줍니다. 홈 탭으로 돌아올 때는
`_homeRefreshKey`를 증가시켜 `HomeScreen`을 `ValueKey`로 다시 빌드해
최신 통계가 반영되도록 했습니다.

**Q11. 각 서비스(`lib/services/`)는 어떤 역할을 분담하나요?**
- `ClaudeService`: Anthropic Claude API 호출 공통 로직(헤더, 에러 처리)
- `TosService`: 약관 텍스트를 4,000자 단위로 청킹 → Claude에 분석 요청 →
  위험/주의/안전 조항으로 파싱 (`mockReport`로 API 없이도 동작 확인 가능)
- `PhishingService`: 키워드/단축 URL/의심 도메인으로 로컬 1차 판정 후,
  필요 시 Claude로 2차 문맥 분석, 오류 시 로컬 판정으로 fallback
- `HistoryService`: 분석 결과를 `shared_preferences`에 최근 20건 저장
- `ActivityService`: 약관 분석/피싱 검사/위협 차단 횟수 통계

---

## C. 개발 환경 / 빌드 / 배포 (5문항)

**Q12. 개발 환경은 어떻게 설정하나요?**
Flutter 3.x + Dart, `flutter pub get`으로 의존성 설치 후
`flutter run`(목 데이터) 또는 `flutter run --dart-define-from-file=.env.dev`
(Claude API 연동)로 실행합니다. 자세한 절차는 `docs/setup.md`에 있습니다.

**Q13. Claude API 키는 어떻게 관리하나요? 코드에 하드코딩되어 있나요?**
아니요. `--dart-define-from-file`로 빌드/실행 시점에 주입합니다.
`.env.dev` / `.env.staging` / `.env.prod`로 환경을 분리했고, 실제 키가
담긴 `.env*` 파일은 `.gitignore`에 포함되어 저장소에 올라가지 않습니다.
API 키가 없으면 `TosService.mockReport`와 `PhishingService`의 로컬
판정으로 자동 fallback해 데모가 항상 동작합니다.

**Q14. 빌드와 배포는 어떤 단계로 이루어지나요?**
1) `flutter pub get` (의존성 설치)
2) `flutter analyze` / `flutter test` (정적분석·테스트 통과 확인)
3) `flutter build apk --release` (Android 릴리즈 APK 빌드)
4) 생성된 `build/app/outputs/flutter-apk/app-release.apk`를 실기기에
   설치해 사이드로드 검증
서명·버전 관리·롤백 절차는 `docs/deploy.md`, 배포 채널 선택 이유는
ADR-0005에 정리되어 있습니다.

**Q15. 이번 학기에 겪은 환경설정 시행착오가 있나요?**
네, `lessons/02-android-sdk-setup.md`에 기록했습니다. Android Studio 없이
cmdline-tools만으로 SDK를 설치하는 과정에서 ① 다운로드 URL의 빌드 번호가
잘못되어 404가 발생했고 `curl -sI`로 유효한 빌드 번호를 직접 찾았습니다.
② `sdkmanager --licenses`에 PowerShell로 `y`를 파이프하면 라이선스
동의가 끝까지 처리되지 않았는데, Git Bash의 `cmd //c <bat경로>` +
`yes` 조합으로 비대화형 동의를 해결했습니다. 이후 `ANDROID_HOME`을
세션·영구 환경변수에 모두 등록해 `flutter doctor`를 통과시켰습니다.

**Q16. APK 외에 iOS 빌드/배포는 어떻게 하나요?**
ADR-0005에 따라 1차 배포 채널은 Android APK 사이드로드입니다. iOS는
Apple Developer 계정·macOS·Xcode가 필요해 6주 일정에는 과도한 비용으로
판단했고, 발표 시연은 Android 실기기 기준으로 진행하며 "Flutter
크로스플랫폼이라 iOS도 동일 코드로 동작한다"는 점을 설명으로 보완합니다.

---

## D. 테스트 / 코드 품질 (5문항)

**Q17. 테스트는 어떤 구조로 되어 있고 몇 개인가요?**
`test/` 아래에 단위 테스트 10개(`phishing_service_test.dart` 5개,
`tos_service_test.dart` 5개), 통합 테스트 1개(`integration/
analysis_scenario_test.dart`), 위젯 스모크 테스트 1개(`widget_test.dart`)가
있습니다. `flutter test`로 전체 실행하며, 자세한 케이스 목록은
`docs/testing.md`에 정리했습니다.

**Q18. 피싱/약관 서비스 단위 테스트는 어떤 걸 검증하나요?**
PhishingService 5개: 위험 키워드 2개 이상→danger, 단축 URL 포함→danger,
위험 키워드 1개→warning, 안전한 텍스트→safe(score≤3), URL 존재 여부 감지.
TosService 5개: 정상 JSON 파싱(dangerCount=1), 잘못된 JSON 입력 시 빈
리스트(예외 없음), 4,000자 이하 → 청크 1개, 4,000자 초과 → 청크 2개 이상,
`mockReport` 검증(dangerCount=2).

**Q19. 통합 테스트는 어떤 시나리오를 검증하나요?**
"피싱 탐지 → 약관 분석 → 활동 통계" 흐름입니다. 스미싱 문자를 입력해
`danger` 판정을 확인하고 `ActivityService.recordPhishingScan`을 호출,
이어서 `TosService.mockReport`로 약관 분석 후
`ActivityService.recordTosAnalysis`를 호출한 뒤, `getStats`로 두 통계가
모두 기록되었는지 확인합니다. `SharedPreferences.setMockInitialValues({})`로
로컬 저장소를 모킹합니다.

**Q20. 코드 품질은 어떻게 관리하나요?**
`flutter analyze`로 정적 분석(0건 목표)을 수행하고, `analysis_options.yaml`은
`flutter_lints` 기본 규칙을 사용합니다. 커밋 전 `flutter analyze && flutter
test` 통과를 작업 규칙(`AGENTS.md` §5)으로 명시해 두었습니다.

**Q21. 개발 중 겪은 디버깅 시행착오를 하나 설명해주세요.**
`lessons/01-phishing-score-test-mismatch.md`에 기록된 사례입니다. 피싱
위험도를 "키워드수×2 + 도메인수×3" 식으로 점수화했는데, 단축 URL이
하나만 있어도 위험으로 판정돼야 하는 케이스가 점수 합산으로는 `safe`로
나오는 버그가 있었습니다. 단위 테스트를 먼저 작성해 이 케이스를 잡았고,
점수 합산 대신 "단축 URL이 있으면 무조건 danger" 같은 규칙 기반 분기를
추가해 해결했습니다. 이런 교훈은 `lessons/`에 누적해 같은 실수를
반복하지 않도록 관리합니다.

---

## E. 기능 동작 / 성능 / 보안 (4문항)

**Q22. 약관 분석은 어떻게 동작하나요? 긴 약관도 처리되나요?**
사용자가 약관 텍스트를 붙여넣으면 `TosService`가 4,000자 단위로 청킹해
각 청크를 Claude API에 보냅니다. 응답 JSON을 파싱해 조항을
🔴위험/🟡주의/🟢안전 3단계로 분류하고 카드 형태로 보여줍니다. API 키가
없거나 오류가 나면 `mockReport`(목 데이터)로 즉시 결과를 보여줘 데모가
끊기지 않습니다.

**Q23. 피싱 탐지는 왜 2단계(로컬+API)로 나눠져 있나요?**
1차로 `PhishingService`가 위험 키워드, 단축 URL(`bit.ly` 등), 의심
도메인을 정규식으로 검사해 즉시 danger/warning/safe를 판정합니다(오프라인,
무료, 즉시). 필요 시 Claude API로 2차 문맥 분석을 추가해 정교한 판단을
보완합니다. API가 미설정이거나 오류일 때도 1차 로컬 판정만으로 항상
결과를 낼 수 있어 안정성이 높습니다.

**Q24. API 키가 없거나 Claude API가 오류를 반환하면 앱이 멈추나요?**
아니요. `TosService`와 `PhishingService` 모두 API 호출이 실패하면
예외를 잡아 로컬 분석/목 데이터 결과로 자동 fallback합니다. 사용자에게는
항상 분석 결과가 표시되며, 이 동작은 `docs/testing.md`의 Claude API
연동 테스트 체크리스트에도 명시되어 있습니다.

**Q25. 사용자 데이터는 어디에 저장되고, 외부로 전송되나요?**
분석 이력(최근 20건)과 통계는 기기 내 `shared_preferences`에만
저장되며 서버로 전송되지 않습니다. 약관 원문/피싱 문자 내용은 분석을
위해 Claude API로만 전송되고, 자체 서버를 거치지 않습니다(ADR-0003).
현재 로컬 저장은 평문이며, 암호화(`flutter_secure_storage`)는
README "향후 계획"에 명시했습니다.

---

## F. AI 워크플로우 / 가산점 (5문항)

**Q26. `AGENTS.md`는 어떤 용도인가요?**
AI 에이전트(Claude Code)가 이 저장소에서 작업할 때 참고하는 단일
진입점입니다. 기획·아키텍처·ADR·setup/deploy/testing 문서 위치,
슬래시 커맨드, `lessons/` 운영 규칙, 커밋 전 체크리스트를 한 파일에
모아 "agent/skills/rules/commands"를 통합했습니다.

**Q27. 어떤 슬래시 커맨드를 만들어 사용했나요?**
`.claude/commands/`에 3개를 정의했습니다. `/analyze-tos`(약관 텍스트
청킹+위험조항 분석), `/check-phishing`(URL/문자 피싱 판정),
`/run-tests`(전체/단위/통합 테스트 실행 및 결과 요약). 반복되는 분석·검증
작업을 표준화해 매번 같은 절차를 다시 설명하지 않도록 했습니다.

**Q28. `lessons/` 위키는 어떻게 운영되나요?**
디버깅·설계 시행착오를 코드와 분리해 `lessons/NN-짧은제목.md` 형식으로
기록합니다. 구성은 발생일→증상→원인분석→해결→교훈입니다. 현재
`lessons/01`(피싱 점수 임계값 버그)과 `lessons/02`(Android SDK 설치
트러블슈팅) 2건이 있고, 새 세션 시작 시 AI가 이 목록을 먼저 확인해
같은 실수를 반복하지 않도록 `AGENTS.md`에 규칙으로 명시했습니다.

**Q29. 가산점 신청서(`bonus.md`)의 핵심 내용은 무엇인가요?**
약관을 끝까지 읽는 사용자가 9% 미만이고 약관 1건을 다 읽는 데 72분이
걸린다는 문제 인식에서 출발해, Guardian AI가 이를 30초 분석으로
줄이는 사회적 임팩트를 제시합니다. 목표 KPI로 약관 위험탐지 정확도
≥80%, 피싱 TPR ≥85%, 테스트 커버리지 ≥70%, PII 서버 전송 0건을
제시했고, 이 내용은 `docs/index.html`의 "가산점" 섹션에 시각화되어
있습니다.

**Q30. 앞으로의 계획은 무엇인가요?**
README "향후 계획"에 정리된 대로 ① 로컬 히스토리 암호화
(`flutter_secure_storage`), ② OCR 기반 약관 촬영 인식, ③ 실제 피싱
DB 연동 탐지 고도화, ④ Android/iOS 배포 산출물 실기기 검증을 계획하고
있습니다. 또한 이번에 만든 AI 협업 워크플로우(슬래시 커맨드, `lessons/`
위키)도 계속 발전시킬 예정입니다.

---

## 발표 직전 체크

- [ ] ADR 5개 — 이름만 보고 1줄 이유를 즉답할 수 있는지 자가 테스트 (Q1~Q6)
- [ ] "계획 vs 실제 구현 차이"(Q3, Q7) — 회피하지 말고 "MVP 범위 조정"으로
      당당히 설명할 것. 솔직한 답변이 ADR 기록 기준의 정확성 평가에 더 유리함.
- [ ] 테스트 개수(단위 10 + 통합 1 + 위젯 1)와 `flutter test` 명령 즉답 (Q17~Q19)
- [ ] `lessons/01`, `lessons/02` 한 줄 요약 즉답 (Q21, Q15)
