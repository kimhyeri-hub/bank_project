# 04-schedule: Guardian AI 6주 개발 일정

**대상 기간**: 10주차 ~ 15주차  
**중간 발표**: 12주차 | **최종 발표**: 15주차

---

## 전체 로드맵

```
10주차  ████████ 설계·환경 구축
11주차  ████████ 앱 기본 구조 + PII 마스킹
12주차  ████████ 약관 분석 + 중간 발표
13주차  ████████ 피싱 탐지 기능
14주차  ████████ 통합·테스트·마무리
15주차  ★★★★★★★ 최종 발표
```

| 주차 | 핵심 테마 | 주요 이벤트 | 위험도 |
|------|---------|-----------|------|
| 10주 | 기반 구축 | — | 낮음 |
| 11주 | PII 마스킹 | — | 낮음 |
| 12주 | 약관 분석 | **중간 발표** | 중간 |
| 13주 | 피싱 탐지 | — | 중간 |
| 14주 | 통합·검증 | — | 높음 |
| 15주 | 발표·제출 | **최종 발표** | 중간 |

---

## 10주차: 기반 구축

### 목표
- 프로젝트 설계 문서 전체 완성
- Flutter 개발 환경 구축 및 Claude API 연동 확인
- 와이어프레임 초안 완성

### 산출물

| 산출물 | 위치 |
|-------|------|
| 비전·요구사항·WBS·일정 문서 | `.planning/` |
| Flutter 프로젝트 초기 구조 | `pubspec.yaml`, `.env` |
| 앱 전체 화면 와이어프레임 | Figma 또는 스케치 파일 |
| 시스템 아키텍처 문서 | `.planning/03-architecture.md` |
| 디자인 시스템 초안 | `lib/core/theme/app_theme.dart` |

### 검증 방법
- `flutter run` 실행 → 에뮬레이터에서 기본 앱 화면 출력 확인
- Claude API 호출 테스트 스크립트 실행 → 터미널에서 응답 JSON 수신 확인
- `.planning/` 내 4개 문서 파일 존재 여부 확인
- 와이어프레임에서 홈·PII·약관·피싱 4개 화면 커버 여부 확인

---

## 11주차: 앱 기본 구조 + PII 마스킹

### 목표
- 온보딩 + 하단 탭 네비게이션 + 기본 화면 뼈대 완성
- 정규식 기반 PII 탐지 + Claude API 보조 인식 동작
- 마스킹 전/후 비교 화면 완성

### 산출물

| 산출물 | 위치 |
|-------|------|
| 온보딩 화면 (3단계) | `lib/features/onboarding/` |
| 하단 탭 네비게이션·라우팅 | `lib/core/router.dart` |
| PII 탐지 정규식 엔진 + 단위 테스트 | `lib/features/pii/pii_detector.dart`, `test/pii_test.dart` |
| 마스킹 유틸리티 + 강도 조절 로직 | `lib/features/pii/masking_utils.dart` |
| Claude API PII 보조 서비스 | `lib/services/pii_ai_service.dart` |
| PII 마스킹 화면 UI | `lib/features/pii/pii_screen.dart` |

### 검증 방법
- 앱 실행 후 온보딩 3단계 → 메인 탭 전환 흐름 수동 확인
- 전화번호·이메일·이름 포함 텍스트 입력 → 자동 탐지 및 마스킹 결과 출력 확인
- `flutter test test/pii_test.dart` 전체 통과 확인
- Claude API PII 분석 응답 수신 로그 확인 (최소 3종 입력 테스트)

---

## 12주차: 약관 분석 + 중간 발표

> **이번 주 이벤트**: 중간 발표 — 구현 진행 상황 및 PII 마스킹 기능 시연

### 목표
- 약관 분석 파이프라인 (텍스트 입력 → Claude API → 위험 조항 분류) 완성
- 분석 결과 UI 완성
- 중간 발표 자료 및 시연 시나리오 준비

### 산출물

