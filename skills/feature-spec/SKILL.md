---
name: feature-spec
description: 3D 게임(Godot 4) what.md의 각 Feature(F1, F2, ...) — 게임 시스템 단위 — 에 대해 Superpowers brainstorming 스킬을 호출하여 docs/features/F{N}/feature-spec.md를 생성한다. 각 Feature의 코어루프 4단계 기여·코어 버브 측면·TTFV 기여도·3층 훅 위치·Pre-mortem 부정 리뷰를 반드시 포함한다. "Feature 스펙 작성", "F3 상세화", "게임 시스템 스펙", "브레인스토밍 기반 스펙", "feature-spec 생성" 요청 또는 오케스트레이터 Phase C에서 자동 호출 시 사용. 각 Feature는 독립 서브 에이전트로 병렬 실행 가능.
---

# Feature Spec — 게임 시스템 단위 상세화

3D 게임의 **Feature = 게임 시스템** 단위. what.md의 각 Feature를 **Superpowers `brainstorming` 스킬**을 활용해 상세 스펙으로 확장한다.

## 입력
- `docs/kickoff/what.md`의 Feature 섹션 (F1, F2, ...)
- `docs/kickoff/why.md`와 `how.md` (맥락 참조용 — 플레이어 원형·코어 결핍·코어 버브·3층 훅·기술 스택)

## 산출물
- `docs/features/F{N}/feature-spec.md` (Feature마다 1개)

## 절차

### 1. Feature 정보 추출

what.md에서 대상 Feature의 다음 정보를 읽는다:
- Feature 이름 (게임 시스템 — 예: "플레이어 이동 & 카메라", "전투 히트박스 시스템", "세이브/로드")
- 한 문장 설명
- **코어루프 기여 단계** (Anticipation/Action/Feedback/Progress 중 최소 1개)
- 수용 기준
- 우선순위 (P0/P1/P2)
- 비-범위

부족하면 `what.md`에 "underspecified" 플래그를 기록하여 Scribe가 재작성하도록 돌려보낸다.

### 2. Superpowers brainstorming 호출

**반드시 Skill 도구로 `superpowers:brainstorming` 스킬을 호출한다.**

호출 시 아래 컨텍스트를 전달:
- Feature 이름과 설명
- why.md의 **1플레이어 원형 · 1코어 결핍 · 1코어 버브**
- what.md의 **코어루프 4단계 정의** + 이 Feature가 지탱하는 단계
- why.md의 **3층 훅 요약** (0.5초 / 5초 / 30초)
- 수용 기준
- how.md의 기술 스택·Physics Layers·InputMap·성능 타깃

브레인스토밍 스킬이 요구하는 포맷(사용자 의도, 요구사항, 설계, 엣지 케이스, 개방 질문)을 따르되, 결과를 아래 `feature-spec.md` 구조로 정리.

### 3. feature-spec.md 작성

