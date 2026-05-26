# ADR-0003: 백엔드 아키텍처 선택 — 자체 서버 없이 Claude API 직접 호출

- 상태: Accepted
- 날짜: 2026-05-19
- 결정자: Guardian AI 개발자

## 배경

Guardian AI의 핵심 기능(PII 보조 인식, 약관 분석, 피싱 문맥 분석)은 AI 처리가 필요하다.  
이 처리를 어디서 수행할 것인가 — 클라이언트 직접 호출, 자체 백엔드 경유, BaaS(Firebase 등) 활용 —  
에 따라 개발 복잡도, 보안, 비용 구조가 달라진다.

## 고려한 대안

### 대안 A: Flutter에서 Claude API 직접 호출 (서버리스)
- 장점:
  - 백엔드 서버 개발·운영 불필요 → 6주 일정 내 현실적
  - 인프라 비용 없음 (Claude API 사용량 비용만 발생)
  - 아키텍처 단순 → 디버깅 용이
  - 사용자 데이터가 자체 서버를 거치지 않음 → Privacy First 원칙 부합
- 단점:
  - API 키가 클라이언트 앱에 존재 → 탈취 위험 (난독화 + Secure Storage로 완화)
  - API 호출 횟수·비용 제어를 서버에서 할 수 없음
  - 향후 기능 확장(사용자 계정, 서버 사이드 로직) 시 백엔드 추가 필요

### 대안 B: 자체 백엔드 서버 (Node.js / FastAPI) + Claude API
- 장점:
  - API 키가 서버에만 존재 → 보안 우수
  - 호출 횟수·비용 서버에서 통제 가능
  - 사용자별 분석 히스토리 서버 저장 가능
- 단점:
  - 백엔드 개발·배포·운영에 추가 2~3주 소요 → 6주 일정 초과
  - 서버 호스팅 비용 발생 (무료 티어: Railway, Render 등)
  - 무료 티어 슬립 모드로 인한 응답 지연 (콜드 스타트 30초+)
  - 1인 프로젝트에서 프론트 + 백엔드 동시 개발은 품질 저하 위험

### 대안 C: Firebase (Firestore + Cloud Functions)
- 장점:
  - Cloud Functions에서 Claude API 호출 → API 키 서버 보관
  - Firestore로 분석 히스토리 클라우드 저장 가능
  - Firebase 무료 Spark 플랜으로 MVP 운영 가능
- 단점:
  - Firebase 학습 비용 (Flutter + Firebase 연동, Cloud Functions 배포)
  - Cloud Functions 콜드 스타트 지연
  - 사용자 데이터가 Google 서버에 저장됨 → Privacy First 원칙과 상충
  - Firestore 쿼리 과금 구조 예측 어려움

### 대안 D: Supabase
- 장점:
  - PostgreSQL 기반 오픈소스 Firebase 대안
  - Edge Functions에서 Claude API 호출 가능
- 단점:
  - Flutter SDK 성숙도가 Firebase 대비 낮음
  - 국내 레퍼런스 부족 → 문제 발생 시 해결 시간 증가
  - 대안 C와 동일한 Privacy 문제

## 결정

**대안 A: Flutter에서 Claude API 직접 호출**을 선택한다.

## 이유

- 6주 일정에서 백엔드 개발에 시간을 투자하면 핵심 기능(PII / 약관 / 피싱) 완성도가 낮아진다. Must Have 3개 기능의 완성이 최우선
- Guardian AI의 핵심 가치 "Privacy First"는 사용자 원문 데이터를 자체 서버에 저장하지 않는 것을 명시하고 있다. 직접 호출 방식이 이 원칙과 가장 잘 맞음
- API 키 보안 위험은 `flutter_secure_storage` + 앱 난독화(`--obfuscate`)로 졸업 작품 수준에서 충분히 완화 가능
- 분석 히스토리는 SQLite 로컬 DB로 저장하여 서버 없이도 요구사항(F-HIST-001) 충족 가능

## 결과 (예상되는 영향)

긍정:
- 백엔드 개발·운영 제거 → 전체 개발 시간의 30~40%를 핵심 기능에 집중 투자
- 인프라 비용 0원 (Claude API 사용량 비용만)
- 아키텍처 단순 → 발표 Q&A에서 전체 흐름 설명 용이

부정 / 제약:
- API 키 클라이언트 노출 위험 → `flutter_secure_storage` 저장 + `--obfuscate` 빌드 필수
- 일일 API 호출 한도를 앱 내에서 자체 제어해야 함 → `cache_service.dart`로 중복 호출 방지
- 향후 사용자 계정·서버 기능 추가 시 백엔드 신규 개발 필요 (MVP 이후 단계)

## 후속 작업

- [ ] `flutter_secure_storage` 패키지 추가 및 API 키 저장 로직 구현
- [ ] `.env` 파일 `.gitignore` 등록 확인
- [ ] `claude_client.dart` 공통 HTTP 클라이언트 구현 (재시도 로직 포함)
- [ ] `cache_service.dart` 입력 해시 기반 응답 캐싱 구현
- [ ] Release 빌드 시 `--obfuscate --split-debug-info` 옵션 적용 확인
