# kickoff-godot 2D 지원 + MCP 제거 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 플러그인을 `kickoff-godot-3d` → `kickoff-godot`으로 리네이밍하고 2D Godot 게임 지원을 추가하며 Godot/Blender MCP 인프라를 완전 제거한다.

**Architecture:** 도큐멘트·설정 리팩터. 코드 변경 없음. 차원-특화 디테일은 references/{2d,3d}.md로 분리하고 SKILL.md 본문은 공용. MCP 관련 파일·스킬·디렉토리는 삭제하고 텍스트 편집 + headless CLI를 기본 경로로 채택.

**Tech Stack:** Markdown, JSON (plugin manifest, .mcp.json), Bash (validation), Godot 4 (target).

**Spec:** `docs/superpowers/specs/2026-04-29-kickoff-godot-2d-support-design.md`

---

## 작업 진행 원칙

- 각 Task는 독립 커밋
- 변경 후 `claude --plugin-dir .` 로드 가능 상태를 유지 (각 Task 끝에서 깨지지 않음)
- 차원-분기 적용 시: SKILL.md 본문에서 3D 전용 내용을 `references/3d.md`로 옮기고 `references/2d.md`를 신설하여 동일 구조로 채움. 본문에는 "프로젝트 종류에 맞는 reference를 로드하라" 지시만 남긴다
- 모든 에이전트/스킬에서 MCP 호출·`ensure-running.sh`·`godot-mcp-protocol` 참조를 grep으로 0건 만들 때까지 정리

---

## Task 1: 플러그인 매니페스트 리네이밍

**Files:**
- Modify: `.claude-plugin/plugin.json`

- [ ] **Step 1: plugin.json 읽고 현재 name·description·version 확인**

Run: `cat .claude-plugin/plugin.json`

- [ ] **Step 2: name/description/version 갱신**

`name`: `"kickoff-godot-3d"` → `"kickoff-godot"`
`description`: 2D/3D 모두 지원함을 명시 (예: `"Kickoff harness for 2D/3D Godot 4 game projects"`)
`version`: `"0.1.0"` → `"0.2.0"`
다른 필드(author, keywords 등)는 자연스럽게 갱신.

- [ ] **Step 3: JSON 유효성 검증**

Run: `node -e "JSON.parse(require('fs').readFileSync('.claude-plugin/plugin.json'))" && echo OK`
Expected: `OK`

- [ ] **Step 4: 커밋**

```bash
git add .claude-plugin/plugin.json
git commit -m "chore: rename plugin to kickoff-godot v0.2.0"
```

---

## Task 2: MCP 인프라 디렉토리·파일 삭제

**Files:**
- Delete: `mcp-servers/` (전체)
- Delete: `scripts/sync-godot-mcp.sh`
- Delete: `scripts/ensure-running.sh`
- Delete: `hooks/hooks.json`
- Delete: `hooks/` (비면)
- Delete: `scripts/` (비면)
- Delete: `.mcp.json` (또는 빈 객체로)
- Delete: `skills/godot-mcp-protocol/` (전체)
- Delete: `docs/godot-mcp/` (있으면)

- [ ] **Step 1: 삭제 전 잔존 디렉토리 확인**

Run: `ls -la mcp-servers scripts hooks skills/godot-mcp-protocol docs/godot-mcp 2>&1 | head -40`

- [ ] **Step 2: `.mcp.json` 처리**

`.mcp.json`을 빈 객체로 덮어쓰기:
```json
{
  "mcpServers": {}
}
```
또는 파일 자체 삭제. **선택:** 비워두기 (Claude Code가 빈 매니페스트로 정상 동작 확인 가능하면 삭제, 아니면 빈 객체).

- [ ] **Step 3: MCP 디렉토리·스크립트·훅·스킬 삭제**

```bash
git rm -rf mcp-servers/
git rm -f scripts/sync-godot-mcp.sh scripts/ensure-running.sh
git rm -f hooks/hooks.json
git rm -rf skills/godot-mcp-protocol/
[ -d docs/godot-mcp ] && git rm -rf docs/godot-mcp/ || true
rmdir hooks scripts 2>/dev/null || true
```

- [ ] **Step 4: 잔존 참조 grep**

Run: `git grep -nE "godot-mcp|blender-mcp|ensure-running|sync-godot-mcp|mcp-servers" -- ':!docs/superpowers/' ':!CHANGELOG.md'`
이 단계에서는 다른 파일들(CLAUDE.md, 에이전트, 스킬)에 잔존 참조가 **남아있을 것**이다. Task 3+에서 정리. 결과를 메모로 남긴다.

- [ ] **Step 5: 플러그인 로드 가능 상태 확인 (스모크)**

Run: `node -e "JSON.parse(require('fs').readFileSync('.claude-plugin/plugin.json'))" && echo OK`
Expected: `OK`

- [ ] **Step 6: 커밋**

```bash
git add -A
git commit -m "chore: remove Godot/Blender MCP infrastructure"
```

---

## Task 3: CLAUDE.md 갱신

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: CLAUDE.md 전체 읽기**

Run: Read tool로 `CLAUDE.md` 전체 확인.

- [ ] **Step 2: 첫 문단·고정 가정·게임 전용 스킬·플러그인 구조 갱신**

다음 변경을 적용:

