---
name: sprint-planning
description: Planner 에이전트가 feature-spec.md를 product-spec.md + 스프린트 분해(S{M}-plan.md) 로 확장할 때 따르는 절차. 스프린트 경계 긋는 기준, Generator-Evaluator 계약 작성법, 컨벤션 4종 초기 채우기 절차를 포함한다. Planner 호출 시 반드시 이 스킬을 먼저 로드한다.
---

# Sprint Planning — Planner 작업 절차

Planner 에이전트의 작업 표준. `build-handoff` 스킬의 핸드오프 #1 포맷을 따르고, `build-conventions` 스킬 4종을 채우는 책임을 진다.

## 입력
- **`docs/features/_feature-list.md` (FROZEN)** — ★ Kickoff C-0에서 확정된 Feature 목록 + 확인 체크리스트 + **기술 통합 리스트** + 공통 누락 점검. **입력 계약**으로 읽음 (뒤집기 금지)
- **`docs/features/F{N}/feature-spec.md`** — 이 F의 상세 (§0-A·§0-B·§3·§4·§7.3·§9·§10 등)
- `docs/kickoff/{why,what,how}.md` — 맥락
- 사용자 프로젝트 루트의 기존 설정 파일 — 컨벤션 채우기용

## Kickoff FROZEN 입력 계약 (중요)

`_feature-list.md`의 "기술 통합 리스트"는 **Build Planner의 입력 계약**이다:

| 동작 | 허용 여부 |
|------|---------|
| 새 씬/스크립트 **추가** | ✅ 허용 (구현 중 필요하면 product-spec에 추가) |
| 기존 씬/스크립트 **확장** (파일 유지, 내용 보강) | ✅ 허용 |
| 기존 씬/스크립트 **삭제** | ❌ 금지 — Kickoff C-0 재소집 |
| 기존 씬/스크립트 **경로 이동·이름 변경** | ❌ 금지 — Kickoff C-0 재소집 |
| Autoload 목록 **축소** | ❌ 금지 — Kickoff C-0 재소집 |
| Physics Layer 번호 **변경** | ❌ 금지 — 전 코드에 번호 박힘, 이동 시 재작업 지옥 |
| InputMap 액션 **이름 변경** | ❌ 금지 — Generator 코드에 액션 이름 박힘 |
| InputMap **키 바인딩 변경** | ⚠️ 주의 — 내부 확장은 가능하나 사용자 합의 권장 |

금지 동작이 필요하다고 판단되면 Planner는 **즉시 반송** — product-spec 작성 중단 후 오케스트레이터에 "Kickoff C-0 재소집 필요. 사유: {무엇을 왜 바꿔야 하는지}" 보고.

## feature-spec 입력 계약 (10섹션 필수)

`F{N}/feature-spec.md`를 읽을 때 다음 10섹션이 채워져 있어야 Planner 작업 가능:

| § | 이름 | 필수 여부 |
|---|------|---------|
| 0-A | 완료 시 보이는 화면·플레이 한 문단 | 필수 — Planner가 Intent 이해 |
| 0-B | 확인 체크리스트 3~5개 | 필수 — Phase 2.7 USER_CHECK.md로 인입 |
| 3 | 코어루프 기여 (4단계 중 1+개 체크) | 필수 — 스프린트 경계 판단 |
| 4 | 코어 버브 구현 측면 | 필수 — 스프린트 분류 |
| 7.3 | 수용 기준 Given/When/Then | 필수 — Evaluator 자동 테스트 변환 |
| 9 | Godot 계약 (씬·스크립트·Autoload·Physics Layers·InputMap) | 필수 — 구현 구체성 |
| 10 | 의존성 (선행 F, MCP capability) | 필수 — 스프린트 순서 |
| 11 | 관측성 | 권장 — Evaluator 계측 검증 |
| 12 | 실패 모드 | 권장 — Evaluator 체크 |
| 13 | Pre-mortem | 권장 — 리스크 인식 |

