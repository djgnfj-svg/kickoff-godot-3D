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
- `docs/kickoff/reviews/build-auditor.md`
- `docs/kickoff/reviews/qa.md`
- `docs/features/_feature-list.md` (Phase C-0 FROZEN Feature 목록)
- `docs/features/_roadmap.html` (Phase C-0 Visual Gate 영구 보관본)
- `docs/features/F{N}/feature-spec.md` (Feature 수만큼, Phase C-1)
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

**프로젝트 고정 가정:** 엔진은 Godot 4로 고정. 차원(2D/3D)은 Phase 0-1에서 사용자에게 명시 질문하여 변수화한다.

---

### Phase 0-1: 프로젝트 차원 결정 (2D/3D)

Founder가 사용자에게 명시적으로 질문:

> "이 게임은 2D인가요, 3D인가요?"

답에 따라 모든 후속 산출물의 헤더를 다음 형식으로 고정:
- 2D 답변 → `**프로젝트 종류:** 2D 게임 (Godot 4)`
- 3D 답변 → `**프로젝트 종류:** 3D 게임 (Godot 4)`

결과를 `docs/kickoff/_meta.md`에 다음 형식으로 저장:

```yaml
project_type: {2d|3d}
engine: godot-4
decided_at: {timestamp}
```

이후 모든 에이전트/스킬은 차원-특화 동작이 필요할 때 `_meta.md`의 `project_type`을 먼저 읽거나 해당 스킬의 `references/{2d,3d}.md`를 로드한다.

**한 번 결정되면 변경 불가** — 차원 변경이 필요하면 사용자에게 새 프로젝트로 시작할 것을 권고.

## Phase 1: 사용자 입력 수집 — **대화 중심 순차 확정**

**절대 한 번에 여러 요소를 묻지 않는다.** 1플레이어 원형 → 1코어 결핍 → 1코어 버브 순서로 하나씩 진행. **각 Step은 여러 턴의 자연 대화**로 상세화되며, Step 완료 조건 = Founder가 **정리 블록을 제시** + 사용자가 **명시적 확정 동의** ("응" / "맞아" / "그걸로").

**Phase 1은 무거워도 된다.** 기획 품질이 속도보다 우선. 빈약한 한 줄 답변도 대화로 구체화한다.

### Founder 대화 원칙 (Phase 1 전체)

- **해석·재진술 금지는 "원문 덮어쓰기 금지"로 재해석.** 원문은 `_workspace/*_raw.md`에 그대로 보존. 해석·갱신은 **별도 섹션에 사용자 명시 동의 후** 저장.
- **시스템 용어 금지.** "축이 비어있다" / "최소 정보 단위 N개가 필요" 같은 표현 금지. 생활 맥락에서 자연스러운 후속 질문으로 상세화.
- **"제가 이해한 게 맞나요?" 허용.** 단 박제 금지 — 확정 동의를 받기 전까지는 언제든 수정 가능.
- **각 Step 여러 턴 OK.** 5~15 턴이 보통. 정리 블록은 Founder가 "이 정도면 확정 가능해 보여요" 판단 시점에 제시.
- **사용자가 지치면 "여기까지만 하고 Open 남길까요?" 선택지 제공.** Open 축은 Phase A 토론 입력으로 자동 승계.

### Step 1-0: 아이디어 상태 분기

Founder가 먼저 사용자 상태를 묻는다.

```
지금 아이디어가 어느 단계인가요? 한 가지 고르시면 됩니다.

A. 한 줄로 설명 가능 (예: "도끼 하나로 거대 보스를 베는 소울라이크")
B. 장르·분위기만 정해졌다 (예: "3인칭 액션 뭔가 만들고 싶다")
C. 아직 백지 — 그냥 만들고 싶다는 의욕만 있다
```

