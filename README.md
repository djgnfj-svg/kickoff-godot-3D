# kickoff-godot-3d

3D 게임(Godot 4) 전용 Claude Code 플러그인. 두 개의 하네스를 제공한다:

- **Kickoff Harness** — `why.md`/`what.md`/`how.md` + Feature 별 `feature-spec.md` 생성
- **Build Harness** — `feature-spec.md`를 받아 Planner → Generator ↔ Evaluator 루프로 실제 코드까지 구현

두 하네스는 독립적이며 `docs/features/F{N}/feature-spec.md`가 계약 인터페이스다.

플러그인에는 **Godot MCP**(bradypp/godot-mcp)와 **Blender MCP**(ahujasid/blender-mcp)가 vendored fork로 포함돼 있어 사용자가 직접 수정·확장할 수 있다.

---

## 설치

### 로컬 개발 모드 (이 레포를 직접 로드)

```bash
cd path/to/kickoff-godot-3D
claude --plugin-dir .
```

첫 세션 시작 시 SessionStart 훅이 `mcp-servers/godot-mcp/`를 TypeScript 컴파일해 `~/.claude/plugins/data/kickoff-godot-3d/godot-mcp/build/index.js`로 빌드한다. 이후 세션은 증분 빌드(변경 감지 시에만 재빌드).

### 사전 요구사항
- Claude Code (최신 버전, `/plugin` 명령 지원)
- Node.js 18+ + npm (Godot MCP 빌드)
- Python 3.10+ + pip (Blender MCP)
- Godot 4.x (실행 시 `GODOT_PATH` 환경변수 또는 표준 경로에 설치)
- Blender 4.5/5.0 + `blender-mcp` pip 패키지 (`pip install blender-mcp`)

### Blender MCP 설정 (최초 1회)

전역 pip 설치 방식을 유지한다:

```bash
pip install blender-mcp
# Blender addon 활성화 (ahujasid/blender-mcp README 참고)
```

---

## 사용

### Kickoff Harness

새 3D 게임의 기획 문서가 필요할 때:

```
/kickoff-godot-3d:kickoff-orchestrator
```

이후:
- Phase 1: 아이디어 → 1플레이어 원형·1코어 결핍·1코어 버브 확정
- Phase A: 7인 팀 토론(why/what/how 사이클 3회)
- Phase B: 2인 리뷰(Build Auditor·QA) 승인 게이트
- Phase C: Feature 분해 + Feature 로드맵 (사용자 확정 게이트)
- Phase D: 체크리스트 검증

산출물: `docs/kickoff/{why,what,how}.md`, `docs/kickoff/_feature-list.md`, `docs/kickoff/_roadmap.html`, `docs/features/F{N}/feature-spec.md`

### Build Harness

`feature-spec.md`가 준비된 후 구현 시작:

```
/kickoff-godot-3d:build-orchestrator
```

- Planner: `product-spec.md` + `S{M}-plan.md` 작성
- Generator: 스프린트 구현 (TDD + GUT/GdUnit4)
- Evaluator: 독립 검증 (PASS/FAIL 판정)
- FAIL 시 최대 2회 재시도 → 지속 실패 시 사용자 에스컬레이션
- Phase 2.7: F 마지막 스프린트 PASS 후 사용자 수동 검수 (USER_CHECK.md)

산출물: `docs/build/F{N}/`, 코드는 사용자 프로젝트 루트

---

## MCP 서버 자체 수정·업데이트

### Godot MCP

1. `mcp-servers/godot-mcp/src/*.ts` 편집
2. (선택) `mcp-servers/godot-mcp/package.json` 버전 bump
3. 새 Claude Code 세션 시작 → `scripts/sync-godot-mcp.sh`가 자동으로 감지·재빌드
4. 빌드 실패 시 `[kickoff-godot-3d] 경고:` 로그 확인

강제 재빌드:
```bash
rm -rf ~/.claude/plugins/data/kickoff-godot-3d/godot-mcp/build
# 다음 세션에서 자동 재빌드
```

업스트림(bradypp/godot-mcp) 동기화:
```bash
cd mcp-servers/godot-mcp
git init && git remote add upstream https://github.com/bradypp/godot-mcp.git
git fetch upstream main
# merge 또는 cherry-pick (수동)
```

### Blender MCP

1. `mcp-servers/blender-mcp/src/blender_mcp/...` 편집
2. 로컬 설치 재실행:
   ```bash
   pip install -e mcp-servers/blender-mcp
   ```
3. Blender 재시작 (addon 포함 시)

업스트림(ahujasid/blender-mcp) 동기화 방식은 Godot MCP와 동일.

---

## 디렉토리 구조

```
kickoff-godot-3d/
├── .claude-plugin/
│   └── plugin.json         # 플러그인 매니페스트
├── agents/                  # 12개 에이전트
├── skills/                  # 22개 스킬
├── mcp-servers/
│   ├── godot-mcp/           # bradypp/godot-mcp vendored fork (TS 원본)
│   └── blender-mcp/         # ahujasid/blender-mcp vendored fork (Python 원본)
├── scripts/
│   ├── sync-godot-mcp.sh    # SessionStart: Godot MCP 자동 빌드
│   └── ensure-running.sh    # Godot/Blender 프로세스 기동
├── hooks/
│   └── hooks.json           # SessionStart 훅 등록
├── .mcp.json                # MCP 서버 등록 (${CLAUDE_PLUGIN_DATA} 참조)
├── CLAUDE.md                # 하네스 아키텍처 문서
├── CHANGELOG.md
└── README.md
```

---

## 아키텍처 근거

Anthropic "Designing harnesses for long-running apps" 기반:

- 생성기-평가기 분리로 자기평가 편향 제거
- 컨텍스트 리셋 > compaction
- 파일 기반 자기완결적 핸드오프
- Evaluator "회의적 튠" — 하드 임계값 하나라도 미달이면 FAIL

상세 근거·변경 이력은 [CLAUDE.md](./CLAUDE.md) 참조.

---

## License

MIT. 포함된 MCP 서버는 각 upstream 라이선스(MIT) 준수.