| 산출물 | 위치 |
|-------|------|
| 약관 분석 프롬프트 모듈 | `lib/features/tos/tos_prompt.dart` |
| API 응답 파싱 로직 | `lib/features/tos/tos_parser.dart` |
| 약관 서비스 클래스 (에러 처리 포함) | `lib/services/tos_service.dart` |
| 약관 입력 화면 | `lib/features/tos/tos_input_screen.dart` |
| 분석 결과 화면 (위험 조항 카드) | `lib/features/tos/tos_result_screen.dart` |
| **중간 발표 슬라이드** | `docs/midterm_presentation.pptx` |
| **중간 발표 데모 시나리오** | `docs/midterm_demo_script.md` |

### 검증 방법
- 실제 서비스 약관(카카오·네이버 중 1종) 붙여넣기 → 위험 조항 분류 결과 출력 확인
- 위험 조항이 고위험·중위험·저위험 3단계로 시각적으로 구분되는지 확인
- 조항별 원문 + AI 해석이 나란히 표시되는지 확인
- **중간 발표**: 10주차~11주차 완성 기능 시연 + 12주차 진행 현황 설명 가능 여부 확인
- 발표 슬라이드 완성도 및 5분 내 시연 완료 여부 리허설로 확인

---

## 13주차: 피싱 탐지 기능

### 목표
- URL 구조 분석 + 스미싱 패턴 매칭 + Claude API 문맥 분석 파이프라인 완성
- 피싱 탐지 화면 UI 완성

### 산출물

| 산출물 | 위치 |
|-------|------|
| URL 구조 분석 유틸리티 | `lib/features/phishing/url_analyzer.dart` |
| 단축 URL 추적 + 스미싱 패턴 DB | `lib/features/phishing/url_expander.dart`, `smishing_patterns.dart` |
| Claude API 피싱 문맥 분석 서비스 | `lib/services/phishing_ai_service.dart` |
| 종합 위험 점수 산출 로직 | `lib/features/phishing/phishing_result.dart` |
| 피싱 탐지 화면 UI | `lib/features/phishing/phishing_screen.dart` |
| 위험 경고 다이얼로그 | `lib/widgets/danger_alert_dialog.dart` |

### 검증 방법
- 실제 스미싱 문자 샘플(최소 3건) 붙여넣기 → 위험 판정 출력 확인
- 정상 URL과 의심 URL 각 3건 입력 → 위험도 점수 및 위험 요소 설명 구분 확인
- 위험 판정 시 경고 다이얼로그 표시 확인
- 정상 URL 오탐률 목표 20% 이하 충족 여부 확인

---

## 14주차: 통합·테스트·마무리

> **목적**: 15주차 최종 발표 전 완성도 확보

### 목표
- 3개 핵심 기능(PII·약관·피싱) 통합 후 버그 없이 동작
- 분석 히스토리 등 부가 기능 구현
- 사용성 테스트 완료 및 피드백 반영
- APK 빌드 및 발표 준비 착수

### 산출물

| 산출물 | 위치 |
|-------|------|
| 통합 버그 수정 커밋 | Git 이력 |
| 분석 히스토리 화면 | `lib/features/history/history_screen.dart` |
| 홈 대시보드 위젯 | `lib/features/home/dashboard_widget.dart` |
| 사용성 테스트 피드백 정리 | `docs/usability_feedback.md` |
| Release APK 빌드 | `build/app/outputs/apk/release/app-release.apk` |
| 최종 발표 슬라이드 초안 | `docs/final_presentation.pptx` |

### 검증 방법
- 온보딩 → PII 마스킹 → 약관 분석 → 피싱 탐지 → 히스토리 조회 전체 흐름 오류 없이 완주 확인
- 크래시 0건, 미처리 예외 0건 (Flutter DevTools 확인)
- 지인 3명 이상 사용성 테스트 완료 및 주요 피드백 최소 1건 이상 반영
- `flutter build apk --release` 성공, 실기기 설치 및 전체 기능 동작 확인

