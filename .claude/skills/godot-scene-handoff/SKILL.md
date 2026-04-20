---
name: godot-scene-handoff
description: Godot 4 프로젝트에서 Planner→Generator→Evaluator 사이에 주고받는 씬·리소스·스크립트·프로젝트 설정의 핸드오프 표준. build-handoff의 일반 규약을 Godot 도메인으로 확장한다. 어떤 씬(.tscn)/리소스(.tres)/스크립트(.gd)/자동로드(autoload)/입력맵(input map)/물리 레이어(physics layers)가 어느 스프린트에서 생성·수정되는지, 다음 에이전트가 어느 파일을 먼저 읽어야 하는지 명시한다. "씬 핸드오프", "godot 프로젝트 구조", "자동로드 규칙", "입력맵 설계", "노드 트리 설계" 상황에 이 스킬을 참조한다.
---

# Godot Scene Handoff — Godot 4 프로젝트 파일 핸드오프

`build-handoff` 스킬이 정의한 일반 파일 핸드오프 위에, Godot 특유의 파일 종류와 프로젝트 설정을 덧붙인다.

## 왜 별도 스킬이 필요한가

- 일반 웹 프로젝트는 "파일 N개 수정"으로 끝나지만, Godot는 **씬 그래프**, **리소스 참조(UID)**, **프로젝트 레벨 설정**(autoload/input map/physics layers/rendering) 같은 다층 상태를 동시에 건드린다
- 한 스프린트에서 `project.godot`의 autoload를 추가하면서 다른 스프린트에서 모르면 **숨은 의존**이 생긴다
- 씬 A가 씬 B를 instance로 포함하면 B를 수정할 때 A의 재저장이 필요할 수 있음 — 에이전트가 모르면 런타임에 터짐

## Godot 프로젝트 표준 레이아웃

하네스가 가정하는 프로젝트 구조. Planner가 product-spec에 이것을 명시하고, 모든 에이전트가 준수.

```
{프로젝트 루트}/
├── project.godot                     # 프로젝트 설정 — autoload/input/physics/rendering
├── icon.svg
├── scenes/                           # .tscn — 씬 파일
│   ├── main/                         # 진입 씬·메뉴
│   ├── systems/                      # 게임 시스템 씬 (플레이어/적/카메라 등 재사용 씬)
│   ├── levels/                       # 레벨·스테이지
│   └── ui/                           # HUD·메뉴·다이얼로그
├── scripts/                          # .gd — 스크립트
│   ├── autoload/                     # 자동로드 스크립트
│   ├── systems/                      # 시스템 로직 (씬과 1:1 대응 권장)
│   ├── components/                   # 재사용 컴포넌트 (HealthComponent 등)
│   └── utils/                        # 유틸
├── resources/                        # .tres — 리소스 (머티리얼, 커브, 사용자 정의 Resource)
│   ├── materials/
│   ├── data/                         # 게임 데이터 (아이템, 스탯) — 사용자 정의 Resource
│   └── themes/                       # UI 테마
├── assets/                           # 원본 에셋
│   ├── models/                       # .glb, .gltf
│   ├── textures/
│   ├── audio/
│   └── fonts/
├── shaders/                          # .gdshader
├── addons/                           # 서드파티 플러그인 (건드리지 않음)
└── tests/                            # GUT 또는 GdUnit4 테스트
```

**원칙:**
- `assets/`는 **원본만**, 런타임 참조는 `resources/` 또는 직접 씬에서
- `scenes/`와 `scripts/`는 **대칭 구조** 권장 (`scenes/systems/player.tscn` ↔ `scripts/systems/player.gd`)
- 한 씬은 **한 스크립트만 루트에** (가능하면). 자식 노드 스크립트는 해당 노드 전용 로직만

## 핸드오프에 추가되는 Godot 전용 섹션

`build-handoff`의 product-spec.md와 S{M}-plan.md / S{M}-generator.md에 아래 섹션을 **반드시** 포함.

### product-spec.md 추가 섹션

```markdown
## 7. Godot 프로젝트 설정 (Godot Project Config)

### 7-1. 프로젝트 메타
- **Godot 버전:** 4.x (정확한 minor — 예: 4.3.stable)
- **렌더러:** Forward+ | Mobile | Compatibility
- **Main Scene:** res://scenes/main/main.tscn
- **표시 해상도:** {기본}, stretch mode/aspect
- **물리 FPS:** 60 (또는 스프린트 목표에 따라)

### 7-2. Autoload (글로벌 싱글톤)
| 이름 | 스크립트 | 책임 | 도입 스프린트 |
|------|---------|------|---------------|
| GameState | res://scripts/autoload/game_state.gd | 씬 전환·세이브 데이터 | S1 |
| EventBus | res://scripts/autoload/event_bus.gd | 시스템 간 signal 허브 | S1 |
| ... | ... | ... | ... |

**원칙:** Autoload는 최소로. 남발 시 강결합 발생. 새 autoload 추가는 architect 리뷰 필요.

### 7-3. Input Map
| 액션 | 기본 바인딩 (KBM) | 기본 바인딩 (Gamepad) | 도입 스프린트 |
|------|------------------|----------------------|---------------|
| move_forward | W | Left Stick Up | S1 |
| jump | Space | A button | S1 |
| ... | ... | ... | ... |

**원칙:** 액션 이름은 snake_case. UI 액션은 `ui_` 접두사 (Godot 기본값 재사용).

### 7-4. Physics Layers
| 번호 | 이름 | 용도 |
|------|------|------|
| 1 | world | 정적 지형 |
| 2 | player | 플레이어 캐릭터 |
| 3 | enemy | 적 |
| 4 | projectile | 발사체 |
| 5 | interactable | 상호작용 오브젝트 |

**원칙:** 번호 재할당 금지 (충돌 매트릭스 붕괴). 이름은 project.godot `[layer_names.*]` 에 반드시 기록.

### 7-5. 렌더링/품질 프리셋
- Shadow atlas size, MSAA, FSR 등 Feature 범위에서 변하는 값만 기재
- 미정이면 "default (Godot 4 기본값 유지)"
```

