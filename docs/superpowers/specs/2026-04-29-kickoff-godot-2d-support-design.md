# kickoff-godot 2D 지원 + MCP 제거 설계

**작성일:** 2026-04-29
**대상 버전:** v0.2.0
**현재 버전:** v0.1.0 (`kickoff-godot-3d`, 3D 전용 + Godot/Blender MCP 통합)

## 1. 배경

현재 플러그인 `kickoff-godot-3d`는 3D 게임(Godot 4) 전용으로 고정되어 있고, Godot MCP + Blender MCP를 vendored fork로 포함하여 자동 빌드/실행을 시도한다. 두 가지 문제:

1. **2D 게임 지원 불가** — 모든 문서 헤더, 어휘, 시점 옵션, 에셋 파이프라인이 3D를 가정
2. **MCP 등록 불안정** — 사용자가 실제로 등록 실패를 겪음. 자동화가 안정적이지 못하면 부채

이 두 문제를 한 번에 해결하여 v0.2.0 `kickoff-godot`으로 리네이밍한다.

## 2. 결정 사항 요약

| 항목 | 결정 |
|------|------|
| 플러그인 이름 | `kickoff-godot-3d` → **`kickoff-godot`** |
| 2D/3D 결정 시점 | Phase 0에서 Founder 명시 질문 |
| MCP 처리 | **완전 제거** (Godot MCP + Blender MCP 둘 다) |
| 분기 깊이 | references 분리 (SKILL.md 본문은 공용, `references/{2d,3d}.md`) |
| 기존 산출물 마이그레이션 | 불필요 (구 헤더 형식이 새 형식의 부분집합) |
| 게임 메타 분기 | 시점 옵션만 (장르·플랫폼·플레이타임·멀티는 공용) |

## 3. 변경 사항 상세

### 3.1 플러그인 메타

- `.claude-plugin/plugin.json`
  - `name`: `kickoff-godot-3d` → `kickoff-godot`
  - `description`: 2D/3D 모두 지원함을 명시
  - `version`: `0.1.0` → `0.2.0`
- `README.md`: 제목·설명·설치 명령어 업데이트
- `CHANGELOG.md`: v0.2.0 항목 신설 (리네이밍 + 2D 지원 + MCP 제거)

### 3.2 Phase 0 프로젝트 종류 결정

`skills/kickoff-orchestrator/SKILL.md` Phase 0 갱신:

- Founder가 사용자에게 직접 질문: **"2D 게임인가요, 3D 게임인가요?"**
- 답을 `docs/kickoff/_meta.md` 또는 Phase 0 산출물에 기록
- 모든 후속 문서 헤더가 `**프로젝트 종류:** {2D|3D} 게임 (Godot 4)`로 고정
- 한 프로젝트에서 도중 변경 불가 — 변경 시 처음부터 재시작 권고

### 3.3 MCP 완전 제거

**제거 대상:**

- `mcp-servers/godot-mcp/` 디렉토리 통째
- `mcp-servers/blender-mcp/` 디렉토리 통째
- `mcp-servers/` 자체도 비면 삭제
- `.mcp.json` (또는 빈 객체로)
- `scripts/sync-godot-mcp.sh`
- `scripts/ensure-running.sh`
- `hooks/hooks.json` (SessionStart 훅 — 다른 훅 없으면 파일 자체 삭제)
- `skills/godot-mcp-protocol/` 스킬 통째
- `docs/godot-mcp/` 갭 리포트 디렉토리

**대체 동작:**

- Generator는 `.tscn` / `.gd` / `.tres` **텍스트 직접 편집** (Edit/Write 도구)
- 검증은 `godot --headless --import` 및 smoke 씬 헤드리스 실행
- 씬의 시각 확인·복잡 에셋 import는 사용자에게 위임
- `skills/asset-pipeline/SKILL.md` 폴백 체인을 4단계 → **2단계**로 축소
  - ① Godot 내장 (3D: MeshInstance3D + 기본 도형 / 2D: ColorRect + 기본 텍스처)
  - ② 사용자 위임 (무료 라이브러리·AI 생성·직접 제작은 모두 사용자 영역)
- `references/ai-capability-matrix.md` 제거 또는 "사용자 영역" 한 줄로 축소

**관련 문서 갱신:**

- `CLAUDE.md` "에디터 자동화: Godot MCP" 라인 → "에디터 작업: 텍스트 편집(.tscn/.gd/.tres) + `godot --headless` smoke + 사용자 위임"
- "MCP 부재 시 fallback" 표현 전체 제거 (이제 fallback이 기본 경로)
- "MCP 개선 트랙" 섹션 제거 (build-orchestrator)
- `build-orchestrator` Phase 0-0 MCP 감지 로직 제거
- 에이전트 6명(planner/generator/evaluator/build-auditor/qa/scribe)에서 MCP 호출 지시 제거

### 3.4 2D/3D 분기 (references 분리)

**원칙:** SKILL.md 본문은 공용으로 유지하고, 차원-특화 디테일은 `references/2d.md` / `references/3d.md`로 분리한다. 본문에서 **"현재 프로젝트 종류에 맞는 reference 로드"**를 지시.

**분기 적용 스킬:**

