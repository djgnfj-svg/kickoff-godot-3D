---
name: build-conventions
description: Build Harness에서 Generator가 지키고 Evaluator가 같은 규칙으로 검증할 "프로젝트별 검증 가능한 규칙" 모음. 코딩(coding)·디자인(design)·접근성(accessibility)·성능(performance) 4개 도메인의 골격을 제공한다. Generator가 구현 전 참조하고, Evaluator가 판정 시 위반 여부를 측정한다. "참조용/평가용 분리 금지" — 한 벌의 규칙이 생성과 평가 양쪽의 단일 진실원(source of truth)이어야 drift가 생기지 않는다. 규칙은 프로젝트 첫 스프린트에서 feature-spec과 초기 코드베이스를 보고 채운다(빈 골격으로 시작해 진화).
---

# Build Conventions — Generator와 Evaluator의 공유 규칙책

Build Harness에서 Generator는 규칙을 **따르고**, Evaluator는 같은 규칙의 **위반을 찾는다**. 두 에이전트가 다른 문서를 보면 drift(생성과 평가의 기준 어긋남)가 발생한다. 그래서 이 스킬은 **단일 진실원(single source of truth)** 역할을 한다.

## 왜 한 벌의 규칙인가

- 규칙이 두 군데 있으면 업데이트 타이밍이 엇갈린다 → Generator는 신 규칙 지키고 Evaluator는 구 규칙으로 판단 → 모순
- "Generator는 느슨하게, Evaluator는 엄격하게"는 실무에서 실패한다. Evaluator가 잡아야 할 위반을 Generator가 *알면서* 만들어서는 안 된다
- 규칙이 검증 불가능하면(예: "코드가 깔끔하다") 둘 다 참조해도 무의미. 이 스킬은 **검증 가능한 규칙만** 담는다

## 4개 도메인

```
build-conventions/
├── SKILL.md                          ← 이 파일 (총괄 + 사용법)
└── references/
    ├── coding.md                     ← 폴더 구조·명명·언어 규칙·테스트
    ├── design.md                     ← 레이아웃·타이포·색·상호작용
    ├── accessibility.md              ← WCAG·키보드·스크린리더
    └── performance.md                ← 번들·응답시간·메모리·렌더링
```

각 파일은 **플러그인이 제공하는 정적 레퍼런스**다. 3D 게임(Godot 4) 일반 규칙(GDScript 네이밍·노드 트리 패턴·Physics·렌더 성능 등)이 미리 채워져 있다. Generator/Evaluator는 **읽기 전용**으로 사용한다.

## 정적 레퍼런스 원칙

- 런타임에 Planner/Generator/Evaluator가 이 파일을 **수정하지 않는다**. 플러그인은 여러 프로젝트가 공유하는 자산이라 런타임 수정은 다른 프로젝트로 오염된다.
- **프로젝트별 특수 규칙**(Autoload 이름·Physics Layer 번호·렌더러 선택·InputMap 등)은 `docs/build/F{N}/product-spec.md 7항`에 기록한다. 이게 프로젝트 단일 진실원.
- 플러그인 레퍼런스의 일반 규칙을 개선해야 한다고 판단되면 Evaluator가 evaluation.md "체제 개선 제안" 섹션에 메모만 남긴다. 실제 반영은 플러그인 유지보수자가 별도로 수행.

## 사용 흐름

### Generator가 쓸 때

1. 구현 시작 전 `build-conventions/references/` 4개를 모두 읽는다
2. 자신의 스프린트에 해당하는 도메인만 엄격히 적용 (예: API 전용 스프린트면 design/accessibility는 "해당 없음" 확인 후 넘어감)
3. 자체 점검 단계에서 각 규칙을 체크리스트화하여 S{M}-generator.md "자체 점검" 섹션에 기록

### Evaluator가 쓸 때

1. S{M}-generator.md를 읽고, 그 스프린트가 건드린 도메인을 파악
2. 해당 도메인의 references 파일을 읽는다
3. **각 규칙을 측정 가능한 절차로 변환**해 실행 — 예:
   - "TS strict 모드" → `tsc --noEmit` 실행, 경고 0건 확인
   - "색상 팔레트 준수" → CSS/SCSS에서 허용 토큰 외 hex/hsl 검색
4. 위반 발견 시 S{M}-evaluation.md 증거 섹션에 구체 파일·줄까지 적음

### 규칙을 추가/수정할 때