(a) 제목·첫 문단:
- `# Kickoff Project — 3D 게임 (Godot 4) 전용 하네스` → `# Kickoff Project — 2D/3D 게임 (Godot 4) 하네스`
- "본 저장소는 **3D 게임(Godot 4) 전용**으로" → "본 저장소는 **2D/3D Godot 4 게임 프로젝트**용으로"

(b) "프로젝트 고정 규칙" 본문:
- 헤더 형식을 `**프로젝트 종류:** {2D|3D} 게임 (Godot 4)`로 변수화
- "1플레이어 원형·1코어 결핍·1코어 버브" 핵심 불변 규칙은 유지

(c) "게임 프로젝트 고정 가정" 블록:
- 엔진: **Godot 4.x** (유지)
- "에디터 자동화: **Godot MCP**…" 줄 → "에디터 작업: `.tscn`/`.gd`/`.tres` 텍스트 직접 편집 + `godot --headless --import` smoke + 시각 확인은 사용자 위임"
- "MCP 부재 시 fallback: …" 줄 삭제
- 에셋 줄: "placeholder-first 4단계 폴백 (primitive → 무료 라이브러리 → AI 생성 → 사용자 위임)" → "placeholder-first 2단계 폴백 (Godot 내장 primitive/ColorRect → 사용자 위임)"
- 테스트: GUT 또는 GdUnit4 (유지)

(d) "게임 전용 스킬" 목록:
- `godot-mcp-protocol` 항목 삭제
- 나머지(godot-scene-handoff, asset-pipeline) 유지

(e) "게임 전용 파일 구조" 블록:
- `${CLAUDE_PLUGIN_ROOT}/skills/godot-mcp-protocol/references/capability-matrix.md` 줄 삭제
- `docs/godot-mcp/gaps/G{N}.md` 줄 삭제
- `${CLAUDE_PLUGIN_ROOT}/skills/asset-pipeline/references/ai-capability-matrix.md` 줄은 폴백 변경에 맞춰 삭제 또는 "사용자 영역" 한 줄로 축소
- `docs/build/F{N}/assets/manifest.md` (유지)

(f) "플러그인 구조" 섹션:
- `mcp-servers/godot-mcp/`, `mcp-servers/blender-mcp/` 라인 삭제
- `scripts/sync-godot-mcp.sh`, `scripts/ensure-running.sh` 라인 삭제
- `hooks/hooks.json` 라인 삭제
- `.mcp.json` 라인은 "비어 있음" 또는 삭제 명시
- "MCP 소스 직접 수정" 블록 통째 삭제

(g) "MCP 개선 트랙 (선택)" 섹션 통째 삭제

(h) Build Harness "변경 이력" 표 마지막에 v0.2.0 행 추가:
```
| 2026-04-29 | **kickoff-godot 2D 지원 + MCP 완전 제거 (v0.2.0).** 플러그인명 `kickoff-godot-3d` → `kickoff-godot`. Phase 0에서 Founder가 2D/3D 명시 질문, 헤더가 `**프로젝트 종류:** {2D|3D} 게임 (Godot 4)`로 변수화. Godot/Blender MCP 인프라(mcp-servers/, sync-godot-mcp.sh, ensure-running.sh, hooks.json, godot-mcp-protocol 스킬, docs/godot-mcp/) 완전 제거 — Generator는 .tscn/.gd 텍스트 직접 편집 + `godot --headless` smoke로 작업, 시각 확인은 사용자 위임. asset-pipeline 4단계 → 2단계 폴백(Godot 내장 → 사용자 위임). 차원-분기는 references/{2d,3d}.md 분리 방식. Phase 1 Step 1-5 시점 옵션이 2D/3D별로 다른 풀 제시. | .claude-plugin/plugin.json, CLAUDE.md, 스킬·에이전트 다수, mcp-servers/·scripts/·hooks/·skills/godot-mcp-protocol/ 삭제 | MCP 등록 안정성 문제 + 2D 게임 프로젝트 지원 요구. 자동화 부채를 제거하고 텍스트/CLI 기본 경로로 단순화 |
```

- [ ] **Step 3: 잔존 MCP 참조 점검**

Run: `git grep -nE "Godot MCP|Blender MCP|godot-mcp|blender-mcp|ensure-running|MCP capability|MCP 부재" -- CLAUDE.md`
Expected: 0건 (또는 변경 이력 표 안의 역사적 기록만 — 이건 OK)

- [ ] **Step 4: 커밋**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md for 2D/3D + MCP removal"
```

---

## Task 4: kickoff-orchestrator Phase 0에 2D/3D 결정 추가

**Files:**
- Modify: `skills/kickoff-orchestrator/SKILL.md`

- [ ] **Step 1: SKILL.md 읽고 Phase 0 위치 파악**

Run: Read `skills/kickoff-orchestrator/SKILL.md`. Phase 0 섹션 라인 번호 기록.

- [ ] **Step 2: Phase 0에 2D/3D 결정 단계 추가**

Phase 0 (또는 Phase 0-0) 직후에 다음 절차를 명시:

```markdown
### Phase 0-1: 프로젝트 차원 결정 (2D/3D)

Founder가 사용자에게 명시적으로 질문:
> "이 게임은 2D인가요, 3D인가요?"

답에 따라 모든 후속 산출물의 헤더를 다음 형식으로 고정:
- 2D 답변 → `**프로젝트 종류:** 2D 게임 (Godot 4)`
- 3D 답변 → `**프로젝트 종류:** 3D 게임 (Godot 4)`

