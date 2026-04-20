---
name: visual-gate
description: 3D 게임(Godot 4) 하네스에서 "이미지 기반 결정"이 필요한 모든 지점에 쓰는 HTML 브라우저 선택 UI. Claude가 HTML/CSS/SVG 코드로 직접 게임 화면·HUD·카메라 시점·캐릭터 실루엣·베기 타이밍·씬 트리·레벨 레이아웃을 그려 사용자가 브라우저에서 클릭으로 선택한다. Kickoff Harness와 Build Harness의 모든 에이전트가 텍스트 설명만으로 A/B 차이가 불분명한 시각 결정이 필요할 때 사용. "시점 선택", "HUD 배치", "캐릭터 실루엣 비교", "레벨 레이아웃", "공격 프레임 타이밍", "씬 트리 A/B", "캡슐 구도", "보스 방 배치" 상황에 트리거. superpowers brainstorming Visual Companion을 게임 도메인으로 확장한 스킬.
---

# Visual Gate (3D 게임 전용)

Claude가 **코드로 직접 그린 게임 화면·도식**을 브라우저에 띄우고, 사용자가 **클릭으로 선택**하면 그 결과를 Claude가 다음 턴에 읽어 반영한다. 외부 이미지·AI 생성·파일 업로드 없음. 모든 시각 요소는 HTML/CSS/SVG로 Claude가 즉석에서 작성한다.

## When to Use

**결정당 판단:** 이 질문을 텍스트로만 물으면 사용자가 이해하기 어려운가? 그러면 Visual Gate.

브라우저 사용 (시각적 내용):
- **게임 화면 레이아웃** — HUD 배치, UI 슬롯 위치
- **카메라 시점·FOV** — 1인칭/3인칭/탑다운/쿼터뷰 도식
- **캐릭터 실루엣·비례** — SVG 실루엣 비교
- **공격·애니 타이밍** — startup/active/recovery 프레임 바
- **씬 트리·상태머신** — 노드 그래프 A/B
- **레벨·보스 방 레이아웃** — 격자 배치
- **캡슐 이미지 구도** — Steam 첫인상 5초 도식
- **카메라 거리·FOV 비교** — Z축 원근감

터미널 사용 (개념·장단점):
- 요구사항·범위·플레이어 원형 선택 (텍스트로 충분)
- 코어 버브·결핍 확정
- 기술 의사결정 (Godot 버전, MCP 선택)
- 장단점·트레이드오프 토론

*"시점에 대해 어떻게 생각해?"는 개념 — 터미널. "이 3가지 시점 중 어느 게 느낌 맞아?"는 시각 — 브라우저.*

## When NOT to Use

- 사용자가 이미 명확히 한 줄로 답한 질문
- 텍스트 목록으로 충분한 A/B/C 선택 (예: "Sonnet / Opus 중 어느 모델?")
- 사용자가 브라우저를 열 수 없는 환경 (원격·CI)

## Starting a Session

```bash
${CLAUDE_PLUGIN_ROOT}/skills/visual-gate/scripts/start-server.sh --project-dir <프로젝트_루트>
```

반환값 JSON에서 `url`, `screen_dir`, `state_dir`를 반드시 저장한다.

**Windows (이 프로젝트 기본 환경):** Git Bash가 nohup 백그라운드를 reap하므로 스크립트가 자동으로 `--foreground`로 전환한다. Bash 도구에서 호출할 때는 `run_in_background: true`를 설정하고, 다음 턴에 `$STATE_DIR/server-info`를 읽어 URL을 복구한다.

**세션 정보 위치 (고정 경로):**
- 세션 루트: `<프로젝트>/.superpowers/visual-gate/<pid>-<timestamp>/`
- 콘텐츠 쓰기: `<세션>/content/<gate_id>.html`
- 이벤트 읽기: `<세션>/state/events` (JSONL)

## The Loop (5 steps)

1. **서버 생존 확인** — `$STATE_DIR/server-info` 존재? 없거나 `server-stopped`면 재시작.
2. **HTML fragment 작성** — Write 도구로 `<screen_dir>/<gate_id>.html`. **파일명 재사용 금지**. 이터레이션은 `<gate_id>-v2.html`.
3. **사용자에게 알림 + 턴 종료** — URL 재안내(매 게이트마다) + 화면 요약 1줄 + "클릭 후 터미널로 복귀해주세요".
4. **다음 턴: 이벤트 읽기** — `$STATE_DIR/events` (있으면). 터미널 텍스트 응답이 주, 이벤트는 구조화 백업.
5. **결과 저장 + 언로드** — `docs/kickoff/_workspace/visual_gates/<gate_id>/selected.md`에 선택 요약 + 이유 1줄. 다음 결정이 터미널이면 `waiting.html` 푸시해 화면 클리어.

