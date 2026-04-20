# Visual Gate CSS 클래스 사전

`frame-template.html`이 제공하는 모든 CSS 클래스의 목적·파라미터·최소 스니펫. Claude는 HTML fragment를 쓸 때 이 사전을 참조한다.

## 공통 선택 컨테이너

### `.options` — 세로 A/B/C 선택 리스트
사용처: 텍스트 중심 설명이 많은 선택. 각 옵션이 2~3줄씩 길 때.

```html
<div class="options">
  <div class="option" data-choice="opt_a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>제목</h3>
      <p>설명 한 줄</p>
    </div>
  </div>
</div>
```

- `data-multiselect` 컨테이너 속성 추가 시 복수 선택.
- `data-choice` 필수. 없으면 events에 기록되지 않는다.

### `.cards` — 그리드 카드 (썸네일·도식)
사용처: 시각 요소가 주인 선택. 카드 안에 도식·SVG·mockup.

```html
<div class="cards">
  <div class="card" data-choice="card_a" onclick="toggleSelect(this)">
    <div class="card-image"><!-- 도식 --></div>
    <div class="card-body"><h3>제목</h3><p>설명</p></div>
  </div>
</div>
```

`.card-image`는 `aspect-ratio: 16/10` 기본. 안에 `.scene-mockup`·`.camera-diagram`·`.silhouette` 등 넣는다.

## 프레임 컨테이너

### `.mockup` / `.mockup-header` / `.mockup-body`
사용처: 한 화면을 라벨 달린 프레임으로 감쌀 때.

```html
<div class="mockup">
  <div class="mockup-header">A: 좌상단 HP</div>
  <div class="mockup-body"><!-- 콘텐츠 --></div>
</div>
```

### `.split` — 2열 side-by-side
사용처: A vs B 비교. 모바일 <700px에선 자동 1열.

### `.pros-cons`
사용처: 한 선택지의 장단점을 명시적으로 보여줄 때.

```html
<div class="pros-cons">
  <div class="pros"><h4>장점</h4><ul><li>…</li></ul></div>
  <div class="cons"><h4>단점</h4><ul><li>…</li></ul></div>
</div>
```

### `.placeholder`
사용처: 콘텐츠가 비었음을 표시할 때 (회색 점선 박스).

---

## 게임 도메인 클래스

### `.scene-mockup` — 게임 화면 프레임 (16:9)
배경: 어두운 회색 + 격자 32px. `.hud-slot` 자식을 절대 위치로 배치.

```html
<div class="scene-mockup" style="width:100%">
  <span class="scene-label">Gameplay</span>
  <!-- 여기에 hud-slot 배치 -->
</div>
```

`.scene-label`로 화면 종류 표기 (Gameplay / Menu / Boss 등).

### `.hud-slot` — HUD 요소 배치
`data-pos` 속성으로 8개 위치 중 1개.

| `data-pos` 값 | 위치 |
|---------------|------|
| `top-left` / `top-center` / `top-right` | 상단 3곳 |
| `middle-left` / `middle-right` | 중단 좌/우 |
| `bottom-left` / `bottom-center` / `bottom-right` | 하단 3곳 |

```html
<div class="hud-slot" data-pos="top-left">
  HP
  <div class="hud-bar"><span style="width:60%"></span></div>
</div>
```

`.hud-bar > span`의 `width: N%`로 현재 값 표현.

### `.camera-diagram` — 탑뷰 카메라 도식 (1:1)

```html
<div class="camera-diagram" style="width:200px">
  <!-- 캐릭터 위치 -->
  <div class="actor" style="top:50%;left:50%"></div>
  <!-- 카메라 위치 + 방향 -->
  <div class="camera" style="top:50%;left:20%"></div>
  <!-- 시야각 (선택) -->
  <div class="fov" style="top:50%;left:20%;width:150px;height:80px;transform:rotate(0deg)"></div>
  <!-- 축 라벨 (선택) -->
  <span class="axis-label" style="top:90%;left:5%">거리 3m</span>
</div>
```

- `.actor` = 캐릭터 위치 (파란 원)
- `.camera` = 카메라 위치·방향 (주황 삼각형, 좌→우 방향)
- `.fov` = 시야각 (점선 영역)

### `.timeline-bar` — 공격·애니메이션 프레임 타이밍