| 스킬 | 분리 항목 |
|------|----------|
| `niche-enforcement` | 1플레이어 원형·1코어 결핍·1코어 버브 판정 테이블 (어휘) |
| `visual-gate` | 카메라/depth-axis 패턴(3D), 타일맵/픽셀 해상도/사이드뷰 도식(2D), CSS 클래스 일부 |
| `godot-scene-handoff` | Node3D vs Node2D 차이 (Physics Layer·InputMap은 공용) |
| `asset-pipeline` | 2D=스프라이트·타일맵, 3D=메시·텍스처 |
| `kickoff-docs` | 게임 부록 2d/3d 양쪽 |
| `competitor-research` | 게임 리서치 프로토콜 어휘 일부 |

**분기 적용 에이전트:**

- `core-mechanic-designer`, `hook-strategist`, `game-market-researcher`, `sellability-auditor`, `niche-enforcer`, `founder`, `scribe`
- 각 파일에 `## 2D/3D 분기` 섹션 추가하거나 본문 내 짧은 인라인 분기

### 3.5 Phase 1 Step 1-5 시점 옵션 분기

`skills/kickoff-orchestrator/SKILL.md` Step 1-5 (게임 메타) 시점 항목:

- **2D 모드:** 탑다운 / 사이드뷰(횡스크롤) / 쿼터뷰(아이소·픽셀) / 정면(비주얼노벨식) / 보드뷰
- **3D 모드:** 1인칭 / 3인칭 어깨너머 / 3인칭 쿼터뷰 / 탑다운 3D / 고정 카메라

다른 메타 항목(장르·플랫폼·플레이타임·멀티)은 공용 유지.

### 3.6 CLAUDE.md 갱신

- 첫 문단 "3D 게임(Godot 4) 전용" → "2D/3D 게임(Godot 4)"
- "프로젝트 고정 규칙" 섹션:
  - 헤더 형식 `**프로젝트 종류:** {2D|3D} 게임 (Godot 4)`로 변수화
  - "에디터 자동화: Godot MCP" 줄 제거 → "에디터 작업: 텍스트 편집 + headless CLI + 사용자 위임"
  - "에셋: placeholder-first 4단계 폴백" → "2단계 폴백"
- "게임 전용 스킬" 목록에서 `godot-mcp-protocol` 삭제
- "게임 전용 파일 구조"에서 MCP 관련 경로 삭제
- "플러그인 구조" 섹션에서 `mcp-servers/`·`scripts/sync-*`·`hooks/` 라인 삭제
- "MCP 개선 트랙" 섹션 삭제
- "변경 이력" Build Harness 표에 v0.2.0 항목 추가

## 4. 영향 범위 (파일 단위)

**삭제:**

- `mcp-servers/` (전체)
- `scripts/sync-godot-mcp.sh`
- `scripts/ensure-running.sh`
- `hooks/hooks.json` (다른 훅 없으면 디렉토리도)
- `skills/godot-mcp-protocol/`
- `docs/godot-mcp/`
- `.mcp.json` (또는 빈 객체)

**수정:**

- `.claude-plugin/plugin.json`
- `CLAUDE.md`
- `README.md`, `CHANGELOG.md`
- `skills/kickoff-orchestrator/SKILL.md` (Phase 0, Step 1-5)
- `skills/build-orchestrator/SKILL.md` (MCP 트랙 제거)
- `skills/asset-pipeline/SKILL.md` + references
- `skills/niche-enforcement/SKILL.md` + references
- `skills/visual-gate/SKILL.md` + references
- `skills/godot-scene-handoff/SKILL.md`
- `skills/kickoff-docs/SKILL.md`
- `skills/competitor-research/SKILL.md`
- `agents/founder.md`
- `agents/scribe.md`
- `agents/core-mechanic-designer.md`
- `agents/hook-strategist.md`
- `agents/game-market-researcher.md`
- `agents/sellability-auditor.md`
- `agents/niche-enforcer.md`
- `agents/planner.md`
- `agents/generator.md`
- `agents/evaluator.md`
- `agents/build-auditor.md`
- `agents/qa.md`

**신설:**

- `skills/{niche-enforcement,visual-gate,godot-scene-handoff,asset-pipeline,kickoff-docs,competitor-research}/references/2d.md`
- `skills/{...}/references/3d.md` (기존 본문에 박혀 있던 3D 디테일을 이쪽으로 이동)

## 5. 검증 계획

1. `claude --plugin-dir .` 로 플러그인 로드 — 에러 없이 시작
2. 새 세션에서 Phase 0 시뮬레이션 — 2D/3D 질문 정상 동작
3. 플러그인 매니페스트 유효성 (JSON parse)
4. MCP 관련 잔존 참조 grep — 0건이어야 함 (`godot-mcp`, `blender-mcp`, `ensure-running`, `sync-godot`)
5. 모든 스킬·에이전트 파일에서 차원-특화 표현 검토 — 본문에서는 공용 어휘, references에서만 분기

## 6. 비고

- 기존 산출물 호환: 구 헤더 `**프로젝트 종류:** 3D 게임 (Godot 4)`는 새 형식에서도 그대로 유효 → 마이그레이션 불필요
- MCP를 나중에 다시 살릴 가능성: 이 결정은 v0.2.0 시점에서 "안정성 우선" 판단. 추후 MCP 안정성이 확보되면 옵트인 형태로 재도입 가능 (별도 설계)
- 사용자가 직접 Blender·외부 도구 사용은 제약 없음 — 단지 하네스가 자동화하지 않을 뿐
