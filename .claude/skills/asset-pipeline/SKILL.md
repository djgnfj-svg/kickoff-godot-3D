---
name: asset-pipeline
description: 3D 게임에 필요한 에셋(3D 메시·텍스처·머티리얼·오디오·UI·폰트)을 확보하는 4단계 폴백 체인. Godot primitive → 무료 라이브러리(Kenney/Quaternius/Godot Asset Library) → AI 생성(이미지·사운드 우선, 3D는 옵션) → 사용자 위임 순서로 시도한다. Generator는 항상 placeholder로 시작해 게임이 동작하게 만들고, 에셋 교체는 별개 스프린트에서 진행한다. AI 생성은 API 키가 있을 때만 활성화되며 capability matrix로 관리한다. "에셋 확보", "3D 모델 필요", "텍스처 생성", "placeholder", "에셋 교체", "에셋 파이프라인" 상황에 이 스킬을 참조한다.
---

# Asset Pipeline — 3D 게임 에셋 확보 체계

게임 에셋(3D 모델·텍스처·사운드·UI·폰트)은 "만들기 어렵다"는 이유로 개발을 막으면 안 된다. 이 스킬은 **언제나 게임이 동작하는 상태**를 유지하며 에셋 품질을 점진적으로 올리는 경로를 정의한다.

## 핵심 원칙

1. **Placeholder First** — 모든 스프린트는 Godot 기본 primitive로 시작. 기능 검증이 우선.
2. **기능과 외형 분리** — 에셋 교체는 기능 구현 완료 후 **별도 스프린트**에서. 한 스프린트에서 둘 다 하지 않음.
3. **폴백 체인 준수** — 상위 경로가 가능하면 하위로 내려가지 않는다 (저렴→비쌈 순).
4. **API 키 없어도 게임 완성** — AI 생성은 품질 부스트 옵션, 필수 아님.

## 4단계 폴백 체인

```
(1) Godot 기본 primitive + 단색 머티리얼
    ↓ 부족하면
(2) 무료 라이브러리 (Kenney, Quaternius, Poly Haven, Godot Asset Library)
    ↓ 부족하면
(3) AI 생성 (이미지/사운드 우선, 3D 메시는 실험적)
    ↓ 부족하면
(4) 사용자 위임
```

**"부족하면"의 판정 기준:** 각 단계의 산출물이 해당 스프린트의 AC(수용 기준)를 만족하는가? 외형 품질이 AC에 없으면 (1)에서 멈춘다.

## 단계 1: Godot Primitive

Godot 4 기본 제공:

### 3D 메시
- `BoxMesh`, `SphereMesh`, `CylinderMesh`, `CapsuleMesh`, `PlaneMesh`, `PrismMesh`, `TorusMesh`, `QuadMesh`
- 플레이어: `CapsuleMesh` (1m 높이, 0.4m 반경)
- 바닥: `PlaneMesh` 또는 `BoxMesh`
- 적/오브젝트: `BoxMesh` + 색 구분

### 머티리얼
- `StandardMaterial3D` + `albedo_color` 단색
- 색 팔레트는 `build-conventions/references/design.md`에서 관리
- **금지:** placeholder 단계에서 복잡한 셰이더·노멀맵·PBR 텍스처

### 오디오
- `AudioStreamGenerator` 프로시저럴 비프음 (디버그 피드백용)
- 실제 사운드는 단계 2부터

### UI
- 기본 Theme (Godot 4 default)
- 폰트: 시스템 기본 (커스텀 폰트 없음)

### Placeholder 명명 규칙
placeholder 에셋을 사용한 노드/리소스 이름에 `_placeholder` 접미사 또는 `pl_` 접두사:
- `MeshInstance3D`의 이름: `PlayerBody_placeholder`
- `StandardMaterial3D` 리소스: `pl_mat_enemy.tres`

이후 단계에서 교체 대상을 grep으로 찾을 수 있게.

## 단계 2: 무료 라이브러리

### 추천 소스 (라이선스 확인 완료)

