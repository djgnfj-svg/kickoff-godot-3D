# Kickoff Project — 3D 게임 (Godot 4) 전용 하네스

본 저장소는 **3D 게임(Godot 4) 전용**으로 두 개의 하네스를 운영한다:
- **Kickoff Harness** — why/what/how + feature-spec 문서 생성 (기획 단계)
- **Build Harness** — feature-spec을 받아 실제 코드까지 구현 (구현 단계)

두 하네스는 독립적이며 `docs/features/F{N}/feature-spec.md`가 인터페이스다.

## 프로젝트 고정 규칙

모든 문서(why/what/how/feature-spec)의 첫 줄은 `**프로젝트 종류:** 3D 게임 (Godot 4)` 헤더를 의무 포함한다. 핵심 불변 규칙은 **1플레이어 원형·1코어 결핍·1코어 버브** — 이 3요소 외의 모든 확장은 Niche Enforcer가 차단한다.

### 게임 프로젝트 고정 가정
- 엔진: **Godot 4.x**
- 에디터 자동화: **Godot MCP** (capability matrix로 관리, 진화하는 변수)
- MCP 부재 시 fallback: `godot --headless` CLI → `.tscn`/`.gd` 텍스트 편집 → 사용자 위임
- 에셋: placeholder-first 4단계 폴백 (primitive → 무료 라이브러리 → AI 생성 → 사용자 위임)
- 테스트: GUT 또는 GdUnit4

### 게임 전용 스킬
- `godot-mcp-protocol` — MCP 사용 규약 + capability matrix + 갭 보고
- `godot-scene-handoff` — 씬/리소스/프로젝트 설정 핸드오프 7항 표준
- `game-design-loop` — 코어루프·버브·페이싱·학습곡선 검토 (Kickoff용)
- `asset-pipeline` — 에셋 4단계 폴백 체인

### 게임 전용 파일 구조
- `.claude/skills/godot-mcp-protocol/references/capability-matrix.md` — MCP 현재 능력
- `docs/godot-mcp/gaps/G{N}.md` — 누적 갭 리포트
- `.claude/skills/asset-pipeline/references/ai-capability-matrix.md` — AI 에셋 생성 API 활성화 여부
- `docs/build/F{N}/assets/manifest.md` — 에셋 출처·라이선스

### MCP 개선 트랙 (선택)
갭 리포트가 누적되면 별도 세션으로 build-orchestrator의 **MCP 개선 트랙**을 실행할 수 있다 (`build-orchestrator` 스킬의 해당 섹션 참조). 게임 구현과 분리된 트랙으로 진행.

## 하네스: Kickoff Harness

**목표:** 3D 게임(Godot 4) 킥오프 단계에서 why/what/how 3대 문서와 Feature별 스펙을 체계적으로 생성한다.

**트리거:** 게임 기획·제품 정의·킥오프 문서 작성·Feature 상세화 등 초기 기획 문서화가 필요하면 `kickoff-orchestrator` 스킬을 사용하라. "다시 실행", "수정", "보완", "특정 문서만 재작성" 같은 후속 요청도 동일 스킬로 처리한다. 단순 질문·코드 작업은 직접 응답 가능.

**아키텍처:** 토론 중심 팀 + 리뷰 게이트 (하이브리드 실행 모드)
- Kickoff 팀 **7인** (Founder lead / **Game Market Researcher** / **Core Mechanic Designer** / **Hook Strategist** / **Sellability Auditor** / Niche Enforcer veto / Scribe) → Phase A에서 **토론 중심**으로 why/what/how 생성
- Phase A는 **토픽별 사이클 3회** (why / what / how). 각 사이클 5단계: 데이터(GMR 1회) → 1차 발화(CMD·HMS·SA 병렬) → 충돌 1회차(자유 토론, Founder 중재) → 충돌 2회차(재반박·방어) → 수렴(Niche veto + Scribe 문서화).
- Reviewer 팀 3인 (Architect / Implementer / QA) → how.md 검증 (전원 승인 게이트)
- Feature별 서브 에이전트 → Superpowers `brainstorming` 기반 feature-spec 생성

**핵심 불변 규칙:** 1플레이어 원형·1코어 결핍·1코어 버브. Niche Enforcer가 유일한 veto 권한을 가진다. CMD가 "깊이", HMS가 "첫인상", SA가 "시장 조건"을 각각 방어하며 서로 부딪친다.

