---
name: asset-pipeline
description: 2D/3D Godot 4 게임에 필요한 에셋(스프라이트·타일맵·메시·텍스처·머티리얼·오디오·UI·폰트)을 확보하는 2단계 폴백 체인. Godot 내장 placeholder → 사용자 위임 순서로 시도한다. Generator는 항상 placeholder로 시작해 게임이 동작하게 만들고, 에셋 교체는 별개 스프린트에서 진행한다. "에셋 확보", "placeholder", "에셋 교체", "에셋 파이프라인" 상황에 이 스킬을 참조한다.
---

# Asset Pipeline — Godot 4 게임 에셋 확보 체계

게임 에셋(스프라이트·3D 모델·텍스처·사운드·UI·폰트)은 "만들기 어렵다"는 이유로 개발을 막으면 안 된다. 이 스킬은 **언제나 게임이 동작하는 상태**를 유지하며 에셋 품질을 점진적으로 올리는 경로를 정의한다.

**프로젝트 차원에 따라 placeholder 카탈로그 로드:** `docs/kickoff/_meta.md`의 `project_type: 2d` → `references/2d.md`, `project_type: 3d` → `references/3d.md`.

## 핵심 원칙

1. **Placeholder First** — 모든 스프린트는 Godot 기본 내장 자산으로 시작. 기능 검증이 우선.
2. **기능과 외형 분리** — 에셋 교체는 기능 구현 완료 후 **별도 스프린트**에서. 한 스프린트에서 둘 다 하지 않음.
3. **하네스는 manifest와 import만 담당** — 에셋 제작·구매·라이선스 결정은 사용자 영역.

## 2단계 폴백 체인

```
① Godot 내장 (primitive 메시 / ColorRect / 단색 스프라이트 / 기본 Theme 등)
    ↓ AC 미달이면
② 사용자 위임
```

**"AC 미달"의 판정 기준:** 해당 스프린트의 AC(수용 기준)가 외형 품질을 명시적으로 요구하는가? 외형 품질이 AC에 없으면 ①에서 멈춘다.

## 단계 ①: Godot 내장 placeholder

차원별 카탈로그는 references로 분리:
- 2D 프로젝트: `references/2d.md` — Sprite2D · TileMap · ColorRect · Camera2D 등
- 3D 프로젝트: `references/3d.md` — MeshInstance3D + 기본 Mesh · StandardMaterial3D · Camera3D · DirectionalLight3D 등

**공통 원칙:**
- placeholder 단계에서는 복잡한 셰이더·노멀맵·PBR·정교 애니메이션 금지
- 색 팔레트는 키컬러로 역할 구분 (아군 파랑, 적 빨강 등). 자세한 규칙은 `build-conventions/references/design.md`에서 관리
- 오디오: `AudioStreamGenerator` 프로시저럴 비프음 (디버그 피드백용). 실제 사운드는 ② 사용자 위임

### Placeholder 명명 규칙

placeholder 에셋을 사용한 노드/리소스 이름에 `_placeholder` 접미사 또는 `pl_` 접두사:
- `Sprite2D` 노드 이름: `PlayerBody_placeholder`
- `MeshInstance3D` 노드 이름: `EnemyBody_placeholder`
- 리소스: `pl_mat_enemy.tres`

이후 단계에서 교체 대상을 grep으로 찾을 수 있게.

## 단계 ②: 사용자 위임

무료 라이브러리(Kenney/Quaternius/OpenGameArt 등) 다운로드, AI 생성, 외주, 직접 제작은 **모두 사용자 영역**. 하네스는 다음 두 가지만 담당한다:

1. **manifest 작성** — 사용자가 도입한 에셋의 출처·라이선스를 `docs/build/F{N}/assets/manifest.md`에 기록
2. **import 검증** — Godot 4 import 설정이 표준에 맞는지 Evaluator가 확인

### 위임 요청 포맷

```markdown
## 에셋 위임 요청 — S{M}

**필요한 것:** {1줄 설명 — 예: "적 캐릭터 스프라이트, 32x32, 4프레임 idle 애니메이션"}

**Placeholder 시도 결과:**
- ① Godot 내장으로는 ColorRect 박스로 기능 검증 완료, 다만 AC "적이 캐릭터로 인식 가능" 미달

**완료 확인 방법:** `assets/sprites/enemy.png` 존재 + Godot에서 import 성공 + `manifest.md`에 출처·라이선스 기록됨
```

### manifest.md 필수 형식

```markdown
# F{N} Asset Manifest

| 경로 | 출처 | 라이선스 | 출처 URL | 도입 스프린트 |
|------|------|---------|---------|--------------|
| assets/sprites/player.png | Kenney | CC0 | https://kenney.nl/... | S2 |
```

라이선스 미기록 에셋은 Evaluator가 **FAIL** 판정.

## Godot 4 Import 설정 표준

에셋을 프로젝트에 추가할 때 `.import` 파일이 자동 생성된다. 공통 규칙:

### 텍스처·스프라이트 (.png, .jpg)
```
- Filter: Nearest (픽셀 아트·UI) / Linear (3D 텍스처·매끄러운 2D)
- Mipmaps: On (3D), Off (2D UI·픽셀 아트)
- Fix Alpha Border: On (알파 있는 텍스처)
```

### 3D 모델 (.glb 권장, .gltf 차선)
```
- Skins: Use Named Skins (캐릭터), Skinless (정적 오브젝트)
- Create Scene: On (재사용 씬으로 저장)
- Materials: Extract (머티리얼 분리 저장 — 후편집 가능)
- Meshes: Ensure Tangents (노멀맵 사용 시)
```

### 오디오 (.wav, .ogg)
```
- SFX (1초 미만): .wav, Loop=Off
- SFX (1~5초): .ogg, Quality=0.5
- BGM: .ogg, Loop=On, Loop Begin 지정
```

**Evaluator 검증:** 각 에셋의 `.import` 파일이 위 규칙을 따르는지 텍스트로 확인.

## Placeholder → 실제 에셋 교체 스프린트

기능 스프린트가 모두 끝난 후 또는 주기적으로:

### "Polish Sprint" 형식
- 범위: `_placeholder` 접미사 또는 `pl_` 접두사 에셋 전체
- AC: 모든 placeholder가 단계 ②(사용자 위임 산출물)로 교체됨, manifest.md 갱신됨
- 기능 변경 금지 — 외형만 교체
- Evaluator: 기존 기능 AC 회귀 없음 + 시각 스크린샷 비교 (before/after)

## 이 스킬을 참조하는 주체

- `planner` 에이전트 — 스프린트 경계 그을 때 "에셋 교체 스프린트"를 별도로 배치
- `generator` 에이전트 — 새 노드/리소스 생성 시 단계 ①부터 순서대로 시도
- `evaluator` 에이전트 — manifest.md 존재·라이선스 기록·import 설정 검증
- `godot-scene-handoff` 스킬 — S{M}-generator.md에 사용한 에셋 단계 기록

## 변경 이력

| 날짜 | 변경 | 사유 |
|------|------|------|
| 2026-04-16 | 초안 (4단계 폴백) | Build Harness Godot 전환, 에셋 폴백 체계 도입 |
| 2026-04-29 | 2단계 폴백으로 축소 + 차원별 placeholder references 분리 (2d.md / 3d.md) | v0.2.0 — 자동화 부채 제거. 에셋 제작은 사용자 영역으로 일원화, 하네스는 manifest+import 검증만 담당 |