결과를 `docs/kickoff/_meta.md`에 다음 형식으로 저장:
\`\`\`yaml
project_type: {2d|3d}
engine: godot-4
decided_at: {timestamp}
\`\`\`

이후 모든 에이전트/스킬은 차원-특화 동작이 필요할 때 `_meta.md`의 `project_type` 또는 `references/{2d,3d}.md` reference를 로드한다.

**한 번 결정되면 변경 불가** — 차원 변경이 필요하면 사용자에게 새 프로젝트로 시작할 것을 권고.
```

- [ ] **Step 3: 기존 MCP 감지 로직 제거**

Phase 0 또는 Phase 0-0에 MCP 감지·`ensure-running.sh` 호출·capability matrix 참조가 있으면 모두 삭제.

- [ ] **Step 4: 커밋**

```bash
git add skills/kickoff-orchestrator/SKILL.md
git commit -m "feat(kickoff): add Phase 0-1 2D/3D dimension decision + drop MCP detection"
```

---

## Task 5: kickoff-orchestrator Step 1-5 시점 옵션 분기

**Files:**
- Modify: `skills/kickoff-orchestrator/SKILL.md`

- [ ] **Step 1: Step 1-5 (게임 메타) 위치 파악**

Run: `git grep -n "1-5" skills/kickoff-orchestrator/SKILL.md`

- [ ] **Step 2: 시점 옵션을 차원별로 분기**

Step 1-5 시점 항목을 다음 형식으로 변경:

```markdown
**시점 옵션** (`_meta.md`의 `project_type`에 따라 다른 풀 제시):

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
```

장르·플랫폼·플레이타임·멀티 항목은 그대로 유지.

- [ ] **Step 3: 커밋**

```bash
git add skills/kickoff-orchestrator/SKILL.md
git commit -m "feat(kickoff): branch Step 1-5 viewpoint options by 2D/3D"
```

---

## Task 6: asset-pipeline 폴백 4→2단계 + 차원 분기

**Files:**
- Modify: `skills/asset-pipeline/SKILL.md`
- Create: `skills/asset-pipeline/references/2d.md`
- Create: `skills/asset-pipeline/references/3d.md`
- Delete: `skills/asset-pipeline/references/ai-capability-matrix.md` (있으면)

- [ ] **Step 1: 현재 SKILL.md 읽기**

Run: Read `skills/asset-pipeline/SKILL.md`. 4단계 폴백 본문을 식별.

- [ ] **Step 2: 본문 폴백 체인 변경**

4단계 (primitive → 무료 라이브러리 → AI 생성 → 사용자 위임) → **2단계**:
- ① **Godot 내장** — 차원에 따라 `references/{2d,3d}.md`의 placeholder 카탈로그 사용
- ② **사용자 위임** — 무료 라이브러리·AI 생성·외주·직접 제작은 모두 사용자 영역. 하네스는 manifest 작성과 import 검증만 담당

본문에서 "AI 생성 API"·"capability matrix" 언급 모두 삭제.

- [ ] **Step 3: `references/3d.md` 신설**

기존 본문에 박혀 있던 3D 전용 placeholder 카탈로그를 이쪽으로 이동:
- 메시: MeshInstance3D + BoxMesh / SphereMesh / CylinderMesh / CapsuleMesh
- 머티리얼: StandardMaterial3D 기본 albedo
- 텍스처: 단색 또는 체크보드
- 애니메이션: AnimationPlayer + 단순 transform 트랙

- [ ] **Step 4: `references/2d.md` 신설**

2D placeholder 카탈로그:
- 스프라이트: Sprite2D + ColorRect 또는 단색 PNG (16x16 / 32x32 / 64x64)
- 타일맵: TileMap + TileSet (단색 타일 또는 격자 텍스처)
- UI: Control + ColorRect 박스
- 애니메이션: AnimationPlayer + frame 변경 또는 AnimatedSprite2D

- [ ] **Step 5: SKILL.md에 reference 로드 지시 추가**

본문 상단 또는 폴백 ① 단계에:
```markdown
**프로젝트 차원에 따라 placeholder 카탈로그를 로드하라:**
- `_meta.md`의 `project_type: 2d` → `references/2d.md`
- `_meta.md`의 `project_type: 3d` → `references/3d.md`
```

- [ ] **Step 6: ai-capability-matrix.md 삭제 (있으면)**

```bash
[ -f skills/asset-pipeline/references/ai-capability-matrix.md ] && git rm skills/asset-pipeline/references/ai-capability-matrix.md || true
```

- [ ] **Step 7: 커밋**

```bash
git add skills/asset-pipeline/
git commit -m "feat(asset-pipeline): collapse to 2-stage fallback + branch 2D/3D references"
```

---

## Task 7: godot-scene-handoff 차원 분기

**Files:**
- Modify: `skills/godot-scene-handoff/SKILL.md`
- Create: `skills/godot-scene-handoff/references/2d.md`
- Create: `skills/godot-scene-handoff/references/3d.md`

- [ ] **Step 1: SKILL.md 읽기**

Run: Read `skills/godot-scene-handoff/SKILL.md`. 7항 표준 식별.

- [ ] **Step 2: 본문에서 Node3D 가정 제거**

7항 표준에서 차원-특화 부분(루트 노드 타입, 카메라, 조명 등)은 references로 이동시키고 본문은 차원 무관 표현으로:
- "씬 트리 구조" — Node 타입 예시는 references로
- "Physics Layers / Collision Mask" — 공용
- "InputMap" — 공용
- "프로젝트 설정 (Rendering / Window)" — 공용 (값만 차원별)