- **A 경로:** Step 1-1 진행. (GMR 스폰은 Step 1-1의 4축 추출 게이트 통과 후에 한다 — 한 줄이 엉성하면 리서치 범위를 못 정하기 때문.)
- **B 경로:** GMR을 **포어그라운드**로 호출 (도메인 탐색 모드). 해당 장르의 최근 트렌드·gap·기회 후보 3~5개 → `_workspace/domain_scan.md`. Founder가 보기 5~10개(⭐ 1~2 + 중립 나열) 제시 → 사용자 선택 후 Step 1-1에서 한 줄로 재진술.
- **C 경로:** Founder가 Discovery 질문 2~3라운드 (최근 재미있게 한 게임, 아쉬웠던 게임, 좋아하는 순간). 답변은 원문 그대로 `_workspace/discovery_notes.md`에 누적. seed 3~5개 모이면 GMR 호출(seed 검증 모드). Founder가 유망 seed 2~3개 보기 형태로 제시 → 사용자 선택 후 Step 1-1에서 한 줄 재진술.

**수렴점:** Step 1-0은 최종적으로 **한 줄 아이디어**를 Step 1-1에 넘긴다.

### Step 1-1: 게임 아이디어 한 줄 + 4축 추출 게이트 + 리서치 범위 공개

#### 1-1-a. 원문 기록
사용자 원문 그대로 `_workspace/idea_raw.md`의 "## 원문" 섹션에 저장. 여러 줄·여러 아이디어면 **"한 줄로 줄여 주세요"만** 요청.

#### 1-1-b. 4축 추출 게이트 (Founder 판정)
Founder가 한 줄에서 리서치 4축을 추출 시도:

| 축 | 파싱 키워드 예 |
|----|---------------|
| **장르** | Souls-like / 로그라이크 / FPS / 덱빌더 / ... |
| **메커닉** | 단일 무기 / 덱빌딩 / 파쿠르 / 스텔스 / ... |
| **테마** | 다크 판타지 / SF / 포스트아포 / 동양 무협 / ... |
| **포맷** | 3인칭 / 1인칭 / 탑다운 / 2D / ... (1-5-3에서 최종 확정) |

판정:

| 추출 축 수 | 상태 | 다음 행동 |
|-----------|------|----------|
| **2~4축** | OK | 1-1-c 진행 (리서치 범위 공개) |
| **1축 (장르만)** | 엉성 | 1-1-b' **보강 대화** (아래) |
| **0축** | 백지 수준 | **C 경로 강등** (Step 1-0 C로 되돌아감, 원문은 discovery_notes.md 최상단 보존) |

#### 1-1-b'. 엉성 한 줄 보강 대화 (1축만 추출된 경우)
Founder가 3축 질문으로 축 보강:

```
기록했습니다: "{원문}"
이건 {추출된 축} 하나만 명확해서, 이 상태로 리서치 시작하면 범위가
너무 넓어요. 한 줄을 조금만 더 구체화하고 싶은데, 3가지 질문으로
좁혀볼게요. 막히면 "패스" 답해도 됩니다.

질문 1: 머릿속에 어떤 경쟁작 이미지가 있으세요?
  예: {경쟁작 리스트 5~7개} / 없음

질문 2: {메커닉 축} 에 특별히 끌리는 스타일 있나요?
  예: {메커닉 카테고리 4~6개} / 아무거나

질문 3: 분위기·테마 축은요?
  예: {테마 카테고리 5~7개} / 미정
```

**제한:** 보강 대화에서 축 3개 시도, 각 "패스" 허용. **보강 후 2축 이상 채워지면** 갱신 한 줄 확정 (사용자 동의) → 1-1-c 진행. **1축 이하면** C 경로 강등.

**보강 중 Founder의 경쟁작 예시 제시는 OK** (리서치 없이 상식 수준). ⭐ 추천은 여전히 리서치 완료 후에만.

**저장:** `idea_raw.md`에 "## 보강 대화" 섹션 누적 + "## 갱신 한 줄 (사용자 확정)" 섹션. 원문은 건드리지 않음.

