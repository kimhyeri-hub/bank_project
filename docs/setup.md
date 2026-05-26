# Setup — Guardian AI

> **절대 조건**: 이 문서만 보고 5분 안에 앱을 실행할 수 있어야 한다.

---

## 1. 사전 요구

| 도구 | 버전 | 확인 명령 |
|------|------|---------|
| Git | 2.40 이상 | `git --version` |
| Flutter | 3.x 이상 | `flutter --version` |
| Dart | Flutter에 포함 | `dart --version` |
| JDK | 17 이상 | `java -version` |
| Android Studio | 2023.x 이상 | — |
| Xcode | 15 이상 (macOS만) | `xcode-select -p` |

**한 번에 확인:**
```bash
flutter --version && dart --version && java -version && git --version
```

### 윈도우 설치

```powershell
# Flutter SDK
winget install Google.Flutter

# JDK 17
winget install EclipseAdoptium.Temurin.17.JDK

# Git
winget install Git.Git

# Android Studio
winget install Google.AndroidStudio
```

### macOS 설치

```bash
# Homebrew가 없으면 먼저 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Flutter
brew install --cask flutter

# JDK 17
brew install --cask temurin@17

# Android Studio
brew install --cask android-studio

# Xcode — App Store에서 설치 후
xcode-select --install
sudo xcodebuild -license accept
```

### 리눅스 (Ubuntu)

```bash
# Flutter 의존성
sudo apt update && sudo apt install -y curl git unzip xz-utils zip libglu1-mesa

# Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# JDK 17
sudo apt install -y openjdk-17-jdk

# Android Studio — 공식 사이트에서 .tar.gz 다운로드 후
tar -xvf android-studio-*.tar.gz -C ~/
~/android-studio/bin/studio.sh
```

---

## 2. 클론

```bash
git clone https://github.com/YOUR_USERNAME/guardian_ai.git
cd guardian_ai
```

---

## 3. 의존성 설치

```bash
flutter pub get
```

정상 완료 시 출력:
```
Resolving dependencies...
Got dependencies!
```

---

## 4. 환경변수 설정

`.env.example`을 복사해 `.env`를 생성합니다.  
`.env`는 `.gitignore`에 포함되어 있으므로 **절대 커밋하지 마세요.**

```bash
# macOS / Linux
cp .env.example .env

# 윈도우 (PowerShell)
Copy-Item .env.example .env
```

`.env.example` 내용:

```dotenv
# -----------------------------------------------
# Guardian AI 환경변수 설정
# 이 파일을 복사해 .env로 저장 후 값을 채우세요.
# .env는 절대 Git에 커밋하지 마세요.
# -----------------------------------------------

# [필수] Anthropic Claude API 키
# 발급: https://console.anthropic.com
CLAUDE_API_KEY=sk-ant-api03-여기에_본인_키_붙여넣기

# [필수] 사용할 Claude 모델명
CLAUDE_MODEL=claude-sonnet-4-20250514

# [선택] VirusTotal API 키
# 없으면 빈칸. 자체 패턴 매칭으로 대체됩니다.
# 발급: https://www.virustotal.com/gui/my-apikey
VIRUSTOTAL_API_KEY=
```

`.env`를 열어 `CLAUDE_API_KEY` 값만 본인 키로 교체하면 됩니다.

---

## 5. 첫 실행

### 연결된 기기 확인

```bash
flutter devices
```

출력 예시:
```
2 connected devices:
  sdk gphone64 (mobile) • emulator-5554 • android-x64
  iPhone 15 (mobile)    • 00008120-...  • ios
```

기기가 없으면:
- **Android**: Android Studio → Device Manager → Create Device
- **iOS (macOS)**: Xcode → Open Developer Tool → Simulator

### 앱 실행

```bash
flutter run
```

특정 기기 지정:
```bash
flutter run -d emulator-5554   # Android 에뮬레이터
flutter run -d 00008120-...    # iPhone 실기기
```

성공 시: 에뮬레이터에 Guardian AI 앱 화면이 표시됩니다. ✅

---

## 6. 자주 묻는 문제 (FAQ)

### Q1. `flutter: command not found` 가 나와요

Flutter SDK가 PATH에 등록되지 않은 상태입니다.

```bash
# macOS / Linux
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

# 윈도우 — 시스템 환경변수 > PATH에 Flutter\bin 경로 추가 후 터미널 재시작
```

### Q2. `ANDROID_HOME not set` 오류가 납니다

```bash
# macOS / Linux
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools' >> ~/.zshrc
source ~/.zshrc

# 윈도우 — 시스템 환경변수에서 ANDROID_HOME 직접 추가
# 값: C:\Users\{사용자명}\AppData\Local\Android\Sdk
```

### Q3. `CocoaPods not installed` 오류가 납니다 (macOS / iOS)

```bash
sudo gem install cocoapods
cd ios && pod install && cd ..
flutter run
```

### Q4. API 호출 시 `401 Unauthorized` 오류가 납니다

1. `.env` 파일이 프로젝트 루트에 있는지 확인
2. `CLAUDE_API_KEY` 값이 `sk-ant-api03-...` 형식인지 확인
3. 키 앞뒤에 공백·따옴표가 없는지 확인
4. https://console.anthropic.com 에서 키 만료 여부 확인

### Q5. `MissingPluginException` 오류가 납니다

```bash
flutter clean
flutter pub get
flutter run
```

그래도 안 되면 에뮬레이터 재시작 후 재시도.
