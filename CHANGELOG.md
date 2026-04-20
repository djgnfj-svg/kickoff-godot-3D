# Changelog

All notable changes to the `kickoff-godot-3d` plugin.

Format follows [Keep a Changelog](https://keepachangelog.com/).

## [1.0.0] - 2026-04-20

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
