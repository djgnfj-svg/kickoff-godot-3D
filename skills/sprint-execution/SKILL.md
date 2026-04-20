---
name: sprint-execution
description: Generator 에이전트가 한 스프린트를 구현할 때 따르는 절차. S{M}-plan.md 독해 → TDD 사이클 → 컨벤션 준수 → 자체 점검 → S{M}-generator.md 작성. superpowers의 test-driven-development 및 executing-plans 스킬을 조합하여 재사용한다. 재시도 시 S{M}-retry-{K}.md 독해 의무 포함.
---

# Sprint Execution — Generator 작업 절차

Generator 에이전트의 작업 표준. `build-handoff` 스킬의 핸드오프 #2 포맷을 따른다.

## 입력 (읽는 순서 고정)
1. `docs/build/F{N}/product-spec.md` — 전체 제품 맥락
2. `docs/build/F{N}/sprints/S{M}-plan.md` — 이번 스프린트 계약
3. `${CLAUDE_PLUGIN_ROOT}/skills/build-conventions/references/*.md` 4종 — 구현 중 지켜야 할 규칙
4. (재시도일 때만) `docs/build/F{N}/sprints/S{M}-evaluation.md` + `S{M}-retry-{K}.md`
5. 사용자 프로젝트 루트 — 현재 코드베이스 상태

읽기 건너뛰기 금지. 특히 컨벤션은 "자체 점검에서 걸릴 것만 확인"하는 식이면 결국 재시도.

## 산출물
- 사용자 프로젝트의 코드 파일들 (스프린트 범위 내)
- `docs/build/F{N}/sprints/S{M}-generator.md` (회차별 신규 파일)

## 절차

### Step 1. 계약 이해

S{M}-plan.md의 다음 섹션을 내재화:
- **스프린트 목표** — 구현이 끝났을 때 유저가 할 수 있어야 하는 것
- **AC** — 하나도 빠짐없이 충족해야 함
- **Generator-Evaluator 계약: "완료의 정의"** — Evaluator가 이 기준으로 판정
- **범위: 제외** — 의도적으로 안 건드리는 것
- **자동 검증 훅** — Evaluator가 돌릴 명령어. Generator도 자체 점검에서 돌린다

### Step 2. (재시도일 때만) 이전 판정 내재화

`S{M}-retry-{K}.md`의 "해결해야 할 것"과 "금지 사항"을 복사 아니라 **이해**한다. 같은 접근법 반복 = 최악.

### Step 3. TDD 사이클

`superpowers:test-driven-development` 스킬을 Skill 도구로 로드한다.

AC를 작은 단위로 쪼개고, 각 단위마다:
1. 실패하는 테스트 작성
2. 최소 구현으로 통과
3. 리팩터
4. 다음 AC로

**TDD 예외 케이스:**
- 주관적 UI 품질 (색 조합, 레이아웃 미감): 테스트로 검증 불가. 대신 Playwright 스크린샷 + 수동 재현 절차를 S{M}-generator.md에 기록
- 외부 서비스 통합의 실제 응답: 목업으로 테스트 + 실제 호출을 수동 재현으로 검증

### Step 4. 컨벤션 준수

구현 중 아래 4종 규칙을 위반하지 않는다. 실수로 위반했다면 자체 점검에서 잡아 수정.

- `coding.md`: 모든 스프린트에 적용
- `design.md`: UI가 있는 스프린트에만
- `accessibility.md`: UI가 있는 스프린트에만
- `performance.md`: 스프린트 성격에 따라

각 도메인이 "해당 없음"이면 읽기만 하고 건너뛴다.

### Step 5. 자체 점검 (Self-check)

구현 완료 선언 전 아래 전부 실행:

1. **빌드 훅 실행** — S{M}-plan의 명령어 그대로. 종료코드 0 확인
2. **타입체크** — 0건 확인
3. **테스트 스위트** — 통과 확인. 신규 AC당 최소 1개 테스트 존재
4. **컨벤션 4종** — 각 ACTIVE 규칙의 "검증" 절차 실행
5. **AC 수동 재현** — 각 AC의 Given/When/Then 절차를 실제로 재현. UI는 브라우저, API는 curl 등

하나라도 실패면:
- 작은 실패: 수정 후 재실행
- 구조적 실패: 수정 불가 판단이면 S{M}-generator.md를 `PARTIAL`로, "알려진 한계" 섹션에 정직하게 기록

### Step 6. S{M}-generator.md 작성

`build-handoff` 스킬 핸드오프 #2 포맷 정확히 준수. 특히:

- **2. 변경/추가된 파일** — 누락 없이. Evaluator가 독립 재현할 때 찾아야 함
- **3. AC 매핑** — 각 AC의 구현 위치 (`파일:줄`)와 수동 재현 방법
- **4. 자체 점검** — 각 체크리스트 항목의 결과를 **명령어 출력 요지**와 함께 기록. 체크 표시만 찍는 것 금지
- **5. 알려진 한계** — 있으면 전부. 숨기면 Evaluator가 적발 → 재시도 비용

### Step 7. 종료 보고

오케스트레이터에게 반환:
- S{M}-generator.md 경로
- 결과 (COMPLETE / PARTIAL)

## 재시도 시 추가 원칙