**필수 섹션 중 하나라도 비었거나 내용 부실(예: "TBD", 빈 리스트)이면 Planner는 반송** — 오케스트레이터에 "F{N} feature-spec 불완전. Kickoff C-0 재소집 필요. 누락 섹션: §X, §Y" 보고.

**§0-B ↔ §7.3 매칭 검증:** §0-B 각 항목에 대해 §7.3 Given/When/Then 1개+ 매칭 있는지 확인. 매칭 없는 §0-B 항목은 "Phase 2.7 사용자 검수 전용"으로 Planner가 분류 (자동 테스트로는 커버 불가).

## 산출물
1. `docs/build/F{N}/product-spec.md` (1개)
2. `docs/build/F{N}/sprints/S{M}-plan.md` (스프린트 수만큼)

> 컨벤션 4종(`build-conventions/references/*.md`)은 플러그인 정적 레퍼런스. Planner가 쓰지 않으며 읽기만 한다.

## 절차

### Step 1. 입력 정독

feature-spec.md를 모두 읽고 아래를 추출:
- 유저 스토리
- 수용 기준 (AC)
- 데이터/API 계약
- 관측성
- 실패 모드
- 의존성
- 비-범위 (Out of Scope)

why/what/how.md는 **모순 감지용**으로만 훑는다. feature-spec이 이미 증류된 산출물이라 중복 정독 불필요.

### Step 2. product-spec.md 작성

`build-handoff` 스킬의 핸드오프 #1 포맷 그대로. 핵심은 다음 3가지:

1. **기술 결정**은 feature-spec에서 그대로 읽어 명시. feature-spec이 애매하면 Planner가 결정하되 "이 결정의 근거" 주석
2. **데이터 모델**은 Generator가 참조할 수 있도록 타입/스키마 수준으로. ER 다이어그램 텍스트화 OK
3. **고수준 설계 결정**을 야심차게 채움 — "로그인 후 홈은 3컬럼 대시보드" 수준까지 내려간다. 선언 없이 Generator에게 맡기면 평범한 결과

### Step 3. 스프린트 분해

**분해 알고리즘:**
1. AC를 모두 나열
2. AC를 "작동하는 유저 가치" 단위로 묶음. 한 묶음 = 한 스프린트
   - 좋은 묶음: "로그인 flow 전체 (이메일 입력 → 검증 → 대시보드 진입)"
   - 나쁜 묶음: "DB 테이블 생성", "로그인 API 스켈레톤" — 유저 가치 없음
3. 묶음이 1개면 스프린트 1개, 2개면 2개. 10개 넘어가면 Feature 자체가 너무 큼 → Kickoff 팀 반송

**스프린트 순서:**
- 뒤 스프린트가 앞 스프린트의 산출에 의존 OK. 단, 매 스프린트는 끝난 시점에 유저에게 무언가를 보여줄 수 있어야 함
- "기반 먼저, UI 나중" 같은 수직 분해 금지. 수평(유저 가치 축) 분해

### Step 4. 각 스프린트의 S{M}-plan.md 작성

핸드오프 #1의 S{M}-plan.md 포맷 따름. 특히 **Generator-Evaluator 계약** 섹션이 중심:

**"완료의 정의"를 쓰는 법:**
1. AC 목록 그대로 "모든 AC 수동 재현 가능" 한 줄
2. 해당 스프린트 특유의 "작동 증거" — 예: "로그인 후 홈 화면이 표시되고 네비게이션이 동작"
3. 컨벤션 위반 0건 (FAIL 규칙 기준)

**"자동 검증 훅"을 쓰는 법:**
- 사용자 프로젝트의 실제 명령어로 기술. 명령어가 없으면 Generator가 첫 스프린트에서 스캐폴딩
- 예: `npm run build`, `npm run typecheck`, `npm test`, `npx playwright test tests/login.spec.ts`
- Playwright 시나리오 이름을 구체로. "로그인 테스트" 같은 모호한 이름 금지

