# Guardian AI 🛡️

> 복잡한 금융 약관을 분석하고, 피싱 위협을 탐지하여 당신의 프라이버시를 능동적으로 수호합니다.

<br>

## 소개

금융 거래 시 마주치는 3페이지짜리 작은 글씨의 약관, 읽으시나요?  
매일 쏟아지는 피싱 문자와 사기 링크, 구분하기 어렵지 않으신가요?

**Guardian AI**는 이 두 가지 문제를 해결합니다.  
AI 기반 약관 분석과 피싱 탐지로 금융 생활의 보안을 한 단계 높여드립니다.

<br>

## 주요 기능

### 📄 약관 분석
- **3가지 입력 방식** 지원: PDF 업로드 / URL 입력 / 텍스트 직접 입력
- 위험 조항을 **위험 · 주의 · 안전** 3단계로 분류
- 조항 번호와 함께 이해하기 쉬운 설명 제공
- AI 요약으로 핵심 내용 한눈에 파악

### 🔍 피싱 탐지
- URL, 문자 메시지, 이메일 내용 분석
- 위험 키워드 및 의심 도메인 자동 감지
- **위험 · 주의 · 안전** 판정 및 감지된 키워드 표시

### 📊 나의 활동
- 약관 분석 횟수, 피싱 검사 횟수, 위협 차단 건수 기록
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
| 로컬 저장소 | shared_preferences |
| 디자인 | Material Design 3 |
| 지원 플랫폼 | Android · iOS · Web |

<br>

## 실행 방법

```bash
# 의존성 설치
flutter pub get

# 웹(Chrome)으로 실행
flutter run -d chrome

# 안드로이드로 실행
flutter run -d android
```

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
    ├── activity_service.dart         # 사용 이력 관리
    └── notification_service.dart     # 공지사항 관리
```

<br>

## 개인정보 보호 원칙

- 입력한 모든 데이터는 **서버에 저장되지 않습니다**
- 활동 기록은 사용자 기기에만 로컬 저장됩니다
- 개인정보보호법 기준에 따라 운영됩니다

<br>

## 향후 계획

- [ ] Claude API 연동으로 실제 AI 약관 분석 구현
- [ ] OCR 기반 카메라 촬영 약관 인식
- [ ] 실제 피싱 DB 연동 탐지 고도화
- [ ] 안드로이드 / iOS 앱 배포