---

## 15주차: 최종 발표

> **이번 주 이벤트**: 최종 발표 — 완성된 MVP 시연 및 프로젝트 결과 발표

### 목표
- 앱 최종 완성도 점검 및 폴리싱
- 발표 자료·데모 시나리오·보고서 완성
- 최종 발표 리허설 및 제출

### 산출물

| 산출물 | 위치 |
|-------|------|
| 최종 Release APK | `build/app/outputs/apk/release/` |
| 최종 발표 슬라이드 (10슬라이드 이상) | `docs/final_presentation.pptx` |
| 3분 데모 시나리오 | `docs/final_demo_script.md` |
| (선택) 데모 영상 | `docs/demo_video.mp4` |
| 최종 보고서 | `docs/final_report.pdf` |
| 업데이트된 README | `README.md` |

### 검증 방법
- Release APK 실기기 설치 → 전체 기능(PII·약관·피싱) 오류 없이 동작 확인
- 발표 슬라이드 10슬라이드 이상, 배경·기능·기술·시연·성과 항목 포함 여부 확인
- 3분 데모 리허설 시 시간 내 완료 여부 확인
- README에 설치·실행 방법 명시 여부 확인
- **최종 발표**: 심사 기준에 따른 완성도 및 시연 품질 평가

---

## 위험 요소 및 대응 방안

| # | 위험 요소 | 가능성 | 영향도 | 대응 방안 |
|---|---------|------|------|---------|
| R1 | Claude API 응답 지연 또는 비용 초과 | 중간 | 높음 | 일일 호출 한도 설정 + 응답 캐싱 적용; 핵심 기능은 정규식 로컬 처리로 API 의존도 최소화 |
| R2 | 긴 약관의 컨텍스트 한계 초과 | 높음 | 높음 | 청킹(Chunking) 전략 사전 구현; 분할 요청 후 결과 병합; 최대 입력 길이 UI에서 사전 안내 |
| R3 | 피싱 탐지 오탐률 목표 미달 | 중간 | 중간 | 신뢰 도메인 화이트리스트 관리; 외부 위협 DB(VirusTotal) 무료 한도 소진 시 자체 패턴 매칭으로 대체 |
| R4 | 12주차 중간 발표 전 기능 미완성 | 낮음 | 높음 | 11주차 금요일 기준 완성 여부 점검; 미완성 시 AI 보조 인식 제외하고 정규식 기반 PII만으로 시연 |
| R5 | 14주차 통합 단계 버그 과다로 일정 초과 | 중간 | 높음 | Should Have 기능 전량 포기, Must Have 3개 핵심 기능만 완성 기준 유지; 최악의 경우 사전 녹화 데모 영상으로 최종 발표 대체 시연 |

---

## 주간 리뷰 체크리스트 (매주 일요일)

```markdown
## [N주차] 주간 리뷰 — YYYY-MM-DD

### 완료된 작업
- 

### 미완료 작업 및 원인
- 

### 발견된 버그
- 

### 위험 요소 발생 여부 (R1~R5 중)
- 

### 다음 주 우선순위
1. 
2. 
3. 
```

---

## 마일스톤 요약

| 마일스톤 | 목표 주차 | 달성 기준 |
|---------|---------|---------|
| M1: 환경 구축 완료 | 10주 말 | API 호출 성공, 앱 실행 확인 |
| M2: PII 마스킹 완성 | 11주 말 | 전화번호·이메일·이름 마스킹 동작 |
| M3: 약관 분석 + 중간 발표 | 12주 말 | 실제 약관 분석 결과 출력, 중간 발표 완료 |
| M4: 피싱 탐지 완성 | 13주 말 | 스미싱 문자 위험 판정 동작 |
| M5: 통합 + APK 빌드 | 14주 말 | 크래시 0건, Release APK 빌드 성공 |
| M6: 최종 발표 완료 | 15주 말 | 발표 및 보고서 제출 완료 |
