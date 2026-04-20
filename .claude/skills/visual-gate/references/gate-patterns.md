# Visual Gate 게이트 패턴 카탈로그

자주 쓰는 시각 결정 게이트의 복사 가능 HTML 템플릿. Claude는 해당 Phase/에이전트에서 이 패턴 중 하나를 가져와 구체값만 채운다.

## 카탈로그 요약

| 패턴 ID | 쓰이는 Phase | 주 에이전트 | 설명 |
|---------|-------------|------------|------|
| `camera-perspective` | Kickoff P1-5-3 | founder | 1인칭/3인칭/탑다운 시점 선택 |
| `capsule-composition` | Kickoff PA why | hook-strategist | Steam 캡슐 이미지 구도 A/B |
| `hud-layout` | Kickoff PA what / Build | hook-strategist, planner | HP/MP/미니맵 배치 |
| `attack-timing` | Kickoff PA why | core-mechanic-designer | 프레임 배분 |
| `character-silhouette` | Kickoff PA what | hook-strategist, CMD | 주인공·보스 비례 |
| `scene-tree` | Build 스프린트 시작 | planner, generator | 씬 노드 구조 A/B |
| `state-machine` | Build 구현 직전 | generator | 플레이어 상태 전이 |
| `level-layout` | Build 스프린트 | planner | 보스룸·지역 격자 배치 |
| `camera-distance` | Kickoff PA / Build | CMD, planner | 카메라 거리·FOV 비교 |

---

## 1. `camera-perspective` — 카메라 시점 선택

**Phase:** Kickoff Phase 1 Step 1-5-3.
**에이전트:** founder.
**트리거 예시:** "시점을 어떻게 정하죠?"

```html
<h2>카메라 시점을 어느 쪽으로?</h2>
<p class="subtitle">코어 버브 "{VERB}"의 타격감/피드백이 카메라 거리에 크게 좌우됩니다</p>

<div class="cards">
  <div class="card" data-choice="first_person" onclick="toggleSelect(this)">
    <div class="card-image">
      <div class="camera-diagram" style="width:80%">
        <div class="actor" style="top:50%;left:25%"></div>
        <div class="camera" style="top:50%;left:25%"></div>
      </div>
    </div>
    <div class="card-body"><h3>1인칭</h3><p>몰입감·조작 직결. 무기 휘두름이 화면 가득</p></div>
  </div>
  <div class="card" data-choice="third_person_close" onclick="toggleSelect(this)">
    <div class="card-image">
      <div class="camera-diagram" style="width:80%">
        <div class="actor" style="top:50%;left:65%"></div>
        <div class="camera" style="top:50%;left:25%"></div>
      </div>
    </div>
    <div class="card-body"><h3>3인칭 근접 (2~3m)</h3><p>다크소울류. 캐릭터 전체와 주변 동시 확인</p></div>
  </div>
  <div class="card" data-choice="third_person_far" onclick="toggleSelect(this)">
    <div class="card-image">
      <div class="camera-diagram" style="width:80%">
        <div class="actor" style="top:50%;left:80%"></div>
        <div class="camera" style="top:50%;left:15%"></div>
      </div>
    </div>
    <div class="card-body"><h3>3인칭 원거리 (8m+)</h3><p>하데스·디아블로류. 전장 조망·군중 대응</p></div>
  </div>
  <div class="card" data-choice="topdown" onclick="toggleSelect(this)">
    <div class="card-image">
      <div class="camera-diagram" style="width:80%">
        <div class="actor" style="top:50%;left:50%"></div>
        <div class="camera" style="top:15%;left:50%;transform:translate(-50%,-50%) rotate(90deg)"></div>
      </div>
    </div>
    <div class="card-body"><h3>탑다운</h3><p>버그 헌터류. 공간 파악 최고, 캐릭터 표정 희생</p></div>
  </div>
</div>
```

---

