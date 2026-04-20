---
name: kickoff-orchestrator
description: 3D 게임(Godot 4) Kickoff에서 why.md / what.md / how.md 3개 문서와 Feature별 feature-spec.md를 생성하는 전체 워크플로우. 사용자가 "킥오프", "게임 기획", "why/what/how", "아이디어를 문서로", "제품 정의", "초기 기획 문서", "킥오프 다시/재실행/수정/보완", "Feature 스펙 추가", "경쟁사 리서치 포함 킥오프" 등을 요청하거나, 새 게임 아이디어를 제시하며 체계적 문서화를 원할 때 반드시 이 스킬을 사용한다. Phase A는 토론 중심(7인 팀, 토픽별 사이클 3회, 각 사이클 5단계)으로 진행한다.
---

# Kickoff Orchestrator (3D 게임 전용)

3D 게임(Godot 4) Kickoff 단계에서 3개 핵심 문서(why/what/how)와 Feature별 상세 스펙을 생성하는 오케스트레이터.

## 아키텍처
**하이브리드 실행 모드:**
- **Phase A (Kickoff):** 에이전트 팀 7인 — **토론 중심** (Founder 중재, Niche Enforcer veto)
- **Phase B (Review):** 에이전트 팀 3인 — 생성-검증 (전원 승인 게이트, Kickoff 팀 해체 후 재구성)
- **Phase C (Feature Specs):** 서브 에이전트 병렬 — Feature마다 Superpowers `brainstorming` 스킬로 독립 실행

## 산출물
- `docs/kickoff/why.md`
- `docs/kickoff/what.md`
- `docs/kickoff/how.md`
- `docs/kickoff/reviews/architect.md`
- `docs/kickoff/reviews/implementer.md`
- `docs/kickoff/reviews/qa.md`
- `docs/features/F{N}/feature-spec.md` (Feature 수만큼)
- `docs/kickoff/_workspace/` (중간 산출물, 감사 추적용 보존)

---

## Phase 0: 컨텍스트 확인

워크플로우 시작 시 기존 산출물을 확인한다.

1. `docs/kickoff/` 디렉토리 존재 여부 확인
2. 실행 모드 판별:
   - **초기 실행:** `docs/kickoff/` 없음 → 새로 시작
   - **부분 재실행:** 기존 산출물 + 사용자가 특정 문서 수정 요청 (예: "how만 다시") → 해당 Phase만 재실행, 이전 `_workspace/`는 참조용으로 유지
   - **새 실행 (덮어쓰기):** 기존 산출물 + 사용자가 새 아이디어 제공 → 기존 `_workspace/`를 `_workspace_prev/`로 이동, 최종 문서는 `docs/kickoff/archive/{timestamp}/`로 백업
3. 사용자에게 감지된 실행 모드를 1줄로 보고하고 진행한다.

**프로젝트 고정 가정:** 이 하네스는 3D 게임(Godot 4) 전용이다. 모든 문서 첫 줄에 `**프로젝트 종류:** 3D 게임 (Godot 4)` 명시.

## Phase 1: 사용자 입력 수집 — **순차 확정 원칙**

**절대 한 번에 여러 요소를 묻지 않는다.** 1플레이어 원형 → 1코어 결핍 → 1코어 버브 순서로 하나씩 질문하고, 각 요소가 확정된 뒤에야 다음으로 넘어간다. 한 항목 확정 = 사용자가 "그래, 그걸로 진행해"라고 명시 동의.

**Phase 1은 무거워도 된다.** 기획 품질이 속도보다 우선.

### Step 1-0: 아이디어 상태 분기

Founder가 먼저 사용자 상태를 묻는다.

```
질문: "지금 아이디어가 어느 단계인가요?"

A. 한 줄로 설명할 수 있다 (예: "도끼 하나로 거대 보스를 베는 소울라이크")
B. 장르/분위기만 정해졌다 (예: "3인칭 액션 뭔가 만들고 싶다")
C. 아직 백지다 (만들고 싶다는 의욕만 있다)
```

