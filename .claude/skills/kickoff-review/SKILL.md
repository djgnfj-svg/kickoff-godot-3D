---
name: kickoff-review
description: 3D 게임(Godot 4) Kickoff how.md에 대한 3인(Architect/Implementer/QA) 리뷰 프로토콜. 각 리뷰어의 게임 전용 체크리스트, 리뷰 파일 포맷, 승인/재요청/거부 기준, 3라운드 재검토 흐름을 정의한다. "how.md 검증", "리뷰어 게이트", "Godot 기술 검토", "킥오프 리뷰", "아키텍처 검증", "구현 계획 리뷰", "QA 경계면 매트릭스" 요청에 트리거. 전원 APPROVED가 되어야 Feature Phase로 진행된다.
---

# Kickoff Review Protocol — 3D 게임 (Godot 4)

how.md 현실성을 3명이 병렬 검증하고, **전원 APPROVED**를 얻어야 다음 단계(Feature Spec)로 진행된다.

## 리뷰어 구성

| 리뷰어 | 관점 | 핵심 판단 |
|--------|-----|----------|
| **Architect** | Godot 기술 아키텍처 | 스택 정당성·씬 그래프·MCP capability·성능 타깃 |
| **Implementer** | 구현 & 일정 | Walking Skeleton·마일스톤 현실성·GDScript 학습·Steam 출시 |
| **QA** | 정합성 & 검증성 | 3문서 교차 일치·수용 기준·코어루프 기여·플레이테스트 시나리오 |

세부 체크리스트는 각 에이전트 `.md` 파일에도 있지만, 아래가 **이 스킬의 단일 진실원**이다.

## Architect 체크리스트 — 7항 + 거부 신호 4가지

### 7항 필수 체크
1. **Godot 버전 고정:** `4.x.y`까지 패치 레벨 명시 — 명시 안 됐으면 CHANGES_REQUESTED.
2. **렌더러 선택 근거:** Forward+ / Mobile / Compatibility 중 하나가 타깃 플랫폼·그래픽 품질 근거와 함께 명시.
3. **씬 그래프 고수준:** 루트 씬 + 주요 하위 씬 + Autoload 목록이 `godot-scene-handoff` 표준 레이아웃과 정합.
4. **InputMap:** 최소 코어 버브 액션이 정의됨. 키보드 + 게임패드 양쪽 매핑 포함.
5. **Physics Layers 번호 고정:** 최소 World/Player/Enemy/Hitbox 레이어에 번호 배정. 이후 drift 금지.
6. **MCP capability 의존:** `.claude/skills/godot-mcp-protocol/references/capability-matrix.md` 참조되고, 구현에 필요한 기능이 matrix에 있는지 확인. 없는 기능은 fallback 경로(headless/텍스트/사용자 위임) 명시.
7. **에셋 조달 + 성능 타깃:** `asset-pipeline` 4단계 폴백 명시 + 타깃 FPS(60/90/30) + 최소 하드웨어 사양.

### 거부 신호 4가지 (REJECTED 자동 트리거)
- "Unity/Unreal 이식 가능하게 설계" — 엔진 추상화는 범위 외
- **Autoload 5개 이상** — Godot 베스트 프랙티스 위반 (4개 이하 권장)
- **MVP에 멀티플레이** — 1플레이어 원형 위반 + 네트워크 레이어는 MVP 이후
- **"나중에 콘솔 이식"이 how에 가정됨** — 입력·렌더러·빌드 파이프라인이 다름, 범위 외

## Implementer 체크리스트 — 일정·역량·Walking Skeleton