- **추가**: 새 스프린트에서 반복 위반이 발생하면 references에 규칙을 추가. 변경 이력을 파일 상단에 기록
- **수정**: 기존 규칙이 오탐이면(Generator가 지키려 해도 정당한 예외가 있으면) 규칙을 완화하되 반드시 **검증 가능한 예외 조건**을 같이 명시
- **삭제 금지**: 한 번 도입된 규칙은 "해당 없음" 상태로 남긴다. 삭제하면 "왜 사라졌는지" 감사 추적이 끊어진다

## "검증 가능한 규칙"이란

다음 질문에 YES여야 규칙으로 등록할 수 있다:

- 이 규칙을 누군가 위반했을 때, **제3자가 재현 가능한 절차로** 위반을 증명할 수 있는가?
- 그 절차는 **명령·스크립트·수동 재현 단계**로 기술되는가?

| 좋은 규칙 | 나쁜 규칙 |
|----------|----------|
| "`src/features/{feature}/` 외부에서 `import * as internal` 금지" | "의존성을 깔끔하게 관리할 것" |
| "버튼 간격 ≥ 8px, 모바일에서 ≥ 16px" | "UI가 보기 좋아야 함" |
| "이미지는 width/height 속성 지정 (CLS 방지)" | "성능 좋게 만들 것" |

나쁜 규칙은 Evaluator가 판정할 수 없어 주관 판정이 들어간다 → 자기평가 편향 부활.

## 규칙 작성 포맷 (references 파일 공통)