## Quality Bar (필수 기준)

모든 Visual Gate는 **"실제로 플레이어가 보는 게임 화면"을 흉내 낸 수준**으로 뽑는다. 추상 도식만으로는 불충분하다 — 사용자가 한눈에 "아, 이 시점/이 배치가 어떤 느낌이구나"를 이해할 수 있어야 한다. 2026-04-20 v2 시연에서 확정된 기준.

### 필수 요소 (5개, 전부 충족)

1. **scene-mockup 16:9 프레임** — 카드마다 `.card-image` 안에 16:9 비율 화면을 그린다. `.camera-diagram` 탑뷰만 단독으로 쓰는 카드는 금지 (보조로만 OK).
2. **실제 장면 흉내** — SVG로 필요 요소(하늘·지평선·지면·캐릭터·적·HUD)를 배치. 1인칭이면 무기/손, 3인칭이면 캐릭터 뒷모습, 탑다운이면 바닥 격자 + 위에서 본 원형 캐릭터.
3. **보조 도식 병행** — 메인 화면 아래에 작은 탑뷰/측면도를 넣어 "왜 이렇게 보이는가"를 설명. 화면만 있으면 초보자가 구조를 못 읽는다.
4. **HUD 예시 포함** — 최소 HP 바 1개(`.hud-hp` 또는 `.hud-slot`+`.hud-bar`)를 화면에 배치. 없으면 "게임이 아닌 풍경"으로 보인다.
5. **레퍼런스 게임 2~3개** — 카드 본문(`.card-body p`)에 "다크소울·엘든링·갓오브워" 같은 실제 게임 이름을 반드시 1~3개 적는다. 사용자 머릿속에 즉시 이미지가 뜬다.

### 금지 사항 (3개)

- **추상 도식만** — 점·삼각형·화살표만으로 끝내면 v1 시연에서 실패했던 패턴. 반드시 실제 장면과 함께.
- **빈 scene-mockup** — 회색 사각형에 라벨만 띄우기 금지. 최소 요소(캐릭터·지평선·HUD 중 2개)는 그려넣는다.
- **외부 이미지·AI 이미지·스크린샷 사용** — 저작권·싱크 문제. 모든 시각은 Claude가 HTML/CSS/SVG로 직접 작성.

### 자체 검증 질문 (fragment 쓴 뒤 3개 중 2개 Yes여야 제출)

1. 사용자가 브라우저를 열자마자 **1초 안에** 각 카드의 차이(시점/배치/타이밍)를 인지할 수 있는가?
2. 카드 본문을 가리고 화면만 봐도 선택지 3개가 **서로 다름**을 알 수 있는가?
3. 레퍼런스 게임 이름을 읽으면 사용자가 **"아, 그 느낌"**이라고 머릿속에 그림이 떠오르는가?

### 모범 예시

`references/gate-patterns.md`의 9개 패턴과 실제 시연 결과물 `.superpowers/visual-gate/*/content/demo-camera-perspective-v2.html` 참조. v2 수준을 "제출 가능한 최소 품질"로 삼는다.

### 3D 렌더 업그레이드 경로

`references/3d-upgrade-path.md` — 현재는 SVG/CSS로 충분하다 판단. 캐릭터 모델·월드 톤처럼 "콘셉트 아트" 영역이 필요할 때만 `<model-viewer>` 또는 Three.js 도입 검토.

## Writing Content Fragments

Fragment만 작성한다. `<html>`/`<head>`/`<body>`·CSS·스크립트는 서버가 자동 주입. 게임 도메인 CSS 클래스는 `references/css-classes.md` 참조. **위의 Quality Bar를 먼저 읽고 시작한다.**

### 예시 1 — 카메라 시점 선택 (camera-diagram)