```html
<div class="timeline-bar">
  <div class="seg" data-kind="startup"  style="width:30%">시전 9f</div>
  <div class="seg" data-kind="active"   style="width:20%">타격 6f</div>
  <div class="seg" data-kind="recovery" style="width:40%">후딜 12f</div>
  <div class="seg" data-kind="cancel"   style="width:10%">캔슬 3f</div>
</div>
```

| `data-kind` | 색상 | 의미 |
|-------------|------|------|
| `startup` | 회색 #6b7280 | 시전 구간 (공격 발동 전) |
| `active` | 주황 (액센트) | 피격 판정 활성 |
| `recovery` | 밝은 회색 #9ca3af | 후딜 (무방비) |
| `cancel` | 노랑 #fbbf24 | 다음 동작 캔슬 가능 구간 |

총 `width:%`의 합이 100%가 되도록. 하단에 `.timeline-axis`로 프레임 눈금 추가 가능.

### `.node-graph` — 씬 트리 / 상태머신

```html
<div class="node-graph">
  <div class="node" data-type="scene">Main (Node3D)</div>
  <div class="node indent-1" data-type="scene">Player (CharacterBody3D)</div>
  <div class="node indent-2" data-type="script">player.gd</div>
  <div class="node indent-2" data-type="scene">Camera3D</div>
  <div class="node indent-1" data-type="scene">World (Node3D)</div>
  <div class="edge indent-2">→ emit_signal("hit")</div>
</div>
```

| `data-type` | 색상 테두리 | 의미 |
|-------------|------------|------|
| `scene` | 액센트 파랑 | 씬·노드 |
| `script` | 초록 | .gd 스크립트 |
| `resource` | 주황 | .tres 리소스 |

`.indent-1` / `indent-2` / `indent-3`로 트리 들여쓰기.

### `.silhouette` — 캐릭터 실루엣 SVG (3:4 비율)

```html
<div class="silhouette">
  <svg viewBox="0 0 100 140">
    <!-- 간단한 사람 실루엣 -->
    <circle cx="50" cy="20" r="12"/>
    <rect x="38" y="32" width="24" height="50" rx="4"/>
    <rect x="42" y="82" width="6" height="40"/>
    <rect x="52" y="82" width="6" height="40"/>
  </svg>
</div>
```

SVG 작성 팁:
- viewBox로 스케일 통일 (예: `0 0 100 140`)
- 단색 fill (CSS `--text-primary`)로 실루엣 느낌
- 비교 시 split 컨테이너에 2~3개 병치

### `.tile-grid` — 레벨/방 격자 (1:1)
`grid-template-columns`는 인라인 스타일로 지정.

```html
<div class="tile-grid" style="grid-template-columns:repeat(8,1fr)">
  <div class="tile" data-type="wall"></div>
  <div class="tile" data-type="wall"></div>
  <!-- … -->
  <div class="tile" data-type="player">P</div>
  <div class="tile" data-type="floor"></div>
  <div class="tile" data-type="enemy">E</div>
  <div class="tile" data-type="goal">G</div>
</div>
```

| `data-type` | 색상 |
|-------------|------|
| `wall` | 짙은 회색 |
| `floor` | 배경색 |
| `player` | 액센트 파랑 |
| `enemy` | 빨강 |
| `goal` | 초록 |

### `.depth-axis` — Z축 원근감 (카메라 거리 비교)

```html
<div class="depth-axis">
  <div class="marker" style="left:10%"></div><span style="left:10%">0m (카메라)</span>
  <div class="marker" style="left:40%"></div><span style="left:40%">3m (캐릭터)</span>
  <div class="marker" style="left:80%"></div><span style="left:80%">15m (적)</span>
</div>
```

---

## Claude 작성 시 주의사항

1. **`data-choice` 누락 금지** — 없으면 events에 기록되지 않는다.
2. **`onclick="toggleSelect(this)"` 필수** — 선택 시각 피드백 + 헬퍼 경로.
3. **파일명 재사용 금지** — 같은 결정의 이터레이션은 `<gate>-v2.html`.
4. **인라인 style은 허용** — CSS 변수(`var(--accent)` 등) 사용 가능.
5. **외부 이미지·스크립트 금지** — 모든 시각 요소를 Claude가 직접 생성. AI 이미지·웹 URL 없음.
6. **SVG는 viewBox로 스케일 통일** — 병치 비교 시 크기 일관성.
7. **`.card-image` aspect-ratio 유지** — 안에 `.scene-mockup` 등 넣어도 16:10 비율 유지.