각 references/*.md는 아래 구조를 따른다:

```markdown
# {도메인} Conventions

**상태:** DRAFT (채워지지 않음) | ACTIVE
**최종 수정:** YYYY-MM-DD
**수정 이력:**
| 날짜 | 변경 | 사유 |
|------|------|------|
| ... | ... | ... |

## 적용 범위
{이 도메인이 어느 스프린트에 적용되는지. 예: "UI가 있는 스프린트" / "모든 스프린트"}

## 규칙

### R{n}. {규칙 이름 한 줄}
- **선언:** {무엇을 지킬 것인가}
- **검증:** {어떻게 검증하는가 — 명령어 / 수동 절차 / 도구}
- **예외:** {허용되는 예외 조건, 없으면 "없음"}
- **위반 시 판정:** FAIL | WARN

### R{n+1}. ...
```

- `FAIL` = Evaluator가 이 규칙 위반 시 스프린트를 FAIL로 판정
- `WARN` = 누적 관찰은 하되 단독으로 FAIL시키지 않음

## 이 스킬을 참조하는 주체

- `generator` 에이전트 → 구현 시 읽기 (정적 레퍼런스)
- `evaluator` 에이전트 → 판정 시 읽기 (정적 레퍼런스)
- `sprint-execution` / `sprint-evaluation` 스킬 → 체크리스트 연동
- 플러그인 유지보수자 → 일반 규칙 자체를 개선할 때만 수정 (런타임 에이전트 아님)

---

## 게임 프로젝트 (3D 게임 — Godot 4) 4도메인 초기 규칙

아래는 플러그인이 미리 채워둔 **3D 게임(Godot 4) 일반 규칙 세트**다. Generator/Evaluator는 읽기 전용으로 참조한다. 프로젝트별 특수 규칙(Autoload 이름·Physics Layer 번호·렌더러 등)은 `product-spec.md 7항`에 따로 기록한다.

### coding.md (게임 버전)
- **R1. 파일 레이아웃:** `godot-scene-handoff` 스킬의 표준 레이아웃 준수. 검증: ls 명령으로 루트 디렉토리 확인, 스크립트가 `scripts/` 외부에 있으면 위반.
- **R2. GDScript 스타일:** Godot 4 공식 스타일 가이드 준수 (snake_case 변수/함수, PascalCase 클래스/노드 타입, 4-space 들여쓰기). 검증: `godot --headless --check-only` + 린터(gdlint 있으면).
- **R3. 노드 명명:** PascalCase. 검증: .tscn 파일을 grep하여 `[node name="..."]` 소문자 시작이 있으면 위반.
- **R4. 시그널 명명:** snake_case + 과거분사/상태 표현 (`health_changed`, `enemy_defeated`). 검증: `grep -r "signal " scripts/` 결과에서 카멜케이스/동사원형 검출.
- **R5. Autoload 최소화:** 새 autoload 추가는 Kickoff how.md에 근거가 있어야 하며, Phase B Build Auditor의 "구현 구체성 최소 세트" 검토 대상. 검증: `project.godot`의 `[autoload]` 섹션 diff 확인.
- **R6. 씬 ↔ 스크립트 대칭:** `scenes/systems/X.tscn`의 루트에 붙는 스크립트는 `scripts/systems/X.gd`. 검증: 씬 파일에서 `script = ExtResource(...)` 경로 정합성.
- **R7. GUT 또는 GdUnit4 테스트:** 새 gd 파일에 핵심 유틸/상태 머신/데미지 계산 있으면 테스트 필수. 검증: `tests/` 하위 대응 테스트 존재.

### design.md (게임 버전)
- **R1. 카메라 거리:** 3인칭이면 타깃과의 고정 범위(예: 3~6m). 검증: 카메라 스크립트의 distance 필드 상수 확인.
- **R2. UI 레이아웃 그리드:** HUD 요소의 화면 safe area (상/하 각 5%, 좌/우 각 3%) 준수. 검증: UI 씬의 anchor 값.
- **R3. 머티리얼 색 팔레트:** 프로젝트 팔레트 파일(`resources/palette.tres`) 외부 색 사용 금지 (placeholder 예외). 검증: grep으로 `StandardMaterial3D` + `albedo_color = Color(...)` 직접 지정 검출.
- **R4. 폰트 일관성:** UI 전체에 지정된 `theme.tres` 사용. 검증: `.tscn`에서 `custom_fonts/` 직접 지정 검출.
- **R5. 피드백 3감각 원칙:** 코어 버브 발동 시 시각/청각/수치 중 최소 2개 동시 반응. 검증: 씬 실행 후 로그에서 `emit_signal("verb_triggered")` 이벤트마다 대응 이펙트 트리거 확인.

### accessibility.md (게임 버전)
- **R1. 키 리매핑:** 모든 게임 액션은 `InputMap`에 정의되고 플레이어가 재매핑 가능. 검증: `project.godot`의 input map + 설정 화면 씬 존재.
- **R2. 감도/데드존 설정:** 아날로그 입력(게임패드 스틱, 마우스)에 감도·데드존 슬라이더 제공. 검증: 설정 씬에 해당 UI 존재.
- **R3. 자막 지원:** 대사·중요 효과음에 자막 토글 옵션. 검증: `accessibility_options.tres` 리소스의 subtitles 필드.
- **R4. 색약 고려:** 색만으로 정보 전달 금지 — 모양·아이콘·텍스트 보조. 검증: 디자인 리뷰 시 명시적 확인 (수동이지만 기록 의무).
- **R5. FPS 선택:** 30/60/120 FPS cap 옵션. 검증: 설정 씬 + Engine.max_fps 연동.

### performance.md (게임 버전)
- **R1. 타깃 FPS:** PC 60fps (하한), 모바일 30fps (하한). 검증: `godot --headless --quit-after 10 scenes/__bench/bench.tscn` 실행 후 로그의 평균 FPS.
- **R2. Draw call 한도:** 벤치 씬에서 프레임당 드로콜 < 2000 (PC), < 1000 (모바일). 검증: MonitoringServer 또는 print(Performance.get_monitor(...)).
- **R3. 메모리 한도:** 벤치 씬 실행 5분 후 메모리 증가율 < 10%/분 (누수 방지). 검증: Performance.MEMORY_STATIC 주기 측정.
- **R4. 씬 로드 시간:** 레벨 씬 로드 < 3초 (PC). 검증: 로드 시작~`_ready()` 완료 스탬프 diff.
- **R5. LOD 정책:** 먼 오브젝트(20m+)에 LOD 또는 culling. 검증: 씬에 VisibilityNotifier3D/OcclusionCulling 사용 확인.

### Evaluator 검증 명령 표준
- 빌드/구문: `godot --headless --import` + `godot --headless --check-only`
- Smoke 씬: `godot --headless --quit-after 5 scenes/__dev/sprint_{M}_smoke.tscn` (exit 0)
- 테스트: `godot --headless -s addons/gut/gut_cmdln.gd` (GUT) 또는 `godot --headless -s addons/gdUnit4/bin/GdUnitCmdTool.gd` (GdUnit4)
- 성능 벤치: `godot --headless --quit-after 10 scenes/__bench/bench.tscn`

### 미준비 항목은 "해당 없음"
첫 스프린트라 벤치 씬·설정 화면 등이 없으면 해당 규칙을 "해당 없음 (S{M}에서 도입 예정)"으로 명시. 삭제 금지.
