---
name: sprint-evaluation
description: Evaluator 에이전트가 S{M}-generator.md를 독립 평가할 때 따르는 절차. 기능/빌드/테스트/설계/컨벤션/UI 6축 점검, 하드 임계값 판정, PASS/FAIL 결정, Generator에게 줄 피드백 포맷. "회의적 튠" 원칙을 강제한다. Playwright MCP 사용 가이드 포함.
---

# Sprint Evaluation — Evaluator 작업 절차

Evaluator 에이전트의 작업 표준. `build-handoff` 스킬의 핸드오프 #3 포맷을 따른다.

## 회의적 튠 — 대원칙

- Generator의 자체 점검을 **신뢰하지 않는다.** 증거로 삼지 않는다.
- "잘 작동합니다"는 서술이지 증거가 아니다. **로그·스크린샷·파일 경로**만 증거로 인정
- 하드 임계값은 종합 점수로 덮지 않는다. 하나라도 미달 = FAIL
- 주관 판단이 들어가면 → 규칙 없음 → 판정 보류 → 체제 개선 제안

## 입력
1. `docs/build/F{N}/product-spec.md`
2. `docs/build/F{N}/sprints/S{M}-plan.md`
3. `docs/build/F{N}/sprints/S{M}-generator.md` — 평가 대상
4. `${CLAUDE_PLUGIN_ROOT}/skills/build-conventions/references/*.md` 4종
5. 사용자 프로젝트 루트의 실제 코드

## 산출물
- `docs/build/F{N}/sprints/S{M}-evaluation.md`

회차별로 기존 파일을 **덮어쓴다** (1회차 평가, 재시도 후 새 평가). 회차 번호를 파일 내 "대상" 줄에 명시. 이전 평가를 보고 싶으면 git history.

## 절차

### Step 1. 계약 재확인

S{M}-plan.md의 "완료의 정의"와 "자동 검증 훅"을 **Evaluator의 체크리스트**로 가져온다. 계약에 없는 항목은 평가하지 않는다 — 계약 범위 밖 요구는 체제 개선 제안으로.

### Step 2. 자동 훅 독립 실행

Generator가 "통과"라고 써놨어도 **다시 실행**.

1. 빌드 명령 실행 → 종료코드 0 + 경고/오류 개수
2. 타입체크 → 오류 개수
3. 테스트 스위트 → 통과/실패 개수
4. 실행 로그를 S{M}-evaluation.md "증거" 섹션에 요약(전체 복붙 금지)

명령어 실행 불가 (환경 문제):
- 1회 재시도
- 그래도 실패: Generator와 동일 환경 문제일 가능성 → 파일에 "환경 재현 불가"라 적고, **그 스프린트는 CONDITIONAL FAIL** (사용자 에스컬레이션)

### Step 3. AC 수동 재현

S{M}-generator.md의 "AC 매핑"에 있는 각 AC의 재현 방법을 **Evaluator가 직접** 실행:

- UI: Playwright MCP로 시나리오 재생 + 스크린샷 저장
- API: curl/fetch로 요청 → 응답 확인
- 배치/CLI: 명령 실행 → 출력 확인

하나라도 재현 실패 → **기능 완성도 축 ✗**.

### Step 4. Playwright MCP 활용 (UI 스프린트)

UI가 있는 스프린트에서는 Playwright MCP로:
1. S{M}-plan.md의 "자동 검증 훅" 중 Playwright 시나리오를 실행
2. AC별로 스크린샷 1장씩 캡처, `docs/build/F{N}/sprints/screenshots/S{M}-AC{k}.png`로 저장
3. 스크린샷을 보고 design.md 규칙 위반 점검 (간격·색·타이포)
4. 키보드만으로 flow 재현 (accessibility.md의 키보드 규칙 검증)

Playwright 연결 불가:
- UI 축만 "검증 불가"로 표기, 다른 축은 평가 지속
- 결과 `CONDITIONAL FAIL` — UI 재검증 후 최종 판정

### Step 5. 컨벤션 4종 검증

각 ACTIVE 도메인의 모든 규칙에 대해 "검증" 필드의 절차를 실행:

- FAIL 규칙 위반 1건이라도 → 해당 축 ✗
- WARN 규칙 위반은 evaluation.md에 기록하되 축 판정에 반영 안 함

"해당 없음" 도메인은 건너뛴다.

### Step 6. 설계 충실도 점검