### 필수 체크
1. **Walking Skeleton 정의:** M0의 "Walking Skeleton"이 **코어 버브 1회 수행 가능**으로 구체화되었는가? (primitive 에셋 허용)
2. **M1 코어루프 닫힘:** M1 완료 조건이 "4단계 루프(Anticipation→Action→Feedback→Progress) 한 사이클 완주 + TTFV 3분 이내 + smoke 통과"인가?
3. **에셋 스프린트 분리:** 에셋 작업이 게임 시스템 스프린트와 분리된 별도 스프린트로 계획되었는가? (에셋 병목으로 시스템 블로킹 방지)
4. **Godot MCP 갭 대응:** MCP가 못 하는 부분이 식별되고 fallback 시간이 일정에 반영되었는가?
5. **GDScript 학습 일정:** 팀에 GDScript 미경험자가 있으면 학습 기간과 목표 수준이 명시되었는가?
6. **성능 타깃 현실성:** 타깃 FPS가 씬 복잡도·타깃 하드웨어와 정합하는가? (예: 모바일 60fps + 동적 조명 다수는 비현실적)
7. **Steam 출시 일정 (해당 시):** Wishlist 오픈·Early Access·1.0 출시 날짜가 현실적인가? (최소 Wishlist 3~6개월 확보)

### Day 1~3 상상 경로
Implementer는 Generator가 **Day 1, Day 2, Day 3에 실제 수행할 작업**을 상상해 써본다. 경로가 막히거나 비현실적이면 how.md에 구체 지시가 부족한 것 → CHANGES_REQUESTED.

```
Day 1: {예: Godot 4.x 프로젝트 생성, InputMap 설정, smoke 씬 1개, headless 실행 성공}
Day 2: {예: 플레이어 CharacterBody3D + 기본 이동, 코어 버브 입력 액션 연결}
Day 3: {예: 코어 버브 1회 수행 가능한 primitive 타겟 배치, 피드백 1층(사운드 1)}
```

## QA 체크리스트 — 경계면 매트릭스

QA는 why/what/how 3문서 교차 일관성을 **경계면 매트릭스**로 검증. 게임 전용 5행이 메인.

| 경계면 | why.md | what.md | how.md | 일치? |
|--------|--------|---------|--------|-------|
| **플레이어 원형** | 1원형 정의 | 대상 유저 | 타깃 입력 가정·플랫폼 | Y/N |
| **코어 결핍 ↔ 코어 버브** | 감정 1개 | 동사 1개 | 구현 의도 정합 | Y/N |
| **코어루프 지탱** | 루프 가설 | Feature별 단계 기여 | 마일스톤 M1 루프 닫힘 | Y/N |
| **플랫폼** | MVP 플랫폼 | 플랫폼 정보 | 렌더러·빌드 타깃 | Y/N |
| **장르** | 장르 선언 | 장르 + 서브장르 | 씬 구조·시스템 복잡도 | Y/N |

### 게임 추가 체크 (모두 Y 여야 APPROVED)
- [ ] **모든 Feature가 코어루프 4단계 중 하나 이상 지탱** (what.md 각 F에 체크 표시)
- [ ] **M0 완료 조건에 "코어 버브 1회 수행 가능" 문구 포함** (how.md 마일스톤 표)
- [ ] **플레이테스트 시나리오 3개가 플레이어 원형과 정합** (TTFV 시나리오 · 실패 회복 · 세션 엔드 모두 원형이 90분 세션 중 실제 겪을 상황)
- [ ] **North Star 지표가 게임 지표** (다운로드 수 / Retention / Session Length / Review Score / Wishlist Conversion 중 하나 + 숫자 목표)
- [ ] **Godot MCP 명시:** capability matrix 파일 경로가 how.md에 참조됨 + 갭 리포트 디렉토리 참조
- [ ] **에셋 정책 4단계 모두 명시:** primitive → 무료 라이브러리 → AI → 사용자 위임

### 거부 신호 3가지 (REJECTED 자동 트리거)
- **튜토리얼이 M0에 먼저 등장** — 코어 버브가 M0인데 튜토리얼이 먼저? 순서 역전 → 게임이 뭔지 모르는 상태에서 튜토리얼 먼저 만듦
- **M0가 "스캐폴딩"으로만 기술됨** — "프로젝트 구조 설정 + Autoload 정의"만 있고 코어 버브 수행 누락 → Walking Skeleton 아님
- **관측성 빠짐** — TTFV·VPM·Loop Duration·Session Length 등 게임 지표 수집 방법이 how.md에 없음