#### 1-1-c. 리서치 범위 공개 + GMR 스폰
Founder가 **리서치 대상을 사용자에게 공개**하고 조정 기회 제공. 블랙박스 금지.

```
한 줄 확정: "{원문 또는 갱신 한 줄}"

이 한 줄에서 Researcher가 경쟁작 조사를 시작합니다.
조사 대상 (15~30분 소요):

  · 장르 — {장르 경쟁작 3~4개}
  · 메커닉 — {메커닉 관련 작 1~2개}
  · 테마 — {테마 관련 작 1~2개}

결과는 Step 1-3(결핍)부터 보기 추천(⭐)에 반영됩니다.
Step 1-2(원형)는 본인 경험 기반으로 진행해요 (리서치 의존도 낮음).

조사 대상 추가/변경 원하는 경쟁작 있으세요? 없으면 바로 Step 1-2 갑니다.
```

사용자가 경쟁작 추가·제외 요청하면 반영 후 GMR **선행 모드**로 `run_in_background: true` 스폰. 스폰 후 바로 Step 1-2 진입.

### Step 1-2: 1플레이어 원형 (리서치 없이 시작)

리서치 의존도 **낮음**. 사용자 본인·주변 경험이 주된 근거. **⭐ 없이 중립 나열**로 시작.

**열린 질문 + 보기 5~10개 한 번에 제시.** 보기는 사용자가 자유 답하든, 보기 중 고르든 자유롭게 쓸 수 있도록 준비된 "선택지이지 유도가 아님".

```
이 게임을 90분 동안 실제로 플레이할 구체 인물 한 명을 그려봤으면 해요.
자유 묘사 OK, 아래 예시 참고 OK. 끌리는 방향 아니면 "이것 말고 X"로 답해도 됩니다.

(⭐ 없음 — Researcher 진행 중. 본인 경험 기반으로 답해주시면 됩니다.)

  1. 30대 퇴근 90분 Steam {장르} 플레이어
     — {원형적 한 줄 설명}
  2. 40대 주중 30분 Steam Deck 짧은 세션 플레이어
  3. 20대 주말 4시간 Steam 하드코어 {장르}
  4. 50대 은퇴자 Steam 데스크톱 느긋한 페이스
  5. 10대 방과후 1시간 Twitch 시청 병행
  ...
```

**대화 확장 원칙:**
- 사용자 자발 답변 → 그 답을 받아 생활 맥락 후속 질문 (세션 길이·플랫폼·동기 등을 **"축"이라 부르지 않고** 자연스럽게)
- 사용자가 막히면 → 보기가 이미 눈앞에 있음 (필요시 Founder가 "1번 가까운 느낌?"으로 힌트)
- 여러 턴 반복 → 사용자·Founder 모두 "이 정도면" 공감

**Step 완료:** Founder가 정리 블록 제시 → 사용자 명시 동의 → `_workspace/confirmed_archetype.md` 저장 (2섹션: "## 대화 원문" + "## 확정 요약"). Niche Enforcer 1원형 판정 → Step 1-3 진입.

### Step 1-3: 1코어 결핍 (리서치 ⭐ 본격 활용)

리서치 의존도 **높음**. Step 1-3 진입 시점에 GMR 결과(본 모드)가 도착해 있어야. 미도착이면 Founder가 "Researcher 완료 대기 5~10분" 선언.

**⭐ 추천 3축 기준:**

| 축 | 내용 |
|----|------|
| **A. 리뷰 불만 반복성** | 경쟁작 Steam 리뷰에서 같은 감정 공백 **3회 이상 반복** 인용 가능 |
| **B. 시장 공백** | 해당 장르×세션 길이×감정 조합의 SteamDB 작품 수 적음 |
| **C. 시장 규모** | 해당 세그먼트 규모 추정 근거 (SteamCharts·Valve 공개) |