- [ ] **Step 3: `references/3d.md` 신설**

3D 전용 디테일:
- 루트: Node3D, 카메라: Camera3D, 조명: DirectionalLight3D / OmniLight3D
- 물리: CharacterBody3D / RigidBody3D / StaticBody3D, CollisionShape3D
- Rendering: Forward+ / Mobile / Compatibility 선택 가이드
- 좌표계 주의 (Y-up, -Z forward)

- [ ] **Step 4: `references/2d.md` 신설**

2D 전용 디테일:
- 루트: Node2D, 카메라: Camera2D, 조명: 옵션(CanvasModulate / Light2D)
- 물리: CharacterBody2D / RigidBody2D / StaticBody2D, CollisionShape2D
- Rendering: stretch_mode (canvas_items 권장), pixel_perfect 옵션
- 좌표계 (Y-down)

- [ ] **Step 5: 본문에 reference 로드 지시 추가**

```markdown
**차원별 노드 타입·물리·렌더 디테일:**
- 2D → `references/2d.md`
- 3D → `references/3d.md`
```

- [ ] **Step 6: 커밋**

```bash
git add skills/godot-scene-handoff/
git commit -m "feat(scene-handoff): split Node2D/3D specifics into references"
```

---

## Task 8: visual-gate 차원 분기

**Files:**
- Modify: `skills/visual-gate/SKILL.md`
- Modify: `skills/visual-gate/references/css-classes.md` (있으면)
- Modify: `skills/visual-gate/references/gate-patterns.md` (있으면)
- Create: `skills/visual-gate/references/2d.md`
- Create: `skills/visual-gate/references/3d.md`

- [ ] **Step 1: 현재 references 구조 파악**

Run: `ls skills/visual-gate/references/`

- [ ] **Step 2: SKILL.md "Quality Bar" 차원 분기**

Quality Bar 필수 5요소 중 "scene-mockup 16:9 / 보조 도식 / 레퍼런스 게임 2~3개"는 공용. 보조 도식 종류만 차원별로:
- 3D: 카메라 도식 / depth-axis / 씬트리(Node3D 중심)
- 2D: 타일 격자 / 픽셀 해상도 박스 / 사이드뷰 레이어 / 씬트리(Node2D 중심)

본문에 reference 로드 지시 추가.

- [ ] **Step 3: `references/3d.md` 신설**

- 사용 가능 CSS 클래스: `scene-mockup`, `camera-diagram`, `depth-axis`, `node-graph`(Node3D), `silhouette`(3D 캐릭터)
- 카메라 도식 예시 (1인칭/3인칭/탑다운)
- depth-axis 사용 케이스

- [ ] **Step 4: `references/2d.md` 신설**

- 사용 가능 CSS 클래스: `scene-mockup`, `tile-grid`, `hud-slot`, `node-graph`(Node2D), `silhouette`(2D 캐릭터/스프라이트)
- 픽셀 해상도 표시 도식
- 타일맵 레이어 구조 도식
- 사이드뷰 패럴랙스 레이어 도식

- [ ] **Step 5: gate-patterns.md 차원 표시**

기존 `gate-patterns.md`의 각 패턴(camera-pick, hud-layout, scene-tree, level-grid, feature-roadmap 등)에 적용 가능 차원을 표시:
- camera-pick: 3D 전용
- depth-axis: 3D 전용
- tile-grid: 2D 전용
- pixel-resolution: 2D 전용
- scene-mockup, hud-slot, scene-tree, feature-roadmap, silhouette: 공용

본문 또는 각 패턴 헤더에 `[차원: 2D | 3D | 공용]` 라벨 추가.

- [ ] **Step 6: 커밋**

```bash
git add skills/visual-gate/
git commit -m "feat(visual-gate): branch 2D/3D mockup patterns + references"
```

---

## Task 9: kickoff-docs 차원 분기

**Files:**
- Modify: `skills/kickoff-docs/SKILL.md`
- Create: `skills/kickoff-docs/references/2d.md`
- Create: `skills/kickoff-docs/references/3d.md`

- [ ] **Step 1: SKILL.md 읽고 게임 부록 위치 식별**

Run: Read `skills/kickoff-docs/SKILL.md`. "게임 부록" 또는 "3D" 키워드 섹션 식별.

- [ ] **Step 2: 게임 부록 본문에서 3D 전용 부분을 references로 이동**

본문에는 차원 무관한 부분만 유지 (1플레이어 원형·1코어 결핍·1코어 버브 어휘, 마일스톤 표 M0a/M0b 구조 등). 차원-특화 어휘·예시는 `references/{2d,3d}.md`.

- [ ] **Step 3: `references/3d.md` 신설**

3D 게임 부록 어휘·예시:
- 코어 버브 예시: "쏘기/베기/잡기/회피/날기" (3D 시점 가정)
- 시점 어휘: "1인칭 / 3인칭"
- M0b Walking Skeleton 3D 예시: 회색 박스 캐릭터 + 회색 평면 + Camera3D 따라가기

- [ ] **Step 4: `references/2d.md` 신설**

2D 게임 부록 어휘·예시:
- 코어 버브 예시: "달리기/점프/슬라이딩/타격/짓기" (2D 시점 가정)
- 시점 어휘: "탑다운 / 사이드뷰 / 쿼터뷰"
- M0b Walking Skeleton 2D 예시: 단색 사각형 캐릭터 + 단색 바닥 + Camera2D 따라가기

