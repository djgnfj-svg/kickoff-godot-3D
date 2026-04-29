---
name: build-handoff
description: Build Harness의 에이전트 간 파일 기반 핸드오프 표준. Planner→Generator, Generator→Evaluator, Evaluator→Generator(재시도) 사이에 주고받는 파일의 경로·섹션·필드를 정의한다. Planner/Generator/Evaluator 에이전트와 sprint-* 스킬은 이 스킬을 반드시 참조해 동일한 포맷을 사용해야 한다. 컨텍스트 리셋 직후 새 에이전트 세션이 이전 작업 상태를 온전히 복원할 수 있도록 "자기 완결적" 문서를 강제한다.
---

# Build Handoff — 에이전트 간 파일 핸드오프 표준

Build Harness는 파일 기반 통신으로 동작한다. `SendMessage`나 대화 요약(compaction)이 아니라, 각 에이전트는 깨끗한 컨텍스트에서 시작해 **약속된 경로의 파일만 읽고** 작업한 뒤 **약속된 경로에 파일을 쓰고** 종료한다.

이 스킬은 그 파일들의 경로·섹션·필드를 고정한다. 포맷이 틀어지면 다음 에이전트가 입력을 해석하지 못해 루프 전체가 망가진다.

## 왜 파일 기반인가

- **컨텍스트 리셋 > compaction** (Anthropic 원칙): 이전 세션의 불안·탈선이 다음으로 새지 않는다
- **재현성**: 같은 핸드오프 파일이면 다음 에이전트의 동작이 결정적
- **감사 추적**: 스프린트가 왜 실패했는지 파일만 보면 됨
- **재시도 안정성**: N회차 세션이 1회차와 똑같은 입력 구조를 받음

## 디렉토리 레이아웃

Feature `F{N}`, 스프린트 `S{M}` 기준:

```
docs/kickoff/                        # Kickoff Harness 비전·계약 합본 (참고용, 읽기 전용)
├── why.md / what.md / how.md        # 5종 단일 진실원
├── GDD.md                           # 비전 합본 (파생 뷰, Build는 미수정)
└── PRD.md                           # 마일스톤 walkthrough 합본 (파생 뷰, Build는 미수정)

docs/features/                       # Kickoff Harness 출력, Build 입력 계약
├── _feature-list.md                 # FROZEN Feature 목록 + 기술 통합 리스트
└── F{N}/feature-spec.md             # F별 상세 (§0-A·§0-B·§7.3·§9 등)

docs/build/F{N}/
├── product-spec.md                  # Planner 산출 — 1회 생성, 수정은 Planner만
├── sprints/
│   ├── S{M}-plan.md                 # 스프린트 계획 + Generator-Evaluator 계약
│   ├── S{M}-generator.md            # Generator 산출 요약 (코드 위치 + 자체 점검)
│   ├── S{M}-evaluation.md           # Evaluator 판정
│   ├── S{M}-retry-{K}.md            # K회차 자동 테스트 재시도 이력 (K=1,2)
│   └── S{M}-user-retry-{J}.md       # J회차 사용자 검수 재시도 이력 (F 마지막 S 한정, J=1,2)
├── USER_CHECK.md                    # Phase 2.7 사용자 검수 체크리스트 (F 마지막 S에서 생성)
└── handoffs/
    ├── S{M}-context.md              # 다음 스프린트로 넘어갈 때 전달할 핵심 상태
    └── final-context.md             # Feature 완료 후 다음 Feature로 넘길 계약

scripts/
└── check-F{N}.sh                    # F 사용자 검수 실행기 (Windows면 .bat 병행)
```

- 코드 자체는 하네스가 관리하지 않음. Generator는 사용자 프로젝트 경로에 코드를 작성하고, 파일 **위치**만 S{M}-generator.md에 기록
- 모든 핸드오프 파일은 **독립적으로 읽을 수 있어야 한다** — "이전 대화 참조" 금지
- `docs/features/*`는 Kickoff에서 FROZEN된 뒤 읽기 전용. Build 단계에서 수정하지 않음 (필요 시 Kickoff C-0 재소집)

## 핸드오프 #1: Planner → Generator

### 파일: `docs/build/F{N}/product-spec.md`

Planner가 feature-spec.md를 읽고 확장한 상세 제품 스펙.

