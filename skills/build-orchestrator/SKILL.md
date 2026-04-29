---
name: build-orchestrator
description: Build Harness의 전체 파이프라인 조율 스킬. docs/features/F{N}/feature-spec.md를 입력으로 받아 Planner → (Generator → Evaluator 루프) → 다음 스프린트 → Feature 완성까지를 관리한다. 사용자가 "F3 구현", "빌드 하네스 실행", "Feature 구현 시작", "스프린트 실행", "코드 생성 파이프라인", "다음 스프린트", "재시도", "구현 이어서", "Build Harness 수정/재실행" 등을 요청하거나, Kickoff Harness가 feature-spec을 모두 만든 다음 단계로 넘어갈 때 반드시 이 스킬을 사용한다. Generator-Evaluator 루프는 재시도 2회 후 사용자 에스컬레이션한다.
---

# Build Orchestrator — Build Harness 파이프라인

`docs/features/F{N}/feature-spec.md` (Kickoff Harness의 산출)를 받아 코드 구현까지 조율한다. Kickoff Harness와 완전히 분리된 하네스이며, feature-spec.md가 두 하네스 사이의 **계약 인터페이스**다.

## 실행 모드: 서브 에이전트 파이프라인

Planner → Generator → Evaluator를 **순차 서브 에이전트**로 호출한다. 각 에이전트는 **컨텍스트 리셋된 새 세션**에서 시작해 파일만 읽고/쓰고 종료. 팀 모드 아님.

이유: Anthropic "Designing harnesses for long-running apps"의 핵심 원칙 — 컨텍스트 리셋 > compaction. 재시도·다음 스프린트가 이전 세션의 탈선/불안을 물려받지 않는다.

## Agent 호출 규약

모든 서브 에이전트 호출은 다음을 지킨다:
- `subagent_type: "general-purpose"` — 빌트인 타입 사용 (에이전트 정의 파일은 `${CLAUDE_PLUGIN_ROOT}/agents/`에 존재)
- `model: "opus"` — 필수
- `prompt`에 다음을 포함:
  1. 어떤 역할로 동작할지 (`${CLAUDE_PLUGIN_ROOT}/agents/{name}.md`를 먼저 Read하라는 지시)
  2. 어떤 스킬을 먼저 로드할지 (`sprint-planning` / `sprint-execution` / `sprint-evaluation`)
  3. 이번 세션의 F{N}, S{M}, 회차 K
  4. 입력 파일 경로 목록
  5. 출력 파일 경로 (기대되는 산출)

## Phase 0. 컨텍스트 확인

오케스트레이터 진입 시 가장 먼저:

### 0-0. 프로젝트 종류 감지
- `docs/kickoff/why.md` 첫 줄에 `**프로젝트 종류:** {2D|3D} 게임 (Godot 4)` 명시되어 있으면 그걸 사용 (차원은 `docs/kickoff/_meta.md` `project_type` 참조)
- 없으면 `docs/features/F{N}/feature-spec.md` 상단 헤더 또는 사용자 요청 키워드("게임/Godot/플레이어/씬") 기반 추정
- 본 하네스는 2D/3D Godot 4 게임 전용 — **아래 "게임 프로젝트 확장"** 섹션을 Phase 1~3 내내 함께 적용

### 0-1. 사용자 요청 파싱
   - "F3 구현" / "Feature 3 실행" → F=3, 모드 = **수동(manual)**
   - "F3 스프린트 2만" → F=3, S=2만
   - "F3 이어서" → F=3, 가장 최근 미완료 스프린트부터
   - "F3 재시도" → F=3, 마지막 FAIL 스프린트 재시도
   - **자동 모드 트리거**: "F1~F5 쭉", "전부 자동", "자동 모드", "자기 전에 돌려둬", "쭉 실행", "자동 진행", "멈추지 말고", "all features" → 모드 = **자동(auto)**, 범위 = 명시된 F 집합(없으면 what.md의 모든 F)
   - **병렬 모드 트리거 (옵트인)**: "F1,F3 병렬", "병렬로", "동시에", "worktree" 같은 **명시적 키워드가 있을 때만** → 모드 = **병렬(parallel)**. 기본값은 **순차(sequential)**. 3D 게임은 씬 트리·Autoload·Physics Layers가 전 Feature에 얽혀서 코드 경로 분리가 어렵고, 의존성 깨지면 복구가 비싸다. 사용자가 명시하지 않으면 병렬 제안도 하지 않는다.

#### 0-1-a. FROZEN Feature 목록 읽기 (게임 프로젝트 필수)

