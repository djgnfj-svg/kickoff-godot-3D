# Kickoff Project — 2D/3D 게임 (Godot 4) 하네스

본 저장소는 **2D/3D Godot 4 게임 프로젝트**용으로 두 개의 하네스를 운영한다:
- **Kickoff Harness** — why/what/how + feature-spec 문서 생성 (기획 단계)
- **Build Harness** — feature-spec을 받아 실제 코드까지 구현 (구현 단계)

두 하네스는 독립적이며 `docs/features/F{N}/feature-spec.md`가 인터페이스다.

## 프로젝트 고정 규칙

모든 문서(why/what/how/feature-spec)의 첫 줄은 `**프로젝트 종류:** {2D|3D} 게임 (Godot 4)` 헤더를 의무 포함한다 (차원은 Phase 0-1에서 사용자에게 명시 질문하여 변수화). 핵심 불변 규칙은 **1플레이어 원형·1코어 결핍·1코어 버브** — 이 3요소 외의 모든 확장은 Niche Enforcer가 차단한다.

### 게임 프로젝트 고정 가정
- 엔진: **Godot 4.x**
- 에디터 작업: `.tscn`/`.gd`/`.tres` 텍스트 직접 편집 + `godot --headless --import` smoke + 시각 확인은 사용자 위임
- 에셋: placeholder-first 2단계 폴백 (Godot 내장 primitive/ColorRect → 사용자 위임)
- 테스트: GUT 또는 GdUnit4

### 게임 전용 스킬
- `godot-scene-handoff` — 씬/리소스/프로젝트 설정 핸드오프 7항 표준
- `asset-pipeline` — 에셋 2단계 폴백 체인

### 에이전트 통합 프로토콜
1인-전용 스킬 6개(`competitor-research` / `game-design-loop` / `hook-design-protocol` / `sellability-audit-protocol` / `niche-enforcement` / `kickoff-review`)는 스킬 개수 축소(19→13)를 위해 각 담당 에이전트 내부 `## 통합 프로토콜:` 섹션으로 흡수되었다. 사용처:
- `game-market-researcher.md` §통합 프로토콜: competitor-research
- `core-mechanic-designer.md` §통합 프로토콜: game-design-loop
- `hook-strategist.md` §통합 프로토콜: hook-design-protocol
- `sellability-auditor.md` §통합 프로토콜: sellability-audit-protocol
- `niche-enforcer.md` §통합 프로토콜: niche-enforcement
- `build-auditor.md` §통합 프로토콜: 2인 리뷰 게이트 운영 규칙 (qa.md도 같은 규칙 참조)

### 게임 전용 파일 구조
- `docs/build/F{N}/assets/manifest.md` — 에셋 출처·라이선스

### 플러그인 구조 (kickoff-godot 플러그인)
이 레포지토리는 Claude Code 플러그인 `kickoff-godot` 그 자체다. 디렉토리:
- `.claude-plugin/plugin.json` — 플러그인 매니페스트
- `agents/` — 에이전트 정의 (12개: founder·scribe·core-mechanic-designer·hook-strategist·game-market-researcher·sellability-auditor·niche-enforcer·build-auditor·qa·planner·generator·evaluator)
- `skills/` — 스킬 (11개, 스킬 호출 시 `/kickoff-godot:<skill-name>` 네임스페이스)
- `.mcp.json` — 비어 있음 (`{ "mcpServers": {} }`)

