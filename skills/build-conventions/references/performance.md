# Performance Conventions (Godot 4 게임)

**상태:** 정적 레퍼런스 (플러그인 유지보수자만 수정)
**적용 범위:** 모든 스프린트. 단, 성능 예산은 스프린트 특성에 따라 달라진다.

본 파일의 기본 규칙은 `SKILL.md`의 "performance.md (게임 버전)" 섹션 R1~R5(타깃 FPS/Draw call/메모리/씬 로드/LOD)를 따른다. 본 파일은 프로젝트별 추가 규칙을 채우는 슬롯이다.

## 채우기 가이드

"빠르게 해라" 같은 문장 금지. **수치 예산(budget)**과 **측정 방법**을 함께 명시한다. 측정은 `scenes/__bench/` 하위 벤치 씬을 헤드리스 실행하여 수행.

### 카테고리 체크리스트
- [ ] **FPS:** 타깃·하한 (PC/모바일 분기)
- [ ] **렌더 부하:** Draw call, vertices, fragment 비용
- [ ] **메모리:** 정적/동적 한도, 누수 감지 정책
- [ ] **씬 로드:** 첫 진입·레벨 전환 시간 상한
- [ ] **LOD/Culling:** 거리·시야 기반 정책
- [ ] **에셋 import:** 텍스처 해상도·압축, 모델 폴리곤 한도

## 측정 도구 (Godot 4)
- `Performance.get_monitor(...)` (FPS·드로콜·메모리)
- `godot --headless --quit-after N scenes/__bench/...` (자동화 벤치)
- 에디터 Profiler / Visual Profiler (수동 분석)
- 로그 기반 명시적 assertion (`assert(fps >= 60, ...)`)

## 규칙

<!-- Planner가 채운다. SKILL.md "performance.md (게임 버전)" R1~R5와 중복되지 않게. -->

### (예시) RP1. 텍스처 해상도 상한
- **선언:** import 후 텍스처 해상도 ≤ 2048×2048 (PC), ≤ 1024×1024 (모바일). 초과 시 import 설정에서 다운스케일.
- **검증:** `.import` 파일의 `compress/lossy_quality` + 결과 텍스처 크기 확인 스크립트.
- **위반 시 판정:** WARN

### (예시) RP2. Physics body 동시 활성 한도
- **선언:** 한 씬에서 동시에 활성화된 RigidBody/CharacterBody 합계 ≤ 50 (PC), ≤ 20 (모바일). 초과 시 풀링 또는 sleep.
- **검증:** 벤치 씬 실행 후 `get_tree().get_nodes_in_group("physics")` 카운트 로그.
- **위반 시 판정:** FAIL

<!-- 위 예시는 참고용. Planner가 채우면 "(예시)" 블록 삭제. -->