## 2. `capsule-composition` — Steam 캡슐 이미지 구도

**Phase:** Kickoff Phase A why 사이클.
**에이전트:** hook-strategist.

```html
<h2>캡슐 이미지 구도 (Steam 스토어 첫인상 0.5초)</h2>
<p class="subtitle">썸네일 크기에서도 읽혀야 합니다. 경쟁작 패턴을 기반으로 3안</p>

<div class="cards">
  <div class="card" data-choice="capsule_hero_center" onclick="toggleSelect(this)">
    <div class="card-image">
      <div class="scene-mockup" style="width:100%;aspect-ratio:460/215">
        <span class="scene-label">Capsule 460×215</span>
        <div class="hud-slot" data-pos="middle-center"
             style="position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);background:transparent;border:2px solid var(--scene-accent);padding:20px 30px">
          주인공 정면
        </div>
        <div class="hud-slot" data-pos="bottom-center" style="background:transparent;color:var(--scene-ink);border:none">GAME TITLE</div>
      </div>
    </div>
    <div class="card-body"><h3>A. 주인공 중앙</h3><p>다크소울·엘든링류. 고독·포스 강조</p></div>
  </div>
  <div class="card" data-choice="capsule_action_moment" onclick="toggleSelect(this)">
    <div class="card-image">
      <div class="scene-mockup" style="width:100%;aspect-ratio:460/215">
        <span class="scene-label">Capsule 460×215</span>
        <div class="hud-slot" data-pos="middle-right"
             style="background:transparent;border:2px solid var(--scene-accent);padding:16px 22px">
          타격 순간
        </div>
        <div class="hud-slot" data-pos="middle-left" style="background:transparent;border:2px dashed var(--scene-ink);padding:16px 22px">
          보스 실루엣
        </div>
      </div>
    </div>
    <div class="card-body"><h3>B. 액션 결정적 순간</h3><p>갓오브워류. 충돌·스파크 강조</p></div>
  </div>
  <div class="card" data-choice="capsule_world_wide" onclick="toggleSelect(this)">
    <div class="card-image">
      <div class="scene-mockup" style="width:100%;aspect-ratio:460/215">
        <span class="scene-label">Capsule 460×215</span>
        <div class="hud-slot" data-pos="bottom-center" style="background:transparent;color:var(--scene-ink);border:none">월드 파노라마 + 소형 주인공</div>
      </div>
    </div>
    <div class="card-body"><h3>C. 월드 와이드</h3><p>젤다·호라이즌류. 스케일·탐험 강조</p></div>
  </div>
</div>
```

---

## 3. `hud-layout` — HUD 배치

**Phase:** Kickoff PA what / Build 스프린트.
**에이전트:** hook-strategist, planner.

```html
<h2>HUD 어떻게 배치할까요?</h2>
<div class="split">
  <div class="mockup">
    <div class="mockup-header">A: 좌상단 HP · 우하단 맵</div>
    <div class="mockup-body">
      <div class="scene-mockup" onclick="toggleSelect(this)" data-choice="hud_classic" style="cursor:pointer">
        <span class="scene-label">Gameplay</span>
        <div class="hud-slot" data-pos="top-left">HP<div class="hud-bar"><span style="width:65%"></span></div></div>
        <div class="hud-slot" data-pos="top-left" style="top:48px">MP<div class="hud-bar"><span style="width:30%"></span></div></div>
        <div class="hud-slot" data-pos="bottom-right">MAP</div>
        <div class="hud-slot" data-pos="bottom-left">아이템</div>
      </div>
    </div>
  </div>
  <div class="mockup">
    <div class="mockup-header">B: 중앙 하단 HP · 우상단 맵</div>
    <div class="mockup-body">
      <div class="scene-mockup" onclick="toggleSelect(this)" data-choice="hud_centered" style="cursor:pointer">
        <span class="scene-label">Gameplay</span>
        <div class="hud-slot" data-pos="bottom-center">HP<div class="hud-bar"><span style="width:65%"></span></div></div>
        <div class="hud-slot" data-pos="top-right">MAP</div>
        <div class="hud-slot" data-pos="bottom-left">아이템</div>
      </div>
    </div>
  </div>
</div>
```