로컬 개발: `claude --plugin-dir .` 로 플러그인 로드. 스킬·에이전트 수정 후 `/reload-plugins` 로 핫 리로드.

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
| 2026-04-20 | 신규 스킬 `visual-gate` 추가 — superpowers brainstorming Visual Companion 이식 + 게임 도메인 확장. HTTP 서버(Node)+HTML fragment 방식으로 Claude가 직접 그린 씬·HUD·카메라·타이밍·씬트리·레벨 격자·실루엣을 브라우저에 띄우고 사용자가 클릭으로 선택. 환경변수·경로·제목을 `VISUALGATE_*` / `.superpowers/visual-gate/` / "Visual Gate"로 네임스페이스 변경. 게임 도메인 CSS 8종(`scene-mockup`/`hud-slot`/`camera-diagram`/`timeline-bar`/`node-graph`/`silhouette`/`tile-grid`/`depth-axis`) 추가, 웹 전용 mock-* 클래스 제거. `references/css-classes.md`·`references/gate-patterns.md` 2종 레퍼런스. `.gitignore`에 `.superpowers/` 등록. AI 이미지 생성·외부 이미지 파이프라인 불채택 (모든 시각 요소를 Claude가 HTML/CSS/SVG로 즉석 작성). **에이전트·오케스트레이터에 호출 훅 배선은 차후 스프린트** | 신규 `.claude/skills/visual-gate/` (SKILL.md + scripts 4개 + references 2개), `.gitignore` | 기획·구현 전 구간에서 시각 결정(시점/HUD/타이밍/레벨/씬트리 등)이 텍스트만으로는 결정 불가능. AI·사람이 같은 그림을 보며 싱크 맞추는 인프라 필요 |
| 2026-04-20 | **visual-gate v2 시연 + Quality Bar 확정 + 에이전트 6명 배선.** (1) SKILL.md에 "Quality Bar" 섹션 신설 — 필수 5요소(scene-mockup 16:9 / 실제 장면 흉내 / 보조 도식 / HUD 예시 / 레퍼런스 게임 2~3개) + 금지 3개 + 자체 검증 3질문. v1 추상 도식은 "잘 이해 안 된다" 피드백으로 거부, v2(실제 게임 화면 흉내) 확정. (2) `references/3d-upgrade-path.md` 신설 — model-viewer·Three.js 선택적 업그레이드 경로 문서화 (현재 불채택, 트리거 조건만 기록). (3) 에이전트 6명(founder/hook-strategist/core-mechanic-designer/sellability-auditor/planner/generator)에 "Visual Gate 사용" 섹션 추가 — 호출 지점 표(Phase×Gate 패턴) + 결과 활용 규약 + 중복 게이트 금지 규칙 | `.claude/skills/visual-gate/SKILL.md`, `.claude/skills/visual-gate/references/3d-upgrade-path.md`, `.claude/agents/{founder,hook-strategist,core-mechanic-designer,sellability-auditor,planner,generator}.md` | 사용자가 v1 시연(점/삼각형) 보고 "이해 안 된다", v2(실제 게임 화면 흉내) 보고 "굉장히 좋다, 이렇게 뽑으라고 에이전트 업데이트해줘" 요청. 품질 기준을 코드로 박아 모든 에이전트가 동일 수준으로 뽑도록 강제 |
| 2026-04-20 | **Phase 1 대화 흐름 전면 재정의.** 기존 "해석·재진술 금지 + 원문 그대로"가 너무 경직돼 "대화 없는 인터뷰 양식"이 되는 문제 해결. (1) 새 원칙: **"원문 덮어쓰기 금지 + 해석·갱신은 별도 섹션에 사용자 명시 동의 후 저장 + 각 Step은 여러 턴 자연 대화"**. (2) **Step 1-1에 4축(장르·메커닉·테마·포맷) 추출 게이트 신설** — 2축+ OK / 1축 엉성→보강 대화(3축 질문+패스 허용) / 0축→C 강등. (3) **리서치 범위를 사용자에게 공개** — Founder가 Step 1-1-c에서 경쟁작 리스트 제시, 사용자 추가·제외 가능. (4) **Step별 리서치 의존도 차등** — 1-2는 리서치 없이 ⭐ 중립 나열 / 1-3부터 ⭐ 본격 활용. (5) **⭐ 추천 3축 기준 확정 — A(리뷰 불만 반복성) / B(시장 공백) / C(시장 규모)**, 2축+ 충족 시만 ⭐. (6) **시스템 용어 금지** — "축이 비어있다" 대신 생활 맥락 후속 질문. (7) **Step 완료 조건 = Founder 정리 블록 + 사용자 명시 동의**. (8) **각 confirmed_*.md는 "## 대화 원문" + "## 확정 요약" 2섹션 구조**. | `.claude/skills/kickoff-orchestrator/SKILL.md` Phase 1 전체, `.claude/agents/founder.md` 작업 원칙 재작성, `.claude/agents/game-market-researcher.md` 선행 모드 세부화 + ⭐ 3축 기준 + 구 잔재(user/pain/action) 제거 | 사용자 피드백 반복: "모호한 채로 넘어가면 안 됨"·"한 줄이 엉성하면?"·"리서치가 끝나고 시작이냐, 뭘 보고 리서치?"·"자연 대화 없이 축 언급은 이상함". 기존 설계의 순환 논리(리서치↔⭐) 및 경직성 해소 |
| 2026-04-20 | **Phase B 리뷰어 3인 → 2인 체계 + 체크리스트 슬림화.** (1) `architect.md` + `implementer.md` 삭제 → `build-auditor.md` 1개로 병합. 새 역할 정의: **"Generator가 막히지 않고 Walking Skeleton까지 갈 수 있는가?"만 본다** (평가 아닌 막힘 진단). (2) 체크리스트 14항+거부 7개 → **6항+거부 2개**로 슬림화. **제거**: 학습 일정(팀 내부), Steam 출시 일정(SA 담당), 렌더러 선택 근거(취향), Autoload 5+ 거부(베스트 프랙티스), 멀티/콘솔/엔진이식 거부(스코프 = Niche 담당). **유지**: Walking Skeleton 정의, M1 코어루프 닫힘, 구현 구체성 최소 세트(Godot 버전·InputMap·Physics Layers), MCP 갭 fallback, 에셋 4단계 폴백, 성능 타깃 현실성. (3) Day 1~3 상상 경로 + 거부 신호 2개(Walking Skeleton 스캐폴딩·구현 지시 누락) 유지. (4) **QA는 그대로 유지** — why/what/how 3문서 교차 정합성은 "구현 가능성"과 다른 축이라 통합 불가. (5) kickoff-review SKILL.md 재작성(3인 → 2인), kickoff-orchestrator Phase B 팀 구성 수정, kickoff-docs/build-conventions/godot-scene-handoff의 `architect 리뷰` 참조 3건 갱신 | `.claude/agents/build-auditor.md` (신규), `.claude/agents/architect.md` (삭제), `.claude/agents/implementer.md` (삭제), `.claude/agents/qa.md` (참조 갱신), `.claude/skills/kickoff-review/SKILL.md` (재작성), `.claude/skills/kickoff-orchestrator/SKILL.md` (Phase B 수정 + 산출물 경로), `.claude/skills/kickoff-docs/SKILL.md`, `.claude/skills/build-conventions/SKILL.md`, `.claude/skills/godot-scene-handoff/SKILL.md` | 사용자 지적: "이 리뷰 필요한가? 시장성 + 구현 가능성만 평가하면 될 듯". 분석 결과 시장성은 Phase A SA가 이미 담당하므로 Phase B에 불필요, Architect/Implementer 7+7항 중복이 많고 두 사람이 같은 "구현 가능성" 축을 다른 각도로 검증. 추가 지적: "멀티 거부는 프로젝트에 따라 다를 수 있음" + "학습 기간은 왜 있어? 과다" → 스코프 판정을 Niche로 명확히 이관하고 체크리스트를 "Generator 막힘 진단"만으로 슬림화 |
| 2026-04-20 | **Feature 단위 확인 체크리스트 3~5개 강제 + 로드맵 카드·목록·Phase D에 전시.** (1) `feature-spec.md` 섹션 0을 **0-A (영상 한 문단) + 0-B (Yes/No 체크리스트 3~5개)**로 분리. 0-B는 측정 가능해야 하며, 개수(3~5) 외 벗어나면 저장 거부. 형용사만 있는 항목("재미있게" 등)은 경고 + 재작성. 정식 Given/When/Then은 여전히 §7.3. (2) `_feature-list.md` 템플릿에 표 아래 **"확인 체크리스트 (각 F)" 서브섹션** 추가 — 각 F의 0-B를 그대로 인용하여 전시 (drift 없게). (3) `feature-roadmap` 카드 body에 **4요소 필수** — 보이는 것 / 확인 ul(3~5) / 순서·의존 / 레퍼런스 게임. 예시 HTML(M0a·M0b·F1) 모두 업데이트. (4) Phase D 체크리스트에 0-A/0-B 분리 검증 + `_feature-list.md` 확인 섹션 존재 + `_roadmap.html` 카드 4요소 존재 추가. | `.claude/skills/feature-spec/SKILL.md` (0-A/0-B 분리 + 0-B 검증 규칙), `.claude/agents/scribe.md` (`_feature-list.md` 템플릿에 확인 체크리스트 섹션), `.claude/skills/visual-gate/references/gate-patterns.md` (§10 카드 4요소 명시 + HTML 예시 업데이트), `.claude/skills/kickoff-orchestrator/SKILL.md` (Phase D 체크리스트 확장) | 사용자 지적: "F 단위에 확인해야 할 것도 나오게 해줘". 현재 섹션 0(영상 한 문단)과 §7.3(정식 AC) 사이에 Yes/No 검증 가능한 짧은 체크리스트가 없어서, 로드맵만 보고 "완성됐는지 어떻게 판단?" 답이 안 나오던 문제 해결. 로드맵·목록·feature-spec 세 위치에 동일 체크리스트 전시하여 단일 진실원(feature-spec 0-B)에서 파생하는 구조 |
| 2026-04-20 | **Phase C 재구성 (C-0 Feature 목록 확정 게이트 + M0a/M0b 분리 + feature-spec 섹션 0 강제 + 병렬 옵트인 하향) + Feature 로드맵 Visual Gate 패턴.** (1) Phase C에 **C-0 서브스텝 신설** — Scribe가 `_feature-list.md` + `_roadmap.html` 최종본 작성 → Visual Gate `feature-roadmap` 패턴으로 사용자에게 로드맵 제시 → OK면 FROZEN, 수정이면 **경미/중간/중대 3단계 판정** 후 티키타카 (Founder가 규모 투명 공개). FROZEN 이후 Phase C-1(병렬 feature-spec) 진입. (2) **M0를 M0a(MCP 환경 검증, 코드 0줄) + M0b(Walking Skeleton)로 분리** — M0a는 Godot MCP 에디터 열림 + Blender MCP 블렌더 열림 + 빈 프로젝트 smoke 실행 성공. kickoff-docs 마일스톤 표, build-auditor 체크리스트 1번, kickoff-review에 반영. (3) **feature-spec 템플릿에 섹션 0 (완료 시 보여야 하는 화면·플레이) 강제** + 금지 표현 감지 (`~생성/구현/시스템/컨트롤러`로 끝나는 한 줄 저장 거부). Feature 목표를 동작·명사가 아닌 화면·플레이 결과로 기술. (4) **visual-gate에 `feature-roadmap` 패턴 신규** — F 카드 나열 + 화살표 의존성 + 하단 OK/수정 옵션, `_roadmap.html`로 영구 보관 (Build Harness도 참조). (5) **Build Harness 병렬 모드를 옵트인으로 하향** — 기본은 순차, 사용자가 명시적으로 "병렬"/"동시에"/"worktree" 키워드 요청 시만 Phase P. Kickoff FROZEN `_feature-list.md` 순서가 구현 순서의 단일 진실원. | `.claude/skills/kickoff-orchestrator/SKILL.md` (Phase C 전면 재구성 + C-0 + 3단계 판정 + 산출물 경로 + Phase D 체크리스트), `.claude/skills/visual-gate/references/gate-patterns.md` (feature-roadmap 패턴 §10 추가), `.claude/skills/feature-spec/SKILL.md` (템플릿 섹션 0 + 금지 표현 감지), `.claude/skills/kickoff-docs/SKILL.md` (M0a/M0b 2단계 마일스톤), `.claude/agents/scribe.md` (`_feature-list.md` + `_roadmap.html` 작성 + 중간 변경 시 what.md 동시 갱신), `.claude/agents/founder.md` (C-0 변경 규모 3단계 판정 원칙 + Visual Gate 호출 지점 추가), `.claude/agents/build-auditor.md` (체크리스트 1번 M0a/M0b 반영 + Day 0 추가), `.claude/skills/build-orchestrator/SKILL.md` (FROZEN 목록 읽기 0-1-a 신설 + 병렬 옵트인 하향), `.claude/skills/kickoff-review/SKILL.md` (M0a/M0b 반영) | 사용자 요구 3가지 연쇄 반영: ① "M0로 MCP 테스트 + 에디터 열기 + 블렌더 열기가 필수" → M0a 신설, ② "F1/F2/F3 순서대로 구현 + 각 F는 확실한 화면·플레이 목표" → 병렬 옵트인 + 섹션 0 금지 표현 + Feature 로드맵 + 순차 기본값, ③ "사용자랑 티키타카로 F 목록 정리 + F 단위 화면 미리보기 로드맵" → C-0 최종본 제시 + Visual Gate 로드맵. 구조적 변경 규모 3단계(경미/중간/중대) 판정을 투명 공개하여 사용자가 "중대인 줄 모르고 말했다가 놀라는" 상황 방지 |