- [ ] **Step 5: 본문에 reference 로드 지시 추가**

- [ ] **Step 6: 커밋**

```bash
git add skills/kickoff-docs/
git commit -m "feat(kickoff-docs): split game appendix into 2D/3D references"
```

---

## Task 10: niche-enforcer 에이전트 차원 분기

**Files:**
- Modify: `agents/niche-enforcer.md`

(주: niche-enforcement는 별도 스킬이 아니라 niche-enforcer 에이전트의 통합 프로토콜 섹션)

- [ ] **Step 1: 현재 통합 프로토콜 섹션 읽기**

Run: Read `agents/niche-enforcer.md`. "통합 프로토콜" 또는 "판정 테이블" 섹션 식별.

- [ ] **Step 2: 판정 테이블에 2D/3D 행 추가**

기존 3D 판정 테이블의 어휘를 2D에도 적용 가능하도록 일반화하고, 차원-특화 예시는 양쪽 케이스 제시:

```markdown
## 1플레이어 원형·1코어 결핍·1코어 버브 판정 (2D/3D 공용)

### 판정 어휘
- 원형(Archetype): 차원 무관
- 결핍(Lack): 차원 무관
- 버브(Verb): 차원 무관

### 차원별 판정 예시
- **3D 예시:** "FPS 슈터 1인 + 탄약 부족 + 쏘기" → 통과 / "RPG + 전투+탐험+크래프팅" → veto
- **2D 예시:** "메트로배니아 + 보스 패턴 학습 + 점프/슬래시" → 통과 / "메트로배니아 + 점프+공격+크래프팅+RPG요소" → veto
```

본문은 공용 어휘로, 예시만 차원별 양쪽 제시.

- [ ] **Step 3: 커밋**

```bash
git add agents/niche-enforcer.md
git commit -m "feat(niche-enforcer): add 2D judgment examples"
```

---

## Task 11: game-market-researcher 에이전트 차원 분기

**Files:**
- Modify: `agents/game-market-researcher.md`

- [ ] **Step 1: 통합 프로토콜(competitor-research) 섹션 읽기**

Run: Read `agents/game-market-researcher.md`.

- [ ] **Step 2: 게임 리서치 프로토콜 어휘 일반화**

Steam·SteamDB·YouTube 검색 프로토콜에서 3D 가정 어휘를 차원 무관으로 변경 + 차원별 검색 키워드 가이드 추가:
- 3D 게임: "first-person / third-person / 3D action / open world 3D" 등
- 2D 게임: "pixel art / 2D platformer / metroidvania / top-down 2D / sidescroller" 등

코어 버브 역공학 프로토콜은 공용. 단지 후보 게임 풀이 차원별로 다름.

- [ ] **Step 3: 본문에 차원 분기 지시 추가**

```markdown
**리서치 시 `_meta.md`의 `project_type`을 먼저 확인**하고 해당 차원의 검색 키워드/플랫폼 가이드를 적용한다.
```

- [ ] **Step 4: 커밋**

```bash
git add agents/game-market-researcher.md
git commit -m "feat(gmr): branch competitor research keywords by 2D/3D"
```

---

## Task 12: 토론 에이전트 4명 차원 분기

**Files:**
- Modify: `agents/core-mechanic-designer.md`
- Modify: `agents/hook-strategist.md`
- Modify: `agents/sellability-auditor.md`
- Modify: `agents/founder.md`

- [ ] **Step 1: 각 에이전트 파일에서 3D 가정 어휘 식별**

Run: `git grep -nE "3D|Node3D|카메라|시점|FPS|TPS" agents/{core-mechanic-designer,hook-strategist,sellability-auditor,founder}.md`

- [ ] **Step 2: 각 에이전트에 `## 2D/3D 분기` 짧은 섹션 추가**

각 에이전트 파일 하단(또는 적절한 위치)에 다음 형식 섹션 추가:

```markdown
## 2D/3D 분기

발화·토론 시 `docs/kickoff/_meta.md`의 `project_type`을 먼저 확인하고 차원에 맞는 어휘를 사용한다.

- **2D:** 시점은 탑다운/사이드뷰/쿼터뷰/정면/보드뷰 중. 코어 버브 예시는 "달리기/점프/슬래시/짓기/캐기" 등. 카메라·depth 토론은 의미 없음
- **3D:** 시점은 1인칭/3인칭(어깨너머/쿼터뷰)/탑다운3D/고정 카메라 중. 코어 버브 예시는 "쏘기/베기/잡기/회피/날기" 등. 카메라·depth·공간 인지가 토론 축

본문 어디서든 차원-특화 예시를 들 때 두 케이스 양쪽을 들거나 `_meta.md`에 맞는 쪽만 들 것.
```

각 에이전트의 고유 토론 축(CMD=깊이, HMS=첫인상, SA=시장 조건)은 그대로 유지.

- [ ] **Step 3: founder.md의 Phase 0-1 호출 지점 갱신**

`agents/founder.md`에 Phase 0-1 시점에서 사용자에게 "2D인가요, 3D인가요?" 질문하는 책임을 명시.

- [ ] **Step 4: 4개 파일 각각 별도 커밋**

```bash
git add agents/core-mechanic-designer.md
git commit -m "feat(cmd): add 2D/3D vocabulary branch"

git add agents/hook-strategist.md
git commit -m "feat(hook-strategist): add 2D/3D vocabulary branch"

git add agents/sellability-auditor.md
git commit -m "feat(sa): add 2D/3D vocabulary branch"

git add agents/founder.md
git commit -m "feat(founder): own Phase 0-1 dimension question + 2D/3D branch"
```

