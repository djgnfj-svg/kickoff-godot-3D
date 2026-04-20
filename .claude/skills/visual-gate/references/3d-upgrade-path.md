# Visual Gate 3D 렌더 업그레이드 경로

**현재 상태:** SVG/CSS로 시각 결정 커버 중. 2026-04-20 v2 시연 기준으로 시점·HUD·타이밍·씬트리·레벨 결정은 충분.

**미도입 사유:** 현재 유즈케이스에 과투자. 도입 시 CDN 의존·씬 설계 부담·렌더 비용 발생.

**이 문서 목적:** 나중에 "실제 3D 모델·월드 톤" 수준의 콘셉트 결정이 필요할 때 참조할 **선택적 업그레이드 경로**. 건드리기 전에 사용자와 합의 필수.

---

## 트리거 — 언제 3D 렌더로 올라가야 하나

다음 중 2개 이상 해당할 때만 검토:

- [ ] SVG/CSS로 표현하려니 3개 이상의 옵션이 **서로 구별되지 않는다** (실루엣 비교가 작은 차이 때문에 모두 비슷해 보임).
- [ ] 캐릭터 모델·무기 디자인처럼 **실사 느낌**이 판단의 핵심이다.
- [ ] 카메라 시점을 **동적으로 돌려가며** 비교해야 이해된다 (정적 SVG 4장으로 불충분).
- [ ] 콘셉트 아트·무드보드 역할을 게이트가 해야 한다 (색상·조명·분위기 결정).

트리거 1개 이하 = 계속 SVG/CSS. 무리해서 3D 쓰지 말 것.

---

## 옵션 A: `<model-viewer>` (최소 침습)

**설치:** 없음. 태그 1개 + CDN 스크립트 1줄.

```html
<script type="module" src="https://unpkg.com/@google/model-viewer/dist/model-viewer.min.js"></script>

<model-viewer src="https://example.com/character.glb"
              alt="Warrior"
              auto-rotate
              camera-controls
              style="width:100%;height:280px">
</model-viewer>
```

**가능한 것:**
- .glb/.gltf 3D 모델을 브라우저에서 드래그로 회전 가능
- 카메라 각도·AR·라이팅 프리셋
- 무료 모델: Kenney (CC0), Quaternius (CC0), Sketchfab 일부, Poly Pizza

**한계:**
- **모델 파일 URL이 있어야 함** — 없으면 사용자에게 제공 요청 필요 (저작권 CC0 확인)
- 씬 구성은 불가 (모델 하나씩 보여주는 뷰어)
- 여러 모델 동시 비교는 `<model-viewer>` 4개 배치

**적합 유즈케이스:**
- 캐릭터 모델 후보 비교 (Kenney/Quaternius CC0 에셋 3~4개)
- 무기·방어구 실루엣 비교
- 보스 실제 비례 프리뷰

**적합 Gate 패턴:** `character-silhouette` 업그레이드판, 향후 신설할 `character-model`·`weapon-mockup` 등.

---

## 옵션 B: Three.js CDN (중간 투자)

**설치:** CDN 스크립트 1줄.

```html
<script type="importmap">
{"imports":{"three":"https://unpkg.com/three@0.160.0/build/three.module.js"}}
</script>

<canvas id="scene-a" style="width:100%;aspect-ratio:16/9"></canvas>

<script type="module">
import * as THREE from 'three';
const canvas = document.getElementById('scene-a');
const renderer = new THREE.WebGLRenderer({ canvas });
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(60, 16/9, 0.1, 100);
// primitive로 씬 구성 (큐브·구·평면)
const player = new THREE.Mesh(
  new THREE.BoxGeometry(1, 2, 0.5),
  new THREE.MeshStandardMaterial({ color: 0x4466ff })
);
scene.add(player);
// 카메라를 1인칭/3인칭/탑다운 중 하나로
camera.position.set(0, 2, 5);
camera.lookAt(player.position);
renderer.render(scene, camera);
</script>
```

**가능한 것:**
- **같은 씬을 4개 카메라로 동시 렌더** → 시점 비교에 가장 강력
- primitive(큐브·구·평면)로 즉석 레벨·적 배치
- 조명·FOV·카메라 거리를 정확한 수치로 세팅
- 애니메이션·카메라 이동 루프 (공격 타이밍 실시간 시연 가능)

**한계:**
- Claude가 Three.js 씬 그래프를 코드로 작성해야 함 (러닝 커브)
- 카드마다 WebGL 컨텍스트 1개 → 4카드 = 4 컨텍스트 (브라우저 한계 있음)
- 모델 로드는 `GLTFLoader` 추가 필요

**적합 유즈케이스:**
- 카메라 시점 비교 **동적** (정적 SVG 대비 결정적 차이)
- 레벨 3D 프리뷰 (격자 2D → 공간 3D)
- 공격 애니메이션 타이밍 **실제 움직임**으로 시연

**적합 Gate 패턴:** `camera-perspective` 업그레이드판, `camera-distance`, 향후 `level-3d`.

---

## 옵션 C: 정적 스크린샷 배포 (불채택)

에셋 라이브러리에서 **미리 찍어둔 PNG 스크린샷**을 `<img>`로 보여주는 방식. **채택 안 함**:

- 싱크 문제 (이미지 수정 시 누가 언제 업데이트?)
- 저작권 관리 부담
- superpowers brainstorming 원칙(Claude가 직접 코드로 그리기)에 역행

**업로드 기반 이미지**는 향후 정말 필요해지면 별 스킬로 분리.

---

## 도입 의사결정 플로우

```
시각 결정 필요
   │
   ▼
SVG/CSS로 v2 품질 가능? ── Yes ──▶ [현재 방식 유지]
   │
   No (트리거 2+개)
   │
   ▼
모델 1개 뷰어로 충분? ── Yes ──▶ [옵션 A: <model-viewer>]
   │
   No (씬 구성·카메라 이동 필요)
   │
   ▼
[옵션 B: Three.js]
```

## 도입 전 체크리스트

- [ ] 사용자 명시 동의 ("이 게이트에 3D 필요" 합의)
- [ ] 트리거 기준 2개 이상 충족 증명
- [ ] CDN 로드 허용 (현재 `server.cjs`는 CSP 미설정, CDN 가능)
- [ ] .glb 모델 경로·라이선스 확인 (옵션 A)
- [ ] 비교 카드 수 ≤ 3 (Three.js 4카드 이상 시 WebGL 컨텍스트 초과)
- [ ] 시연 후 v3로 기록 (`demo-<gate_id>-v3.html`)

## 도입 시 추가할 자산

- `references/3d-patterns.md` (모델 뷰어·Three.js 게이트 템플릿)
- `frame-template.html`에 `<model-viewer>` 대응 CSS 클래스 (`.model-card`, `.scene-3d`)
- `asset-pipeline` 스킬과 연결 (CC0 모델 출처 매트릭스)

---

**결론:** 지금은 건드리지 않는다. "3D 모델 콘셉트" 스프린트가 실제로 잡힐 때 이 문서 다시 펼친다.