`docs/features/_feature-list.md`가 존재하면 반드시 먼저 읽는다:
- `Status: FROZEN` 이 아니면 "Kickoff Harness Phase C C-0이 아직 끝나지 않았습니다. Feature 목록 확정 후 다시 실행하세요" → 종료
- `Status: FROZEN` 이면 그 표의 F 순서가 **구현 순서의 단일 진실원**. what.md의 Features 섹션과 drift가 있어도 `_feature-list.md`가 우선
- 마일스톤 행(M0a/M0b)은 Build Harness의 F 파이프라인 대상이 아니다 (how.md 마일스톤 표에서 처리). `F1`부터가 실제 Build 대상.

2. `docs/build/F{N}/` 디렉토리 존재 확인:
   - 없음 → **초기 실행** (Phase 1부터)
   - product-spec.md 존재 + 일부 스프린트 완료 → **이어서 실행** (Phase 2부터, 다음 미완료 스프린트)
   - product-spec.md 존재 + 사용자가 "전체 재실행" 요청 → 기존을 `docs/build/F{N}_prev/`로 이동 후 초기 실행
3. `docs/features/F{N}/feature-spec.md` 존재 확인. 없으면 "Kickoff Harness를 먼저 실행해야 함" 메시지 + 종료
4. **자동/병렬 모드일 때 상태 파일 작성**: `docs/build/_autorun/state.md` (자동 모드)에 범위·시작 시각·모드·멈춤 조건 기록. 병렬 모드면 `docs/build/_parallel/state.md`.

**사용자 확인 포인트 (모드별)**:
- **수동 모드**: 디렉토리가 이미 존재하면 반드시 사용자에게 현황을 보고하고 "이어서/재실행/중단" 중 선택받음.
- **자동 모드**: 시작 시 "자동 모드로 F{범위} 실행합니다. 에스컬레이션/환경 오류 외엔 멈추지 않음. 기존 F{M} 디렉토리는 **이어서** 실행으로 처리(전체 재실행 원하면 수동 모드로 재호출)." 한 번만 알리고 진행.
- **병렬 모드**: Phase P 진입 시 worktree·Feature 매핑을 한 번 보고 후 자동 진행.

## Phase 1. 계획 (Planner 호출)

초기 실행일 때만.

1. Planner 서브 에이전트 1회 호출:
   ```
   Agent(
     subagent_type: "general-purpose",
     model: "opus",
     prompt: "너는 planner 에이전트다. 먼저 ${CLAUDE_PLUGIN_ROOT}/agents/planner.md를 Read로 읽어 역할·원칙을 내재화하고, ${CLAUDE_PLUGIN_ROOT}/skills/sprint-planning/SKILL.md도 Read로 로드한 뒤 그 절차를 따른다. 이번 대상: F{N}. 입력: docs/features/F{N}/feature-spec.md, docs/kickoff/{why,what,how}.md, 사용자 프로젝트 루트. 산출: docs/build/F{N}/product-spec.md (FINAL), docs/build/F{N}/sprints/S{M}-plan.md (M=1..N), build-conventions/references/*.md 채우기. 완료 후 스프린트 수와 각 파일 경로를 반환."
   )
   ```
2. 반환값 검증: product-spec.md FINAL 상태, S{M}-plan.md 개수가 반환값과 일치
3. 결과를 사용자에게 간단히 보고 (스프린트 수 + 각 스프린트 목표 한 줄씩)

## Phase 2. 구현 루프 (스프린트별)

각 스프린트 M=1..N에 대해 순차 실행.

### 2-1. Generator 호출 (회차 K=1)

```
Agent(
  subagent_type: "general-purpose",
  model: "opus",
  prompt: "너는 generator 에이전트다. 먼저 ${CLAUDE_PLUGIN_ROOT}/agents/generator.md를 Read로 읽고, ${CLAUDE_PLUGIN_ROOT}/skills/sprint-execution/SKILL.md도 Read로 로드한 뒤 그 절차를 따른다. 이번 대상: F{N}, S{M}, 회차 1. 입력 파일 순서: docs/build/F{N}/product-spec.md, docs/build/F{N}/sprints/S{M}-plan.md, ${CLAUDE_PLUGIN_ROOT}/skills/build-conventions/references/*.md 4종. 사용자 프로젝트 루트에 코드 작성 + docs/build/F{N}/sprints/S{M}-generator.md 작성 후 결과(COMPLETE/PARTIAL) + 파일 경로 반환."
)
```

### 2-2. Evaluator 호출