product-spec.md의 "고수준 설계 결정"과 실제 구현 비교:

- 레이아웃·상호작용 패턴이 product-spec과 일치하는가?
- 아키텍처 결정(모노/멀티, 상태 관리 방식 등)이 지켜졌는가?
- 편차가 있으면 S{M}-generator.md에 사유가 기록되어 있는가?

사유 없는 편차 → **설계 충실도 축 ✗**.

### Step 7. 점수 매트릭스 + 판정

핸드오프 #3 포맷의 "1. 기준별 점수" 표를 채운다. 하나라도 ✗ → **FAIL**.

**FAIL 사유 기록:**
- "무엇이" — 관찰된 결함 (구체. "버튼이 이상함" 금지, "로그인 버튼 클릭 시 콜백 미실행" O)
- "어디서" — 파일:줄 또는 시나리오 이름
- "왜 실패로 판정" — 계약의 어떤 항목 위반인지 인용

### Step 8. Generator에게 피드백 (FAIL일 때만)

재시도 시 Generator가 행동 가능한 수준으로:

- 우선순위 순: 기반 결함 먼저, 잔가지 나중
- "피할 접근법": 회의적 관찰에서 "이 방향은 또 실패할 것"이라 판단되면 명시
- 범위 밖 요구 금지: 계약에 없는 것을 피드백으로 추가하지 않는다 (체제 개선 제안으로 따로)

### Step 9. (선택) 체제 개선 제안

Evaluator가 평가 중 발견한 구조적 개선점:
- 컨벤션 references에 없는데 계속 등장하는 안티패턴
- Planner가 계약에 포함했어야 할 누락 항목
- 재시도 루프 자체의 비효율

evaluation.md 말미에 "## 체제 개선 제안" 섹션으로 기록. 오케스트레이터가 F 종료 후 사용자에게 제시.

## PASS 조건 (전부 만족해야)

- 모든 하드 임계값 축 ✓
- 모든 AC 수동 재현 성공
- 컨벤션 FAIL 규칙 위반 0건
- Generator의 "알려진 한계"가 계약의 필수 항목에 해당하지 않음

## 자주 발생하는 판정 실수

- **관대함:** "95% 됐으니 PASS" → 금지. 계약 미달 = FAIL
- **작성자 신뢰:** S{M}-generator.md만 읽고 재현 생략 → 금지. 증거는 재현에서만 생성
- **범위 이탈:** 계약에 없는 것을 이유로 FAIL → 금지. 체제 개선 제안으로 이동
- **주관 판단:** "UI가 촌스럽다" → 금지. design.md 규칙이 없으면 판정 불가, 규칙 추가 제안만

## 재시도 후 재평가

- 새 S{M}-generator.md가 도착하면 **전체 절차 재수행**. 이전 평가의 일부만 재확인 금지 (다른 부분이 회귀했을 수 있음)
- "대상" 줄의 회차 번호 갱신
- 이전 FAIL 사유가 해결됐는지 + 새 FAIL 사유가 없는지 모두 확인

---

## 게임 프로젝트 (Godot 4) 확장 절차

프로젝트가 Godot 4 게임(2D/3D)이면 위 절차에 **Playwright 대신 `godot --headless` CLI + 텍스트 검증**을 사용한다.

### Step 0. 입력 계약 읽기
Evaluator도 `docs/kickoff/_meta.md`의 `project_type`을 먼저 읽고 노드 가정 분기를 결정한다.

### 필수 선행 로드 스킬
- `godot-scene-handoff` — S{M}-generator.md 7항 해독
- `build-conventions` 게임 섹션 — 4도메인 규칙 독립 재측정 (+ project_type에 따라 `references/{2d,3d}.md`)

### Step 2 (자동 훅 독립 실행) — 게임용 기본 세트
Generator가 돌린 명령을 **다시 실행**. 결과를 S{M}-evaluation.md 증거 섹션에 요지로.
1. `godot --headless --import` — 종료코드 0 + 스테리어 에러 0건
2. `godot --headless --check-only` — 구문 오류 0건
3. 테스트 스위트 (`addons/gut/gut_cmdln.gd` 또는 `addons/gdUnit4/bin/GdUnitCmdTool.gd`) — 실패 0
4. `godot --headless --quit-after 5 scenes/__dev/sprint_{M}_smoke.tscn` — 종료코드 0 + 크래시 0
5. (해당 스프린트에 성능 벤치가 정의되면) 벤치 씬 10초 실행 → FPS/draw call/메모리 임계 확인