```markdown
# F{N} Product Spec

**Source:** docs/features/F{N}/feature-spec.md
**Planner 세션:** {YYYY-MM-DD HH:MM}
**상태:** DRAFT | FINAL

## 1. 제품 개요
{1-3 문단. 제품이 무엇이고, 대상 유저가 이것으로 무엇을 달성하는가.}

## 2. 기술 결정
- **스택:** {언어·프레임워크·DB·배포 환경. feature-spec에서 그대로 읽어오거나 명시}
- **아키텍처 패턴:** {모노레포 / 단일 앱 / 클라-서버 분리 등}
- **외부 의존성:** {API·라이브러리·서비스 — 버전까지 고정 가능하면 고정}

## 3. 데이터 모델
{엔티티·필드·관계. ER 또는 TS 타입/스키마 수준으로.}

## 4. 주요 화면/엔드포인트
| 이름 | 경로 | 목적 | 수용 기준 참조 |
|------|------|------|----------------|
| ... | ... | ... | AC{k} |

## 5. 고수준 설계 결정
{Planner가 "야심차게" 내린 결정 — 레이아웃, 상호작용 패턴, 상태 관리 방식 등. Generator가 판단 낭비하지 않도록 미리 선언.}

## 6. 범위 밖 (Out of Scope)
- {이번 Feature에서 안 하는 것을 명시. 범위 팽창 방지}
```

### 파일: `docs/build/F{N}/sprints/S{M}-plan.md`

Planner가 스프린트 하나를 기술한 계획 + **Generator-Evaluator 계약**.

```markdown
# F{N} / S{M} Plan

**Planner 세션:** {YYYY-MM-DD HH:MM}
**선행 스프린트:** S{M-1} (없으면 "없음")
**목표 소요:** {기능 단위 크기 감각. "작은 기능 1개" 등. 시간 고정 금지}

## 1. 스프린트 목표
{이 스프린트가 끝나면 유저가 무엇을 할 수 있는가. 1-3문장.}

## 2. 범위
- 포함: {이번에 구현할 기능 단위 리스트}
- 제외: {의도적으로 뒤 스프린트로 미룬 것}

## 3. 수용 기준 (AC)
- **AC1.** Given ..., When ..., Then ...
- **AC2.** ...

## 4. Generator-Evaluator 계약
**"완료"의 정의:**
1. 모든 AC가 수동 재현 가능
2. {이 스프린트 특유의 "작동 증거" — 예: 코어 버브 1회 수행 후 피드백 1개 이상 발생}
3. 관련 컨벤션 위반 0건

**자동 검증 훅:**
- Import: `godot --headless --import` → 종료코드 0
- 정적 검사: `godot --headless --check-only` → 0건
- 테스트: GUT 또는 GdUnit4 스위트 → 통과
- Smoke: `scenes/__dev/sprint_{M}_smoke.tscn` 헤드리스 실행 → 종료코드 0

**명시적 비-목표:**
- {이 스프린트에서 검증하지 않는 것. 예: "성능 벤치마크는 S{M+2}에서"}

## 5. 선행 조건
- 입력 파일: {이전 스프린트 산출, 외부 리소스, 샘플 데이터 등}
- 권한/자원: {API 키·DB·포트 등 필요한 것}

## 6. 위험
- {이 스프린트에서 막힐 만한 지점 1-3개. Generator가 미리 알고 시작}
```

## 핸드오프 #2: Generator → Evaluator

### 파일: `docs/build/F{N}/sprints/S{M}-generator.md`

Generator가 구현을 끝내고 남기는 산출 요약. **코드 자체는 여기 붙이지 않는다** — 경로·요지만.

```markdown
# F{N} / S{M} Generator Output

**Generator 세션:** {YYYY-MM-DD HH:MM}
**회차:** 1 (재시도면 2 또는 3)
**결과:** COMPLETE | PARTIAL (다음에 언급)

## 1. 구현 요약
{무엇을, 왜 그렇게 구현했는가. 1-3문단.}

## 2. 변경/추가된 파일
| 경로 | 역할 |
|------|------|
| src/... | ... |

## 3. AC 매핑
| AC | 구현 위치 | 수동 재현 방법 |
|----|-----------|----------------|
| AC1 | `src/...:42` | "홈에서 버튼 클릭 → 모달 확인" |

## 4. 자체 점검 (Self-check)
- [ ] 빌드 성공 — `{명령어}` 실행 결과 요지
- [ ] 타입체크 통과
- [ ] 테스트 통과 (개수/신규)
- [ ] 컨벤션 4종(coding/design/a11y/performance) 자체 검토
- [ ] 계약의 "완료 정의" 항목 모두 충족

## 5. 알려진 한계
- {테스트가 덜 덮은 부분, 임시 처리한 부분. 숨기지 않는다.}

## 6. Evaluator에게 요청
- {특별히 확인 요청하는 시나리오 또는 경로}
```