---

## Task 13: scribe 에이전트 헤더 형식 갱신

**Files:**
- Modify: `agents/scribe.md`

- [ ] **Step 1: scribe.md 읽기**

Run: Read `agents/scribe.md`. 문서 헤더 형식·`_feature-list.md` 템플릿 식별.

- [ ] **Step 2: 헤더 형식 변수화**

모든 문서(why/what/how/feature-spec/_feature-list.md/USER_CHECK.md 등) 첫 줄 헤더를:
- `**프로젝트 종류:** 3D 게임 (Godot 4)` (고정)
→ `**프로젝트 종류:** {project_type 값} 게임 (Godot 4)` (`_meta.md`에서 읽음)

Scribe가 모든 문서를 작성/갱신할 때 `_meta.md`의 `project_type`을 먼저 읽고 헤더를 그 값으로 채우도록 지시 추가.

- [ ] **Step 3: `_feature-list.md` 템플릿의 "기술 통합 리스트"에 차원 메모**

Physics Layers·InputMap은 공용이지만 씬 트리에 들어가는 노드 타입(Node2D/Node3D)이 차원에 따라 다름을 한 줄로 명시.

- [ ] **Step 4: 커밋**

```bash
git add agents/scribe.md
git commit -m "feat(scribe): variabilize project_type header from _meta.md"
```

---

## Task 14: Build 에이전트 5명에서 MCP 참조 제거

**Files:**
- Modify: `agents/planner.md`
- Modify: `agents/generator.md`
- Modify: `agents/evaluator.md`
- Modify: `agents/build-auditor.md`
- Modify: `agents/qa.md`

- [ ] **Step 1: 각 파일에서 MCP·ensure-running·godot-mcp-protocol 참조 grep**

Run: `git grep -nE "MCP|ensure-running|godot-mcp-protocol|capability matrix|godot mcp|blender mcp|Godot MCP|Blender MCP" agents/{planner,generator,evaluator,build-auditor,qa}.md`

- [ ] **Step 2: planner.md 갱신**

- "에셋 태스크" 테이블의 "필요 도구" 컬럼에서 MCP 도구 목록 제거 → "사용자 위임" 또는 컬럼 자체 제거
- "MCP 신호" 표현 제거
- S{M}-plan.md 템플릿에서 MCP capability 참조 제거

- [ ] **Step 3: generator.md 갱신**

- "구현 시작 전 ensure-running.sh로 MCP 도구 사전 준비" 절차 통째 삭제
- 씬 편집 = `.tscn` 텍스트 직접 편집 + Edit/Write 도구
- 검증 = `godot --headless --import` 및 smoke 씬 실행
- 시각 확인은 사용자 위임 명시

- [ ] **Step 4: evaluator.md 갱신**

- 게임 전용 하드 임계값에서 MCP 관련 항목 제거
- 유지: 크래시 0, 런타임 에러 0, Import 성공, Physics Layer 번호 고정
- 추가/유지: 에셋 manifest 존재 + import 성공 (MCP 없이 텍스트로 검증 가능한 부분만)

- [ ] **Step 5: build-auditor.md 갱신**

- 체크리스트에서 "MCP capability fallback" 항목 → "Godot 텍스트 편집 + headless CLI 경로 가능성"으로 재기술
- "MCP 갭 fallback" 표현 제거 또는 일반화

- [ ] **Step 6: qa.md 갱신**

- 경계면 매트릭스에서 MCP 관련 행 제거
- 게임 행(원형·결핍·버브·플랫폼·장르) 유지

- [ ] **Step 7: 차원-분기 한 줄 추가 (각 에이전트)**

각 에이전트에:
```markdown
**차원 분기:** `docs/kickoff/_meta.md`의 `project_type`을 먼저 확인. 2D면 Node2D/Camera2D/Sprite2D/CollisionShape2D 가정, 3D면 Node3D/Camera3D/MeshInstance3D/CollisionShape3D 가정.
```

- [ ] **Step 8: 5개 파일 각각 커밋**

```bash
git add agents/planner.md
git commit -m "refactor(planner): remove MCP references + add 2D/3D branch"

git add agents/generator.md
git commit -m "refactor(generator): text-edit + headless CLI baseline + 2D/3D branch"

git add agents/evaluator.md
git commit -m "refactor(evaluator): drop MCP thresholds + 2D/3D branch"

git add agents/build-auditor.md
git commit -m "refactor(build-auditor): drop MCP gap checklist + 2D/3D branch"

git add agents/qa.md
git commit -m "refactor(qa): drop MCP boundary row + 2D/3D branch"
```

---

## Task 15: build-orchestrator MCP 트랙 제거

**Files:**
- Modify: `skills/build-orchestrator/SKILL.md`

- [ ] **Step 1: MCP 관련 섹션 식별**

Run: `git grep -nE "MCP|ensure-running|godot-mcp-protocol|capability matrix" skills/build-orchestrator/SKILL.md`

- [ ] **Step 2: 다음 항목 모두 제거 또는 재작성**

- "Phase 0-0 프로젝트 종류 감지"의 MCP 감지 부분 → 제거 또는 단순화 (Godot 프로젝트 디렉토리 존재 여부 정도만)
- "MCP 개선 트랙" 섹션 통째 삭제
- 서브 에이전트 prompt에서 "Godot MCP 스킬 로드" 지시 → "godot-scene-handoff + asset-pipeline 스킬 로드"