**2축 이상 충족 시 ⭐ 부여.** 근거 없으면 ⭐ 비우고 "근거 부족으로 중립 나열" 명시.

```
Researcher 메모 도착. 경쟁작 리뷰 불만 패턴에서 반복되는 감정 공백을 봤어요.

이 원형이 현재 시장에서 못 채우고 있는 감정 1개는 뭘까요?

⭐ 1. "{감정 후보 1}"
     근거: A+B ({경쟁작 리뷰 반복 인용 / 작품 수 부족 통계})

⭐ 2. "{감정 후보 2}"
     근거: A+C ({리뷰 인용 / 시장 규모})

  3. 긴장 해소 — 장점: / 단점:
  4. 탐험 충동 — 장점: / 단점:
  5. 사회적 연결 — 장점: / 단점:
  ...
```

**대화 확장 원칙:**
- 사용자가 ⭐ 1/2 중 고르면 → 본인 경험과 연결해 심화
- 사용자가 다른 감정 답하면 → Researcher에게 해당 감정 근거 추가 요청 가능
- "왜 그 감정이 시장에 비어있는지" 근거 1줄 함께 (사용자·Founder 협력)

**Step 완료:** 정리 블록 + 확정 동의 → `confirmed_lack.md` (2섹션). Niche 1결핍 판정 → Step 1-4 진입.

### Step 1-4: 1코어 버브 (⭐ + 60분/TTFV 검증)

리서치 의존도 **높음**. GMR의 **코어 버브 역공학** 결과 활용.

```
이제 코어 메커닉을 한 단어 동사로 좁혀봅시다. 플레이어가 게임에서
가장 자주 반복하는 동작 1개는 뭘까요?

⭐ 1. "{버브 후보 1}"
     근거: A+B ({경쟁작 코어 버브 역공학 / 해당 버브 시장 공백})

⭐ 2. "{버브 후보 2}"
     근거: A+C

  3. 쏘다 / 4. 짓다 / 5. 피하다 / 6. 탐험하다 / 7. 던지다 / 8. 베다 / ...
```

**검증 질문 2개 의무 (Step 완료 전 반드시 대답):**
1. **60분/100회+ 반복 방어:** "이 버브를 60분 동안 100회 이상 반복해도 질리지 않을 이유?" — 답변: 매번 학습하는 축 (타이밍·위치·무게감 등).
2. **TTFV (Time To First Verb) 3분:** "처음 켠 사용자가 3분 안에 첫 버브 체감 가능한가?" — Yes/No + 이유.

**Step 완료:** 정리 블록 + 확정 동의 → `confirmed_verb.md`. Niche 1버브 판정 (**버브 2개+ 즉시 거부** — 규칙 유지). 통과 시 Step 1-5 진입.

### Step 1-5: 게임 메타 5항 (각 항목 한 번에 하나씩)

**1-5-1. 장르 1개** — SteamDB 태그 기준 상위 장르 1개. 세부 장르 조합 금지. 보기 5~7개.
**1-5-2. 플랫폼 1개 (MVP)** — Steam 기본. 2개 선택 시 Niche 거부.
**1-5-3. 시점 · 카메라** — ★ **Visual Gate 필수** (`camera-perspective` 패턴). Founder가 브라우저에 4~5개 카드 띄움 → 사용자 클릭 → `selected.md`. 텍스트 설명 대신 시각 결정.

**시점 옵션** (`docs/kickoff/_meta.md`의 `project_type`에 따라 다른 풀 제시):

- **2D 게임:**
  - 탑다운 (Top-down)
  - 사이드뷰 / 횡스크롤 (Side-scrolling)
  - 쿼터뷰 (Isometric / Pixel isometric)
  - 정면 (Visual novel / Front-facing)
  - 보드뷰 (Board / Grid overhead)