**PARTIAL 결과:** Generator가 계약 일부를 채우지 못하고 종료할 때. 이 경우 "5. 알려진 한계"에 누락 항목을 전부 명시해야 한다. 숨기는 것은 Evaluator 루프를 오염시킨다.

## 핸드오프 #3: Evaluator → (Generator 또는 종료)

### 파일: `docs/build/F{N}/sprints/S{M}-evaluation.md`

Evaluator가 독립적으로 점검한 결과.

```markdown
# F{N} / S{M} Evaluation

**Evaluator 세션:** {YYYY-MM-DD HH:MM}
**대상:** S{M}-generator.md (회차 {N})
**판정:** PASS | FAIL

## 1. 기준별 점수
| 기준 | 임계값 | 결과 | 판정 |
|------|--------|------|------|
| 기능 완성도 (AC 통과) | 100% | x/y | ✓/✗ |
| 설계 충실도 (product-spec 일치) | 준수 | ... | ✓/✗ |
| 코드 품질 (컨벤션) | 위반 0 | ... | ✓/✗ |
| 시각 확인 (해당 시) | 사용자 위임 | Phase 2.7 USER_CHECK 참조 | — |

**하드 임계값:** 하나라도 ✗면 FAIL. 종합 점수로 가리지 않음.

## 2. 증거 (Evidence)
- 빌드/타입/테스트 실행 로그 요지
- 헤드리스 smoke 실행 로그 + 종료코드
- 컨벤션 위반 구체 항목

## 3. FAIL 원인 (판정이 FAIL일 때만)
- **무엇이:** {관찰된 결함}
- **어디서:** {파일·경로·시나리오}
- **왜 실패로 판정:** {계약의 어떤 항목 위반}

## 4. Generator에게 피드백 (FAIL일 때만)
- {재시도 시 먼저 고쳐야 할 것 — 우선순위 순}
- {피할 접근법 — 회의적 관찰을 근거로}

## 5. PASS 확인 (PASS일 때만)
- 모든 하드 임계값 통과
- 남은 위험 (다음 스프린트에서 지켜볼 것): ...
```

**"회의적으로" 판정한다:**
- Generator의 자체 점검을 신뢰하지 않고 독립 재현
- "잘 동작합니다"는 증거가 아니라 서술 — 로그·스크린샷이 없으면 증거 없음
- AC 하나라도 수동 재현 실패면 PASS 불가
- 컨벤션 위반 1건이어도 FAIL (작으면 다음 회차에서 쉽게 고침)

## 핸드오프 #4: 재시도 이력

### 파일: `docs/build/F{N}/sprints/S{M}-retry-{K}.md`

재시도 세션(K=1은 1차 재시도, K=2는 2차 재시도)이 시작되기 전 오케스트레이터가 작성. Generator의 새 세션은 이 파일을 먼저 읽는다.

```markdown
# F{N} / S{M} Retry {K} Context

**직전 회차:** S{M}-generator.md (회차 {K}) + S{M}-evaluation.md

## 반드시 먼저 읽을 파일
1. docs/build/F{N}/product-spec.md
2. docs/build/F{N}/sprints/S{M}-plan.md
3. docs/build/F{N}/sprints/S{M}-evaluation.md  ← 이번 재시도의 핵심 입력

## 이번 회차에서 해결해야 할 것
{Evaluator의 피드백을 우선순위 순으로 정리 — 복붙이 아니라 오케스트레이터의 재구성}

## 금지 사항
- 이전 회차의 실패 접근법 반복
- {Evaluator가 "피할 접근법"으로 지정한 것}

## 보존할 것
- 직전 회차에서 PASS한 AC는 건드리지 않음
- 파일 이동/삭제 금지 (컨벤션 변경 사항 제외)
```

## 핸드오프 #5: 스프린트 간 연결

### 파일: `docs/build/F{N}/handoffs/S{M}-context.md`

S{M} 통과 후 S{M+1}로 넘어갈 때 상태 요약. 다음 스프린트 에이전트가 깨끗한 컨텍스트에서 시작할 수 있도록 한다.