```
Agent(
  subagent_type: "general-purpose",
  model: "opus",
  prompt: "너는 evaluator 에이전트다. 먼저 ${CLAUDE_PLUGIN_ROOT}/agents/evaluator.md를 Read로 읽고, ${CLAUDE_PLUGIN_ROOT}/skills/sprint-evaluation/SKILL.md도 Read로 로드한 뒤 그 절차를 따른다. 이번 대상: F{N}, S{M}, Generator 회차 1. 입력: product-spec.md, S{M}-plan.md, S{M}-generator.md, build-conventions/references/*.md, 사용자 프로젝트 루트. 독립 재현 후 S{M}-evaluation.md 작성, PASS/FAIL 결과 반환."
)
```

### 2-3. 판정 분기

- **PASS** → 스프린트 종료 처리 (Phase 2-4)
- **FAIL** → 재시도 루프 (Phase 2-5)
- **CONDITIONAL FAIL** → 환경/도구 문제. 사용자 에스컬레이션

### 2-4. 스프린트 종료 처리 (PASS 시)

1. `docs/build/F{N}/handoffs/S{M}-context.md` 작성:
   - 완료된 AC 요약
   - 현재 시스템 상태
   - 다음 스프린트(S{M+1}) 선행 조건 체크
2. 사용자에게 짧은 보고: "S{M} PASS. 다음: S{M+1} 또는 Feature 완료"
3. 분기:
   - **마지막 스프린트 아님** → Phase 2-1로 (M+1 스프린트)
   - **마지막 스프린트 (F 완료 임박)** → **Phase 2.7 (User Acceptance Gate)** 로 진입

## Phase 2.7. User Acceptance Gate (F 단위 사용자 검수)

F의 마지막 스프린트 PASS 후, Phase 3 진입 전. **자동 테스트(Evaluator)로 못 잡는 체감 이슈**(반응성·카메라 느낌·시각 피드백 인상 등)를 사용자가 직접 플레이하며 확인한다. Feature 단위로 1회만 실행 (스프린트마다 아님).

### 2-7-1. Generator 준비물

마지막 스프린트 Generator가 코드 작성과 **동시에** 다음 2개 파일을 작성 (기존 `S{M}-generator.md`에 추가로):

1. **실행 스크립트:** `scripts/check-F{N}.sh` (Windows면 `.bat`도 병행)
   - Godot 프로젝트 실행 + 해당 F 검증 씬(`scenes/__dev/check_f{N}.tscn`) 자동 로드
   - 가능하면 HUD에 §0-B 체크 가이드 텍스트 노드 표시 (예: "체크 1: WASD 눌러보세요")
   - Godot 경로 못 찾으면 "Godot 4.x 에디터에서 `scenes/__dev/check_f{N}.tscn` 열고 F5" 안내로 폴백

2. **사용자 체크리스트:** `docs/build/F{N}/USER_CHECK.md`
   - `docs/features/F{N}/feature-spec.md` 섹션 **0-A 영상 + 0-B 체크리스트**를 그대로 복제
   - 각 0-B 항목에 `- [ ]` 체크박스 + 결과/코멘트 란
   - 자동 테스트 매칭 (§7.3 AC-N 있으면 "Evaluator PASS" 표시) — 사용자는 체감 판정에만 집중
   - 하단 종합 판정: OK / 부분 재시도 / 완전 재기획

### 2-7-2. 사용자 검수 프로토콜

오케스트레이터가 사용자에게 다음 1회 안내 후 **사용자 응답 대기**:

```
F{N} 구현이 Evaluator PASS로 완료됐습니다.
자동 테스트로 못 잡는 체감을 직접 확인해주세요.

실행:   ./scripts/check-F{N}.sh  (또는 에디터에서 scenes/__dev/check_f{N}.tscn F5)
체크:   docs/build/F{N}/USER_CHECK.md 에 §0-B 항목 Y/N 기록

결과를 한 줄로 알려주세요:
  · "F{N} 전부 OK"         → Phase 3 진행
  · "F{N} N번 부분"        → Generator 재시도 (사용자 코멘트 기반)
  · "F{N} 완전 재기획"      → 에스컬레이션 (§0-B 자체 문제)
```

### 2-7-3. 재시도 (사용자 피드백 기반)

