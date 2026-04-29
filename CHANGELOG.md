# Changelog

All notable changes to the `kickoff-godot` plugin.

Format follows [Keep a Changelog](https://keepachangelog.com/).

## v0.2.0 — 2026-04-29

### Breaking Changes
- 플러그인 이름 `kickoff-godot-3d` → `kickoff-godot`. 기존 사용자는 재설치 필요
- 슬래시 커맨드 네임스페이스 `/kickoff-godot-3d:` → `/kickoff-godot:`
- Godot MCP / Blender MCP 인프라 완전 제거 (`mcp-servers/`, `scripts/sync-godot-mcp.sh`, `scripts/ensure-running.sh`, `hooks/hooks.json`, `skills/godot-mcp-protocol/`, `docs/godot-mcp/` 삭제)
- `.mcp.json`이 빈 매니페스트 (`{ "mcpServers": {} }`)

### Added
- 2D Godot 게임 프로젝트 지원
- Phase 0-1에서 Founder가 사용자에게 2D/3D 명시 질문 (Founder 책임)
- `docs/kickoff/_meta.md`에 `project_type: {2d|3d}` 저장. 모든 에이전트·스킬이 이 값으로 차원 분기
- 차원-특화 디테일은 `references/{2d,3d}.md`로 분리:
  - `skills/asset-pipeline/`
  - `skills/godot-scene-handoff/`
  - `skills/visual-gate/`
  - `skills/kickoff-docs/`
  - `skills/build-conventions/`
- Phase 1 Step 1-5 시점 옵션이 차원별로 다른 풀 제시 (2D: 탑다운/사이드뷰/쿼터뷰/정면/보드뷰 / 3D: 1인칭/3인칭/탑다운3D/고정 카메라)

### Changed
- 헤더 형식 `**프로젝트 종류:** 3D 게임 (Godot 4)` → `**프로젝트 종류:** {2D|3D} 게임 (Godot 4)`로 변수화 (Scribe·Generator가 `_meta.md` 읽어 채움)
- `asset-pipeline` 폴백 4단계 → 2단계 (Godot 내장 → 사용자 위임)
- Generator는 `.tscn`/`.gd`/`.tres` 텍스트 직접 편집 + `godot --headless --import` smoke로 작업
- 시각 확인·복잡 에셋 import는 사용자 위임 (핸드오프 표준에 명시)

### Removed
- `skills/godot-mcp-protocol/` (스킬 통째)
- `mcp-servers/{godot-mcp,blender-mcp}/` (vendored fork)
- `scripts/sync-godot-mcp.sh`, `scripts/ensure-running.sh`
- `hooks/hooks.json` (SessionStart hook), `hooks/`·`scripts/` 빈 디렉토리
- `docs/godot-mcp/` (갭 리포트 트랙)
- `build-orchestrator`의 "MCP 개선 트랙" 섹션
- 에이전트·스킬의 MCP 호출 지시·capability matrix 참조 일체

## [0.1.0] - 2026-04-20

### Added
- 초기 플러그인 릴리스. `.claude/` standalone 구조에서 Claude Code 플러그인 표준으로 전환.
- `.claude-plugin/plugin.json` 매니페스트 신설.
- `mcp-servers/godot-mcp/`: bradypp/godot-mcp main HEAD vendored fork (TypeScript 원본 포함, 사용자 직접 수정 가능).
- `mcp-servers/blender-mcp/`: ahujasid/blender-mcp main HEAD vendored fork (Python 원본 포함).
- `scripts/sync-godot-mcp.sh`: SessionStart 훅에서 Godot MCP 소스 변경 감지 → `${CLAUDE_PLUGIN_DATA}/godot-mcp/`에 자동 재빌드. 증분 빌드 지원.
- `hooks/hooks.json`: SessionStart 훅 등록.
- `.mcp.json`: `${CLAUDE_PLUGIN_ROOT}`·`${CLAUDE_PLUGIN_DATA}` 변수 사용으로 이식성 확보.
- README.md, CHANGELOG.md.

### Changed
- `.claude/{agents,skills,scripts}/` → 플러그인 루트의 `{agents,skills,scripts}/`로 이동.
- `.claude/mcp-servers/godot-mcp/` (컴파일된 JS만) → `mcp-servers/godot-mcp/` (TypeScript 원본).
- 에이전트·스킬 13개 파일 내 `.claude/{agents,skills,scripts}/...` 하드코딩 경로 37줄을 `${CLAUDE_PLUGIN_ROOT}/...` 변수 참조로 일괄 치환.
- CLAUDE.md 상단 구조 섹션을 플러그인 구조로 재작성.
- `.gitignore`: `mcp-servers/*/build/`, `mcp-servers/*/dist/` 제외 (업스트림 소스는 추적).

### Removed
- `.claude/mcp-servers/godot-mcp/` 구 컴파일 결과물 (22MB node_modules 포함).

### Kept
- `.claude/settings.local.json` — 사용자 로컬 permissions, 이식 불필요.
- Blender MCP의 전역 `blender-mcp` pip 명령어 의존 (vendored fork는 "수정용" 참조).

## [1.1.0] - 2026-04-20

### Changed — 스킬 개수 축소 (19 → 13, 6개 감소)

1인-전용 프로토콜 스킬 6개를 각 담당 에이전트 `.md` 파일 내부 `## 통합 프로토콜:` 섹션으로 흡수. 목표: 스킬 description character budget 초과 해소 + Claude의 스킬 자동 발견 정확도 향상.

| 제거된 스킬 | 흡수된 에이전트 |
|------|------|
| `competitor-research` | `game-market-researcher.md` |
| `game-design-loop` | `core-mechanic-designer.md` |
| `hook-design-protocol` | `hook-strategist.md` |
| `sellability-audit-protocol` | `sellability-auditor.md` |
| `niche-enforcement` | `niche-enforcer.md` |
| `kickoff-review` | `build-auditor.md` (공통 운영 규칙) + `qa.md` (참조) |

- 18줄의 스킬 참조를 에이전트 참조로 일괄 치환 (다른 에이전트·스킬·오케스트레이터 문서).
- 각 에이전트 파일 크기 증가: 평균 ~6KB → ~10KB (최대 `game-market-researcher.md` 26KB).
- 공식 `superpowers` 플러그인(14 스킬, SKILL.md 평균 226줄)과 유사한 규모로 정돈.

### 근거
- Claude Code 공식 문서: 스킬 description character budget(기본 8,000자 fallback) 초과 시 설명이 잘려 자동 매칭 실패.
- [GitHub Issue #14882](https://github.com/anthropics/claude-code/issues/14882): progressive disclosure가 제대로 동작하지 않고 스킬 본문이 startup 시 전체 로드되는 버그 보고.
- 업계 비교: Anthropic 공식 플러그인은 한 플러그인당 1~2 컴포넌트, `superpowers`는 15, `wshobson/agents`는 평균 3.6. 기존 19는 상한선 초과.