### Step 3 (AC 수동 재현) — Godot 씬 텍스트/headless 검증
AC마다 재현 경로:
- **게임플레이 AC:** smoke 씬 headless 실행 + 로그 확인 + `.tscn`/`.gd` 텍스트 점검 (노드/시그널/프로퍼티 존재 여부). 시각 확인이 필수면 사용자에게 "해당 씬을 에디터에서 Run하고 X를 확인해달라"고 위임.
- **순수 로직 AC:** 단위 테스트로 커버되면 테스트 실행으로 증거 채택.
- **시각 AC:** GDScript에서 `get_viewport().get_texture().get_image().save_png(...)`로 스크린샷 저장 + 사용자 검토 위임.

### Step 4 (텍스트 검증 우선)
`.tscn` / `.gd` / `project.godot` / `.tres` 파일을 grep/Read로 직접 확인:
- 씬 그래프: `.tscn`의 `[node name=... type=...]` 텍스트 점검
- 노드 타입(차원별 분기): 3D면 `CharacterBody3D`/`Camera3D`/`MeshInstance3D`, 2D면 `CharacterBody2D`/`Camera2D`/`Sprite2D`
- 시그널·프로퍼티: `.gd`의 `signal ...`, `@export` 라인 검색
- Autoload·InputMap·Physics Layers: `project.godot` 섹션 비교

스크린샷 등 GUI 확인이 필수면 사용자에게 명시 위임 (스프린트당 3회 이상이면 범위 재조정 신호).

### Step 5 (컨벤션 4종 검증) — 게임용 명령
build-conventions 게임 섹션의 각 규칙 "검증" 필드에 따라 실행. 전형:
- coding: `godot --headless --check-only`, grep 기반 명명 규칙 검사
- design: UI 씬 anchor 값 확인, 팔레트 위반 grep
- accessibility: InputMap·설정 씬 존재 확인
- performance: 벤치 씬 실행 결과의 FPS/draw call/메모리

### Step 6 (설계 충실도) — 씬 그래프 일치
product-spec.md 7항(Autoload/Input Map/Physics Layers)과 현 project.godot 비교:
- Autoload가 추가되었는데 product-spec 7-2에 기재 없음 → 설계 충실도 ✗
- Input Map 새 액션이 product-spec 7-3에 없음 → ✗
- Physics Layer 이름 변경 → ✗ (번호 재할당은 즉시 FAIL)

### 게임 전용 하드 임계값
기능/설계/컨벤션 3축 외에 다음 **게임 전용 하드 임계값** 적용:
- **크래시 0:** smoke/headless 실행 중 세그폴트/assertion 0건
- **런타임 에러 0:** `_ready()` ~ 종료까지 stderr에 ERROR/SCRIPT ERROR 0건
- **타깃 FPS 하한:** performance.md에 명시된 하한 이상 (첫 스프린트엔 벤치 씬 없어 "해당 없음" 허용)
- **Import 성공:** `--import` 종료코드 0 (에셋 오류 발생 시 FAIL)
- **에셋 태스크 완수:** S{M}-plan.md의 "에셋 태스크" 테이블에 명시된 에셋이 모두 존재하고 Godot import 성공

하나라도 미달 → FAIL.

### 에셋 검증 (텍스트 검증 가능)

S{M}-plan.md의 "에셋 태스크" 테이블과 S{M}-generator.md의 7-2 "작업 경로 테이블"을 교차 검증한다.

**검증 항목:**
1. **에셋 존재 확인:** plan의 에셋 태스크 테이블에 나열된 각 에셋 파일이 실제로 프로젝트에 존재하는지 `ls`로 확인
2. **Import 성공:** `godot --headless --import` 실행 후 해당 에셋의 `.import` 파일이 생성되었는지 확인
3. **manifest 기록:** 외부 에셋(2단계 폴백 = 사용자 위임 경로)은 `docs/build/F{N}/assets/manifest.md`에 출처·라이선스가 기록되어 있는지 확인
4. **에셋 태스크 누락:** plan에는 있는데 generator.md에 언급이 없는 에셋 = FAIL

**위반 시:**
- 에셋 미존재 또는 import 실패 → FAIL (하드 임계값)
- manifest 미기록 → FAIL (라이선스 추적성)