### S{M}-plan.md 추가 섹션

```markdown
## 7. 이 스프린트의 Godot 영향

### 7-1. 생성/수정되는 씬
| 경로 | 신규/수정 | 루트 노드 타입 | 스크립트 | 용도 |
|------|-----------|---------------|---------|------|
| scenes/systems/player.tscn | 신규 | CharacterBody3D | scripts/systems/player.gd | 플레이어 이동 |

### 7-2. 생성/수정되는 스크립트
| 경로 | 신규/수정 | 의존 (다른 스크립트/autoload) |
|------|-----------|-------------------------------|
| ... | ... | ... |

### 7-3. 생성/수정되는 리소스
| 경로 | 타입 | 용도 |
|------|------|------|
| resources/data/player_stats.tres | PlayerStatsResource (사용자 정의) | 기본 스탯 |

### 7-4. 프로젝트 설정 변경
- Autoload: {추가/제거/변경 — 없으면 "없음"}
- Input Map: {추가/제거/변경}
- Physics Layers: {추가/제거/변경}
- 기타: {rendering/display/debug 등}

**프로젝트 설정 변경은 product-spec.md 7항의 테이블을 동시에 갱신한다.**

### 7-5. 검증 가능한 씬 실행
- **Smoke 씬:** `scenes/__dev/sprint_{M}_smoke.tscn` — 이번 스프린트 산출을 실행만으로 확인하는 최소 씬
- **Headless 실행:** `godot --headless --quit-after 5 scenes/__dev/sprint_{M}_smoke.tscn` 종료코드 0 + 에러 로그 0건
```

**Smoke 씬 원칙:** 스프린트마다 `scenes/__dev/sprint_{M}_smoke.tscn` 같은 **검증 전용 씬**을 만든다. Evaluator가 headless로 이걸 돌려 크래시 없음을 확인. 씬 하나당 최소 에셋으로 기능을 실증 (프로덕션 씬과 분리).

### S{M}-generator.md 추가 섹션

```markdown
## 7. Godot 산출 요약

### 7-1. 새 씬 트리 (신규 씬만)
```
Player (CharacterBody3D) [script: player.gd]
├── CollisionShape3D
├── MeshInstance3D
├── Camera3D (node_name: PlayerCamera)
└── AudioListener3D
```

### 7-2. 사용한 MCP 경로 (godot-mcp-protocol 참조)
| 작업 | 경로 | 비고 |
|------|------|------|
| 씬 생성 | MCP | - |
| 스크립트 attach | MCP | - |
| Autoload 등록 | 텍스트 편집 (project.godot) | MCP 미지원 (갭 G3 참조) |

### 7-3. 발생한 갭 리포트
- G{N}: {한 줄 요약} — `docs/godot-mcp/gaps/G{N}.md`

### 7-4. Smoke 씬 실행 결과
- 명령: `godot --headless --quit-after 5 scenes/__dev/sprint_{M}_smoke.tscn`
- 종료코드: 0
- 로그 경로: docs/build/F{N}/sprints/logs/S{M}-smoke.log
```

## UID·참조 규칙

Godot 4는 파일 참조에 UID를 쓴다 (`uid://xxxxx`). 에이전트가 지켜야 할 것:

- **MCP로 만든 파일의 UID는 건드리지 않는다.** Godot가 자동 할당.
- **텍스트로 새 .tscn/.tres 파일을 만들 때**는 UID 없이 저장 가능 (Godot가 첫 로드 시 할당). 단 이미 다른 파일이 이걸 참조하면 경로로 먼저 참조하게.
- **파일 이동/이름 변경**은 MCP 또는 에디터 내에서 수행 (참조 자동 갱신). 텍스트 편집으로 경로만 바꾸면 참조 끊어짐.

## 씬 간 의존성 추적

한 스프린트에서 씬 A가 씬 B를 `PackedScene`으로 참조하면, 다음 스프린트에서 B를 수정할 때 A를 재검증해야 한다. 이걸 놓치지 않기 위해:

- **S{M}-generator.md 7-1 섹션에 "이 씬이 instance로 포함하는 씬" 기록**
- `handoffs/S{M}-context.md`에 **씬 의존성 그래프 요약** 섹션 추가:
  ```markdown
  ## 씬 의존성 (S{M} 종료 시점)
  - scenes/levels/level_01.tscn → [player.tscn, enemy.tscn, hud.tscn]
  - scenes/systems/enemy.tscn → [enemy_state_machine.tscn]
  ```

## 이 스킬을 참조하는 주체

- `planner` 에이전트 → product-spec.md 7항 + S{M}-plan.md 7항 작성
- `generator` 에이전트 → S{M}-generator.md 7항 작성, 씬 생성 시 표준 레이아웃 준수
- `evaluator` 에이전트 → 씬 트리 일치 확인, smoke 씬 실행, 의존성 역추적
- `build-handoff` 스킬 → 이 스킬은 build-handoff의 확장
- `godot-mcp-protocol` 스킬 → "사용한 경로" 기록 연동

## 변경 이력

| 날짜 | 변경 | 사유 |
|------|------|------|
| 2026-04-16 | 초안 | Build Harness Godot 전환 |