```html
<h2>카메라 시점을 어느 쪽으로?</h2>
<p class="subtitle">코어 버브 "베기"의 타격감은 카메라 거리에 크게 좌우됩니다</p>

<div class="cards">
  <div class="card" data-choice="first_person" onclick="toggleSelect(this)">
    <div class="card-image">
      <div class="camera-diagram" style="width:80%">
        <div class="actor" style="top:50%;left:20%"></div>
        <div class="camera" style="top:50%;left:20%"></div>
      </div>
    </div>
    <div class="card-body"><h3>1인칭</h3><p>몰입감 최대, 무기 휘두름이 화면에 가득</p></div>
  </div>
  <div class="card" data-choice="third_person_close" onclick="toggleSelect(this)">
    <div class="card-image">
      <div class="camera-diagram" style="width:80%">
        <div class="actor" style="top:50%;left:60%"></div>
        <div class="camera" style="top:50%;left:20%"></div>
      </div>
    </div>
    <div class="card-body"><h3>3인칭 근접</h3><p>다크소울류, 캐릭터 뒤 2~3m</p></div>
  </div>
  <div class="card" data-choice="third_person_far" onclick="toggleSelect(this)">
    <div class="card-image">
      <div class="camera-diagram" style="width:80%">
        <div class="actor" style="top:50%;left:80%"></div>
        <div class="camera" style="top:50%;left:20%"></div>
      </div>
    </div>
    <div class="card-body"><h3>3인칭 원거리</h3><p>하데스류, 전장 조망</p></div>
  </div>
</div>
```

### 예시 2 — HUD 배치 비교 (scene-mockup + hud-slot)

```html
<h2>HUD 어떻게 배치할까요?</h2>
<div class="split">
  <div class="mockup">
    <div class="mockup-header">A: 좌상단 HP</div>
    <div class="mockup-body">
      <div class="scene-mockup" onclick="toggleSelect(this)" data-choice="hud_a">
        <span class="scene-label">Gameplay</span>
        <div class="hud-slot" data-pos="top-left">HP<div class="hud-bar"><span style="width:60%"></span></div></div>
        <div class="hud-slot" data-pos="bottom-right">MAP</div>
      </div>
    </div>
  </div>
  <div class="mockup">
    <div class="mockup-header">B: 중앙 하단 HP</div>
    <div class="mockup-body">
      <div class="scene-mockup" onclick="toggleSelect(this)" data-choice="hud_b">
        <span class="scene-label">Gameplay</span>
        <div class="hud-slot" data-pos="bottom-center">HP<div class="hud-bar"><span style="width:60%"></span></div></div>
        <div class="hud-slot" data-pos="top-right">MAP</div>
      </div>
    </div>
  </div>
</div>
```

### 예시 3 — 베기 프레임 타이밍 (timeline-bar)

```html
<h2>베기 공격 프레임 배분</h2>
<p class="subtitle">30fps 기준. 초록=피격 판정, 회색=시전·후딜, 노랑=캔슬 가능 구간</p>

<div class="options">
  <div class="option" data-choice="timing_fast" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>빠른 검 (총 18프레임)</h3>
      <div class="timeline-bar">
        <div class="seg" data-kind="startup"  style="width:22%">시전 4f</div>
        <div class="seg" data-kind="active"   style="width:17%">타격 3f</div>
        <div class="seg" data-kind="recovery" style="width:50%">후딜 9f</div>
        <div class="seg" data-kind="cancel"   style="width:11%">캔슬 2f</div>
      </div>
      <p>다크소울 숏소드급 — 난사 가능, 리스크 낮음</p>
    </div>
  </div>
  <div class="option" data-choice="timing_heavy" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>무거운 도끼 (총 40프레임)</h3>
      <div class="timeline-bar">
        <div class="seg" data-kind="startup"  style="width:35%">시전 14f</div>
        <div class="seg" data-kind="active"   style="width:15%">타격 6f</div>
        <div class="seg" data-kind="recovery" style="width:45%">후딜 18f</div>
        <div class="seg" data-kind="cancel"   style="width:5%">캔슬 2f</div>
      </div>
      <p>다크소울 그레이트액스급 — 한 방 무겁게, 헛스윙 시 큰 손해</p>
    </div>
  </div>
</div>
```

## CSS Classes Reference

프레임 제공 공통 클래스 + 게임 도메인 확장. 자세한 사용법은 `references/css-classes.md`.