| 2026-04-29 | **Phase D에 GDD/PRD 합본 컴파일 단계 추가 (파생 뷰).** Phase D를 D-0(5종 검증) → D-1(GDD.md 컴파일) → D-2(PRD.md 컴파일) → D-3(합본 검증) → D-4(보고)로 재편. (1) `docs/kickoff/GDD.md` — Game Design Document 5~10p, why/what/game_meta/confirmed_*/sellability_memo 압축, 외부 공유·피칭용. 0~6번 섹션(한 줄 요약 / 원형·결핍·버브 / 코어루프 / 3층 훅 / 게임 메타 / 시장·가격 / 출처). (2) `docs/kickoff/PRD.md` — Product Requirements Document 마일스톤 walkthrough, _feature-list + how.md + 각 F의 §0-A/§0-B/§7.3 컴파일, 구현 진입점. 각 마일스톤 행에 동작 기준 + 자동 테스트 + 사용자 검수 3축 명시. **비주얼 완성도 축은 도입하지 않음** (사용자 결정). (3) 둘 다 **파생 뷰** — 5종 단일 진실원에서 Scribe가 자동 생성, 직접 편집 금지, 5종 갱신 시 재컴파일. (4) build-handoff 디렉토리 레이아웃에 `docs/kickoff/{GDD,PRD}.md` 노출 (Build는 읽기 전용, 미수정). | `.claude/agents/scribe.md` (Phase D 합본 산출물 섹션 신설, GDD/PRD 템플릿), `.claude/skills/kickoff-orchestrator/SKILL.md` (Phase D D-0~D-4 재편 + 산출물 경로 추가), `.claude/skills/build-handoff/SKILL.md` (디렉토리 레이아웃에 GDD/PRD 추가) | 사용자 요구: "GDD 나오고 PRD 나오고 그 안에 마일스톤 + 테스트 — 매 마일스톤이 동작·테스트 완성된 상태로 전진". 기존 5종 분리 산출물(why/what/how/_feature-list/feature-spec)이 외부 공유·구현 진입점에 부적합 → 합본 2종을 파생 뷰로 추가. 비주얼 5축은 사용자가 명시적으로 제외 |