- [ ] **Step 3: 차원 정보 전달 명시**

서브 에이전트(planner/generator/evaluator) prompt에 "`docs/kickoff/_meta.md`의 `project_type`을 먼저 읽도록" 지시 추가.

- [ ] **Step 4: 커밋**

```bash
git add skills/build-orchestrator/SKILL.md
git commit -m "refactor(build-orchestrator): remove MCP track + propagate project_type"
```

---

## Task 16: build-conventions / build-handoff / sprint-* 4종 MCP·차원 갱신

**Files:**
- Modify: `skills/build-conventions/SKILL.md`
- Modify: `skills/build-handoff/SKILL.md`
- Modify: `skills/sprint-planning/SKILL.md`
- Modify: `skills/sprint-execution/SKILL.md`
- Modify: `skills/sprint-evaluation/SKILL.md`

- [ ] **Step 1: 각 파일 MCP·차원 참조 grep**

Run: `git grep -nE "MCP|ensure-running|Godot MCP|Blender MCP|godot-mcp-protocol|3D 게임|Node3D" skills/{build-conventions,build-handoff,sprint-planning,sprint-execution,sprint-evaluation}/SKILL.md`

- [ ] **Step 2: build-conventions 갱신**

- Godot 4 코딩 규칙은 공용 유지
- 디자인·접근성·성능 규칙에서 3D 가정 부분(렌더러 선택·LOD·셰이더 등)을 차원별 분기 또는 references로
- 새 references: `references/2d.md` (픽셀 퍼펙트·canvas_items stretch·draw_call) / `references/3d.md` (Forward+/Mobile/Compatibility 선택·LOD·HDR)

- [ ] **Step 3: build-handoff 갱신**

- 핸드오프 항목에서 "MCP capability matrix"·"갭 리포트" 참조 모두 제거
- 핸드오프 #6·#7·#8(USER_CHECK.md, S{M}-user-retry, check-F{N}.sh) 유지
- "Kickoff FROZEN 입력 계약" 행에 `_meta.md`(project_type) 추가

- [ ] **Step 4: sprint-planning 갱신**

- "에셋 태스크" 테이블에서 MCP 도구 컬럼 제거 또는 "사용자 위임"으로 일반화
- Kickoff FROZEN 입력 계약에 `_meta.md` 행 추가
- feature-spec 10섹션 필수 체크는 유지

- [ ] **Step 5: sprint-execution 갱신**

- "ensure-running.sh로 MCP 사전 준비" 절차 통째 삭제
- "텍스트 편집 + headless CLI" 경로를 기본으로 명시
- GUT/GdUnit4 TDD 절차는 공용 유지

- [ ] **Step 6: sprint-evaluation 갱신**

- "에셋 존재+import+manifest 교차 검증" 하드 임계값 유지 (텍스트 검증으로 가능)
- MCP 호출 검증 항목 제거

- [ ] **Step 7: 5개 파일 각각 커밋**

```bash
git add skills/build-conventions/
git commit -m "refactor(build-conventions): split 2D/3D performance refs + drop MCP"

git add skills/build-handoff/SKILL.md
git commit -m "refactor(build-handoff): _meta.md in input contract + drop MCP"

git add skills/sprint-planning/SKILL.md
git commit -m "refactor(sprint-planning): drop MCP tools column + add _meta.md"

git add skills/sprint-execution/SKILL.md
git commit -m "refactor(sprint-execution): text-edit + headless baseline"

git add skills/sprint-evaluation/SKILL.md
git commit -m "refactor(sprint-evaluation): drop MCP call checks"
```

---

## Task 17: feature-spec 스킬 헤더·차원 갱신

**Files:**
- Modify: `skills/feature-spec/SKILL.md`

- [ ] **Step 1: 현재 SKILL.md 읽기**

Run: Read `skills/feature-spec/SKILL.md`. 템플릿 헤더·섹션 0 식별.

- [ ] **Step 2: 헤더 형식 변수화**

feature-spec 템플릿 첫 줄을 `**프로젝트 종류:** {project_type} 게임 (Godot 4)`로 변수화. Scribe/Generator가 작성 시 `_meta.md`에서 읽도록 지시.

- [ ] **Step 3: 섹션 0 금지 표현 차원별 보강 (선택)**

기존 금지 표현 감지(`~생성/구현/시스템/컨트롤러`로 끝나는 한 줄)는 유지. 차원별 추가 가이드는 references로 분리해도 되지만 현재 본문 무게로는 본문에 한 줄 메모만:
> "차원-특화 예시: 2D=픽셀 캐릭터가 좌우로 달리며 적 슬래시, 3D=주인공이 1인칭으로 적 머리 조준 사격"

- [ ] **Step 4: 커밋**

```bash
git add skills/feature-spec/SKILL.md
git commit -m "feat(feature-spec): variabilize project_type header"
```

---

## Task 18: README / CHANGELOG 갱신

**Files:**
- Modify: `README.md`
- Modify: `CHANGELOG.md`

- [ ] **Step 1: README.md 갱신**

- 제목 / 첫 단락 / 설치 명령 / 디렉토리 구조 모두 `kickoff-godot`으로 갱신
- 2D/3D 둘 다 지원함을 명시
- MCP 관련 설치/설정 안내 모두 삭제 (Blender addon 활성화·`pip install -e mcp-servers/blender-mcp` 등)
- "에디터 작업: 텍스트 편집 + `godot --headless`" 기본 경로 명시