- **선택 컨테이너:** `.options` / `.option` / `.letter`, `.cards` / `.card` / `.card-image` / `.card-body`
- **프레임 컨테이너:** `.mockup` / `.mockup-header` / `.mockup-body`, `.split`, `.pros-cons`, `.placeholder`
- **게임 도메인:** `.scene-mockup`, `.hud-slot[data-pos]` + `.hud-bar`, `.camera-diagram` + `.actor`/`.camera`/`.fov`, `.timeline-bar` + `.seg[data-kind]`, `.node-graph` + `.node[data-type]`, `.silhouette`, `.tile-grid` + `.tile[data-type]`, `.depth-axis` + `.marker`

**멀티셀렉트:** `.options` 또는 `.cards` 컨테이너에 `data-multiselect` 속성 추가.

## Events Format

사용자가 선택한 요소에 `data-choice` 속성이 있으면 `$STATE_DIR/events`에 JSONL 한 줄씩 기록된다. 새 HTML 파일을 푸시할 때마다 events 파일은 초기화된다.

```jsonl
{"type":"click","choice":"first_person","text":"1인칭 몰입감 최대...","id":null,"timestamp":1706000101}
{"type":"click","choice":"third_person_close","text":"3인칭 근접...","id":null,"timestamp":1706000108}
```

마지막 `choice`가 최종 선택. 여러 번 클릭 이력은 주저·탐색의 신호.

## 호출 권한 (어느 에이전트가 언제)

| 에이전트 | Phase | 전형적 Gate |
|----------|-------|-------------|
| `founder` | Kickoff Phase 1 | 카메라 시점 (Step 1-5-3) |
| `hook-strategist` | Kickoff Phase A why/what | 캡슐 이미지 구도, 5초 첫인상 |
| `core-mechanic-designer` | Kickoff Phase A why/what | 공격 타이밍, 씬 트리, 상태머신 |
| `sellability-auditor` | Kickoff Phase A (선택) | 비교 대상 경쟁작 캡슐 구도 매칭 |
| `planner` | Build 스프린트 시작 | HUD 레이아웃, 레벨 레이아웃, 씬 트리 |
| `generator` | Build 구현 직전 | 씬 노드 구조, 입력맵 배치 |

각 에이전트는 호출 전 반드시 `references/gate-patterns.md`에서 해당 카테고리 템플릿을 먼저 참조한다.

## 결과 저장 규약

게이트 1회당 다음 파일을 생성한다:

```
docs/kickoff/_workspace/visual_gates/<gate_id>/
├── question.html       (Claude가 쓴 fragment 사본)
├── events.jsonl        ($STATE_DIR/events 사본)
└── selected.md         (최종 선택 + 이유 1~2줄 + 다음 에이전트에게 줄 컨텍스트)
```

Build 단계에서는 `docs/build/F{N}/sprints/S{M}-visual-gates/<gate_id>/` 로 저장 경로 변경.

`selected.md` 템플릿:
```markdown
# <gate_id>: <한 줄 질문>

**선택:** <choice 값> ("<사용자가 본 라벨>")
**선택 시각:** <ISO8601>
**근거 (사용자 발화):** <1~2줄>
**다음 에이전트 컨텍스트:** <이 선택이 이후 결정에 미치는 영향 1줄>
```

## Cleanup

```bash
${CLAUDE_PLUGIN_ROOT}/skills/visual-gate/scripts/stop-server.sh <SESSION_DIR>
```

`--project-dir`로 띄운 세션은 `.superpowers/visual-gate/<session_id>/` 에 파일이 남는다 (감사 추적용). `.gitignore`에 `.superpowers/`가 포함되어 있는지 확인.

## Red Flags

| 징후 | 원인 | 대응 |
|------|------|------|
| 사용자가 "URL 안 열린다"고 함 | 방화벽·포트 변경 | `--host 0.0.0.0 --url-host localhost` 재시작 |
| events 파일에 기록 없음 | `data-choice` 속성 누락 | HTML fragment 재작성, `onclick="toggleSelect(this)"` 필수 |
| 사용자가 텍스트로만 답함 | 클릭 안 함 | 텍스트 응답을 primary로, events는 참고 |
| 세션이 30분 후 죽음 | IDLE_TIMEOUT_MS | 긴 토론 중이면 60초마다 활성화(아무 요청)하거나 재시작 |
| 같은 파일명 재사용 | reload 안 터짐 | semantic 이름 + `-v2` suffix |

## Reference

- 프레임 CSS 전체: `scripts/frame-template.html`
- 클라이언트 헬퍼: `scripts/helper.js`
- 게임 도메인 클래스 사전: `references/css-classes.md`
- 자주 쓰는 게이트 템플릿: `references/gate-patterns.md`