| 소스 | 종류 | 라이선스 | URL |
|------|------|---------|-----|
| **Kenney** | 로우폴리 3D, 텍스처, UI, 오디오 | CC0 | kenney.nl |
| **Quaternius** | 로우폴리 3D 팩 | CC0 | quaternius.com |
| **Poly Haven** | HDRI, PBR 텍스처, 스캔 모델 | CC0 | polyhaven.com |
| **Godot Asset Library** | Godot 전용 애드온·샘플 | 각자 표기 | godotengine.org/asset-library |
| **freesound.org** | 사운드 이펙트 | CC 계열 | freesound.org |
| **OpenGameArt** | 혼합 에셋 | 각자 표기 | opengameart.org |

### Generator 사용 절차
1. WebSearch/WebFetch로 해당 소스에서 매치되는 에셋 검색
2. 다운로드 URL과 라이선스를 `docs/build/F{N}/assets/manifest.md`에 기록
3. 사용자에게 **다운로드 위임** (Claude가 원격 파일을 직접 받지 못하므로):
   ```markdown
   ## 에셋 다운로드 위임
   - URL: {링크}
   - 저장 경로: assets/models/kenney_enemy_pack.glb
   - 라이선스: CC0 (manifest에 기록됨)
   ```
4. 다운로드 확인 후 Godot 4 import 설정 적용 (다음 섹션)

### 라이선스 기록 의무
`docs/build/F{N}/assets/manifest.md` 필수 형식:

```markdown
# F{N} Asset Manifest

| 경로 | 출처 | 라이선스 | 출처 URL | 도입 스프린트 |
|------|------|---------|---------|--------------|
| assets/models/player.glb | Kenney | CC0 | https://kenney.nl/... | S2 |
```

라이선스 미기록 에셋은 Evaluator가 **FAIL** 판정.

## 단계 3: AI 생성

### Capability Matrix

**위치:** `.claude/skills/asset-pipeline/references/ai-capability-matrix.md`
**책임자:** 사용자 (API 키 소유자). 하네스는 matrix를 읽기만 함.

```markdown
# AI Asset Generation Capability Matrix

**최종 갱신:** {YYYY-MM-DD}

## Enabled (✅ API 키 있고 활성화됨)
| 종류 | 서비스 | API 환경변수 | 비용 감각 |
|------|--------|------------|---------|
| 이미지 (2D 텍스처/UI) | FLUX Dev via Replicate | REPLICATE_API_TOKEN | ~$0.003/이미지 |
| 사운드 이펙트 | ElevenLabs SFX | ELEVENLABS_API_KEY | ~$0.01/초 |

## Disabled (❌ 현재 사용 안 함)
| 종류 | 이유 |
|------|------|
| 3D 메시 생성 (TripoSR/Meshy) | 품질 불안정, 토폴로지 문제 |
| 음악 (Suno) | 저작권 이슈 우려 |

## Experimental (⚠️ 테스트 중)
| 종류 | 서비스 | 주의 |
|------|--------|------|
| 보이스 | ElevenLabs TTS | 캐릭터 더빙용 — 라이선스 확인 필요 |
```

### 이미지 생성 (가장 안정)

**용도:**
- 2D 텍스처 (텍스처 시트, 스카이박스, UI 아이콘)
- 컨셉 아트 (디자인 레퍼런스로만, 게임 내 사용 금지)

**절차:**
1. capability matrix에 enabled인지 확인
2. 생성 프롬프트는 `docs/build/F{N}/assets/prompts/{name}.md`에 기록 (재현성)
3. API 호출 → `assets/textures/{name}.png`에 저장
4. Godot 4 import 설정: Texture2D, Filter=Nearest(픽셀 아트일 때) 또는 Linear, Mipmaps=On(3D 텍스처)
5. manifest.md에 출처 "AI Generated (FLUX)"로 기록

### 사운드 이펙트 생성

**용도:** 피드백 사운드 (점프·충돌·수집·UI 클릭)
**주의:** 음악(BGM)은 별도 — AI 음악은 라이선스 불명확, 사용 안 함