- [ ] **Step 2: CHANGELOG.md에 v0.2.0 항목 추가**

```markdown
## v0.2.0 — 2026-04-29

### Breaking Changes
- 플러그인 이름 `kickoff-godot-3d` → `kickoff-godot`. 기존 사용자는 재설치 필요
- Godot MCP / Blender MCP 인프라 완전 제거 (`mcp-servers/`, `scripts/sync-godot-mcp.sh`, `scripts/ensure-running.sh`, `hooks/hooks.json`, `skills/godot-mcp-protocol/` 삭제)
- `.mcp.json`이 빈 매니페스트 (또는 삭제됨)

### Added
- 2D Godot 게임 프로젝트 지원
- Phase 0-1에서 Founder가 사용자에게 2D/3D 명시 질문
- `docs/kickoff/_meta.md`에 `project_type` 저장
- 차원-특화 디테일은 `references/{2d,3d}.md`로 분리 (asset-pipeline, godot-scene-handoff, visual-gate, kickoff-docs 등)
- Phase 1 Step 1-5 시점 옵션이 차원별로 다른 풀 제시

### Changed
- 헤더 형식이 `**프로젝트 종류:** {2D|3D} 게임 (Godot 4)`로 변수화
- `asset-pipeline` 폴백 4단계 → 2단계 (Godot 내장 → 사용자 위임)
- Generator는 `.tscn`/`.gd`/`.tres` 텍스트 직접 편집 + `godot --headless` smoke로 작업
- 시각 확인·복잡 에셋 import는 사용자 위임

### Removed
- `skills/godot-mcp-protocol/`
- `mcp-servers/{godot-mcp,blender-mcp}/` vendored fork
- `docs/godot-mcp/` 갭 리포트 트랙
- `build-orchestrator`의 MCP 개선 트랙 섹션
- 에이전트들의 MCP 호출 지시
```

- [ ] **Step 3: 커밋**

```bash
git add README.md CHANGELOG.md
git commit -m "docs: README + CHANGELOG for v0.2.0"
```

---

## Task 19: 최종 잔존 참조 점검 및 정리

**Files:** (전체 저장소 grep)

- [ ] **Step 1: MCP·이전 이름 잔존 grep**

Run:
```bash
git grep -nE "godot-mcp|blender-mcp|ensure-running|sync-godot-mcp|MCP capability|capability matrix|kickoff-godot-3d|MCP 부재|Godot MCP|Blender MCP" -- ':!docs/superpowers/' ':!CHANGELOG.md' ':!CLAUDE.md'
```
Expected: 0건. (CHANGELOG.md / CLAUDE.md 변경이력 / docs/superpowers/specs|plans 안의 역사적 기록만 OK)

- [ ] **Step 2: 잔존 참조가 있으면 해당 파일에서 제거**

각 잔존 위치별로 적절히 정리. 한꺼번에 별도 커밋:

```bash
git add -A
git commit -m "chore: remove final stale MCP/old-name references"
```

- [ ] **Step 3: 차원 변수화 누락 grep**

Run:
```bash
git grep -nE "프로젝트 종류:\*\* 3D 게임" -- ':!docs/superpowers/' ':!CHANGELOG.md' ':!CLAUDE.md'
```
Expected: 0건. (있으면 해당 위치를 `{project_type}` 변수 또는 양쪽 케이스로 변경)

- [ ] **Step 4: JSON 유효성 최종 확인**

Run:
```bash
node -e "JSON.parse(require('fs').readFileSync('.claude-plugin/plugin.json'))" && echo plugin.json OK
[ -f .mcp.json ] && node -e "JSON.parse(require('fs').readFileSync('.mcp.json'))" && echo mcp.json OK || echo "mcp.json absent (OK)"
```

- [ ] **Step 5: 플러그인 로드 스모크 (수동)**

사용자에게 안내:
> "다음 명령으로 플러그인 로드 확인 부탁드립니다:
> `claude --plugin-dir .`
> 새 세션에서 `/kickoff-godot:kickoff-orchestrator` 슬래시 커맨드가 보이고 시작 시 에러가 없으면 OK."

- [ ] **Step 6: 정리 커밋이 있으면 커밋**

```bash
git status
# 깨끗하면 종료, 변경 있으면:
git add -A
git commit -m "chore: final cleanup for v0.2.0"
```

---

## 자체 검토 (Self-Review) 결과

**Spec coverage:**

- 1.1 플러그인 메타 → Task 1 ✓
- 1.2 Phase 0 결정 → Task 4 ✓
- 1.3 MCP 완전 제거 → Task 2, 14, 15, 16 ✓
- 1.4 차원 분기 (references 분리) → Task 6, 7, 8, 9, 10, 11, 12, 13, 14, 16 ✓
- 1.5 Step 1-5 시점 옵션 → Task 5 ✓
- 1.6 CLAUDE.md 갱신 → Task 3 ✓
- 5. 검증 계획 → Task 19 ✓

**Placeholder 스캔:** 없음. 모든 단계가 구체적 명령·파일 경로·변경 내용을 포함.

**Type/이름 일관성:** `project_type`, `_meta.md`, `kickoff-godot` 명칭이 모든 Task에서 일관.

**스코프:** 19개 Task, 모두 doc/config 변경. 단일 plan 규모로 적합.
