# docs/deploy.md — Guardian AI 빌드 및 배포

> 발표용 APK 빌드부터 실기기 설치까지.

---

## 1. 빌드 전 체크리스트

```bash
flutter analyze          # 정적 분석 — 경고 0건 목표
flutter test             # 단위 테스트 전체 통과 확인
flutter pub outdated     # 의존성 업데이트 필요 여부 확인
```

---

## 2. Android Release APK 빌드

### 2-1. 서명 키 생성 (최초 1회)

```bash
keytool -genkey -v \
  -keystore guardian_ai.keystore \
  -alias guardian_ai \
  -keyalg RSA -keysize 2048 \
  -validity 10000
```

생성된 `guardian_ai.keystore` 파일은 프로젝트 루트에 보관.  
`.gitignore`에 추가해 절대 커밋하지 마세요.

### 2-2. `android/key.properties` 생성

```properties
storePassword=설정한_비밀번호
keyPassword=설정한_비밀번호
keyAlias=guardian_ai
storeFile=../guardian_ai.keystore
```

### 2-3. `android/app/build.gradle` 서명 설정 확인

`build.gradle`의 `signingConfigs` 블록이 `key.properties`를 참조하는지 확인.  
(Flutter 공식 문서: https://docs.flutter.dev/deployment/android)

### 2-4. 빌드 실행

```bash
# 난독화 포함 (권장)
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info/

# 일반 빌드 (발표용으로도 충분)
flutter build apk --release
```

산출물 위치:
```
build/app/outputs/apk/release/app-release.apk
```

---

## 3. 실기기 설치

### USB 연결 설치
```bash
flutter install --release
```

### APK 직접 전송
```bash
# adb로 설치
adb install build/app/outputs/apk/release/app-release.apk
```

또는 APK 파일을 이메일/USB로 기기에 복사 후 파일 관리자에서 실행.  
설치 전 기기 설정에서 "알 수 없는 소스 허용" 필요 (Android 8+는 앱별 설정).

---

## 4. iOS 빌드 (macOS만 가능)

```bash
flutter build ios --release
```

배포 없이 시뮬레이터 시연만 필요하면:
```bash
flutter run --release -d "iPhone 15"
```

> App Store 배포는 MVP 범위 외. 발표는 실기기 USB 연결 또는 시뮬레이터로 시연.

---

## 5. 버전 관리

`pubspec.yaml`의 `version` 필드를 발표 전 업데이트:

```yaml
version: 1.0.0+1   # 형식: 버전명+빌드번호
```

---

## 6. 발표 당일 빌드 체크리스트

```
[ ] flutter clean && flutter build apk --release 성공
[ ] 실기기 설치 완료
[ ] 온보딩 → PII → 약관 → 피싱 전체 흐름 오류 없이 통과
[ ] Claude API 호출 성공 (핫스팟 연결 상태에서 테스트)
[ ] 데모 예시 텍스트 앱 내 "예시 불러오기" 버튼으로 탑재 확인
[ ] 예비 데모 영상(docs/demo_video.mp4) 존재 여부 확인
```
