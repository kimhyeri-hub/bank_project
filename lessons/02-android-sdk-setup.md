# [환경설정] Android SDK 처음부터 설치하기 — release APK 빌드 막힘 해결

**발생일**: 2026-06-15
**영향 범위**: `flutter build apk --release`, 로컬 개발 환경 (Android Studio 미설치 상태)

---

## 증상

```
flutter build apk --release
```

실행 시:

```
No Android SDK found. Try setting the ANDROID_HOME environment variable.
```

`flutter doctor`에서도 Android toolchain 항목이 `[X]`로 표시. Android Studio를 설치한 적이
없어 SDK가 시스템 어디에도 존재하지 않는 상태였다.

---

## 원인 분석

Android Studio 없이 SDK만 설치하려면 Android **cmdline-tools**를 받아 `sdkmanager`로
필요한 패키지(`platform-tools`, `platforms;android-36`, `build-tools;36.0.0`)를 직접
설치해야 한다. 두 가지 막힘이 있었다:

1. **다운로드 URL을 신뢰할 수 없었다**: 검색으로 얻은 `commandlinetools-win-*_latest.zip`
   URL이 404를 반환. `dl.google.com/android/repository/`의 빌드 번호는 추측이 필요했고,
   `curl -sI`로 HEAD 요청을 보내 200을 반환하는 빌드 번호(13114758)를 직접 찾아야 했다.

2. **라이선스 동의 프롬프트가 PowerShell에서 먹히지 않았다**: `sdkmanager --licenses`는
   대화형으로 7개 라이선스에 `y`를 입력받는데, PowerShell에서
   ```powershell
   $yes = (("y`n") * 50); $yes | & "...\sdkmanager.bat" --licenses --sdk_root="C:\Android"
   ```
   처럼 파이프해도 "7 of 7 licenses not accepted"로 끝나고 멈췄다. `.bat` 파일이
   PowerShell의 표준입력 파이프를 제대로 받지 못하는 것으로 보인다.

---

## 해결

1. **다운로드 URL**: 알려진 빌드 번호 후보들을 `curl -sI`로 순서대로 확인해 200 응답이
   오는 것을 채택 (`commandlinetools-win-13114758_latest.zip`).

2. **라이선스 동의**: PowerShell 대신 **Bash 도구 + `cmd //c` + `yes`** 조합으로 해결.

   ```bash
   export ANDROID_HOME=/c/Android
   yes | cmd //c "C:\\Android\\cmdline-tools\\latest\\bin\\sdkmanager.bat" \
     --licenses --sdk_root="C:\\Android"
   ```

   - `cmd //c` (Git Bash에서 슬래시 2개) 로 `.bat`을 cmd.exe 컨텍스트에서 실행
   - `yes`로 무한히 `y`를 흘려보내 모든 라이선스 프롬프트를 통과
   - 결과: "All SDK package licenses accepted"

3. 이후 패키지 설치도 동일 패턴으로 진행:
   ```bash
   echo y | cmd //c "C:\\Android\\cmdline-tools\\latest\\bin\\sdkmanager.bat" \
     --sdk_root="C:\\Android" "platform-tools" "platforms;android-36" "build-tools;36.0.0"
   ```

4. `ANDROID_HOME`/`ANDROID_SDK_ROOT`를 사용자 환경변수로 영구 설정
   (`[Environment]::SetEnvironmentVariable(..., "User")`) 후
   `flutter config --android-sdk C:\Android` → `flutter doctor -v`에서
   Android toolchain `[√]` 확인.

---

## 교훈

1. **AI가 생성한 다운로드 URL은 그 자체로 신뢰하지 말고 `curl -sI`로 먼저 검증한다.**
   특히 빌드 번호처럼 추측성 숫자가 포함된 URL은 hallucination 가능성이 높다.

2. **`.bat`/대화형 CLI에 입력을 파이프할 때 PowerShell이 막히면 Git Bash의
   `cmd //c <경로>` + `yes`/`echo` 조합을 시도한다.** Windows에서 인터랙티브 설치
   스크립트를 비대화형으로 돌릴 때 재사용 가능한 패턴.

3. **환경변수는 현재 세션(`$env:`)과 영구 설정(`SetEnvironmentVariable ... "User"`)을
   모두 해줘야** 새 셀/재부팅 후에도 `flutter doctor`가 통과한다.