### Step 5. 품질 체크리스트

아래 항목 모두 만족해야 Planner 작업 완료.

- [ ] product-spec.md에 모든 섹션이 채워져 있음 (빈 "..." 없음)
- [ ] product-spec.md의 "기술 결정"이 feature-spec과 일치하거나 보강됨
- [ ] product-spec.md의 "고수준 설계 결정"이 구체 (Generator가 판단 낭비 없게)
- [ ] product-spec.md의 "범위 밖" 섹션이 비어 있지 않음
- [ ] 스프린트 수가 feature 크기에 적절 (AC당 0.3~1.5스프린트 범위)
- [ ] 각 S{M}-plan.md의 "자동 검증 훅"이 실제 실행 가능한 명령어
- [ ] 각 S{M}-plan.md의 AC가 feature-spec의 AC와 1:1 매핑 가능
- [ ] 컨벤션 4종 references 각각 "상태: ACTIVE" 또는 "해당 없음" 명시
- [ ] ACTIVE인 도메인은 최소 3개 규칙 채워짐
- [ ] product-spec.md 상태 FINAL

미달 항목이 있으면 해당 단계 재작업. DRAFT로 종료 금지.

## 이전 산출물 처리

오케스트레이터가 Planner를 재호출하는 경우:

- `product-spec.md`가 FINAL 상태이고 사용자 요청이 "새 스프린트 추가"면 → product-spec 건드리지 않고 `S{M+1}-plan.md`부터 신규 작성
- 사용자가 "product-spec 재작성"을 명시적으로 요청하면 → 기존을 `product-spec-prev.md`로 백업하고 새로 작성
- 컨벤션 references에 이미 규칙이 있으면 건드리지 않고, 새 규칙이 필요하면 추가만

---

## 게임 프로젝트 (3D 게임 — Godot 4) 확장 절차

프로젝트가 Godot 4 게임이면 위 절차에 아래를 추가한다.

### 필수 선행 로드 스킬
Planner 세션 시작 시 `build-handoff` 외에 **반드시 로드**:
- `godot-scene-handoff` — product-spec.md 7항 / S{M}-plan.md 7항 형식
- `godot-mcp-protocol` — MCP capability matrix 현재 상태 파악 (Evaluator 훅 설계에 영향)
- `asset-pipeline` — 에셋 스프린트 경계 결정
- `build-conventions` 게임 섹션 — 4도메인 초기 규칙 채우기

### 게임 전용 스프린트 분해 기준

**좋은 스프린트 묶음 (게임):**
- "플레이어 3D 이동 + 기본 카메라 팔로우" — 첫 M0 ("Walking Skeleton")
- "코어 버브 1회 수행 가능 (타격 입력 + 데미지 판정 + 사망)" — M1 루프 닫힘
- "기본 적 1종 + AI 1수준" — 전투 루프 완성
- "에셋 교체 스프린트 — placeholder → Kenney pack" — 외형만

**나쁜 스프린트 묶음 (게임):**
- "모든 적 AI 구현" — 수평 너무 큼, 묶어서 재분해
- "씬 파일 스켈레톤만" — 유저 가치 0, 다음 스프린트에 녹여라
- "기획서만 작성" — 스프린트가 아님

### product-spec.md 7항 (godot-scene-handoff 스킬이 정의)
- 7-1. 프로젝트 메타 (Godot minor, 렌더러, Main Scene, 해상도, 물리 FPS)
- 7-2. Autoload 목록 (이름, 스크립트, 책임, 도입 스프린트)
- 7-3. Input Map (액션, KBM/Gamepad 바인딩, 도입 스프린트)
- 7-4. Physics Layers (번호 고정, 이름)
- 7-5. 렌더링/품질 프리셋

