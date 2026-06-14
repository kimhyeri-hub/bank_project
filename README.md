# Guardian AI 🛡️

> 복잡한 금융 약관을 분석하고, 피싱 위협을 탐지하여 당신의 프라이버시를 능동적으로 수호합니다.

<br>

## 소개

금융 거래 시 마주치는 3페이지짜리 작은 글씨의 약관, 읽으시나요?  
매일 쏟아지는 피싱 문자와 사기 링크, 구분하기 어렵지 않으신가요?

**Guardian AI**는 이 두 가지 문제를 해결합니다.  
Claude API 기반 약관 분석과 피싱 탐지로 금융 생활의 보안을 한 단계 높여드립니다.

<br>

## 스크린샷 / 데모

(이미지 또는 데모 영상 링크 — 최종 발표 전 추가)

발표 슬라이드: [`docs/index.html`](docs/index.html) (GitHub Pages)

<br>

## 주요 기능

### 📄 약관 분석
- **3가지 입력 방식** 지원: PDF 업로드 / URL 입력 / 텍스트 직접 입력
- Claude API로 위험 조항을 **위험 · 주의 · 안전** 3단계로 분류
- 조항 번호와 함께 이해하기 쉬운 설명 제공
- 4,000자 단위 청킹으로 긴 약관도 분석 (`TosService`)
- API 키 미설정 시 목 데이터(`TosService.mockReport`)로 동작 확인 가능

### 🔍 피싱 탐지
- URL, 문자 메시지, 이메일 내용 분석
- 위험 키워드 · 단축 URL · 의심 도메인 기반 로컬 1차 판정 (`PhishingService`)
- Claude API로 2차 문맥 분석, 미설정/오류 시 로컬 판정으로 자동 fallback
- **위험 · 주의 · 안전** 판정 및 감지된 키워드 표시

### 📊 나의 활동
- 약관 분석 횟수, 피싱 검사 횟수, 위협 차단 건수 기록
- 최근 분석 이력 최대 20건 로컬 저장 (`HistoryService`)
- 기기 로컬 저장 (서버에 데이터 전송 없음)

### 🔔 공지사항
- 최신 보안 위협 안내 및 앱 업데이트 소식
- 읽지 않은 공지 배지 표시

<br>

## 기술 스택

| 항목 | 내용 |
|------|------|
| Framework | Flutter 3.x |
| Language | Dart |
| AI | Anthropic Claude API (`http` 패키지로 직접 호출) |
| 로컬 저장소 | shared_preferences |
| 디자인 | Material Design 3 |
| 지원 플랫폼 | Android · iOS · Web |

<br>

## 빠른 시작

```bash
flutter pub get
flutter run                                  # Claude API 없이 실행 (로컬/목 데이터)
flutter run --dart-define-from-file=.env.dev # Claude API 연동
```

설치/환경변수 설정 등 자세한 내용은 [`docs/setup.md`](docs/setup.md) 참고.

<br>

## 빌드 / 배포

```bash
flutter build apk --release
```

빌드 종류, 서명, 환경별 설정(`.env.dev`/`.env.staging`/`.env.prod`), 버전 관리,
롤백 방법은 [`docs/deploy.md`](docs/deploy.md) 참고.

<br>

## 테스트

```bash
flutter test
```

테스트 구조와 케이스 목록은 [`docs/testing.md`](docs/testing.md) 참고.

<br>

## 아키텍처

레이어 구조, 데이터 흐름, 핵심 의사결정은 [`docs/architecture.md`](docs/architecture.md) 참고.

<br>

## 프로젝트 구조

```
lib/
├── main.dart
├── app.dart                          # 앱 진입점, 하단 네비게이션
├── presentation/
│   ├── screens/
│   │   ├── home_screen.dart          # 홈 (활동 요약)
│   │   ├── tos_screen.dart           # 약관 분석
│   │   ├── phishing_screen.dart      # 피싱 탐지
│   │   └── notifications_screen.dart # 공지사항
│   └── theme/
│       └── app_them.dart             # 앱 테마
└── services/
    ├── activity_service.dart         # 사용 이력 관리 (통계)
    ├── history_service.dart          # 분석 이력 로컬 저장
    ├── notification_service.dart     # 공지사항 관리
    ├── claude_service.dart           # Claude API 공통 클라이언트
    ├── tos_service.dart              # 약관 분석 (청킹 + Claude)
    └── phishing_service.dart         # 피싱 탐지 (로컬 + Claude)
```

<br>

## 보안 / 개인정보 보호 원칙

- 입력한 모든 데이터는 **서버에 저장되지 않습니다** (Claude API 호출 시에만 전송)
- 분석 이력은 사용자 기기에만 로컬 저장됩니다 (현재 평문 — 향후 암호화 개선 예정)
- API 키는 코드에 하드코딩하지 않고 `--dart-define-from-file`로 빌드 시 주입

체크리스트 전체는 [`docs/security.md`](docs/security.md) 참고.

<br>

## 라이선스

본 프로젝트는 교육 목적으로 제작되었습니다.

<br>

## 향후 계획

- [ ] 로컬 히스토리 암호화 저장 (`flutter_secure_storage` 도입)
- [ ] OCR 기반 카메라 촬영 약관 인식
- [ ] 실제 피싱 DB 연동 탐지 고도화
- [ ] Android/iOS 배포 산출물(apk/ipa) 빌드 및 실기기 설치 검증
