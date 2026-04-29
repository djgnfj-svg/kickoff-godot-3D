# kickoff-godot

2D/3D Godot 4 게임 프로젝트용 Claude Code 플러그인. 두 개의 하네스를 제공한다:

- **Kickoff Harness** — `why.md`/`what.md`/`how.md` + Feature 별 `feature-spec.md` 생성
- **Build Harness** — `feature-spec.md`를 받아 Planner → Generator ↔ Evaluator 루프로 실제 코드까지 구현

두 하네스는 독립적이며 `docs/features/F{N}/feature-spec.md`가 계약 인터페이스다.

차원(2D/3D)은 Phase 0-1에서 Founder가 사용자에게 명시 질문하여 `docs/kickoff/_meta.md`의 `project_type` 필드에 저장하고, 모든 에이전트·스킬이 이 값을 읽어 `references/{2d,3d}.md`로 분기한다.

---

## 설치

### 로컬 개발 모드 (이 레포를 직접 로드)

```bash
cd path/to/kickoff-godot
claude --plugin-dir .
```

스킬·에이전트 수정 후 `/reload-plugins`로 핫 리로드.

### 사전 요구사항
- Claude Code (최신 버전, `/plugin` 명령 지원)
- Godot 4.x (실행 시 `GODOT_PATH` 환경변수 또는 표준 경로에 설치)

---

## 사용

### Kickoff Harness

새 게임의 기획 문서가 필요할 때:

```
/kickoff-godot:kickoff-orchestrator
```

이후:
- Phase 0-1: 2D/3D 차원 확정 (Founder 질문 → `_meta.md` 저장)
- Phase 1: 아이디어 → 1플레이어 원형·1코어 결핍·1코어 버브 확정
- Phase A: 7인 팀 토론(why/what/how 사이클 3회)
- Phase B: 2인 리뷰(Build Auditor·QA) 승인 게이트
- Phase C: Feature 분해 + Feature 로드맵 (사용자 확정 게이트)
- Phase D: 체크리스트 검증

산출물: `docs/kickoff/{why,what,how}.md`, `docs/kickoff/_meta.md`, `docs/kickoff/_feature-list.md`, `docs/kickoff/_roadmap.html`, `docs/features/F{N}/feature-spec.md`

### Build Harness

`feature-spec.md`가 준비된 후 구현 시작:

```
/kickoff-godot:build-orchestrator
```

- Planner: `product-spec.md` + `S{M}-plan.md` 작성
- Generator: 스프린트 구현 (TDD + GUT/GdUnit4)
- Evaluator: 독립 검증 (PASS/FAIL 판정)
- FAIL 시 최대 2회 재시도 → 지속 실패 시 사용자 에스컬레이션
- Phase 2.7: F 마지막 스프린트 PASS 후 사용자 수동 검수 (USER_CHECK.md)

산출물: `docs/build/F{N}/`, 코드는 사용자 프로젝트 루트

---

## 에디터 작업 방식

`.tscn`/`.gd`/`.tres` 텍스트 직접 편집 + `godot --headless --import` smoke로 작업한다. 시각 확인은 사용자가 Godot 에디터에서 직접 수행한다 (핸드오프 표준에 명시).

에셋 폴백은 2단계: Godot 내장 primitive/ColorRect → 사용자 위임. 복잡 에셋 import도 사용자 위임.

---

## 디렉토리 구조

```
kickoff-godot/
├── .claude-plugin/
│   └── plugin.json         # 플러그인 매니페스트
├── agents/                  # 12개 에이전트
├── skills/                  # 12개 스킬
├── .mcp.json                # 빈 매니페스트 ({ "mcpServers": {} })
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

MIT.
