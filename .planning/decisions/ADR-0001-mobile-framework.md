# ADR-0001: 모바일 플랫폼 선택 — Flutter

- 상태: Accepted
- 날짜: 2026-05-19
- 결정자: Guardian AI 개발자

## 배경

Guardian AI는 PII 마스킹, 약관 분석, 피싱 탐지 기능을 제공하는 모바일 앱이다.  
Android와 iOS를 동시에 지원해야 하며, 6주라는 짧은 개발 기간 안에 MVP를 완성해야 한다.  
어떤 모바일 플랫폼/프레임워크를 선택하느냐에 따라 개발 속도, 유지보수성, 플랫폼 커버리지가 결정된다.

## 고려한 대안

| 플랫폼 | 장점 | 단점 | 추천 대상 |
|--------|------|------|---------|
| **Flutter** | 한 코드로 양 OS 동시 지원, UI 위젯 풍부 | Dart 언어 별도 학습 필요 | Android + iOS 동시 타겟 |
| **React Native** | JS/TS 생태계 활용, 빠른 프로토타입 | JS Bridge 성능 오버헤드, 익숙함 필요 | 웹 경험자, 빠른 프로토타입 |
| **Android (Kotlin)** | 풀 네이티브 성능, 도구 성숙 | iOS 별도 개발 필요 | Android만 타겟 |
| **iOS (Swift)** | Apple 생태계 깊이 활용, 네이티브 모듈 | macOS 필수, Android 미지원 | iOS만 타겟, 중급 이상 |
| **Kotlin Multiplatform** | 코어 로직 공유, 네이티브 UI 유지 | 복잡도 높음, 생태계 미성숙 | 고급 크로스플랫폼 |

## 결정

**Flutter**를 선택한다.

## 이유

- 1인 프로젝트 + 6주 일정에서 Android / iOS 동시 지원을 위한 유일한 현실적 선택
- 졸업 작품 심사 기준에 "Android / iOS 동시 빌드"가 포함되어 있어 크로스플랫폼 필수
- 필요한 패키지(`flutter_secure_storage`, `sqflite`, `file_picker`, `http`)가 모두 Flutter pub에 존재하여 외부 의존성 위험 낮음
- Dart 학습 곡선은 10주차 환경 구축 기간에 공식 Codelabs로 해소 가능

## 결과 (예상되는 영향)

긍정:
- 단일 코드베이스로 두 플랫폼 동시 지원 → 개발·디버깅 시간 절반
- Widget 기반 UI로 다크/라이트 모드, 반응형 레이아웃 구현 용이
- `flutter build apk --release` 단일 명령으로 발표용 APK 빌드 가능

부정 / 제약:
- Dart 언어 신규 학습 필요 (10주차 버퍼에 포함)
- 클립보드 자동 감지(F-CLIP-001) 등 일부 기능은 플랫폼 채널 작업 필요 → Should Have로 분류하여 리스크 완화
- 네이티브 대비 앱 용량 증가 (발표 시연에는 무관)

## 후속 작업

- [x] `pubspec.yaml` 의존성 초기 설정 (10주차)
- [x] Android / iOS 동시 빌드 확인 (`flutter devices`, `flutter run`)
- [ ] Dart 기초 학습 — Flutter 공식 Codelabs "Write your first Flutter app" 완주
- [ ] `android/app/build.gradle` minSdkVersion 26 설정 확인
- [ ] `ios/Runner/Info.plist` 최소 버전 13.0 설정 확인
