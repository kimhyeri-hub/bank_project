# ADR-0005: 배포 채널 선택 — APK 직접 배포 (사이드로딩)

- 상태: Accepted
- 날짜: 2026-05-19
- 결정자: Guardian AI 개발자

## 배경

완성된 앱을 심사위원·테스터에게 어떻게 전달할 것인가를 결정해야 한다.  
Play Store / App Store 정식 배포, 테스트 배포 플랫폼, 직접 APK 전달 등 여러 방법이 있으며  
각각 심사 기간, 비용, 개발 복잡도가 다르다.

## 고려한 대안

### 대안 A: APK 직접 배포 (Android 사이드로딩)
- 장점:
  - 스토어 심사 없음 → 즉시 배포 가능
  - 비용 없음
  - `flutter build apk --release` 한 명령으로 빌드 완료
  - 발표 당일 USB 또는 파일 공유로 즉시 설치 가능
- 단점:
  - 기기에서 "알 수 없는 소스 허용" 설정 필요
  - iOS는 APK 설치 불가 → 별도 대응 필요
  - 일반 사용자 배포 불가 (졸업 작품 시연 목적으로는 무관)

### 대안 B: Google Play Store (정식 배포)
- 장점:
  - 정식 앱으로 신뢰도 높음
  - 자동 업데이트, 버전 관리
- 단점:
  - 개발자 계정 등록비 $25 (1회)
  - 심사 기간 3~7일 → 6주 일정에서 리스크 과다
  - 개인정보 처리 방침 문서 필수 제출
  - 졸업 작품 시연 목적에 과도한 요건

### 대안 C: Firebase App Distribution
- 장점:
  - 테스터 이메일로 APK/IPA 배포 가능
  - 버전별 배포 이력 관리
  - 무료
- 단점:
  - Firebase 프로젝트 설정 필요 (ADR-0003에서 Firebase 미채택)
  - 테스터가 Firebase 초대 메일 수락 필요 → 발표 당일 즉시 배포 불가
  - 구성 복잡도 대비 이점이 APK 직접 배포와 큰 차이 없음

### 대안 D: TestFlight (iOS) + APK (Android) 병행
- 장점:
  - iOS 실기기 시연 가능
  - TestFlight는 App Store 심사 없이 100명까지 배포
- 단점:
  - Apple Developer Program 연간 $99 비용
  - TestFlight 업로드 → 심사 1~2일 소요
  - macOS + Xcode 환경 필수
  - 1인 MVP 졸업 작품에 과도한 비용과 복잡도

## 결정

**대안 A: Android APK 직접 배포(사이드로딩)**를 1차 배포 채널로 선택한다.  
iOS 시연이 필요한 경우 macOS + Xcode 시뮬레이터로 보완한다.

## 이유

- 졸업 작품 발표의 목적은 "동작하는 앱 시연"이며, 스토어 배포가 평가 기준에 포함되지 않는다
- `flutter build apk --release` 단일 명령으로 즉시 빌드·배포 가능 → 발표 당일 유연한 대응
- 비용 0원, 심사 대기 없음 → 14주차 빌드 완료 후 실기기 설치 및 최종 검증에 집중 가능
- Android 실기기 시연이 요구사항(04-schedule.md 14주차 검증)에 명시되어 있음
- iOS는 시뮬레이터 또는 macOS 화면 공유로 보완 가능 (비용·시간 0)

## 결과 (예상되는 영향)

긍정:
- 배포 준비에 소요되는 시간 최소화 → 기능 완성도·발표 준비에 집중
- 발표 당일 APK 재빌드 후 즉시 설치 가능 (긴급 버그 수정 대응)
- 데모 영상(`docs/demo_video.mp4`) 병행 준비 시 기기 미동작 상황도 커버

부정 / 제약:
- iOS 실기기 시연 불가 (macOS + Apple Developer 계정 없을 경우)
  → 발표 시 "Android 기준으로 시연, iOS도 Flutter 크로스플랫폼으로 동일 동작" 언급으로 대응
- "알 수 없는 소스 허용" 설정을 심사위원 기기에서 직접 해야 할 경우 불편
  → 발표자 본인 기기에 사전 설치 후 USB 미러링(scrcpy) 또는 화면 공유로 시연

## 후속 작업

- [ ] `android/app/build.gradle` — `minSdkVersion 26`, `targetSdkVersion 34` 설정 확인
- [ ] 서명 키(`guardian_ai.keystore`) 생성 및 `key.properties` 설정 (ADR-0001 후속 작업과 연계)
- [ ] 14주차: `flutter build apk --release --obfuscate` 성공 확인
- [ ] 발표 당일 시연 기기에 APK 사전 설치 완료
- [ ] 예비 시연 수단 준비: scrcpy(USB 미러링) 또는 사전 녹화 데모 영상
- [ ] (선택) iOS 시뮬레이터 시연 환경 확인 (`flutter run -d "iPhone 15"`)