**산출물 경로:**
- `docs/kickoff/why.md`, `what.md`, `how.md`
- `docs/kickoff/reviews/{architect,implementer,qa}.md`
- `docs/features/F{N}/feature-spec.md`

**변경 이력:**
| 날짜 | 변경 내용 | 대상 | 사유 |
|------|----------|------|------|
| 2026-04-15 | 초기 구성 (에이전트 8명, 스킬 5개) | 전체 | Kickoff Harness 신규 구축 |
| 2026-04-15 | Researcher 에이전트 + competitor-research 스킬 추가, 오케스트레이터 Phase A 재배선 | agents/researcher.md, skills/competitor-research, kickoff-orchestrator | Business가 근거 없는 경쟁 분석을 해오는 문제 해결, 웹 리서치 전담 분리 |
| 2026-04-15 | Phase 1 순차 확정 원칙 도입 (1유저→1Pain→1Action 각각 별도 확정 라운드, Phase A의 why/what/how는 기존대로 연속 진행) | kickoff-orchestrator Phase 1, niche-enforcement, founder | Phase 1에서 3요소를 한 번에 묻지 말라는 요구 반영 |
| 2026-04-15 | 경쟁사 리서치 심층화: 운영 상태/메인·부가 기능/사용자 규모 추정 필수 | competitor-research, researcher | "있다" 수준이 아니라 "운영 중, 부가 기능, 사용자 몇 명" 수준의 깊이 요구 반영 |
| 2026-04-15 | Phase 1 "원문 그대로" 원칙 추가, Founder 해석·구체화·재진술 금지 | kickoff-orchestrator Step 1-1~1-4, founder | Founder가 사용자 아이디어를 멋대로 재구성해 "이게 맞냐"고 묻는 패턴 제거 |
| 2026-04-15 | 산출물 경로 `.claude/kickoff/` → `docs/kickoff/`, `.claude/features/` → `docs/features/` 이동 | 전 에이전트/스킬 + CLAUDE.md | `.claude/` 쓰기 시 매번 권한 승인 필요한 문제 회피, `.claude/`는 하네스 구성만 유지 |
| 2026-04-15 | Phase 1 각 Step에 후보 예시 5~10개 제시 의무화 (Founder 담당) | kickoff-orchestrator Step 1-2~1-4, founder | 백지로 "누구인가요?"만 묻지 말고 선택지를 주라는 요구 반영 |
| 2026-04-15 | why/what/how/feature-spec 4종 문서에 `## 근거 (Sources)` 각주 섹션 의무화. 공통 각주 규칙 명시, Scribe 원칙·QA 체크리스트에 출처 추적성 추가 | kickoff-docs, feature-spec, scribe, qa | research_memo는 출처 엄격했으나 최종 문서에서 역추적 불가였던 문제 해결 |
| 2026-04-15 | Phase 1에 Step 1-0 신설 (아이디어 상태 A/B/C 분기). A=한 줄→Researcher 백그라운드 선행, B=도메인만→도메인 탐색, C=백지→Discovery→seed 검증. Researcher에 4가지 실행 모드(본/선행/도메인/seed), competitor-research 스킬에 3개 경량 프로토콜 추가 | kickoff-orchestrator, founder, researcher, competitor-research | 아이디어가 없거나 도메인만 있는 사용자도 Kickoff 진입 가능. Phase 1은 무거워도 됨(기획 품질 우선) |
| 2026-04-15 | Step 1-2~1-4 예시 포맷을 A+B 혼합(⭐추천 1~2개+근거 / 나머지 장단점 한 줄)으로 변경. "추천 금지" 원칙 폐기 | kickoff-orchestrator, founder | "추천 없으면 결정이 힘들다"는 사용자 지적 반영. 리서치 데이터가 추천 근거로 녹아들도록 |
| 2026-04-16 | 게임 프로젝트 도메인 확장 (1플레이어 원형·1코어 결핍·1코어 버브). kickoff-docs에 게임 전용 부록, niche-enforcement에 게임 판정 테이블, competitor-research에 게임 리서치 프로토콜(Steam/SteamDB/YouTube/코어 버브 역공학), founder/business/researcher/devil/scribe/niche-enforcer 에이전트에 게임 섹션 추가. kickoff-orchestrator Phase 0에 프로젝트 종류 감지 + Phase 1 게임 어휘 치환 + Step 1-5 게임 메타(장르/플랫폼/시점/플레이타임/멀티) 단계 추가 | kickoff 전 스킬·에이전트, 오케스트레이터, CLAUDE.md | SaaS/도구 전용이던 기존 하네스를 3D 게임(Godot 4) 프로젝트와 겸용으로 확장 |
| 2026-04-16 | 신규 스킬 `game-design-loop` 추가 — 코어루프 4단계(Anticipation/Action/Feedback/Progress), 세션 곡선, 4단계 메커닉 도입 프로토콜, 검증 가능한 프록시 지표(TTFV/VPM/Loop Duration/Session Retention/Day-1 Return) | skills/game-design-loop | 게임의 "재미"를 검증 가능한 구조로 분해하기 위한 Kickoff 전용 스킬 |
| 2026-04-16 | **SaaS 경로 완전 제거 + 3D 게임 전용 전환 + Phase A 토론 중심 재설계.** 신규 에이전트 4명(`core-mechanic-designer`/`hook-strategist`/`game-market-researcher`/`sellability-auditor`), SaaS 에이전트 3개 삭제(business/researcher/devil), 신규 스킬 2개(`hook-design-protocol`/`sellability-audit-protocol`). Phase A = 7인 팀 + 토픽별 사이클 3회 + 각 사이클 5단계(데이터→1차 발화→충돌1→충돌2→수렴). 자유 토론(Founder 중재), CMD↔HMS↔SA 충돌 축 명시. 기존 스킬 5개(kickoff-docs/niche-enforcement/competitor-research/feature-spec/kickoff-review)와 유지 에이전트 6명(founder/scribe/niche-enforcer/architect/implementer/qa)에서 SaaS 분기 제거 후 게임 전용 본문으로 재편 | 전 Kickoff 스킬/에이전트 + CLAUDE.md | 사용자가 "게임 전용 에이전트들로 채워야겠다"며 핵심 기믹/세일즈/팔리는 조건 3축으로 토론 구조 요구. 순차 릴레이식 Phase A가 실제 충돌을 만들지 못하던 문제 해결 |