- **재시도 카운트 J** — 자동 테스트 재시도 K와 **독립**. 최대 **J=2**.
- 사용자가 "부분" 답하면:
  1. 오케스트레이터가 `docs/build/F{N}/sprints/S{마지막}-user-retry-{J}.md` 작성
     - 원본 §0-B 항목별 사용자 코멘트 (Yes/부분/No + 체감 설명)
     - 사용자 코멘트를 Generator에게 줄 구체 지시로 번역 (예: "카메라 보간 속도 0.3 → 0.5초로 완화")
  2. Generator 재호출 (회차 K는 그대로, J+1만 증가)
  3. Evaluator 재호출 — 기존 자동 테스트가 여전히 PASS인지 확인 (체감 조정이 유닛 테스트 깨뜨리면 안 됨)
  4. Phase 2.7 재진입 (USER_CHECK.md 재체크)
  5. J=2 이후에도 "부분"이면 2-7-4 에스컬레이션

### 2-7-4. 에스컬레이션 (체감 문제 특화)

사용자에게 3개 선택지 제시:

| 선택 | 의미 | 파급 |
|------|------|------|
| ① **§0-B 재협의** | 체크 항목 자체가 비현실적·모호함 → Kickoff Phase C-0 재소집 | `_feature-list.md` + `feature-spec.md` 수정, Build 해당 F 재시작 |
| ② **§7.3 AC 추가** | 체감을 자동 테스트로 재현 가능하게 Given/When/Then 보강 (예: "카메라 보간 0.5s 이내") → Planner 재호출로 스프린트 추가 | Build 해당 F에 스프린트 1개 추가 |
| ③ **이 F 일시 보류** | 종속성 없는 다른 F 먼저 진행, 이 F는 나중에 재검토 | `_feature-list.md` 해당 F Status: DEFERRED 기록 |

사용자 선택 전까지 오케스트레이터 중단.

### 2-7-5. 비가시 F 예외

§0-B 항목이 **"창에 보이는 체감"이 아닌 순수 내부 시스템** (예: 저장 로직, 네트워크 패킷)만 포함하면 Phase 2.7 건너뛰기 가능:
- Generator가 USER_CHECK.md에 "사용자 검수 필요 없음 (전부 자동 테스트 범위)" 명시
- 오케스트레이터가 이 플래그 확인 → Phase 2.7 스킵 → Phase 3 직행

판정 기준: §0-B 항목 전부가 §7.3 Given/When/Then과 1:1 매칭되고 자동 테스트로 PASS된 경우.

### 2-5. 재시도 루프 (FAIL 시)

최대 2회 재시도. K=1과 K=2.