- **A 경로:** Step 1-1 진행 + Game Market Researcher를 `run_in_background: true`로 스폰 (선행 모드).
- **B 경로:** GMR을 **포어그라운드**로 호출 (도메인 탐색 모드). 해당 장르의 최근 트렌드·gap·기회 후보 3~5개 → `_workspace/domain_scan.md`. Founder가 ⭐ 추천 1~2개(근거 포함) + 나머지 장단점 한 줄 포맷으로 사용자에게 제시. 사용자 선택 후 Step 1-1에서 한 줄로 재진술.
- **C 경로:** Founder가 Discovery 질문 2~3라운드 (직업/루틴·최근 재밌게 한 게임·좋아하는 순간·친구에게 추천한 게임). 답변은 원문 그대로 `_workspace/discovery_notes.md`에 누적. seed 3~5개 모이면 GMR 호출(seed 검증 모드). Founder가 유망 seed 2~3개 추천 → 사용자 선택 후 Step 1-1에서 한 줄 재진술.

**수렴점:** Step 1-0은 최종적으로 사용자가 쓴 **한 줄 아이디어 원문**을 Step 1-1에 넘긴다.

### Step 1-1: 게임 아이디어 한 줄
**사용자 원문 그대로** `_workspace/idea_raw.md`에 기록. Founder는 해석·구체화·재진술 금지. 입력이 여러 줄/여러 아이디어면 "한 줄로 줄여 주세요"만 요청. A 경로에서 GMR 선행 스폰이 안 됐으면 지금 스폰.

### 공통 원칙 (Step 1-2 ~ 1-5)
- **질문은 백지로 묻지 않는다.** Founder가 **후보 예시 5~10개**를 리스트로 제시한 뒤 사용자가 고르거나 자유롭게 쓰도록.
- **예시는 선택지이지 유도가 아니다.** 사용자가 예시 중 어느 것도 고르지 않고 "이것 말고 X"라고 써도 그대로 수용.
- **사용자 답변 원문 그대로** `confirmed_*.md`에 기록.
- 규칙 위반(원형 2개·결핍 2개·버브 2개+)일 때만 Niche Enforcer가 "어느 쪽?"을 되묻는다.

### 예시 리스트업 원칙 (Founder 담당)
- 5~10개의 서로 다른 축 커버
- 각 예시는 구체적·측정 가능
- **추천·장단점 포맷 (A+B 혼합, 의무):**
  - **⭐ 추천 1~2개**: GMR 데이터 근거 1줄 첨부
  - **나머지 예시**: 중립 나열, 각각 **장점 한 줄 / 단점 한 줄**
  - **추천 강제 아님**: 하단에 "추천은 참고용입니다. 끌리는 다른 방향을 쓰셔도 됩니다"
  - **GMR 데이터 없을 때**: "⭐ 없음 — 근거 부족으로 중립 나열"로 표시, 억지 추천 금지

### Step 1-2: 1플레이어 원형 확정
```
질문: "이 게임을 90분 동안 실제로 플레이할 구체 인물 1명은 누구인가요?"

후보 예시 (연령·세션 길이·플랫폼·게임 경험 조합):
⭐ 1. {예: 30대 퇴근 90분 Steam 소울라이크 플레이어}
   근거: {GMR §N 리뷰 불만 패턴에서 반복되는 segment}
  2. 20대 주말 4시간 Steam FPS 플레이어 — 장점: / 단점:
  3. ...
```
- 답변 원문 기록 → Niche Enforcer 1원형 판정 → `_workspace/confirmed_archetype.md`.

### Step 1-3: 1코어 결핍 확정
```
질문: "이 원형이 현 시장에서 채우지 못하는 감정 1개는?"

후보 예시 (감정적 결핍):
⭐ 1. 긴장 해소 — 근거: {리뷰 불만 패턴}
  2. 탐험 충동 — 장점: / 단점:
  3. 성취감 / 4. 사회적 연결 / 5. 이완 / 6. 표현 욕구 / ...
```
- 답변 원문 기록 → Niche Enforcer 1결핍 판정 → `_workspace/confirmed_lack.md`.

### Step 1-4: 1코어 버브 확정
```
질문: "플레이어가 가장 자주 하는 동사 1개는?"

후보 예시:
⭐ 1. 베어낸다 — 근거: {경쟁작 코어 버브 역공학}
  2. 쏜다 / 3. 탐험한다 / 4. 짓는다 / 5. 피한다 / 6. 수집한다 / 7. 대화한다 / ...
```
- 답변 원문 기록 → Niche Enforcer 1버브 판정 (2개+ 거부) → `_workspace/confirmed_verb.md`.
- 60분/100회+ 테스트 질문: "이 버브를 60분 동안 100회 이상 반복해도 질리지 않을 근거?"
- 3분 내 경험 가능성(TTFV) 검증.