## 하네스: Build Harness

**목표:** `docs/features/F{N}/feature-spec.md`를 받아 실제 코드 구현까지 진행한다. Kickoff Harness와 분리되어 있으며 feature-spec.md가 두 하네스의 계약 인터페이스다.

**트리거:** "F{N} 구현", "빌드 하네스", "스프린트 실행", "코드 생성", "다음 스프린트", "재시도", "구현 이어서", "Build Harness 수정/재실행" 등의 요청 시 `build-orchestrator` 스킬을 사용하라. feature-spec 미존재 시 Kickoff Harness를 먼저 실행해야 함.

**아키텍처:** 서브 에이전트 파이프라인 (Planner → Generator ↔ Evaluator 루프)
- Planner 1회 호출 → product-spec.md + 스프린트 분해(S{M}-plan.md) + 컨벤션 4종 초기 채우기
- Generator 스프린트 구현 → Evaluator 독립 평가 (PASS/FAIL) → FAIL 시 최대 2회 재시도 → 실패 지속 시 사용자 에스컬레이션
- 각 서브 에이전트는 **컨텍스트 리셋된 새 세션**에서 파일 기반으로만 통신 (compaction 금지)
- Generator-Evaluator는 **동일한 `build-conventions` 스킬**을 참조하여 drift 방지