### 3D 메시 생성 (실험적, 기본 비활성)

현재(2026-04) 3D 생성 AI는 제작 품질에 못 미침:
- 토폴로지(와이어프레임)가 게임용으로 부적합
- UV 매핑 품질 낮음
- 리깅/애니메이션 불가

**사용 조건:** 사용자가 명시적으로 요청 + capability matrix에서 enabled. 디폴트는 disabled.

## 단계 4: 사용자 위임

최후 수단. 다른 경로가 모두 막혔을 때만.

**위임 요청 포맷:**

```markdown
## 에셋 위임 요청 — S{M}

**필요한 것:** {1줄 설명 — 예: "적 캐릭터 3D 모델, 인간형, 1m 키"}

**폴백 체인 시도 결과:**
- (1) Primitive: 시도함 — CapsuleMesh로는 기능 검증 완료, 다만 AC "적이 인간형으로 인식 가능" 미달
- (2) 무료 라이브러리: Kenney에 매치 없음, Quaternius "Ultimate Modular Characters" 확인 요청 (링크)
- (3) AI: 3D 메시 생성은 capability matrix에서 disabled

**제안 대안:**
1. Quaternius 팩 다운로드 후 사용 (추천)
2. 사용자가 Blender로 직접 제작
3. Capsule + 머리(Sphere)를 그룹화한 간단한 인간형 (primitive 조합)

**완료 확인 방법:** `assets/models/enemy_humanoid.glb` 존재 + Godot에서 import 성공
```

## Godot 4 Import 설정 표준

에셋을 프로젝트에 추가할 때 `.import` 파일이 자동 생성된다. 공통 규칙:

### 3D 모델 (.glb 권장, .gltf 차선)
```
- Skins: Use Named Skins (캐릭터), Skinless (정적 오브젝트)
- Create Scene: On (재사용 씬으로 저장)
- Materials: Extract (머티리얼 분리 저장 — 후편집 가능)
- Meshes: Ensure Tangents (노멀맵 사용 시)
```

### 텍스처 (.png, .jpg)
```
- Filter: Linear (3D 텍스처) / Nearest (픽셀 아트 UI)
- Mipmaps: On (3D), Off (UI)
- BPTC Compression: On (타깃이 데스크톱일 때)
- Fix Alpha Border: On (알파 있는 텍스처)
```

### 오디오 (.wav, .ogg)
```
- SFX (1초 미만): .wav, Loop=Off
- SFX (1~5초): .ogg, Quality=0.5
- BGM: .ogg, Loop=On, Loop Begin 지정
```

**Evaluator 검증:** 각 에셋의 `.import` 파일이 위 규칙을 따르는지 `godot-mcp-protocol`의 Fallback B(텍스트 읽기)로 확인.

## Placeholder → 실제 에셋 교체 스프린트

기능 스프린트가 모두 끝난 후 또는 주기적으로:

### "Polish Sprint" 형식
- 범위: `_placeholder` 접미사 또는 `pl_` 접두사 에셋 전체
- AC: 모든 placeholder가 단계 2 이상으로 교체됨, manifest.md 갱신됨
- 기능 변경 금지 — 외형만 교체
- Evaluator: 기존 기능 AC 회귀 없음 + 시각 스크린샷 비교 (before/after)

## 이 스킬을 참조하는 주체

- `planner` 에이전트 — 스프린트 경계 그을 때 "에셋 교체 스프린트"를 별도로 배치
- `generator` 에이전트 — 새 노드/리소스 생성 시 단계 1부터 순서대로 시도
- `evaluator` 에이전트 — manifest.md 존재·라이선스 기록 검증
- `godot-scene-handoff` 스킬 — S{M}-generator.md에 사용한 에셋 소스 단계 기록
- `godot-mcp-protocol` 스킬 — import 설정 편집 시 fallback 경로 선택

## 변경 이력

| 날짜 | 변경 | 사유 |
|------|------|------|
| 2026-04-16 | 초안 | Build Harness Godot 전환, 에셋 폴백 체계 도입 |