| 2026-04-29 | **M0a 마일스톤 폐지 → M0 사전 게이트로 흡수.** v0.2.0 MCP 인프라 제거 후 M0a 정의가 "MCP 환경 검증"에서 "`godot --headless --import` 종료코드 0" 명령어 1줄로 단순화 → 별도 마일스톤으로 둘 가치 약함. M0a 행 제거, M0b → M0 rename, "사전 게이트(코드 0줄)"는 마일스톤이 아닌 진입 조건으로 처리. 영향 6파일: `agents/{scribe,build-auditor}.md`, `skills/{kickoff-docs,kickoff-orchestrator,build-orchestrator,sprint-planning}/SKILL.md` + 2D/3D references 2건. _feature-list.md/PRD/build-auditor 체크리스트 모두 M0 단일 행 + 사전 게이트 명시 구조로 정합. | 위 6파일 | 사용자: "godot만 확인하면 되는데". M0a 분리는 MCP 시절 정당화됐으나 v0.2.0 이후 ceremony 과함. 환경 검증은 진입 조건으로 한 줄 명시하면 충분 |

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
| 2026-04-20 | **하네스 전체 점검 후 drift 5건 수정.** (1) `scribe.md`의 `_feature-list.md` 템플릿에 **"기술 통합 리스트"** 섹션 실제 구현 (씬 · 스크립트 · Autoload · Physics Layers · InputMap 집계 + F별 누적 규모 요약) — 이전엔 언급만 있고 실제 섹션 없음. (2) `build-handoff/SKILL.md`에 **핸드오프 #6·#7·#8 신규 등록** — `_feature-list.md` / `_roadmap.html` 읽기 전용 입력 계약 + `USER_CHECK.md` + `S{M}-user-retry-{J}.md` + `check-F{N}.sh` 포맷 4종. (3) `kickoff-orchestrator` Phase D 체크리스트에 **기술 통합 리스트 존재 + 공통 누락 점검 4항목 해결** 추가. (4) `sprint-planning/SKILL.md`에 **Kickoff FROZEN 입력 계약**(씬·스크립트·Autoload·Physics·InputMap 수정/삭제 허용 매트릭스) + **feature-spec 10섹션 필수 체크** + 불완전 시 Planner 반송 규칙. (5) `evaluator.md`에 **§7.3 vs §0-B 책임 경계** 명시 — Evaluator는 §7.3만 담당, §0-B 체감은 Phase 2.7 사용자 전담. 경계 위반 금지 | `.claude/agents/scribe.md`, `.claude/skills/build-handoff/SKILL.md`, `.claude/skills/kickoff-orchestrator/SKILL.md`, `.claude/skills/sprint-planning/SKILL.md`, `.claude/agents/evaluator.md` | 사용자 "전체 훑어보고 이상한부분 점검" 요청에 대응. 이전 변경들이 에이전트·오케스트레이터에는 반영됐으나 표준 스킬 2개(build-handoff, sprint-planning)와 evaluator에 drift 발생. 핸드오프 표준이 단일 진실원이 되어야 신규 파일 포맷(USER_CHECK 등)이 Generator·Evaluator·Planner 전체에 동기화됨 |
| 2026-04-20 | **Phase C-0 공통 누락 점검 4항목 추가 (메인 메뉴·게임오버·설정·일시정지).** 플레이 핵심(이동·전투)에만 집중하다 UI/흐름 F를 빼먹는 문제 해결. Scribe가 `_feature-list.md` FROZEN 전에 4항목을 각각 ✅포함/⚠️의도적 제외(사유 1줄)/❌누락 중 하나로 판정. ❌ 하나라도 있으면 FROZEN 불가, Founder가 사용자에게 포함/제외 질문. Walking Skeleton(M0b)은 메뉴 없이 바로 플레이라 MVP 초기엔 의도적 제외가 보통이지만 **"잊은 게 아니라 뺀 결정"**이 기록되어야 한다 | `.claude/agents/scribe.md` (Phase C C-0 공통 누락 점검 섹션 신설 + `_feature-list.md` 템플릿 확장) | 사용자 지적: "게임 시작할 때는 메인 창이랑 이런 정보들이 없어서 메인 화면 이야기임" — Walking Skeleton만으로 기획 끝나면 타이틀·메뉴·게임오버가 통째 누락. 기획 단계에서 강제 체크 |
| 2026-04-20 | **Phase 2.7 User Acceptance Gate 신설 (F 단위 사용자 검수).** Evaluator 자동 테스트가 PASS여도 "플레이어 체감"(반응성·카메라 느낌·시각 피드백)은 기계가 못 잡는 문제 해결. (1) **build-orchestrator Phase 2.7 섹션 신설** — F 마지막 스프린트 PASS → 2.7 진입, 사용자가 실제 플레이로 §0-B 체크, "OK/부분/재기획" 3갈래 응답. 재시도 J=2 (자동 테스트 K와 독립), 에스컬레이션 3개 선택지(§0-B 재협의 / §7.3 AC 추가 / F 보류). 비가시 F(순수 내부 시스템)는 §0-B↔§7.3 1:1 매칭 시 스킵 가능. (2) **Generator 마지막 스프린트 추가 산출물** — `scripts/check-F{N}.sh` (+ `.bat` + `scenes/__dev/check_f{N}.tscn` HUD 가이드 포함) + `docs/build/F{N}/USER_CHECK.md` (§0-A + §0-B 복제 + Y/N/부분 체크란 + 자동 테스트 매칭 표시). 재시도 시 USER_CHECK_prev_J{J}.md로 백업. (3) feature-spec §0-B가 단일 진실원 — _feature-list.md, _roadmap.html, USER_CHECK.md 3곳 전시. | `.claude/skills/build-orchestrator/SKILL.md` (Phase 2.7 섹션 + Phase 2-4 분기 수정), `.claude/agents/generator.md` (F 마지막 스프린트 추가 책임) | 사용자 요구: "F마다 목표 확실 → 구현 → AI 테스트(Evaluator) → ★ 인간이 체크 ★". 현재 흐름과 딱 1칸 차이(사람 체크). Evaluator PASS로 Phase 3 바로 넘어가던 구멍을 Phase 2.7 한 개로 메움. 10섹션 계약·TDD 경계 명시는 당장 불필요(§0-B·§7.3 기존 분리로 커버) — 복잡도 최소화 |
| 2026-04-20 | **Claude Code 플러그인화 완료 (v0.1.0).** (1) `.claude/{agents,skills,scripts}/` → 플러그인 루트의 `{agents,skills,scripts}/`로 이동. `.claude-plugin/plugin.json` 매니페스트 신설. (2) `mcp-servers/godot-mcp/` — bradypp/godot-mcp main HEAD vendored fork(TypeScript 원본). `mcp-servers/blender-mcp/` — ahujasid/blender-mcp main HEAD vendored fork(Python 원본). (3) `scripts/sync-godot-mcp.sh` + `hooks/hooks.json` SessionStart 훅 — 소스 변경 감지 시 `${CLAUDE_PLUGIN_DATA}/godot-mcp/`에 자동 재빌드(증분). (4) `.mcp.json`이 `${CLAUDE_PLUGIN_ROOT}`·`${CLAUDE_PLUGIN_DATA}` 변수 참조 — 이식성 확보. (5) 에이전트·스킬 13개 파일 내 `.claude/{agents,skills,scripts}/` 하드코딩 37줄 일괄 치환. (6) 로컬 테스트 — `claude --plugin-dir .`로 로드 가능, sync 스크립트 실제 빌드 성공(index.js 생성 + Node 기동 확인). (7) README.md + CHANGELOG.md 신설. 상세 내역은 CHANGELOG.md v0.1.0 | `.claude-plugin/plugin.json`, `agents/`·`skills/`·`scripts/`·`mcp-servers/`·`hooks/` 디렉토리, `.mcp.json`, `.gitignore`, CLAUDE.md 플러그인 구조 섹션, README.md, CHANGELOG.md | 사용자 요구 3가지: ① "완전 플러그인화 해줘" — `.claude/` 통째로 프로젝트 종속인 문제 해결, 다른 프로젝트에서도 재사용 가능한 플러그인 형태로. ② "MCP 설정 현재 상태 맞는지 + 플러그인화 후 문제없는지 확인" — JSON 3종 유효성 + 실제 Godot MCP 빌드·기동까지 검증 통과. ③ "내가 Blender·Godot MCP를 자체적으로 업데이트할 수 있었으면" — vendored fork로 TypeScript·Python 원본을 플러그인 내부에 포함, 사용자가 편집 시 Godot은 다음 세션에서 자동 재빌드, Blender는 `pip install -e` 재실행으로 반영 |
| 2026-04-29 | **kickoff-godot 2D 지원 + MCP 완전 제거 (v0.2.0).** 플러그인명 `kickoff-godot-3d` → `kickoff-godot`. Phase 0-1에서 Founder가 사용자에게 2D/3D 명시 질문, 결과를 `_meta.md`에 저장, 헤더가 `**프로젝트 종류:** {2D\|3D} 게임 (Godot 4)`로 변수화. Godot/Blender MCP 인프라(mcp-servers/, scripts/sync-godot-mcp.sh, scripts/ensure-running.sh, hooks/hooks.json, skills/godot-mcp-protocol/, docs/godot-mcp/) 완전 제거 — Generator는 .tscn/.gd 텍스트 직접 편집 + `godot --headless` smoke로 작업, 시각 확인은 사용자 위임. asset-pipeline 4단계 → 2단계 폴백(Godot 내장 → 사용자 위임). 차원-분기는 `references/{2d,3d}.md` 분리 방식 (asset-pipeline·godot-scene-handoff·visual-gate·kickoff-docs 등). Phase 1 Step 1-5 시점 옵션이 차원별로 다른 풀 제시. | .claude-plugin/plugin.json, CLAUDE.md, 스킬·에이전트 다수, mcp-servers/·scripts/·hooks/·skills/godot-mcp-protocol/ 삭제 | MCP 등록 안정성 문제 + 2D 게임 프로젝트 지원 요구. 자동화 부채 제거 후 텍스트/CLI 기본 경로로 단순화 |