### Step 1-5: 게임 메타 확정 (한 번에 하나씩)
- **1-5-1. 장르 1개** — SteamDB 태그 기준 상위 장르 1개 (세부 장르 조합 X)
- **1-5-2. 플랫폼 1개 (MVP)** — Steam 기본. 다른 플랫폼은 2개 선택 시 Niche Enforcer 거부
- **1-5-3. 시점/카메라** — 1인칭 / 3인칭 / 탑다운 / 쿼터뷰 / 사이드뷰 중 1개
- **1-5-4. 예상 플레이 시간** — 10h 이하 / 10~30h / 30h+
- **1-5-5. 멀티 여부** — 기본값: 솔로 전용. 멀티 추가 시 Niche Enforcer 거부 기본

각 단계 답변 원문 → `_workspace/confirmed_meta.md`.

### 입력이 너무 추상적일 때
"재밌는 게임 만들고 싶어" 수준이면 Step 1-2로 바로 진입하지 않고 Step 1-0 C 경로로 우회.

### 금지 사항
- **3요소(원형/결핍/버브)를 한 번의 메시지로 묻지 않는다.**
- **한 요소 확정 전에 다음 요소를 논의하지 않는다.**
- **Founder/Scribe가 확정되지 않은 요소를 초안에 채우지 않는다.**

---

## Phase A: Kickoff 팀 실행 (토론 중심)

**실행 모드:** 에이전트 팀 7인 — 순차 릴레이 아님, **토론 사이클 3회** (why / what / how 각각)

### A-1. 팀 생성
`TeamCreate`로 팀 `kickoff-team`을 구성. 팀원:
- `founder` (리더·중재)
- `game-market-researcher` (GMR, 데이터 공급)
- `core-mechanic-designer` (CMD, 메커닉 깊이)
- `hook-strategist` (HMS, 훅·세일즈 비주얼)
- `sellability-auditor` (SA, 정량 감사 + Pre-mortem)
- `niche-enforcer` (옵저버·veto)
- `scribe` (기록·문서화)

모든 Agent 호출에 `model: "opus"` 명시.

### A-2. 데이터 깔기 (사이클 진입 전 1회)

**[GMR]** 본 모드로 `confirmed_{archetype,lack,verb,meta}.md` 기반 경쟁사·대체재·시장 데이터 수집 → `_workspace/research_memo.md` (`competitor-research` 스킬 게임 프로토콜 사용). 3축(직접/간접/대체재) + 코어 버브 역공학(플레이 영상 시청 필수) + 리뷰 불만 패턴.

### A-3. 토론 사이클 3회 (why → what → how)

**각 사이클 = 5단계.** 한 토픽(why/what/how)에 대해 아래 5단계를 순차 실행하고 다음 토픽으로 넘어간다.

#### 사이클 구조 (매 토픽 동일)

**단계 1 — 1차 발화 (병렬)**
- CMD·HMS·SA 각각 자기 관점에서 1차 의견을 `_workspace/{topic}_r1_{agent}.md`로 제출
  - why 사이클: CMD = "왜 이 버브가 깊어지는가", HMS = "왜 이 게임이 첫인상에서 이기는가", SA = "왜 이 가격에 팔리는가"
  - what 사이클: CMD = "어떤 메커니즘이 필요한가 (Feature 후보)", HMS = "어떤 비주얼 프루프가 필요한가 (Feature 후보)", SA = "어떤 요소가 Refund 방어/Review Score에 필수인가"
  - how 사이클: CMD = "구현 리스크/깊이 최소 구현", HMS = "마케팅 자산 생산 일정", SA = "가격·Wishlist·런칭 체크리스트"
- GMR은 발화 없음. 요청받으면 데이터 추가만.

**단계 2 — 충돌 1회차 (자유 토론)**
- `SendMessage`로 3명이 서로 반박. Founder가 중재.
- **자유 토론**: 누구든 누구에게나 반박 가능. 단 "근거 1줄" 의무.
- 반박 내용은 `_workspace/{topic}_r2_debate.md`에 누적 기록 (Scribe 초기 기록자 역할).
- Niche Enforcer는 옵저버로 관찰, 범위 위반 감지 시 즉시 발화(veto 권한은 단계 4로 보류).
- **종료 조건:** 각자 반박 최소 1회 발화 OR 15분/6턴 경과.

**단계 3 — 충돌 2회차 (재반박·방어)**
- 단계 2에서 제기된 반박에 대해 피고(반박 대상)가 방어.
- 방어 불가능이면 해당 주장 철회 또는 Open Question으로 보존.
- Founder가 "남은 쟁점 N개"를 정리하며 단계 4로 넘김.
- 기록은 `_workspace/{topic}_r3_defense.md`.