- **3D 게임:**
  - 1인칭 (First-person)
  - 3인칭 어깨너머 (Third-person over-the-shoulder)
  - 3인칭 쿼터뷰 (Isometric 3D)
  - 탑다운 3D (Top-down 3D)
  - 고정 카메라 (Fixed camera)
**1-5-4. 예상 플레이 시간** — 10h 이하 / 10~30h / 30h+ 중 1개.
**1-5-5. 멀티 여부** — 기본값: 솔로 전용. 멀티 추가 시 Niche 거부 기본.

각 항목 대화 형태. 리서치 결과가 결정을 **거의 내려줬으면** Founder가 "결핍이 짧은 세션이었으니 10h 이하가 자연스러운데 확인?" 식으로 일관성 점검.

**저장:** `_workspace/game_meta.md` (1-5-1 ~ 1-5-5 각각 확정 요약). 1-5-3만 별도 `visual_gates/camera-perspective/selected.md`.

### Phase 1 종료 → Phase A 전환

Founder가 최종 요약 블록 제시:

```
Phase 1 입력 수집 완료. 지금까지 확정:

  1. 한 줄: "{갱신 한 줄 or 원문}"
  2. 원형: {확정 요약 1줄}
  3. 결핍: {확정 요약 1줄}
  4. 버브: {확정 요약 1줄, TTFV/60분 검증 결과 포함}
  5. 메타: 장르/플랫폼/시점/시간/멀티

Open 축: {Phase A로 이월되는 축, 있으면}

Phase A 진입할까요? 수정할 부분 있으면 해당 Step으로 돌아갑니다.
```

사용자 동의 시 Phase A 시작. 이전 Step 돌아가기는 `_workspace/confirmed_*.md`의 "확정 요약" 섹션만 재작성 (원문 보존).

### 금지 사항 (요약)

- **한 번에 여러 Step 묻기 금지** (1-2와 1-3을 동시에 묻는 등).
- **원문 덮어쓰기 금지** — 해석·갱신은 별도 섹션 + 사용자 동의 필수.
- **시스템 용어 금지** — "축"·"최소 정보 단위" 등 사용자 모르는 용어 금지.
- **억지 ⭐ 추천 금지** — 3축 기준 2축 이상 충족 못 하면 중립 나열.
- **4축 추출 0개인 한 줄로 리서치 시작 금지** — C 강등.
- **Founder가 확정되지 않은 내용을 초안에 채우기 금지**.

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

**[GMR]** 본 모드로 `confirmed_{archetype,lack,verb,meta}.md` 기반 경쟁사·대체재·시장 데이터 수집 → `_workspace/research_memo.md` (`game-market-researcher` 에이전트(§통합 프로토콜) 게임 프로토콜 사용). 3축(직접/간접/대체재) + 코어 버브 역공학(플레이 영상 시청 필수) + 리뷰 불만 패턴.

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

> 문서 템플릿: `kickoff-docs`. 범위 판정: `niche-enforcer` 에이전트. 메커닉 분해: `core-mechanic-designer` 에이전트 (CMD). 훅 설계: `hook-strategist` 에이전트 (HMS). 세일즈 감사: `sellability-auditor` 에이전트 (SA). 리서치: `game-market-researcher` 에이전트 (GMR).

---

## Phase B: Reviewer 팀 실행 (how.md 검증)

**실행 모드:** 에이전트 팀 (Kickoff 팀 해체 후 새 팀)

### B-1. 팀 생성
`TeamCreate`로 팀 `reviewer-team`:
- `build-auditor` — "Generator가 막히는가?" (how.md 한 장)
- `qa` — "3문서가 같은 게임을 말하는가?" (why/what/how 교차)

### B-2. 작업 할당
2명이 **병렬로** `how.md`를 독립 검토. 각자 `docs/kickoff/reviews/{name}.md`에 `APPROVED / CHANGES_REQUESTED / REJECTED` 상태와 상세 의견 기록. QA는 why/what/how 3개를 동시에 읽고 교차 검증. Build Auditor는 Day 1~3 상상 경로로 막힘을 진단. 스코프 판정(멀티/엔진 이식 등)은 Build Auditor가 다루지 않고 언급만 하여 Niche 재소집으로 돌린다.