### S{M}-plan.md 7항 (godot-scene-handoff 스킬이 정의)
- 7-1. 생성/수정되는 씬 목록
- 7-2. 생성/수정되는 스크립트 + 의존
- 7-3. 생성/수정되는 리소스
- 7-4. 프로젝트 설정 변경 (product-spec 7항과 동기화)
- 7-5. Smoke 씬 (`scenes/__dev/sprint_{M}_smoke.tscn`) + headless 검증 명령

### 자동 검증 훅 (게임용 기본 세트)
- 빌드: `godot --headless --import` → 종료코드 0, 에러 0건
- 구문: `godot --headless --check-only` (전 스크립트)
- 테스트: GUT/GdUnit4 명령 (테스트 파일이 있을 때만)
- Smoke: `godot --headless --quit-after 5 scenes/__dev/sprint_{M}_smoke.tscn` → exit 0
- 성능 벤치 (벤치 씬 도입 이후 스프린트만): `godot --headless --quit-after 10 scenes/__bench/bench.tscn`

### Step 3.5. 에셋 요구사항 추출 + MCP 도구 사전 지정

**각 스프린트마다** feature-spec의 AC와 씬 구성에서 에셋 요구사항을 추출하여 S{M}-plan.md에 **에셋 태스크** 섹션을 반드시 포함한다.

**추출 절차:**
1. AC를 읽으며 3D 오브젝트/메시/머티리얼/텍스처/오디오/UI 에셋이 필요한 항목 식별
2. 각 에셋에 4단계 폴백 중 어느 단계를 쓸지 결정: `primitive` / `library` / `blender-mcp` / `user`
3. S{M}-plan.md에 아래 포맷으로 기록

```markdown
## 에셋 태스크

| ID | 에셋 | 용도 | 폴백 단계 | 필요 도구 | 비고 |
|----|------|------|-----------|-----------|------|
| A1 | 플레이어 메시 | Player 씬 | primitive | 없음 | CSGCapsule3D |
| A2 | 바닥 타일 | World 씬 | library | 없음 | Kenney Kit |
| A3 | 적 메시 | Enemy 씬 | blender-mcp | Blender 실행 필요 | 도형 조합 |
```

**`필요 도구` 컬럼이 Generator에게 주는 신호:**
- "Blender 실행 필요" → Generator는 `ensure-running.sh blender` 먼저 실행
- "Godot MCP 필요" → Generator는 `ensure-running.sh godot` 먼저 실행
- "없음" → primitive/텍스트 편집으로 처리

**씬 조작도 동일 원칙:** 씬 생성/노드 추가 등 Godot MCP capability matrix에 있는 작업이 plan에 포함되면 `필요 도구: Godot MCP 필요`로 명시.

### 에셋 스프린트를 별도로 분리
기능 스프린트와 에셋 교체 스프린트를 **섞지 마라**. "기능도 짜고 에셋도 교체"는 FAIL 사유 증가.
- 기능 스프린트: placeholder primitive로만 동작하게
- 에셋 스프린트 (`polish-S{M}`): 기능 변경 금지, placeholder → 실 에셋, manifest.md 갱신

### 품질 체크리스트 추가 항목
위 기본 체크리스트에 더해:
- [ ] product-spec.md 7항 (Godot 프로젝트 설정) 모든 하위 섹션 채워짐
- [ ] 각 S{M}-plan.md 7항 (Godot 영향) 채워짐
- [ ] Smoke 씬 경로가 명시되고 headless 실행 가능한 명령이 기록됨
- [ ] Autoload 추가/삭제가 있으면 product-spec 7-2와 S{M}-plan 7-4 양쪽에 기록
- [ ] 에셋 의존이 있는 스프린트는 `asset-pipeline` 4단계 중 어느 단계를 쓸지 명시
- [ ] 각 S{M}-plan.md에 "에셋 태스크" 테이블이 존재 (에셋 불필요 시 "없음" 명시)
- [ ] `필요 도구` 컬럼에 Blender/Godot MCP 필요 여부가 명시됨