**단계 4 — 수렴 (Niche veto + Founder 중재)**
- Niche Enforcer가 최종 발화: APPROVED / REJECTED / CHANGES_REQUESTED.
- REJECTED면 Founder가 축소 재협상 → 최대 2회 재시도. 3회 실패 시 사용자 에스컬레이션.
- APPROVED되면 Founder가 합의문 1문단 작성 → `_workspace/{topic}_r4_consensus.md`.

**단계 5 — 문서화**
- Scribe가 합의문 + 미합의(Open Questions) + Risks(SA 제출)를 `kickoff-docs` 스킬 템플릿에 맞춰 `docs/kickoff/{topic}.md`로 작성.
- 각 문장에 `## 근거 (Sources)` 각주 링크 포함 (GMR의 research_memo.md §N 역참조).

### A-4. 사이클 간 이행

한 사이클(예: why) 완료 후 다음 사이클(예: what)로 넘어간다. 앞 사이클의 합의문(`{topic}_r4_consensus.md`)은 다음 사이클의 입력 컨텍스트.

**재협상 제한:** 뒤 사이클에서 앞 사이클을 뒤집고 싶으면, Founder가 "앞 사이클 롤백 요청"을 발의. Niche Enforcer가 동의하면 해당 사이클만 재실행. 이유 없이 무한 롤백 금지.

### A-5. 팀 해체
모든 산출물(`why.md`, `what.md`, `how.md`)이 `docs/kickoff/` 하위에 저장되면 `TeamDelete`.

### Niche Enforcer 거부 처리
- 단계 4에서 Niche가 REJECTED하면 해당 토픽은 확정되지 않는다.
- Founder가 "무엇을 뺄 것인가"만 재협상. 최대 2회 재시도.
- 3회 실패 시 why.md의 "Open Questions" 섹션에 기록하고 사용자에게 에스컬레이트.

> 문서 템플릿: `kickoff-docs`. 범위 판정: `niche-enforcement`. 메커닉 분해: `game-design-loop` (CMD). 훅 설계: `hook-design-protocol` (HMS). 세일즈 감사: `sellability-audit-protocol` (SA). 리서치: `competitor-research` (GMR).

---

## Phase B: Reviewer 팀 실행 (how.md 검증)

**실행 모드:** 에이전트 팀 (Kickoff 팀 해체 후 새 팀)

### B-1. 팀 생성
`TeamCreate`로 팀 `reviewer-team`:
- `architect`
- `implementer`
- `qa`

### B-2. 작업 할당
3명이 **병렬로** `how.md`를 독립 검토. 각자 `docs/kickoff/reviews/{name}.md`에 `APPROVED / CHANGES_REQUESTED / REJECTED` 상태와 상세 의견 기록. QA는 why/what/how 3개를 동시에 읽고 교차 검증.

### B-3. 승인 게이트
- **전원 `APPROVED`** → Phase C 진행.
- **하나라도 `CHANGES_REQUESTED` 또는 `REJECTED`** →
  1. Reviewer 팀 해체.
  2. Kickoff 팀(또는 최소 인원: founder + scribe + niche-enforcer + 관련 전문가)을 재구성하여 리뷰 피드백 반영.
  3. `how.md` 재작성 후 Phase B 재시작.
  4. **최대 3라운드**. 초과 시 사용자 결정 요청.

### B-4. 팀 해체
승인 완료 후 `TeamDelete`.

> 리뷰 프로토콜: `kickoff-review` 스킬.

---

## Phase C: Feature Spec 생성 (서브 에이전트 병렬)

**실행 모드:** 서브 에이전트 (팀 불필요, 각 Feature 독립)

### C-1. Feature 목록 추출
`what.md`의 "Features" 섹션 파싱 → F1, F2, ... 순번 부여.

### C-2. 병렬 브레인스토밍
각 Feature F{N}마다:
1. `Agent`로 `general-purpose` 서브 에이전트를 `run_in_background: true`로 스폰.
2. 프롬프트: `feature-spec` 스킬 사용 + Superpowers `brainstorming` 스킬 내부 호출, 결과를 `docs/features/F{N}/feature-spec.md`로 저장.
3. 최대 동시 실행 **3개**. Feature가 더 많으면 배치로.

### C-3. 결과 수집
모든 서브 에이전트 완료 후, 생성된 `feature-spec.md` 목록을 사용자에게 보고.

> Feature 스펙 템플릿: `feature-spec` 스킬.

---

