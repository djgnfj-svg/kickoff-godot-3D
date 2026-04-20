---
name: godot-mcp-protocol
description: Godot MCP 서버를 Generator/Evaluator가 사용할 때의 프로토콜. 현재 MCP가 할 수 있는 것과 없는 것을 capability matrix로 명시하고, 못 하는 동작은 3단계 fallback(사용자 위임 / godot --headless CLI / .tscn·.gd 텍스트 직접 편집)으로 우회한다. MCP 호출 실패 또는 capability matrix에 없는 기능이 필요할 때마다 docs/godot-mcp/gaps/G{N}.md에 "갭 리포트"를 남긴다. MCP 자체가 진화하는 변수이므로 capability matrix는 버전별로 갱신된다. "MCP 사용법", "Godot 편집 불가", "헤드리스 빌드", "갭 리포트" 상황에 반드시 이 스킬을 참조한다.
---

# Godot MCP Protocol — MCP 사용 규약 + 갭 관리

Godot 에디터를 프로그램적으로 조작하는 경로가 **여러 개**이고, 각 경로는 "할 수 있는 것"이 다르다. 이 스킬은 Generator와 Evaluator가 같은 경로를 같은 순서로 시도하게 만들어 **drift를 막는다**.

## 왜 이 스킬이 필요한가

- Godot MCP는 **진화하는 변수**다. 오늘 못 하던 기능이 다음 주에 생길 수 있다. 하드코딩된 "MCP를 쓰라" 지시는 금방 낡는다.
- 대신 "**capability matrix를 먼저 보고, 없으면 fallback**"이라는 절차를 규약화하면 MCP 버전이 바뀌어도 하네스가 부서지지 않는다.
- 갭(MCP가 못 하는 것)을 **체계적으로 기록**해야 별도의 MCP 개선 트랙이 갈아낼 대상이 생긴다.

## 3단계 경로 체계

Godot 조작 작업은 항상 이 순서로 시도한다:

```
1. Godot MCP 도구 호출 (capability matrix에 있으면)
   ↓ 실패 또는 기능 없음
2. Fallback A: `godot --headless` CLI
   (씬 실행·빌드·export·프로젝트 검증 등 헤드리스로 가능한 작업)
   ↓ 실패 또는 기능 없음
3. Fallback B: 텍스트 직접 편집
   (.tscn / .tres / .gd / project.godot를 텍스트 파일로 읽고 쓰기)
   ↓ 실패 또는 안전 불가
4. Fallback C: 사용자 위임
   (에디터 수동 조작이 필요한 작업 — 사용자에게 구체 지시를 한 문단으로 전달)
```

**순서를 건너뛰면 안 된다.** 예를 들어 "씬에 노드 추가"를 할 때 MCP가 지원한다면 텍스트 편집으로 .tscn 직접 수정 금지 (포맷 깨지기 쉬움).

## Capability Matrix

**위치:** `${CLAUDE_PLUGIN_ROOT}/skills/godot-mcp-protocol/references/capability-matrix.md`
**책임자:** 사용자 (MCP를 커스터마이즈하는 주체). 하네스는 읽기만 한다.
**포맷:**

```markdown
# Godot MCP Capability Matrix

**MCP 버전:** {semver 또는 커밋 해시}
**최종 갱신:** {YYYY-MM-DD}

## Supported (✅ MCP로 직접 호출 가능)
| 작업 | MCP 도구 이름 | 입력 | 출력 | 제약 |
|------|--------------|------|------|------|
| 씬 열기 | mcp__godot__open_scene | path | scene_id | - |
| 노드 추가 | mcp__godot__add_node | parent, type, name | node_path | type은 Godot 내장만 |
| 스크립트 attach | mcp__godot__attach_script | node_path, script_path | - | .gd만, C# 미지원 |
| ...  | ... | ... | ... | ... |

## Unsupported (❌ MCP로 못 하는 것 — fallback 필요)
| 작업 | 권장 Fallback | 비고 |
|------|--------------|------|
| Shader 편집 | 텍스트 직접 (.gdshader) | MCP가 shader 노드 이해 못 함 (v0.3 기준) |
| Export preset 수정 | 사용자 위임 | GUI 전용 |
| AnimationPlayer 트랙 편집 | 텍스트 (.tscn) | 포맷 복잡, 주의 |

## Experimental (⚠️ 지원하지만 불안정 — 주의)
| 작업 | MCP 도구 | 주의 |
|------|---------|------|
| Import 설정 변경 | mcp__godot__set_import | 변경 후 reimport 필요 |
```