---

## 4. `attack-timing` — 공격 프레임 배분

**Phase:** Kickoff PA why 사이클.
**에이전트:** core-mechanic-designer.

```html
<h2>{VERB} 공격 프레임 배분 (30fps 기준)</h2>
<p class="subtitle">초록=피격 판정, 회색=시전/후딜, 노랑=캔슬 가능 구간</p>

<div class="options">
  <div class="option" data-choice="timing_fast" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>빠른 무기 (총 18f)</h3>
      <div class="timeline-bar">
        <div class="seg" data-kind="startup"  style="width:22%">시전 4f</div>
        <div class="seg" data-kind="active"   style="width:17%">타격 3f</div>
        <div class="seg" data-kind="recovery" style="width:50%">후딜 9f</div>
        <div class="seg" data-kind="cancel"   style="width:11%">캔슬 2f</div>
      </div>
      <p>숏소드·대거. 난사 가능, 리스크 낮음</p>
    </div>
  </div>
  <div class="option" data-choice="timing_heavy" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>무거운 무기 (총 40f)</h3>
      <div class="timeline-bar">
        <div class="seg" data-kind="startup"  style="width:35%">시전 14f</div>
        <div class="seg" data-kind="active"   style="width:15%">타격 6f</div>
        <div class="seg" data-kind="recovery" style="width:45%">후딜 18f</div>
        <div class="seg" data-kind="cancel"   style="width:5%">캔슬 2f</div>
      </div>
      <p>그레이트액스·마울. 한 방 무거움, 헛스윙 시 치명</p>
    </div>
  </div>
  <div class="option" data-choice="timing_medium" onclick="toggleSelect(this)">
    <div class="letter">C</div>
    <div class="content">
      <h3>표준 (총 26f)</h3>
      <div class="timeline-bar">
        <div class="seg" data-kind="startup"  style="width:28%">시전 7f</div>
        <div class="seg" data-kind="active"   style="width:20%">타격 5f</div>
        <div class="seg" data-kind="recovery" style="width:44%">후딜 11f</div>
        <div class="seg" data-kind="cancel"   style="width:8%">캔슬 3f</div>
      </div>
      <p>롱소드. 균형. 다크소울 기본값</p>
    </div>
  </div>
</div>
```

---

## 5. `character-silhouette` — 캐릭터 실루엣·비례

**Phase:** Kickoff PA what.
**에이전트:** hook-strategist, core-mechanic-designer.

```html
<h2>주인공 실루엣 비례</h2>
<p class="subtitle">캡슐·트레일러에서 1초 안에 읽히는 실루엣을 만드는 결정</p>

<div class="split">
  <div class="mockup">
    <div class="mockup-header">A: 가는 검사 (장비 중심)</div>
    <div class="mockup-body">
      <div class="silhouette" onclick="toggleSelect(this)" data-choice="silhouette_slim" style="cursor:pointer">
        <svg viewBox="0 0 100 140">
          <circle cx="50" cy="18" r="9"/>
          <rect x="42" y="28" width="16" height="44" rx="2"/>
          <rect x="44" y="72" width="4" height="44"/>
          <rect x="52" y="72" width="4" height="44"/>
          <rect x="58" y="32" width="18" height="4"/><!-- 검 -->
          <rect x="72" y="22" width="4" height="24"/>
        </svg>
      </div>
    </div>
  </div>
  <div class="mockup">
    <div class="mockup-header">B: 거대 전사 (장비가 체격을 덮음)</div>
    <div class="mockup-body">
      <div class="silhouette" onclick="toggleSelect(this)" data-choice="silhouette_bulky" style="cursor:pointer">
        <svg viewBox="0 0 100 140">
          <circle cx="50" cy="20" r="10"/>
          <rect x="32" y="30" width="36" height="56" rx="4"/>
          <rect x="40" y="86" width="8" height="30"/>
          <rect x="52" y="86" width="8" height="30"/>
          <rect x="66" y="38" width="24" height="6"/><!-- 대검 -->
        </svg>
      </div>
    </div>
  </div>
</div>
```