## Phase D: 최종 정리 및 피드백

1. 산출물 체크리스트:
   - `docs/kickoff/why.md`, `what.md`, `how.md` 첫 줄 `**프로젝트 종류:** 3D 게임 (Godot 4)` 존재
   - why의 플레이어 원형 = what의 대상 = how의 타깃 플랫폼/입력 가정인가
   - what의 F1이 코어루프를 닫는 스프린트로 매핑 가능한가
   - how의 M0가 "코어 버브 1회 수행"을 포함하는가
   - `docs/kickoff/reviews/` 3개 파일 전원 `APPROVED`
   - `docs/features/F*/feature-spec.md` 수 = what.md의 Feature 수
2. 사용자에게 산출물 요약 3~5줄 보고.
3. 피드백 요청: "결과 중 개선하고 싶은 부분이 있나요?"
4. 피드백 있으면 하네스 진화 경로. 없으면 종료.

---

## 데이터 전달 프로토콜

| 전략 | 적용 |
|------|------|
| 태스크 기반 | Phase A/B 내 팀 조율 |
| 메시지 기반 | Phase A 토론 사이클 내 실시간 반박/방어 |
| 파일 기반 | `_workspace/` 중간 산출물, `docs/kickoff/` 최종, `docs/features/` |
| 반환값 기반 | Phase C 서브 에이전트 결과 |

파일명 컨벤션 (`_workspace/`):
- `idea_raw.md`, `discovery_notes.md`, `domain_scan.md`, `seed_scan.md`
- `confirmed_{archetype,lack,verb,meta}.md`
- `research_memo.md`, `mechanic_memo.md`, `hook_memo.md`, `sellability_memo.md`
- `{topic}_r1_{agent}.md` (토픽 × 에이전트 1차 발화)
- `{topic}_r2_debate.md` (충돌 1회차)
- `{topic}_r3_defense.md` (충돌 2회차)
- `{topic}_r4_consensus.md` (수렴 합의문)

## 에러 핸들링

| 상황 | 대응 |
|------|------|
| Niche Enforcer 3회 연속 거부 | 사용자 에스컬레이트, 범위 축소 제안 목록 제시 |
| Reviewer 3라운드 초과 | 사용자 결정 요청. 미결 이슈를 `docs/kickoff/open_issues.md`에 기록 |
| Feature 서브 에이전트 실패 | 1회 재시도. 재실패 시 `docs/features/F{N}/FAILED.md`로 표시 |
| 토론 단계 2에서 15분/6턴 경과 | Founder가 강제 종료, 남은 반박은 단계 3으로 넘김 |
| CMD·HMS 합의 불가 (5초층 비주얼 프루프) | Hook Strategist가 "훅 실패 선언" → 게임 컨셉 재검토 / Phase 1 롤백 제안 |
| SA Pre-mortem 3개 모두 방어 불가 | Founder가 게임 컨셉 재검토 선언 |

## 테스트 시나리오

### 정상 흐름
입력: "도끼 하나로 거대 보스를 베는 소울라이크, 퇴근 후 90분 세션"
기대:
1. Phase 1: Niche Enforcer가 "도끼+방패+활"을 "도끼만"으로 축소 요구 가능 → Founder 수용.
2. Phase A: 
   - why 사이클 — CMD "베기 깊이 = 타이밍/위치/무게감 3축", HMS "5초에 도끼가 어깨에서 내려오며 지면 박힘", SA "15$ 범주, Wishlist 8천 목표". 충돌: HMS "깊이가 영상에 안 보임" → CMD "슬로모 리플레이 인스턴트 재생으로 해결".
   - what 사이클 — Feature: 베기 시스템 / 보스 만남 / 죽음과 복귀 / 장착 교체. Niche가 "장착 교체"를 보류(코어 버브와 직결성 약함).
   - how 사이클 — Godot 4.x, 3인칭, M0 = 더미 적 베기 1회, M1 = 첫 보스.
3. Phase B: 3인 리뷰 전원 APPROVED까지 1~2라운드.
4. Phase C: Feature 3~4개 feature-spec.md 생성.

### 에러 흐름
입력: "소울라이크 + 도시 빌더 + 로그라이크 + 생존 멀티 MMORPG"
기대:
1. Phase 1: Niche Enforcer 즉시 거부 (장르 5중 + 멀티 + 장르 혼합).
2. Founder "코어 버브 1개 선택"으로 유도, GMR 데이터로 유망 후보 제시.
3. 3회 재협상 미해결 시 사용자 에스컬레이트.