**핵심 설계 근거:** Anthropic "Designing harnesses for long-running apps" (https://www.anthropic.com/engineering/harness-design-long-running-apps)
- 생성기-평가기 분리로 자기평가 편향 제거
- 컨텍스트 리셋 > compaction
- 파일 기반 자기완결적 핸드오프
- Evaluator "회의적 튠" — 하드 임계값 하나라도 미달이면 FAIL

**산출물 경로:**
- `docs/build/F{N}/product-spec.md`
- `docs/build/F{N}/sprints/S{M}-{plan,generator,evaluation}.md`, `S{M}-retry-{K}.md`, `screenshots/`
- `docs/build/F{N}/handoffs/S{M}-context.md`, `final-context.md`
- 코드 자체는 사용자 프로젝트 루트 (하네스 관리 밖)

**변경 이력:**
| 날짜 | 변경 내용 | 대상 | 사유 |
|------|----------|------|------|
| 2026-04-15 | 초기 구성 (에이전트 3명, 스킬 6개) | 전체 | Build Harness 신규 구축 — Kickoff Harness가 만든 feature-spec 이후 단계 비어 있던 문제 해결. TODO.md 1번 항목. |
| 2026-04-15 | 자동 모드 추가 (Phase 3에서 다음 F 자동 진입 + Phase 4 세션 리포트). 멈춤 조건 = 에스컬레이션/CONDITIONAL FAIL/범위 소진 3가지로 한정. 상태 파일 `docs/build/_autorun/state.md` 신설 | build-orchestrator | "자기 전에 돌려둠" 유즈케이스 지원. 중간 확인 없이 F1~FN 연속 실행 |
| 2026-04-15 | 병렬 모드(Phase P) 추가. worktree 격리 + `run_in_background` 기반 Feature별 독립 Agent. P-0 안전성 검사(선행 조건 참조 차단), 동시 실행 기본 3개. 머지는 사용자 책임 | build-orchestrator | Feature 간 코드 경로 겹치지 않을 때 병렬 구현으로 시간 단축. superpowers:using-git-worktrees + dispatching-parallel-agents 재사용 |
| 2026-04-16 | 신규 스킬 3종: `godot-mcp-protocol`(MCP 사용 + 3단계 fallback + 갭 보고), `godot-scene-handoff`(씬/리소스/프로젝트 설정 7항 표준), `asset-pipeline`(placeholder-first 4단계 폴백). build-handoff/build-conventions/sprint-planning/sprint-execution/sprint-evaluation에 게임 프로젝트 확장 섹션 추가 (Godot 4 코딩·디자인·접근성·성능 4도메인 규칙, GUT/GdUnit4 TDD, godot --headless 자동 훅, smoke 씬 의무) | build 전 스킬 + 신규 3개 | Playwright MCP 기반이던 기존 하네스를 Godot MCP + headless 기반으로 확장. feature-spec 이후 단계가 게임 도메인을 커버하지 못하던 문제 해결 |
| 2026-04-16 | Build 에이전트 6명에 게임 섹션 추가 (planner/generator/evaluator/architect/implementer/qa). Evaluator는 게임 전용 하드 임계값(크래시 0, 런타임 에러 0, Import 성공, Physics Layer 번호 고정) 추가. Architect는 Godot 프로젝트 설정·씬 그래프·MCP capability 검증. QA는 경계면 매트릭스에 게임 행(원형·결핍·버브·플랫폼·장르) 추가 | agents/{planner,generator,evaluator,architect,implementer,qa}.md | 게임 프로젝트에서 각 에이전트의 검증 기준을 게임 도메인으로 확장 |
| 2026-04-16 | build-orchestrator Phase 0-0에 프로젝트 종류 감지 추가 + 서브 에이전트 prompt에 Godot 스킬 로드 지시 + **MCP 개선 트랙** 섹션 신설. 누적된 갭 리포트를 별도 세션에서 미니 build-orchestrator로 처리하는 경로 (게임 구현과 분리) | build-orchestrator | 사용자가 Godot MCP를 직접 커스터마이즈하여 품질을 올리려는 요구 반영. MCP는 "진화하는 변수"이므로 capability matrix가 단일 진실원 |
| 2026-04-16 | **MCP 능동 파이프라인 구축.** (1) Godot MCP(bradypp) + Blender MCP(ahujasid) 설치·`.mcp.json` 등록, (2) Blender addon 자동 활성화(startup script), (3) `ensure-running.sh` 프로세스 감지+자동 실행 스크립트, (4) Planner: S{M}-plan.md에 "에셋 태스크" 테이블 필수화(필요 도구 컬럼으로 MCP 신호), (5) Generator: 구현 시작 전 ensure-running.sh로 MCP 도구 사전 준비 절차 추가, (6) Evaluator: 에셋 존재+import+manifest 교차 검증 하드 임계값 추가 | sprint-planning, sprint-execution, sprint-evaluation, generator.md, evaluator.md, .mcp.json, docs/godot-mcp/, docs/assets/ | Generator가 "MCP를 언제 호출할지" 판단 경로가 없던 문제 해결. Planner가 plan에 신호를 심고 → Generator가 읽고 실행 → Evaluator가 검증하는 3단계 파이프라인 |
