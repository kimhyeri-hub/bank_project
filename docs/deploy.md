# docs/deploy.md — Guardian AI 빌드 및 배포

> 발표용 APK 빌드부터 실기기 설치까지.

---

## 1. 빌드 종류 (debug / release / profile)

| 종류 | 명령 | 용도 |
|------|------|------|
| debug | `flutter run` / `flutter build apk --debug` | 개발 중 디버깅. hot reload, 전체 로그, assert 활성화 |
| profile | `flutter run --profile` / `flutter build apk --profile` | 성능 프로파일링용. 디버그 배너 제거, 일부 디버그 서비스만 유지 |
| release | `flutter build apk --release` | 실제 배포용. 코드 최적화·축소(minify), 디버그 기능 전부 비활성화 |

---

## 2. 빌드 전 체크리스트

```bash
flutter analyze          # 정적 분석 — 경고 0건 목표
flutter test             # 단위 테스트 전체 통과 확인
flutter pub outdated     # 의존성 업데이트 필요 여부 확인
```

---

## 3. Android Release APK 빌드

### 3-1. 서명 키 생성 (최초 1회)

```bash
keytool -genkey -v \
  -keystore guardian_ai.keystore \
  -alias guardian_ai \
  -keyalg RSA -keysize 2048 \
  -validity 10000
```

생성된 `guardian_ai.keystore` 파일은 프로젝트 루트에 보관.  
`.gitignore`에 이미 포함되어 있으므로 절대 커밋하지 마세요.

### 3-2. `android/key.properties` 생성

```properties
storePassword=설정한_비밀번호
keyPassword=설정한_비밀번호
keyAlias=guardian_ai
storeFile=../guardian_ai.keystore
```

`android/key.properties`도 `.gitignore`에 포함되어 있습니다.

### 3-3. `android/app/build.gradle` 서명 설정 확인

`build.gradle`의 `signingConfigs` 블록이 `key.properties`를 참조하는지 확인.  
(Flutter 공식 문서: https://docs.flutter.dev/deployment/android)

> `key.properties`가 없으면 현재 설정대로 디버그 키로 서명되어
> `flutter build apk --release`도 정상 동작합니다 (발표용으로 충분).

### 3-4. 빌드 실행

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

## 4. 실기기 설치

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

## 5. iOS 빌드 (macOS만 가능)

```bash
flutter build ios --release
```

배포 없이 시뮬레이터 시연만 필요하면:
```bash
flutter run --release -d "iPhone 15"
```

> App Store 배포는 MVP 범위 외. 발표는 실기기 USB 연결 또는 시뮬레이터로 시연.

---

## 6. 환경별 설정 (.env.dev / .env.staging / .env.prod)

Guardian AI는 `--dart-define-from-file`로 환경별 Claude API 키를 주입합니다.
(`.env.dev.example` / `.env.staging.example` / `.env.prod.example` 참고, 자세한 작성법은 `docs/setup.md`)

| 파일 | 용도 | 빌드/실행 명령 |
|------|------|------|
| `.env.dev` | 로컬 개발 (목 데이터 fallback, verbose 로그) | `flutter run --dart-define-from-file=.env.dev` |
| `.env.staging` | 사내 테스트 (실 API, 디버그 가능) | `flutter build apk --release --dart-define-from-file=.env.staging` |
| `.env.prod` | 실배포 (실 API) | `flutter build apk --release --dart-define-from-file=.env.prod` |

- `.env.*.example`만 git에 commit, 실제 `.env.*`는 `.gitignore`에 의해 제외됨
- API 키 등 시크릿은 절대 커밋하지 않음
- 환경 변수가 없어도(`.env` 미사용) 앱은 실행되며, `ClaudeService.isConfigured == false`일 때
  로컬 분석/목 데이터(`PhishingService._analyzeLocally`, `TosService.mockReport`)로 동작

---

## 7. 버전 관리 (SemVer)

`pubspec.yaml`의 `version` 필드를 발표 전 업데이트:

```yaml
version: 1.0.0+1   # 형식: MAJOR.MINOR.PATCH+빌드번호
```

- **MAJOR**: 호환되지 않는 큰 변경 (예: 데이터 구조 변경으로 기존 로컬 데이터 마이그레이션 필요)
- **MINOR**: 기능 추가 (예: 새 분석 화면 추가)
- **PATCH**: 버그 수정
- **빌드번호(+N)**: 빌드마다 1씩 증가 (Android `versionCode`, iOS `CFBundleVersion`)

---

## 8. 롤백 방법

새 버전 설치 후 치명적인 문제가 발견되면:

1. **APK 보관**: 발표/배포 시점마다 `app-release.apk`를 버전 태그와 함께 보관
   ```bash
   git tag v1.0.0
   cp build/app/outputs/apk/release/app-release.apk release/app-release-v1.0.0.apk
   ```
2. **이전 버전 재빌드** (보관된 APK가 없을 경우)
   ```bash
   git checkout v1.0.0
   flutter clean && flutter build apk --release
   ```
3. **기기 재설치**
   ```bash
   adb uninstall com.yourname.claude_project
   adb install release/app-release-v1.0.0.apk
   ```
   versionCode가 낮은 APK는 그냥 덮어설치되지 않으므로, 다운그레이드 시 `uninstall` 후 `install` 필요.
4. **로컬 데이터 영향**: 앱 삭제 시 `shared_preferences` 기반 히스토리/공지 읽음 상태도 함께 삭제됨.
   사용자에게 데이터가 초기화될 수 있음을 안내.

---

## 9. 발표 당일 빌드 체크리스트

```
[ ] flutter clean && flutter build apk --release 성공
[ ] 실기기 설치 완료
[ ] 홈 → 약관 분석 → 피싱 탐지 전체 흐름 오류 없이 통과
[ ] Claude API 호출 성공 (핫스팟 연결 상태에서 테스트)
[ ] 데모 예시 텍스트 앱 내 "예시 불러오기" 버튼으로 탑재 확인
[ ] 예비 데모 영상(docs/demo_video.mp4) 존재 여부 확인
```