**초기 작성:** 사용자가 첫 세션에서 MCP를 설치한 직후 기본 매트릭스를 채운다. 비어 있으면 Generator/Evaluator는 **모든 작업을 Fallback부터 시도**한다 (보수적 안전).

## Fallback A: `godot --headless`

Godot 4.x는 헤드리스 모드를 공식 지원한다. 자주 쓰는 명령:

```bash
# 프로젝트 import 검증 (처음 열 때 필요)
godot --headless --import

# 단일 씬 실행 + 지정 시간 후 종료 (smoke test)
godot --headless --quit-after 5 path/to/scene.tscn

# 스크립트 실행 (게임 루프 없이)
godot --headless --script path/to/tool.gd

# export preset으로 빌드
godot --headless --export-release "Linux/X11" build/game.x86_64

# 프로젝트 설정 검증 (MainLoop 없이 끝)
godot --headless --check-only
```

**쓰임:**
- Evaluator의 "빌드 통과" 자동 훅 → `godot --headless --import` 종료코드 0 + 에러 로그 0건
- Evaluator의 "씬 실행 가능" → `godot --headless --quit-after 3 scene.tscn` 로 크래시 없이 종료
- Generator의 "GDScript 구문 검증" → `godot --headless --check-only` 후 stderr 확인

**한계:**
- 렌더링 출력을 얻을 수 없음 (스크린샷은 Fallback B + 사용자 또는 MCP로만)
- Input 이벤트 시뮬레이션 제한적

## Fallback B: 텍스트 직접 편집

Godot 파일은 **텍스트 포맷**이라 Edit/Write로 직접 수정 가능. 단 포맷이 엄격해서 주의.

### 안전한 편집 대상
- `.gd` 파일 — 일반 GDScript, 자유롭게 편집
- `project.godot` — INI 계열, 섹션·키 구조 보존하며 수정
- `*.tres` 리소스 — 간단한 스칼라 값 변경은 안전
- `input_map` 항목 (`project.godot` 내) — 새 액션 추가

### 위험한 편집 대상 (가능하면 MCP로)
- `.tscn` 씬 파일 — 노드 트리, 서브리소스 UID, 참조 관계. 수동 편집 시 UID 중복 조심
- `.tres` 중 `ExtResource`/`SubResource` 블록이 있는 복잡 리소스
- `AnimationPlayer` 트랙 데이터

### 직접 편집 체크리스트
1. 편집 전 파일을 `Read`로 전체 확인 (부분 수정 금지)
2. UID가 필요하면 Godot 4 포맷 준수: `uid://xxxxx` (자동 생성 어려우면 MCP나 사용자 위임)
3. 편집 후 `godot --headless --check-only`로 구문 검증
4. 가능하면 Generator가 만든 변경을 그 자리에서 `git diff`로 확인 후 commit

## Fallback C: 사용자 위임

MCP·headless·텍스트 편집으로 불가능한 것만 사용자에게 맡긴다. 위임은 **예외**지 규칙이 아니다. 한 스프린트에서 위임이 3회 이상이면 설계가 잘못된 것 — Planner가 범위를 재조정해야 한다.

### 위임 요청 포맷
사용자에게 전달하는 메시지 형식:

```markdown
## 사용자 위임 요청 — S{M} 진행 중

**무엇을 해주세요:** {구체 동작 1문장}

**왜 위임:** {MCP 불가 / CLI 불가 / 텍스트 편집 위험}

**정확한 절차:**
1. Godot 에디터 열기 (프로젝트 경로: `...`)
2. {메뉴 경로 포함한 단계. "Project → Export → Add..." 수준까지}
3. 완료되면 이 스레드에 "완료"만 답장해주세요

**완료 확인 방법:** {예: "export/game.pck 파일이 생성됐는지 확인"}
```

## 갭 보고 프로토콜

Fallback A/B/C가 발동할 때마다 갭 리포트를 생성한다. 이것이 MCP 개선의 입력이 된다.

### 파일: `docs/godot-mcp/gaps/G{N}.md`

N은 갭 누적 번호 (G1, G2, ...). 디렉토리에 이미 있는 최대 N+1을 사용.

```markdown
# Gap G{N}: {짧은 제목}

**발견 세션:** {YYYY-MM-DD HH:MM — Generator/Evaluator 누구 세션}
**발견 컨텍스트:** F{N}/S{M} 구현 중
**MCP 버전:** {capability-matrix.md의 버전 — 복사}

## 무엇이 필요했나
{원래 하려고 했던 작업. 1-2문장.}

## 왜 MCP로 불가능했나
- [ ] capability matrix에 없음
- [ ] matrix에 있으나 호출 실패 (에러: `{에러 메시지}`)
- [ ] matrix에 있으나 결과가 기대와 다름 (구체: ...)

## 사용한 Fallback
- **경로:** Fallback A (headless) | B (텍스트) | C (사용자 위임)
- **명령/절차:** `{실제로 실행한 명령 또는 편집 내용}`
- **소요:** {시간 또는 작업량 감각}
- **성공 여부:** 성공 | 부분 성공 | 실패

## 제안 MCP API
```
도구 이름: mcp__godot__{제안 이름}
입력: {필드와 타입}
출력: {필드와 타입}
의미: {한 문장}
```

## 관련 파일
- {이 갭이 건드린 파일 경로 목록}
```

### 갭 리포트 생성 규칙
- **중복 방지:** 이미 같은 주제의 갭이 있으면 새로 만들지 말고 기존 G{k}에 "재발견: {세션}" 줄만 추가
- **바로 기록:** 작업 끝난 후가 아니라, Fallback이 발동하는 즉시 기록 (기억 손실 방지)
- **Blocking 아님:** 갭 리포트는 작업 진행을 막지 않는다. Fallback으로 진행 후 기록.

## 동시성/상태 규칙

- **Godot 에디터 세션은 한 번에 하나만.** MCP는 보통 살아있는 에디터 인스턴스에 붙는다. 헤드리스 명령과 MCP 호출이 동시에 같은 프로젝트를 건드리면 락 깨짐.
- Evaluator가 headless 실행을 돌릴 때 MCP 연결은 일시 끊고 재연결 (또는 별도 프로젝트 복사본 사용)
- 파일을 직접 편집한 후 MCP가 이미 해당 파일을 열고 있으면 에디터가 "외부 변경" 경고 → MCP로 `reload_current_scene` 호출 필요

## 이 스킬을 참조하는 주체

- `generator` 에이전트 — 구현 시 MCP 우선, 실패 시 fallback 체계적 적용
- `evaluator` 에이전트 — 빌드/씬 실행/스크린샷 검증 시 fallback 체계 동일 적용
- `sprint-execution` 스킬 — TDD 사이클 중 MCP 호출 패턴 연동
- `sprint-evaluation` 스킬 — 자동 훅에서 headless 명령 실행
- `godot-scene-handoff` 스킬 — 핸드오프 파일에 "사용한 경로(MCP/headless/text/manual)" 기록 의무

## 변경 이력 (SKILL.md 자체)

| 날짜 | 변경 | 사유 |
|------|------|------|
| 2026-04-16 | 초안 | Build Harness Godot 전환 |