## 승인 상태 3단계

- **APPROVED**: 모든 체크리스트 통과. 추가 제안은 있을 수 있으나 차단 요소 없음.
- **CHANGES_REQUESTED**: 본질적 결함은 없으나 구체 수정 필요. 개선 후 재리뷰.
- **REJECTED**: 본질적 결함 또는 거부 신호 트리거. 문서를 크게 다시 쓰거나 why/what부터 재검토.

## 리뷰 파일 포맷

각 리뷰어는 `docs/kickoff/reviews/{architect|implementer|qa}.md`를 다음 구조로 작성.

```markdown
**프로젝트 종류:** 3D 게임 (Godot 4)

# {Role} Review — Round {N}

**Status:** APPROVED | CHANGES_REQUESTED | REJECTED
**Date:** YYYY-MM-DD
**Round:** {1, 2, 3 ...}

## 체크리스트 결과
- [x] / [ ] 항목 1 — 간단 코멘트
- [x] / [ ] 항목 2
...

## 거부 신호 점검 (해당 리뷰어의 신호 목록)
- [x] / [ ] ... (트리거된 게 있으면 REJECTED)

## 상세 피드백
### 강점
- ...

### 차단 이슈 (REJECTED 사유)
1. ...

### 개선 요구 (CHANGES_REQUESTED)
1. {무엇을, 어디를, 왜 바꿔야 하는지}
2. ...

### 대안 제안
- ...

## Day 1~3 상상 경로 (Implementer만 해당)
Day 1: ...
Day 2: ...
Day 3: ...

## 경계면 매트릭스 (QA만 해당)
| 경계면 | why | what | how | 일치? |
|--------|-----|------|-----|-------|
| ... | ... | ... | ... | Y/N |

## 이전 라운드 피드백 반영 여부 (Round ≥ 2)
| 이전 피드백 | 반영 상태 | 코멘트 |
|-----------|----------|-------|
| ... | Yes / Partial / No | ... |
```

## 게이트 판정

```
전원 APPROVED → Feature Phase(feature-spec)로 진행
하나라도 CHANGES_REQUESTED → Kickoff 팀 재소집, how.md 수정 후 재리뷰
하나라도 REJECTED → Kickoff 팀 재소집, why 또는 what부터 재검토 가능
```

## 재리뷰 라운드 제한

**최대 3라운드**. 초과 시 다음 중 하나를 사용자에게 요청:
1. 범위를 더 줄일 것인가? (Niche Enforcer 재소집)
2. 리뷰어 판단을 일부 무시하고 진행할 것인가? (위험 기록 후 진행)
3. 킥오프를 중단할 것인가?

## 리뷰어 간 충돌 처리

서로 다른 리뷰어가 상충하는 요구를 낼 수 있다 (예: Architect는 "Autoload 줄여라", Implementer는 "상태 관리 싱글톤 늘려라"). 이 경우:
1. 각 리뷰어가 상대의 요구에 대한 **재코멘트**를 자신의 리뷰 파일에 추가.
2. 해결 안 되면 Founder가 결정하고, 결정 근거를 how.md의 "Open Questions"에 기록.
3. 결정된 방향이 다른 리뷰어의 `REJECTED` 사유였다면, 해당 리뷰어는 `CHANGES_REQUESTED + 조건부 승인`으로 전환 가능.

## 병렬 실행 규칙

3명은 반드시 **병렬**로 리뷰를 시작. 서로의 결과를 보기 전에 독립 판정. 이후에만 `SendMessage`로 상호 비교·재코멘트.

## 증분 검증 (Incremental QA)

QA 에이전트는 Phase A의 각 산출물(why → what → how)이 생성될 때마다 즉시 경계면 교차 검증을 실행할 수 있다 (선택적). how.md가 완성될 때까지 기다리지 않고 미리 불일치를 잡으면 재작업 비용이 줄어든다.