### B-3. 승인 게이트
- **전원 `APPROVED`** → Phase C 진행.
- **하나라도 `CHANGES_REQUESTED` 또는 `REJECTED`** →
  1. Reviewer 팀 해체.
  2. Kickoff 팀(또는 최소 인원: founder + scribe + niche-enforcer + 관련 전문가)을 재구성하여 리뷰 피드백 반영.
  3. `how.md` 재작성 후 Phase B 재시작.
  4. **최대 3라운드**. 초과 시 사용자 결정 요청.

### B-4. 팀 해체
승인 완료 후 `TeamDelete`.

> 리뷰 프로토콜: `build-auditor`·`qa` 에이전트 2인 리뷰 게이트.

---

## Phase C: Feature Spec 생성 (C-0 확정 → C-1 병렬 → C-2 수집)

**실행 모드:** 하이브리드 — C-0은 Founder+Scribe 대화형, C-1은 서브 에이전트 병렬, C-2는 오케스트레이터 수집.

### C-0. Feature 목록 최종본 제시 + 확인 + FROZEN

Phase B(Reviewer 게이트) 통과 후 C-1(병렬 feature-spec 생성) 이전에 **목록 고정** 게이트.

#### C-0-1. Scribe 최종본 작성
`what.md`의 Features 섹션을 읽어 `docs/features/_feature-list.md` **DRAFT** 본 작성. 각 F는:
- F 번호 · ID(M0a/M0b/F1/F2...) · 이름
- **완료 시 보이는 화면·플레이 한 줄** (동작·명사만 금지, 화면 결과로 기술)
- 순서 + 의존
- M0a(MCP 환경 검증) + M0b(Walking Skeleton) 행을 **항상 먼저** 포함 (코드 게임 F가 아니어도 마일스톤으로 나열)

#### C-0-2. Visual Gate 로드맵 제시
Scribe가 `feature-roadmap` 패턴(`visual-gate` 스킬 `references/gate-patterns.md` §10)을 사용해 HTML 작성. 두 곳에 저장:
- Visual Gate 세션: `<session>/content/feature-roadmap.html`
- 영구 보관: `docs/features/_roadmap.html` (Build Harness가 참조)

Founder가 사용자에게 로드맵 URL 제시 + 한 줄 설명 + "OK 또는 수정 코멘트 주세요" 안내.

#### C-0-3. 사용자 응답 분기
- **"OK" → FROZEN**: `_feature-list.md` 최상단에 `Status: FROZEN` + 확정일 기록 → C-1 진입
- **"수정"**: Founder가 **변경 규모 3단계 판정** (투명 공개 후 처리)

| 규모 | 범위 | 처리 |
|------|------|------|
| **경미** | F 순서 교체 · 이름·한 줄 다듬기 · F 1개 독립 추가/삭제 | Scribe 즉시 반영 → 최종본 재제시 (티키타카 허용) |
| **중간** | F 2개+ 동시 추가/삭제 · 의존 재편 · 코어루프 기여 변경 | Scribe가 `_feature-list.md` + `what.md` Features 둘 다 갱신. how.md 수용 기준 영향 시 Phase B 재실행 필요 알림 |
| **중대** | 코어 버브 · 코어 결핍 · 플레이어 원형 · 플랫폼·장르 변경 | "Phase A {topic} 사이클 롤백 필요" 알림 + 사용자 명시 동의 후 해당 사이클 재실행 (Niche 재소집) |

**투명 공개 원칙:** Founder가 매 수정 요청마다 "이건 경미/중간/중대입니다. 이유: {한 줄}"을 **먼저 알려준 뒤** 처리. 사용자가 모르고 중대 변경 요청했다가 놀라는 상황 방지.