---

## 6. `scene-tree` — Godot 씬 노드 구조

**Phase:** Build 스프린트 시작.
**에이전트:** planner, generator.

```html
<h2>{SCENE} 씬 구조 A/B</h2>
<p class="subtitle">각 스타일의 결합도·테스트 용이성이 다릅니다</p>

<div class="split">
  <div class="mockup">
    <div class="mockup-header">A: 납작한 구조 (코드 중심)</div>
    <div class="mockup-body">
      <div class="node-graph" onclick="toggleSelect(this)" data-choice="tree_flat" style="cursor:pointer">
        <div class="node" data-type="scene">Player (CharacterBody3D)</div>
        <div class="node indent-1" data-type="script">player.gd</div>
        <div class="node indent-1" data-type="scene">CollisionShape3D</div>
        <div class="node indent-1" data-type="scene">MeshInstance3D</div>
        <div class="node indent-1" data-type="scene">Camera3D</div>
      </div>
    </div>
  </div>
  <div class="mockup">
    <div class="mockup-header">B: 컴포넌트 분리 (재사용 중심)</div>
    <div class="mockup-body">
      <div class="node-graph" onclick="toggleSelect(this)" data-choice="tree_component" style="cursor:pointer">
        <div class="node" data-type="scene">Player (CharacterBody3D)</div>
        <div class="node indent-1" data-type="script">player.gd</div>
        <div class="node indent-1" data-type="scene">MovementComponent</div>
        <div class="node indent-2" data-type="script">movement.gd</div>
        <div class="node indent-1" data-type="scene">CombatComponent</div>
        <div class="node indent-2" data-type="script">combat.gd</div>
        <div class="node indent-1" data-type="scene">HealthComponent</div>
        <div class="node indent-2" data-type="script">health.gd</div>
      </div>
    </div>
  </div>
</div>
```

---

## 7. `state-machine` — 플레이어 상태 전이

**Phase:** Build 구현 직전.
**에이전트:** generator.

```html
<h2>플레이어 상태 그래프</h2>
<p class="subtitle">상태 수가 많을수록 표현력↑, 버그 면적도↑</p>

<div class="options">
  <div class="option" data-choice="sm_minimal" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>최소 (3개: Idle / Move / Attack)</h3>
      <div class="node-graph">
        <div class="node" data-type="scene">Idle</div>
        <div class="edge indent-1">→ 입력 WASD</div>
        <div class="node indent-1" data-type="scene">Move</div>
        <div class="edge indent-2">→ 입력 LMB</div>
        <div class="node indent-2" data-type="scene">Attack</div>
      </div>
      <p>프로토타입에 적합. TTFV 최단</p>
    </div>
  </div>
  <div class="option" data-choice="sm_standard" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>표준 (6개: +Jump/Roll/Stun)</h3>
      <div class="node-graph">
        <div class="node" data-type="scene">Idle</div>
        <div class="node indent-1" data-type="scene">Move → Jump / Roll</div>
        <div class="node indent-1" data-type="scene">Attack → Combo</div>
        <div class="node indent-1" data-type="scene">Stun (피격 시)</div>
      </div>
      <p>다크소울 베이스라인</p>
    </div>
  </div>
</div>
```

---

## 8. `level-layout` — 레벨·보스룸 격자

**Phase:** Build 스프린트.
**에이전트:** planner.

