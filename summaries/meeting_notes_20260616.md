# 회의록 / 결정사항 요약
> 생성: 2026-06-16 00:08


## AGENTS.md

**Line 26:**
```
- `docs/architecture.md` — 레이어 구조(Presentation/Services 2계층), 데이터 흐름, 의존 방향 규칙
- `.planning/decisions/` — ADR 5건
  - ADR-0001 모바일 프레임워크: Flutter
  - ADR-0002 상태 관리: setState (Provider는 검토 후 MVP 범위에서 보류 — 추가 노트 참고)
```


## README.md

**Line 106:**
```

레이어 구조, 데이터 흐름, 핵심 의사결정은 [`docs/architecture.md`](docs/architecture.md) 참고.

<br>
```


## docs/07-directory-structure.md

**Line 90:**
```

*연관 문서: `docs/architecture.md` (레이어/데이터 흐름 상세), `.planning/decisions/ADR-0002-state-management.md` (상태 관리 결정 근거)*
```


## docs/architecture.md

**Line 130:**
```

## 핵심 의사결정 요약

| 결정 | 선택 | 이유 | ADR |
```

**Line 132:**
```

| 결정 | 선택 | 이유 | ADR |
|------|------|------|-----|
| 모바일 플랫폼 | Flutter | 1인 + 6주, Android/iOS 동시 지원 | ADR-0001 |
```


## docs/presentation/qna.md

**Line 11:**
```

**Q1. ADR이 몇 개이고, 각각 무엇을 결정했나요?**
총 5개입니다 (`.planning/decisions/`).
ADR-0001 모바일 프레임워크(Flutter), ADR-0002 상태관리(Provider),
```

**Line 12:**
```
**Q1. ADR이 몇 개이고, 각각 무엇을 결정했나요?**
총 5개입니다 (`.planning/decisions/`).
ADR-0001 모바일 프레임워크(Flutter), ADR-0002 상태관리(Provider),
ADR-0003 백엔드(없음, Claude API 직접 호출), ADR-0004 인증(없음, 로컬 전용),
```


## docs/presentation/script.md

**Line 85:**
```

> "핵심 결정 5가지를 ADR로 남겼습니다.
> 첫째, **모바일 프레임워크는 Flutter** — 1인 개발 + 6주 안에 Android/iOS
> 동시 지원이 필요해서입니다.
```