- 이전 세션의 작업물은 `git status`로 확인 후 선택: PASS한 부분은 보존, FAIL 부분만 재작업
- `S{M}-retry-{K}.md`의 "금지 사항"에 등록된 접근법은 쓰지 않는다
- 2회차 재시도가 진행 중이면(K=2) 이번이 마지막 기회 — 신중히

## 에러 핸들링

- 빌드 환경 자체가 망가진 경우 (의존성 설치 실패 등): 수정 시도 1회, 그래도 실패면 S{M}-generator.md에 "환경 문제로 자체 점검 불가" 명시 + PARTIAL 상태로 종료
- AC를 물리적으로 충족 불가능한 경우 (외부 API 제약 등): 멈추고 "Evaluator에게 요청" 섹션에 재협상 요청 기록. 억지로 짜맞추기 금지
- 범위를 벗어나야만 동작 가능한 경우: "범위 내 해결 불가"를 명시하고 계약 재협상 요청. 범위를 몰래 넓히지 않는다

---

## 게임 프로젝트 (3D 게임 — Godot 4) 확장 절차

프로젝트가 Godot 4 게임이면 위 절차에 아래를 추가한다.

### 필수 선행 로드 스킬
Generator 세션 시작 시 반드시 로드:
- `godot-scene-handoff` — S{M}-plan.md 7항 해독, S{M}-generator.md 7항 작성
- `godot-mcp-protocol` — MCP 사용 절차 + fallback + 갭 보고
- `asset-pipeline` — 새 에셋이 필요할 때 4단계 폴백 체인
- `build-conventions` 게임 섹션 — 코딩/디자인/접근성/성능 4도메인 게임 규칙

### Step 0. MCP 도구 사전 준비 (구현 시작 전 필수)

S{M}-plan.md의 **"에셋 태스크"** 테이블을 먼저 읽고 `필요 도구` 컬럼을 확인한다.

**실행 절차:**
1. `필요 도구`에 "Godot MCP 필요"가 있으면:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/ensure-running.sh godot
   ```
2. `필요 도구`에 "Blender 실행 필요"가 있으면:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/ensure-running.sh blender
   ```
3. 둘 다 있으면:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/ensure-running.sh both
   ```
4. 에셋 태스크가 "없음"만이면 — 스킵

**ensure-running.sh는 프로세스 감지 후 미실행 시에만 launch한다.** 이미 실행 중이면 즉시 통과.

Blender MCP로 에셋 생성 시 흐름:
1. Blender MCP 도구로 오브젝트 생성 + 머티리얼 적용
2. glTF (.glb) export
3. Godot 프로젝트의 `assets/models/` 하위에 복사
4. `godot --headless --import`로 import 확인
5. `docs/build/F{N}/assets/manifest.md`에 기록

### Godot 조작 3단계 경로 (godot-mcp-protocol 스킬이 정의)
모든 에디터 조작은 이 순서:
1. Godot MCP 호출 (capability matrix 확인 후)
2. Fallback A: `godot --headless` CLI
3. Fallback B: .tscn / .gd / project.godot 텍스트 직접 편집
4. Fallback C: 사용자 위임 (최후 수단, 스프린트당 3회 이상이면 범위 재조정 신호)

Fallback 발동 시 **즉시** `docs/godot-mcp/gaps/G{N}.md`에 갭 리포트 생성.

### TDD 적용 (GDScript)
- 프레임워크: **GUT** (`addons/gut/`) 또는 **GdUnit4** (`addons/gdUnit4/`) 중 프로젝트가 채택한 하나
- 대상: 핵심 유틸·데미지 계산·상태 머신·데이터 변환. 씬 통합은 smoke 씬으로.
- 실행: `godot --headless -s addons/gut/gut_cmdln.gd` (GUT)
- TDD 예외 (시각·감각 품질): 스크린샷 + 수동 재현 절차 기록

### 자체 점검에 추가
1. `godot --headless --import` (exit 0, 에러 0)
2. `godot --headless --check-only` (구문 검증)
3. 테스트 스위트 (GUT/GdUnit4)
4. `godot --headless --quit-after 5 scenes/__dev/sprint_{M}_smoke.tscn` (exit 0)
5. 벤치 씬 있으면 성능 벤치 (FPS/draw call/메모리)
6. 컨벤션 4종 (build-conventions 게임 섹션 기준)
7. 에셋 manifest.md 갱신 (새 에셋 사용 시)

### S{M}-generator.md 7항 (godot-scene-handoff가 정의)
- 7-1. 새 씬 트리 (간단 ASCII 그림)
- 7-2. 사용한 MCP 경로 테이블 (작업별 MCP/headless/text/manual)
- 7-3. 발생한 갭 리포트 번호 목록
- 7-4. Smoke 실행 결과 (명령·종료코드·로그 경로)

### 에셋 관련 추가 원칙
- 기능 스프린트에서는 **placeholder primitive만**. 실 에셋 교체 금지.
- 새 에셋 사용 시 `docs/build/F{N}/assets/manifest.md`에 출처·라이선스·도입 스프린트 기록 (asset-pipeline 스킬 참조)
- AI 생성 에셋은 capability matrix가 enabled일 때만, 프롬프트를 `assets/prompts/` 보존