**FROZEN 이후 수정:** C-1 진행 중 "F4 빼먹었네" 같은 추가 요청 시 사용자 재동의 + `_feature-list.md` 변경 이력 섹션 기록 + 해당 F 서브 에이전트만 추가 스폰.

### C-1. 각 F의 feature-spec 병렬 생성

FROZEN된 `_feature-list.md` 순서대로 F1, F2, ... 순번 확정. 마일스톤(M0a/M0b)은 feature-spec 불필요 (how.md 마일스톤 표로 충분). 각 F{N}마다:
1. `Agent`로 `general-purpose` 서브 에이전트를 `run_in_background: true`, `model: "opus"`로 스폰.
2. 프롬프트: `feature-spec` 스킬 사용 + Superpowers `brainstorming` 스킬 내부 호출 + **섹션 0(완료 시 화면) 필수 + 금지 표현 감지 규칙** 적용, 결과를 `docs/features/F{N}/feature-spec.md`로 저장.
3. 최대 동시 실행 **3개**. Feature가 더 많으면 배치로.

### C-2. 결과 수집
모든 서브 에이전트 완료 후, 생성된 `feature-spec.md` 목록과 `_feature-list.md` FROZEN 상태를 사용자에게 보고.

> Feature 스펙 템플릿: `feature-spec` 스킬 (섹션 0 포함 버전).
> 로드맵 패턴: `visual-gate` 스킬 `feature-roadmap`.

---

## Phase D: 최종 정리 및 피드백

1. 산출물 체크리스트:
   - `docs/kickoff/why.md`, `what.md`, `how.md` 첫 줄 `**프로젝트 종류:** 3D 게임 (Godot 4)` 존재
   - why의 플레이어 원형 = what의 대상 = how의 타깃 플랫폼/입력 가정인가
   - what의 F1이 코어루프를 닫는 스프린트로 매핑 가능한가
   - how의 **M0a 완료 조건이 MCP 환경 검증(Godot+Blender 열림·smoke)** + **M0b 완료 조건이 코어 버브 1회 수행** 둘 다 포함
   - `docs/kickoff/reviews/` 2개 파일(build-auditor·qa) 전원 `APPROVED`
   - `docs/features/_feature-list.md`의 Status가 `FROZEN`
   - `docs/features/_roadmap.html` 존재
   - `docs/features/F*/feature-spec.md` 수 = `_feature-list.md`의 F 행 수 (마일스톤 M0a/M0b 제외)
   - 각 feature-spec.md에 **섹션 0-A (완료 시 보이는 화면·플레이 한 문단)** 존재 + 금지 표현(`~생성/구현/시스템/컨트롤러`로 끝나는 한 줄) 없음
   - 각 feature-spec.md에 **섹션 0-B (확인 체크리스트 3~5개)** 존재 + 측정 가능한 항목 (형용사만 있는 항목 없음)
   - `_feature-list.md`의 "확인 체크리스트" 섹션에 각 F의 0-B가 인용됨 (drift 없음)
   - `_feature-list.md`의 "**기술 통합 리스트**" 섹션에 씬·스크립트·Autoload·Physics Layers·InputMap 집계 완료 (feature-spec §9 + how.md 취합)
   - `_feature-list.md`의 "**공통 누락 점검**" 4항목 모두 ✅포함 또는 ⚠️의도적 제외 (사유 1줄) 상태 — ❌누락 하나도 없음
   - `_roadmap.html` 카드 body에 `보이는 것` + `확인:` ul + `순서/의존` + `레퍼런스` 4요소 모두 존재
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

Phase C 산출물 (`docs/features/`):
- `_feature-list.md` (C-0 FROZEN 목록, Status + 표 + 대화 원문 + 변경 이력)
- `_roadmap.html` (C-0 Visual Gate 영구 보관본)
- `F{N}/feature-spec.md` (C-1 각 Feature 상세)

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