```markdown
**프로젝트 종류:** {project_type} 게임 (Godot 4)

# F{N}. {게임 시스템 이름}

**Source:** docs/kickoff/what.md
**Priority:** P0 | P1 | P2
**Status:** DRAFT | APPROVED

## 0. 완료 시 보여야 하는 화면·플레이  ★ 필수 — Feature 목표

Feature의 유일한 "목표"는 **0-A 영상**과 **0-B 체크리스트** 두 층으로 기술한다. 0-A는 감성(플레이어 관점), 0-B는 검증(완성 판정). 정식 Given/When/Then은 §7.3에.

### 0-A. 영상처럼 한 문단 (감성)

**한 문단으로 영상처럼 써라.** 무엇이 동작으로 이름 지어지는가가 아니라, 무엇이 **플레이어 눈에 보이거나 손에 느껴지는가**로 쓴다.

**예시 (허용):**
> 게임을 켜면 회색 평면 위에 CapsuleMesh 주인공이 서 있다. WASD를 누르면 1.5초 안에 주인공이 걷기 시작하고, 카메라가 주인공 뒤 4m·위 2m 거리에서 부드럽게 따라간다. 60초 동안 걸어다녀도 프레임 드랍 없고, 벽에 부딪히면 멈춘다.

**예시 (금지):**
- ✗ "카메라 생성" ← 동작만, 결과 없음
- ✗ "입력 시스템 구현" ← 시스템 이름만
- ✗ "플레이어 컨트롤러" ← 명사만
- ✗ "~ 생성", "~ 구현", "~ 시스템", "~ 컨트롤러"로 **끝나는** 한 줄 전부

**검증:** 이 문단을 읽은 사람이 **게임 창 스크린샷 1장과 영상 5초**를 상상할 수 있어야 한다. 상상할 수 없으면 feature-spec을 다시 쓴다.

**자동 체크:** 섹션 0-A 텍스트에 위 금지 패턴 (정규식: `^.*(생성|구현|시스템|컨트롤러)\s*$`)이 감지되면 저장 거부. brainstorming 재호출.

**`{project_type}` 채우는 법:** Scribe/Generator가 작성 시 `docs/kickoff/_meta.md`의 `project_type` 값(`2D 게임 (Godot 4)` 또는 `3D 게임 (Godot 4)`)을 읽어 헤더에 그대로 채운다. 변수가 남아 있는 채로 저장 거부.

**차원-특화 예시:** 2D = "픽셀 캐릭터가 좌우로 달리며 적 슬래시", 3D = "주인공이 1인칭으로 적 머리 조준 사격"

### 0-B. 확인 체크리스트 3~5개 (검증)

**Yes/No로 판단 가능한 짧은 문장 3~5개.** 이 체크리스트는 `_feature-list.md`와 `_roadmap.html` 카드에 **그대로 전시**되므로 짧고 명확하게.

- 각 항목은 한 줄. 기술 용어 허용 (금지 표현 규칙은 0-A 한정 — "WASD 입력", "3인칭 카메라 거리 4m" 같은 기술 표현 OK).
- 측정 가능해야 한다. "재미있다" ✗, "60초 프레임 드랍 0회" ✓.
- 최소 3개, 최대 5개. 그보다 상세한 수용 기준은 §7.3 Given/When/Then.

**예시 (F1 플레이어 이동 & 카메라):**
- [ ] WASD 누르면 주인공이 1.5초 안에 걷기 시작
- [ ] 3인칭 카메라가 주인공 뒤 4m·위 2m 위치 유지
- [ ] 60초 연속 플레이 중 프레임 드랍 0회
- [ ] 벽에 부딪히면 정지 (통과 X)

**검증:**
- 개수가 3 미만 또는 5 초과면 저장 거부
- 측정 불가능한 형용사("빠르게", "자연스럽게", "재미있게")만 있는 항목 있으면 경고 + 재작성 권유

## 1. 플레이어 의도 (Intent)
{이 시스템을 만나면 플레이어가 무엇을 기대하는가 — brainstorming 결과의 "Intent" 섹션}

## 2. 플레이어 스토리
As a {플레이어 원형}, I want to {코어 버브 또는 버브 보조 동작}, so that {감정 결과 / 코어 결핍 해소}.

## 3. 코어루프 기여 (필수)
**이 Feature가 지탱하는 코어루프 단계:**
- [ ] Anticipation — {어떻게? — 예: "적 약점 하이라이트"}
- [ ] Action — {어떻게? — 예: "코어 버브 입력 처리"}
- [ ] Feedback — {어떻게? — 예: "히트스톱·카메라 셰이크·사운드"}
- [ ] Progress — {어떻게? — 예: "적 사망 후 경험치 드랍"}

**최소 1개 이상 체크**. 어디에도 체크 안 되면 이 Feature는 삭제 또는 보조 시스템으로 강등 검토.

## 4. 코어 버브 구현 측면
이 Feature가 코어 버브의 어느 측면을 구현하는가 (복수 선택):
- [ ] **입력(Input)** — 플레이어 입력을 받아 버브 트리거
- [ ] **처리(Processing)** — 버브 로직·물리·상태 전이
- [ ] **피드백(Feedback)** — 시각/청각/햅틱 반응
- [ ] **진행(Progress)** — 다음 버브 루프로의 전환

## 5. TTFV(Time-to-First-Verb) 기여도
- **이 Feature가 TTFV 3분 달성에 필수인가?** YES / NO
- NO라면: "이 Feature 없이 TTFV 3분 달성 가능 — {M1/M2} 마일스톤으로 연기 가능"
- YES라면: 해당 Feature는 자동 P0이며 M0~M1 사이 구현

## 6. 3층 훅 위치
이 Feature가 3층 훅 중 어디에 등장하는가 (복수 가능):
- [ ] **0.5초 훅 (캡슐 이미지/썸네일)** — {스크린샷에 보이는 요소?}
- [ ] **5초 훅 (트레일러 첫 5초)** — {영상에 등장?}
- [ ] **30초 훅 (스트리머 클립)** — {방송에서 반응 유발?}
- [ ] **훅 무관** — 내부 시스템 (세이브/로드 등)

## 7. 기능 요구사항

### 7.1 기능 스코프 (범위)
- ...

### 7.2 비-범위
- ...

### 7.3 수용 기준 (Given / When / Then)
- **AC1.** Given ..., When ..., Then ...
- **AC2.** ...
- **AC3.** ...

## 8. UX / 게임 흐름
1. {진입 → 첫 상호작용 → 완료까지의 단계 — 예: "전투 개시 → 타겟 지정 → 코어 버브 입력 → 피드백 → 적 사망"}
2. ...

### 8.1 엣지 케이스 & 실패 경로
| 상황 | 동작 | 피드백 |
|------|-----|-------|
| 입력 동시 2개 | 우선순위 규칙 적용 | ... |
| 범위 밖 타겟 | 입력 무시 + 힌트 | ... |
| 네트워크 끊김 (해당 시) | ... | ... |

## 9. 데이터 & Godot 계약
### 9.1 관련 씬 / 스크립트
- `scenes/{path}.tscn`
- `scripts/{path}.gd`

### 9.2 Autoload / 싱글톤
- 사용하는 Autoload: ...

### 9.3 Physics Layers
- 이 Feature가 사용하는 Layer 번호: ...

### 9.4 InputMap 액션
- 사용하는 액션: `core_verb`, `move_forward`, ...

### 9.5 상태 전이
- ...

## 10. 의존성
- **내부 Feature:** 이 Feature보다 먼저 필요한 다른 Feature (F{M})
- **에디터/도구 의존:** 이 Feature 구현에 필요한 Godot 에디터·CLI 동작 (없으면 사용자 위임)
- **에셋 의존:** placeholder로 가능한가 / 고급 에셋 필요한가 (asset-pipeline 2단계 중 어디)

## 11. 관측성
- **이벤트:** {트래킹할 플레이어 행동 — 예: "core_verb_success", "core_verb_fail"}
- **지표:** Verbs-per-Minute, Loop Duration, TTFV 기여 시간 등 이 Feature의 성공 지표

## 12. 실패 모드
| 실패 | 감지 | 복구 |
|-----|-----|-----|
| ... | ... | ... |
| 씬 크래시 | headless smoke FAIL | Evaluator FAIL → Generator 재시도 |
| FPS 드롭 | 벤치 씬 | Draw call·LOD 재검토 |

## 13. Pre-mortem — 이 Feature 누락/결함 시 예상 부정 리뷰
**필수 — 최소 1개 작성.** Sellability Auditor 관점.

- **예상 Steam 부정 리뷰 1:** "{리뷰어 톤을 흉내낸 한 문장 — 예: '공격 반응이 너무 늦다. 한 타가 늦게 들어가는 느낌이 계속 거슬림.'}"
  - 원인: 이 Feature에서 {구체 실패}
  - 완화: {수용 기준에 이미 포함되었는가?}

## 14. 구현 노트
- {구현 시 주의사항, brainstorming에서 나온 "구현 전 결정해야 할 것"}
- {Godot 4 API 특이점, GDScript vs C# 선택 사유}

## 15. Open Questions
- ...

## 근거 (Sources)
<!-- 플레이어 행동 근거·경쟁작 벤치마크·Godot 4 API 문서·성능 사례 등 외부 사실에 각주를 단다. why/what의 근거를 재인용할 때는 "why.md#근거-sources §[^N]" 형태로 체인 가능. -->
[^1]: {주제/한 줄 요지} — `docs/kickoff/why.md §근거` 또는 `https://... (접근 YYYY-MM-DD)`
[^2]: ...
```

### 4. 저장

디렉토리가 없으면 생성하고 파일을 저장:
```
docs/features/F1/feature-spec.md
docs/features/F2/feature-spec.md
...
```

## 병렬 실행 모드 (오케스트레이터 Phase C)

오케스트레이터가 이 스킬을 사용할 때는 각 Feature를 **독립 서브 에이전트**에서 병렬 실행:
- `Agent` 도구, `subagent_type: general-purpose`, `model: "opus"`, `run_in_background: true`
- 동시 실행 3개 제한
- 각 서브 에이전트는 이 스킬을 Skill 도구로 로드 후 절차 수행
- 각 서브 에이전트는 반드시 `superpowers:brainstorming` 스킬을 내부 호출

## 단일 실행 모드 (수동 호출)

사용자가 "F3만 다시 써줘" 같이 특정 Feature를 지정할 때는 해당 F{N}만 절차 1~4로 실행. 이전 `feature-spec.md`가 있으면 읽고 변경점만 갱신.

## 품질 기준

다음을 만족하지 못하면 feature-spec.md를 DRAFT로 표시하고 원인을 기록.

- [ ] **코어루프 기여 단계 최소 1개 체크** (§3) — 없으면 이 Feature는 코어 버브 무관, 삭제 검토
- [ ] **코어 버브 구현 측면 최소 1개 체크** (§4)
- [ ] **TTFV 기여도 명시** (§5)
- [ ] **3층 훅 위치 명시** (§6)
- [ ] 수용 기준이 Given/When/Then 형태로 **최소 3개** (§7.3)
- [ ] 실패 모드 최소 2개 (§12)
- [ ] **Pre-mortem 부정 리뷰 1개 이상** (§13)
- [ ] 관측 지표 최소 1개 (§11)
- [ ] Godot 씬/스크립트 경로 명시 (§9.1)
- [ ] 외부 의존성이 명시되었거나 "없음"이 명시됨 (§10)
- [ ] why.md의 1코어 결핍 / what.md의 1코어 버브를 참조
- [ ] 외부 사실 주장에 각주(`[^n]`) + 하단 `## 근거 (Sources)` 채움. 외부 사실이 전혀 없으면 "근거 섹션: 해당 없음"으로 명시