```markdown
# F{N} / After S{M} Context

## 완료된 범위
- S1: {한 줄 요약} — PASS
- S2: {한 줄 요약} — PASS
...
- S{M}: {한 줄 요약} — PASS

## 현재 시스템 상태
- 돌아가는 기능: ...
- 구성된 데이터: ...
- 실행 방법: `{명령}`

## 다음 스프린트(S{M+1}) 선행 조건 체크
- [ ] ...

## 유지해야 할 계약
- {이후 스프린트에서도 깨면 안 되는 AC·인터페이스}
```

## 공통 규칙

1. **자기 완결성**: 핸드오프 파일만 읽고도 상태를 복원할 수 있어야 한다. "위 대화에서 말한 대로" 금지.
2. **회차 기록**: 재시도가 있으면 회차 번호를 섹션 첫 줄에 명시. 이전 회차 파일을 덮어쓰지 않는다.
3. **증거 원칙**: "잘 된다" 대신 명령·로그·스크린샷·파일 경로를 남긴다.
4. **경로 규칙**: `docs/build/F{N}/` 하위 트리를 벗어나지 않는다. 코드는 사용자 프로젝트 루트에.
5. **파일 덮어쓰기**: `product-spec.md`는 Planner만, `S{M}-generator.md`는 Generator만, `S{M}-evaluation.md`는 Evaluator만 쓴다. 다른 에이전트는 읽기 전용.

## 이 스킬을 참조하는 주체

- `planner` 에이전트 → 핸드오프 #1
- `generator` 에이전트 → 핸드오프 #2, #4 (재시도 입력)
- `evaluator` 에이전트 → 핸드오프 #3
- `build-orchestrator` 스킬 → 핸드오프 #4, #5 작성
- `sprint-planning` / `sprint-execution` / `sprint-evaluation` 스킬 → 각자 해당 포맷을 따름

## 게임 프로젝트 (3D 게임 — Godot 4) 확장

프로젝트가 Godot 4 게임이면 위 포맷에 **추가 섹션이 의무**. 확장 규약은 `godot-scene-handoff` 스킬이 정의한다:

- product-spec.md에 "7. Godot 프로젝트 설정" (엔진 버전·렌더러·Autoload·Input Map·Physics Layers) 추가
- S{M}-plan.md에 "7. 이 스프린트의 Godot 영향" (생성/수정되는 씬·스크립트·리소스·프로젝트 설정 변경·smoke 씬) 추가
- S{M}-generator.md에 "7. Godot 산출 요약" (씬 트리, 작업 경로 테이블[text-edit/headless CLI/사용자 위임], 사용자 위임 항목, smoke 실행 결과) 추가
- `handoffs/S{M}-context.md`에 "씬 의존성 그래프" 추가

게임 프로젝트의 Planner/Generator/Evaluator는 **`build-handoff` + `godot-scene-handoff` 두 스킬을 모두 로드**한 뒤 작업한다. 차원별로 추가 references(`build-conventions/references/{2d,3d}.md`)를 `_meta.md`의 project_type에 따라 로드한다.

## 핸드오프 #6: Kickoff → Build (읽기 전용 입력)

### 파일: `docs/kickoff/_meta.md` (Phase 0-1 결정)

Kickoff Phase 0-1에서 사용자가 명시 답변한 차원/엔진 메타. 핵심 키:

- `project_type`: `2D 게임 (Godot 4)` 또는 `3D 게임 (Godot 4)`
- (선택) `godot_version`, `target_platforms` 등

Build 측 모든 에이전트(Planner / Generator / Evaluator / build-auditor / qa)는 작업 시작 전 이 파일을 가장 먼저 읽고, `project_type`에 따라 노드 가정과 references 로드를 분기한다. 파일이 없거나 `project_type` 키가 없으면 Build orchestrator가 "Kickoff Phase 0-1 먼저" 에러 후 중단.

### 파일: `docs/features/_feature-list.md` (Kickoff C-0 FROZEN)

Scribe가 C-0에서 FROZEN한 Feature 목록 + 확인 체크리스트 + 기술 통합 리스트 + 공통 누락 점검. 포맷 정본은 `${CLAUDE_PLUGIN_ROOT}/agents/scribe.md` 참조. Build Harness는 이 파일을 **읽기 전용 입력**으로 사용:

- **Planner**: product-spec 만들 때 "기술 통합 리스트" (씬·스크립트·Autoload·Physics Layers·InputMap)를 입력 계약으로 읽는다. **새 항목 추가는 가능, 기존 삭제·이동은 금지** (Kickoff C-0 재소집 필요).
- **Build orchestrator**: Status=FROZEN 아니면 "Kickoff C-0 먼저" 에러 후 중단.
- **오케스트레이터 Phase 0-1-a**에서 읽기 — 표의 F 순서가 구현 순서 단일 진실원.

## 핸드오프 #7: Generator → 사용자 (F 마지막 스프린트 직후)

### 파일: `docs/build/F{N}/USER_CHECK.md`

F의 **마지막 스프린트**에서 Generator가 자동 생성. Phase 2.7 User Acceptance Gate에서 사용자가 직접 플레이하며 §0-B 체크리스트를 Y/N으로 기록하는 폼.

```markdown
**Feature:** F{N} {이름}
**생성일:** YYYY-MM-DD
**Generator 회차:** K / **사용자 재시도:** J (0~2)
**실행 방법:**
  · `./scripts/check-F{N}.sh` (또는 `.bat`)
  · 폴백: Godot 에디터에서 `scenes/__dev/check_f{N}.tscn` 열고 F5

# F{N} 사용자 검수

## §0-A 영상 (feature-spec에서 복제)
> {feature-spec §0-A 한 문단 그대로}

## §0-B 체크리스트 (플레이하며 직접 체크)

### ☐ 체크 1: {§0-B 항목 1 원문}
- 결과: [ ] Yes / [ ] 부분 / [ ] No
- 코멘트: 
- 자동 테스트 매칭: §7.3 AC-N (Evaluator PASS ✓ / 매칭 없음 —)

### ☐ 체크 2: ...
(§0-B 항목 수만큼 3~5개)

## 종합 판정 (사용자가 체크)
- [ ] **F{N} 전부 OK**        → Phase 3 진행
- [ ] **부분 재시도 필요**     → 코멘트 기반 Generator 재시도 (J+1)
- [ ] **완전 재기획 필요**     → §0-B 자체 재협의 (Phase C-0 재소집)

## 비가시 F 예외 (해당 시만 체크)
- [ ] 이 F의 §0-B가 전부 순수 내부 시스템이며 §7.3 AC와 1:1 매칭되어
      Evaluator PASS가 충분함. Phase 2.7 검수 불필요.
```

**재시도 시 백업:** 기존 USER_CHECK.md는 `USER_CHECK_prev_J{J}.md`로 이름 변경 후 새 버전 덮어쓰기.

### 파일: `scripts/check-F{N}.sh` (+ `.bat` 병행)

Generator 자동 생성. `scenes/__dev/check_f{N}.tscn` 검증 씬을 Godot로 실행. Godot 바이너리 자동 탐지 실패 시 폴백 메시지 안내. 상세 포맷은 `${CLAUDE_PLUGIN_ROOT}/agents/generator.md` 참조.

## 핸드오프 #8: 사용자 피드백 → Generator (Phase 2.7 재시도)

### 파일: `docs/build/F{N}/sprints/S{마지막}-user-retry-{J}.md`

Phase 2.7에서 사용자가 "부분 재시도" 답한 경우 오케스트레이터가 작성. 사용자 코멘트를 Generator에게 줄 구체 지시로 번역.

```markdown
**F{N}, Sprint {마지막M}, 사용자 재시도 J={J}**

## 사용자 코멘트 (USER_CHECK.md에서)

### 체크 N: {§0-B 항목}
- 결과: 부분 / No
- 사용자 코멘트: "{원문 그대로}"

## Generator에게 주는 지시 (오케스트레이터 번역)

- {구체 변경 요청 — 예: "카메라 보간 속도 0.3 → 0.5초로 완화"}
- {변경 범위: 스프린트 범위 내 파일만. 다른 F에 영향 주지 말 것}

## 금지 사항

- 자동 테스트(§7.3 AC) 깨뜨리지 말 것 — Evaluator가 재확인
- 스프린트 범위 밖 파일 건드리지 말 것
- §0-B 항목 자체 변경 금지 (그건 Phase C-0 재소집 영역)

## 재시도 이력

- J=0 (원본): Generator 회차 K={완료된 K}, USER_CHECK 결과 "부분"
- J={J}: 이번 재시도
```

**Evaluator 재확인 원칙:** 사용자 피드백 반영 후 Evaluator를 다시 돌려 §7.3 AC가 여전히 PASS임을 검증. 체감 조정이 기존 자동 테스트를 깨면 즉시 FAIL → 재설계 필요.