**재시도 K 준비:**
1. `docs/build/F{N}/sprints/S{M}-retry-{K}.md` 작성 (핸드오프 #4 포맷):
   - 이전 회차 evaluation의 FAIL 사유를 우선순위 순으로 재구성
   - "금지 사항"에 Evaluator가 "피할 접근법"으로 지정한 것 명시
2. Generator 재호출 (회차 K+1):
   ```
   prompt에 "이번 대상: F{N}, S{M}, 회차 {K+1}. 반드시 S{M}-retry-{K}.md를 먼저 읽어라. S{M}-evaluation.md의 FAIL 사유도 정독."
   ```
3. Evaluator 재호출 (절차 2-2와 동일, Generator 회차 번호만 바뀜)
4. 판정:
   - PASS → Phase 2-4
   - FAIL이고 K<2 → K+1로 다시 재시도
   - FAIL이고 K=2 → **사용자 에스컬레이션** (Phase 2-6)

### 2-6. 사용자 에스컬레이션 (2회 재시도 후 FAIL)

사용자에게 다음 요지로 보고:
- F{N}/S{M} 2회 재시도 후에도 FAIL
- 마지막 FAIL 사유 3개
- Evaluator의 "체제 개선 제안" (있으면)
- 선택지 제시:
  1. **스프린트 계약 완화** — Planner를 재호출해 S{M}-plan.md의 AC 범위를 축소
  2. **Planner 재설계** — product-spec의 고수준 결정 자체를 재검토 (Planner 재호출)
  3. **수동 구현** — 사용자가 직접 코드 작성 후 Evaluator 호출로 검증만
  4. **중단** — 해당 Feature 일시 보류

사용자 선택 전까지 오케스트레이터 중단.

## Phase 3. Feature 종료

모든 스프린트 PASS 후:

1. `docs/build/F{N}/handoffs/final-context.md` 작성:
   - Feature 전체 완료 상태
   - 구현된 주요 파일·엔드포인트
   - 다음 Feature(F{N+1})로 넘어갈 때 유지해야 할 계약
2. 누적된 "체제 개선 제안"을 한 번에 사용자에게 제시 (자동 모드에서는 파일에만 기록, 차단 없음)
3. 다음 Feature 분기:
   - **수동 모드**: 사용자에게 "F{N+1} 진행할까요?" 확인. 사용자가 "F{N+1} 시작" 말하면 재트리거.
   - **자동 모드**: `docs/build/_autorun/state.md`의 범위 확인 → 다음 F가 남아 있으면 **사용자 확인 없이** Phase 0으로 돌아가 F{N+1} 진행. 범위 끝이면 Phase 4 (자동 세션 종료)로.

## Phase 4. 자동 세션 종료 (자동 모드만)

자동 모드의 모든 F가 완료(또는 에스컬레이션)되면:

1. `docs/build/_autorun/report.md` 작성:
   - 각 F별 결과 (PASS 스프린트 수 / FAIL·에스컬레이션 / 스킵)
   - 누적된 "체제 개선 제안" 전체 목록
   - 총 소요 시간, 시작·종료 시각
2. 사용자에게 한 번에 요약 보고 (컨텍스트 리셋 후 재개 시에도 이 리포트만 보면 상태 복원 가능)
3. `docs/build/_autorun/state.md`를 `state.done.md`로 이름 변경 (다음 자동 세션 시작 시 혼동 방지)

## Phase P. 병렬 모드 실행 (옵트인 전용)

**기본값 아님.** 사용자가 명시적으로 병렬 키워드를 요청했을 때만 Phase P로 진입한다. 키워드가 없으면 Phase 1~3의 순차 파이프라인을 사용하며, 오케스트레이터는 병렬을 자발 제안하지 않는다.

병렬 모드 트리거 시 Phase 1~3을 거치지 않고 Phase P로 직행.

### P-0. 병렬 안전성 검사

사용자가 병렬을 선언했더라도 최소한 다음을 확인:
1. 각 Feature의 `docs/features/F{N}/feature-spec.md` 존재
2. 각 feature-spec의 "선행 조건(Depends on)" 섹션에 **서로를 참조하지 않는지** 확인 — 참조가 있으면 사용자에게 "F{A}가 F{B}에 의존합니다. 병렬 불가능. 직렬로 전환할까요?" 질문
3. 각 feature-spec의 주요 파일 영역(Scribe가 명시) 겹침 여부 경고 (겹치면 사용자에게 "충돌 위험. 계속할까요?" 질문 — 사용자가 강행하면 진행)

검사 통과 못 하면 병렬 모드 중단, 수동 모드 제안.

### P-1. worktree 분기 + 서브 에이전트 병렬 스폰

각 Feature에 대해 **독립 Agent**를 스폰한다:

```
Agent(
  subagent_type: "general-purpose",
  model: "opus",
  isolation: "worktree",
  run_in_background: true,
  description: "F{N} 병렬 빌드",
  prompt: "너는 이 저장소의 build-orchestrator를 F{N}에 대해 실행하는 독립 에이전트다. 먼저 ${CLAUDE_PLUGIN_ROOT}/skills/build-orchestrator/SKILL.md를 Read로 로드하고, 수동 모드 규칙에 따라 F{N}을 초기 실행부터 Phase 3까지 완수해라. 단 Phase 3에서 '다음 F'로 자동 진행하지 말고 final-context.md만 쓰고 종료해라. 에스컬레이션(Phase 2-6) 발생 시 즉시 종료하고 사유를 반환값에 담아라. 병렬 세션이므로 다른 F의 상태를 가정하지 말 것."
)
```

- `isolation: "worktree"`로 각 Feature가 독립 worktree에서 작업 → 코드 충돌 원천 차단
- `run_in_background: true`로 병렬 실행. 메인 오케스트레이터는 완료 통지를 기다림
- 동시 실행 수 제한: 기본 **3개**. 초과 시 배치로 나눔 (superpowers:dispatching-parallel-agents 원칙)

### P-2. 결과 수집 + 머지 계획

모든 서브 에이전트 완료 후:
1. 각 worktree의 결과를 수집: `docs/build/F{N}/handoffs/final-context.md` 목록
2. 에스컬레이션/실패 F 목록을 별도 보고
3. worktree 머지는 **사용자가 직접 수행**. 오케스트레이터는 "머지 순서 권장" 목록만 제시 (경로 영역·테스트 영향 기준)
4. `docs/build/_parallel/report.md`에 전체 요약 기록

### P-3. 병렬 + 자동의 조합

사용자가 "F1~F5를 3개씩 병렬, 전체 자동"이라고 요청하면:
- 병렬 모드가 상위 — 한 번에 최대 3개 Feature를 worktree 병렬로 실행
- 하나 끝나면 다음 대기 Feature가 슬롯으로 들어감
- 내부적으로는 Phase P-1의 서브 에이전트 관리 패턴 유지, 배치가 끝나면 다음 배치 자동 진입

## 에러 핸들링

- **feature-spec.md 부재**: Kickoff Harness 실행 안내 + 중단
- **Planner 실패**: Planner 반환값이 기대 포맷이 아니면 1회 재호출. 재실패 시 사용자 에스컬레이션
- **Generator/Evaluator 타임아웃**: 서브 에이전트 응답이 없으면 해당 세션만 재시도. 같은 회차로 카운트 (K 증가 아님)
- **환경 문제 (CONDITIONAL FAIL)**: 절대 재시도 카운트에 넣지 않음. 사용자 에스컬레이션
- **오케스트레이터 자체 중단**: `docs/build/F{N}/sprints/`의 마지막 완성 상태까지가 재개 포인트. 사용자가 "이어서"라고 하면 Phase 0에서 감지

## 재호출/후속 요청 처리

**"F3 이어서"**: Phase 0에서 `docs/build/F3/` 현황 확인. 가장 최근 PASS 스프린트 다음부터 시작.

**"S{M} 재시도"**: 해당 스프린트의 S{M}-evaluation.md가 FAIL 상태여야 함. 아니면 "이미 PASS" 반환. 재시도 시 K는 기존 회차 이어서 증가 (K가 이미 2라면 사용자 확인 후 초기화).

**"product-spec 재설계"**: 기존 product-spec.md를 `product-spec-prev.md`로 백업, Planner 재호출. 하위 스프린트 구조가 바뀌므로 기존 sprints/도 `sprints_prev/`로 이동.

**"컨벤션 추가"**: 사용자가 새 규칙을 말하면 해당 references/*.md에 추가. 향후 스프린트부터 적용 (소급 적용은 사용자 확인 후).

## 실행 모드 명시 (Phase별 정리)

| Phase | 실행 주체 | 모드 |
|-------|----------|------|
| 0 | 오케스트레이터 본인 | 내부 로직 (트리거 파싱 + 모드 결정) |
| 1 | Planner 서브 에이전트 1회 | 서브 |
| 2-1 | Generator 서브 에이전트 | 서브 |
| 2-2 | Evaluator 서브 에이전트 | 서브 |
| 2-5 | Generator + Evaluator 재호출 | 서브 |
| 2-6 | 오케스트레이터가 사용자와 대화 | 직접 (에스컬레이션 — 자동 모드에서도 차단) |
| 3 | 오케스트레이터 본인 | 내부 로직 (수동=사용자 확인 / 자동=다음 F로 즉시) |
| 4 | 오케스트레이터 본인 | 자동 세션 종료 리포트 |
| P | 오케스트레이터 본인 + 병렬 Agent들 | 서브 병렬 (isolation=worktree) |

팀 모드 없음. SendMessage 없음. 파일 기반 핸드오프만.

### 모드 매트릭스

| 사용자 요청 예 | 직렬/병렬 | 자동/수동 | 핵심 차이 |
|----------------|-----------|-----------|-----------|
| "F3 구현" | 직렬 | 수동 | 기본. 모든 확인 포인트 유지 |
| "F1~F5 쭉 실행" / "자동 모드" | 직렬 | 자동 | Phase 3에서 사용자 확인 스킵, 에스컬레이션만 멈춤 |
| "F1,F3 병렬" | 병렬 | 수동 | Phase P 진입. worktree 격리 |
| "F1~F5 병렬 자동" | 병렬 | 자동 | 배치 병렬 + 배치 간 자동 진행 (P-3) |

### 자동 모드의 멈춤 조건 (명시)

자동 모드는 **오직 다음 3가지에서만** 멈춘다:
1. **에스컬레이션(Phase 2-6)** — 재시도 2회 후 FAIL
2. **환경 문제(CONDITIONAL FAIL)** — 빌드 환경/도구 이상 (재시도 카운트에 안 들어감)
3. **전체 범위 완료** — `_autorun/state.md`의 F 범위가 소진됨 (Phase 4)

그 외 FAIL·PARTIAL·리뷰 실패·체제 개선 제안은 **파일에만 기록하고 다음으로 진행**. "자다가 돌아가게" 유즈케이스의 계약이다.

### 병렬 모드의 안전 경계

- Feature 간 **코드 경로 겹침** = 사용자 자기책임. P-0에서 경고는 하되 강행 허용
- Feature 간 **선행 조건 참조** = 강제 차단. 직렬 전환 제안
- worktree 머지는 **자동화하지 않음**. 사용자가 직접 (충돌 책임 분리)
- 동시 실행 수 기본 3개 한도 (Opus 부하 및 빌드 환경 안정성 고려)

## 테스트 시나리오

### 정상 흐름

**트리거:** "F3 구현 시작해줘"
1. Phase 0: `docs/build/F3/` 없음 확인 → 초기 실행
2. Phase 1: Planner 호출 → product-spec.md + S1-plan.md (단일 스프린트) 산출
3. Phase 2-1: Generator S1 회차 1 → S1-generator.md (COMPLETE) 산출
4. Phase 2-2: Evaluator 회차 1 → S1-evaluation.md (PASS)
5. Phase 2-4: S1-context.md 작성
6. Phase 3: Feature 종료 보고

### 에러 흐름 (재시도 후 성공)

**트리거:** "F3 구현"
1. Phase 0, 1 동일
2. Phase 2-1: Generator 회차 1 → PARTIAL 또는 COMPLETE
3. Phase 2-2: Evaluator 회차 1 → FAIL (AC2 재현 실패)
4. Phase 2-5: S1-retry-1.md 작성 → Generator 회차 2 → Evaluator 회차 2 → PASS
5. Phase 2-4: 종료 처리

### 에러 흐름 (에스컬레이션)

**트리거:** "F3 구현"
1. Phase 0, 1 동일
2. Phase 2-1/2-2 반복, K=1과 K=2 모두 FAIL
3. Phase 2-6: 사용자에게 4가지 선택지 제시 → 오케스트레이터 대기

### 자동 모드 흐름

**트리거:** "F1~F5 자동 모드로 돌려줘. 자기 전에"
1. Phase 0: 모드=자동, 범위=[F1..F5]. `_autorun/state.md` 작성. 사용자에게 한 번 알림 후 진행.
2. F1 Phase 1~3 진행 → PASS → Phase 3에서 **사용자 확인 없이** F2 진입
3. F2 Phase 2-6 에스컬레이션 → `_autorun/state.md`에 기록 + Phase 2-6 사용자 에스컬레이션 발동 (자동 모드에서도 차단)
4. 사용자가 에스컬레이션 해결(예: "계약 완화")하면 F2 재개, 해결 후 F3 진입
5. F3~F5 연속 → 모두 PASS → Phase 4 리포트 → 세션 종료

### 병렬 모드 흐름

**트리거:** "F1, F2, F3 병렬로 실행"
1. Phase 0: 모드=병렬. Phase P-0 안전성 검사 → feature-spec 서로 참조 없음 확인.
2. Phase P-1: Agent 3개 스폰 (isolation=worktree, run_in_background=true)
3. 각 Agent는 자기 worktree에서 수동 모드 build-orchestrator를 F{N}에 대해 실행
4. Phase P-2: 3개 모두 완료 → final-context.md 수집 → 머지 순서 권장 목록 사용자에게 제시
5. 사용자가 직접 머지 (오케스트레이터 개입 없음)

## 관련 산출물 경로 요약

```
docs/build/
├── F{N}/
│   ├── product-spec.md                 # Planner
│   ├── sprints/
│   │   ├── S{M}-plan.md                # Planner
│   │   ├── S{M}-generator.md           # Generator (회차별 덮어쓰지 않음 — 아니, 실제로는 덮어쓴다. git으로 이력)
│   │   ├── S{M}-evaluation.md          # Evaluator
│   │   ├── S{M}-retry-{K}.md           # Orchestrator (K=1,2)
│   │   └── screenshots/                # 사용자 검수 시각 자료 (선택)
│   │       └── S{M}-AC{k}.png
│   └── handoffs/
│       ├── S{M}-context.md             # Orchestrator (스프린트 PASS 후)
│       └── final-context.md            # Orchestrator (Feature 완료 후)
├── _autorun/                           # 자동 모드 세션 상태
│   ├── state.md                        # 진행 중 (범위·시작시각·현재 F·에스컬레이션 이력)
│   ├── state.done.md                   # 종료 후
│   └── report.md                       # Phase 4 리포트
└── _parallel/                          # 병렬 모드 세션 상태
    ├── state.md                        # 진행 중 (worktree-Feature 매핑, 배치 큐)
    └── report.md                       # P-2 리포트
```

### 자동 모드 상태 파일 (`docs/build/_autorun/state.md`)

```markdown
# Autorun Session State
**Mode:** auto
**Started:** YYYY-MM-DD HH:MM
**Scope:** [F1, F2, F3, F4, F5]
**Current:** F{N}
**Completed:** [F1, F2]
**Escalated:** [F3 (S2 재시도 2회 후 FAIL — 사유 링크)]
**Stop-Conditions:** 에스컬레이션 / CONDITIONAL FAIL / 범위 소진

## 이벤트 로그
- HH:MM F1 시작
- HH:MM F1 PASS (스프린트 3개)
- ...
```

### 병렬 모드 상태 파일 (`docs/build/_parallel/state.md`)

```markdown
# Parallel Session State
**Mode:** parallel (auto=on/off)
**Started:** YYYY-MM-DD HH:MM
**Concurrency:** 3
**Pending:** [F4, F5]
**Running:** [F1 @ worktree-A, F2 @ worktree-B, F3 @ worktree-C]
**Done:** []
**Failed:** []
```

---

## 게임 프로젝트 (3D 게임 — Godot 4) 확장

Phase 0-0에서 **게임 프로젝트**로 판별되면 아래를 적용한다.

### 서브 에이전트 prompt 확장 (Phase 1/2-1/2-2/2-5)

각 호출의 `prompt`에 **추가 스킬 로드 지시**를 포함:

**Planner 호출 (Phase 1):**
```
... sprint-planning/SKILL.md 외에 다음도 Read로 로드해라:
- ${CLAUDE_PLUGIN_ROOT}/skills/godot-scene-handoff/SKILL.md
- ${CLAUDE_PLUGIN_ROOT}/skills/asset-pipeline/SKILL.md
또한 docs/kickoff/_meta.md를 먼저 읽어 project_type(2D 게임/3D 게임)을 확인한 뒤 그에 맞는 노드 가정으로 작업한다.
이 프로젝트는 Godot 4 게임이므로 product-spec.md에 7항(Godot 프로젝트 설정), 각 S{M}-plan.md에 7항(Godot 영향)을 포함해야 한다.
```

**Generator 호출 (Phase 2-1, 2-5):**
```
... sprint-execution/SKILL.md 외에 다음도 Read로 로드해라:
- ${CLAUDE_PLUGIN_ROOT}/skills/godot-scene-handoff/SKILL.md
- ${CLAUDE_PLUGIN_ROOT}/skills/asset-pipeline/SKILL.md
또한 docs/kickoff/_meta.md를 먼저 읽어 project_type을 확인한다.
Godot 조작은 .tscn/.gd/.tres/project.godot 텍스트 직접 편집(Edit/Write) + `godot --headless --import` smoke를 기본 경로로 사용한다. 시각 확인이 필요한 단계는 사용자 위임으로 명시한다. S{M}-generator.md에 7항(Godot 산출 요약) 포함.
```

**Evaluator 호출 (Phase 2-2):**
```
... sprint-evaluation/SKILL.md 외에 다음도 Read로 로드해라:
- ${CLAUDE_PLUGIN_ROOT}/skills/godot-scene-handoff/SKILL.md
또한 docs/kickoff/_meta.md를 먼저 읽어 project_type을 확인한다.
`godot --headless` CLI + 텍스트 검증으로 독립 재현한다. 게임 전용 하드 임계값(크래시 0, 런타임 에러 0, Import 성공) 추가. 시각 확인은 Phase 2.7 사용자 검수로 위임.
```

### 파일 구조 추가 (게임 프로젝트)
```
docs/
└── build/F{N}/
    └── assets/
        ├── manifest.md                 # Generator (라이선스·출처)
        └── prompts/                    # (선택) 사용자가 외부에서 가져온 에셋의 메모
            └── {name}.md
```

### 검증 훅 (Phase 2-2 기본 세트)
- `godot --headless --import` (exit 0)
- `godot --headless --check-only`
- GUT/GdUnit4 테스트 실행
- Smoke 씬 실행 (`scenes/__dev/sprint_{M}_smoke.tscn`)
- (벤치 씬 있으면) 성능 벤치 10초 실행

### 게임 전용 테스트 시나리오

**트리거:** "F2 구현 시작" (게임 프로젝트)
1. Phase 0: `docs/kickoff/_meta.md`의 project_type(2D/3D) 감지 → Planner prompt에 godot-scene-handoff/asset-pipeline 스킬 로드 지시 포함
2. Phase 1: Planner → product-spec.md (7항 Godot 설정 포함), S1-plan.md (7항 Godot 영향 포함)
3. Phase 2-1: Generator → `.tscn`/`.gd` 텍스트 편집으로 플레이어 씬 작성, `godot --headless --import` smoke 통과, 시각 확인 필요한 부분은 사용자 위임
4. Phase 2-2: Evaluator → `godot --headless --quit-after 5 scenes/__dev/sprint_1_smoke.tscn` exit 0 확인, `.tscn` 텍스트에서 차원별 노드(3D=CharacterBody3D / 2D=CharacterBody2D) 존재 확인
5. PASS → 다음 스프린트