```html
<h2>{ROOM_NAME} 배치</h2>
<p class="subtitle">P=플레이어, E=적, G=골, 검은=벽</p>

<div class="split">
  <div class="mockup">
    <div class="mockup-header">A: 좁은 복도 (근접 강제)</div>
    <div class="mockup-body">
      <div class="tile-grid" onclick="toggleSelect(this)" data-choice="layout_corridor"
           style="grid-template-columns:repeat(8,1fr);cursor:pointer">
        <!-- 8x8 grid. Wall 테두리 + 중앙 좁은 통로 -->
        <div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div>
        <div class="tile" data-type="wall"></div><div class="tile" data-type="player">P</div><div class="tile" data-type="floor"></div><div class="tile" data-type="floor"></div><div class="tile" data-type="floor"></div><div class="tile" data-type="enemy">E</div><div class="tile" data-type="goal">G</div><div class="tile" data-type="wall"></div>
        <div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div>
      </div>
    </div>
  </div>
  <div class="mockup">
    <div class="mockup-header">B: 넓은 원형 (회피 공간 확보)</div>
    <div class="mockup-body">
      <div class="tile-grid" onclick="toggleSelect(this)" data-choice="layout_arena"
           style="grid-template-columns:repeat(8,1fr);cursor:pointer">
        <div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div>
        <div class="tile" data-type="wall"></div><div class="tile" data-type="player">P</div><div class="tile" data-type="floor"></div><div class="tile" data-type="floor"></div><div class="tile" data-type="floor"></div><div class="tile" data-type="floor"></div><div class="tile" data-type="floor"></div><div class="tile" data-type="wall"></div>
        <div class="tile" data-type="wall"></div><div class="tile" data-type="floor"></div><div class="tile" data-type="floor"></div><div class="tile" data-type="enemy">E</div><div class="tile" data-type="floor"></div><div class="tile" data-type="floor"></div><div class="tile" data-type="floor"></div><div class="tile" data-type="wall"></div>
        <div class="tile" data-type="wall"></div><div class="tile" data-type="floor"></div><div class="tile" data-type="floor"></div><div class="tile" data-type="floor"></div><div class="tile" data-type="floor"></div><div class="tile" data-type="floor"></div><div class="tile" data-type="goal">G</div><div class="tile" data-type="wall"></div>
        <div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div><div class="tile" data-type="wall"></div>
      </div>
    </div>
  </div>
</div>
```

---

## 9. `camera-distance` — 카메라 거리/FOV

**Phase:** Kickoff PA / Build.

```html
<h2>카메라 거리·FOV 비교</h2>

<div class="options">
  <div class="option" data-choice="cam_near_wide" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>근접 · 광각 FOV 90°</h3>
      <div class="depth-axis">
        <div class="marker" style="left:10%"></div><span style="left:10%">카메라</span>
        <div class="marker" style="left:28%"></div><span style="left:28%">캐릭터 2m</span>
        <div class="marker" style="left:78%"></div><span style="left:78%">적 10m</span>
      </div>
      <p>빠른 템포·몰입. 멀미 가능성</p>
    </div>
  </div>
  <div class="option" data-choice="cam_far_narrow" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>원거리 · 표준 FOV 60°</h3>
      <div class="depth-axis">
        <div class="marker" style="left:5%"></div><span style="left:5%">카메라</span>
        <div class="marker" style="left:55%"></div><span style="left:55%">캐릭터 8m</span>
        <div class="marker" style="left:92%"></div><span style="left:92%">적 18m</span>
      </div>
      <p>전장 조망·군중 대응. 타격감 약화</p>
    </div>
  </div>
</div>
```

---

## 게이트 ID 명명 규칙

- **kebab-case**: `camera-perspective`, `hud-layout`
- **Scope 접두사** (선택): Kickoff용은 `kickoff-`, Build용은 `build-S{M}-`
- 예: `kickoff-camera-perspective`, `build-S2-hud-layout`
- 이터레이션은 `-v2`, `-v3` suffix.
