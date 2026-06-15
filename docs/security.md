# docs/security.md — Guardian AI 보안 체크리스트

> 14주차 발표 Q&A 단골 질문 "보안은 어떻게 챙기셨나요?"에 대한 답변 자료.
> 항목별로 현재 구현 상태와 근거 코드를 정리합니다.

---

## 체크리스트

| 항목 | 상태 | 근거 |
|------|------|------|
| API 키가 코드에 하드코딩되어 있지 않은가 | ✅ | `lib/services/claude_service.dart`에서 `String.fromEnvironment('ANTHROPIC_API_KEY')`로 빌드 시점에 주입. 코드에 키 문자열 없음 |
| `.gitignore`에 `.env`, 인증서, keystore 포함 | ✅ | `.gitignore`에 `.env*`, `android/key.properties`, `*.keystore`, `*.jks` 추가 (`.env.*.example`만 예외) |
| 사용자 입력 검증 (XSS / SQLi / 경로 탈출) | ✅ | 로컬 DB·SQL 미사용(`shared_preferences`만 사용), 입력 텍스트는 `jsonEncode`로 이스케이프되어 Claude API에 전달. PDF는 바이트 배열로만 처리되어 파일 경로 입력 없음. URL 약관 분석은 입력 URL로 직접 네트워크 요청을 보내지 않고 데모 결과를 반환하므로 SSRF 위험 없음 |
| 통신 HTTPS 강제 | ✅ | `ClaudeService._baseUrl = 'https://api.anthropic.com/v1/messages'`. 코드 내 `http://` 호출 없음 (피싱 탐지 화면의 `http://bit.ly/...`는 데모용 예시 텍스트일 뿐 실제 요청 아님) |
| 로컬 저장 민감정보 암호화 | ⚠️ 미적용 | `lib/services/history_service.dart`가 분석 이력(`input`, `resultSummary`)을 `shared_preferences`에 평문 저장. 서버 전송은 없으나 기기 내 평문 저장 — 발표 시 "향후 개선 과제"로 안내 권장 (예: `flutter_secure_storage` 도입) |
| 로그에 비밀번호 / 토큰 출력 안됨 | ✅ | `lib/` 전체에 `print`/`debugPrint`로 키·토큰을 출력하는 코드 없음 (`grep -rn "print("` 결과 없음) |
| 권한 (카메라, 위치, 알림) 사유 명시 | ✅ N/A | `android/app/src/main/AndroidManifest.xml`에 카메라/위치/알림 등 추가 런타임 권한 요청 없음 (기본 `PROCESS_TEXT` 쿼리만 존재) |

---

## 알려진 한계 (발표 시 안내용)

1. **로컬 히스토리 평문 저장**: `HistoryService`는 분석 입력/결과 요약을 `SharedPreferences`에 평문으로 최대 20건 보관합니다.
   서버로 전송되지 않아 외부 유출 위험은 낮지만, 기기 자체가 탈취될 경우 노출될 수 있습니다.
   - 개선 방향: `flutter_secure_storage`(Keychain/Keystore 기반) 또는 SQLCipher로 전환
2. **Claude API 키 관리**: `--dart-define-from-file`로 빌드 시점에만 주입되며 앱 바이너리에는 포함되지만,
   APK 리버스 엔지니어링 시 추출 가능성은 일반적인 클라이언트 앱의 한계입니다 (서버 프록시 구조가 근본 해결책,
   본 프로젝트는 MVP 범위상 직접 호출 — `docs/architecture.md` ADR-0003 참고).

---

## 참고

- 환경변수/시크릿 관리: `docs/setup.md` §4, `docs/deploy.md` §6
- API 클라이언트 구현: `lib/services/claude_service.dart`
- 로컬 저장소 구현: `lib/services/history_service.dart`
