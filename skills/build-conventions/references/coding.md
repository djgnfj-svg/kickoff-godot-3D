# Coding Conventions (Godot 4)

**상태:** 정적 레퍼런스 (플러그인 유지보수자만 수정)
**적용 범위:** 모든 스프린트 (코드가 있는 모든 기능 단위)

본 파일의 기본 규칙은 `SKILL.md`의 "coding.md (게임 버전)" 섹션에서 정의된 R1~R7을 따른다. 본 파일은 프로젝트별 추가 규칙을 채우는 슬롯이다.

## 채우기 가이드

Planner가 첫 스프린트 직전에 아래 카테고리별로 추가 규칙(0~3개)을 채운다. Godot 4 공식 스타일 가이드와 사용자 프로젝트의 기존 컨벤션을 반영한다.

### 카테고리 체크리스트
- [ ] **씬 트리 구조:** 깊이 한도, 컴포넌트 분리 vs 납작 구조 정책
- [ ] **명명 규칙:** 추가 prefix/suffix 컨벤션 (예: `_ui_`, `_sys_`)
- [ ] **GDScript 패턴:** static typing 사용 강제 여부, `class_name` 등록 정책
- [ ] **시그널 vs 직접 호출:** 결합도 정책
- [ ] **에러 처리:** `push_error`/`push_warning`/`assert` 사용 기준
- [ ] **테스트:** GUT 또는 GdUnit4 선택, 테스트 파일 위치, 최소 커버리지

## 규칙

<!-- Planner가 채운다. SKILL.md "coding.md (게임 버전)" R1~R7과 중복되지 않게. -->

### (예시) RP1. static typing 강제
- **선언:** 신규 `.gd` 파일의 모든 함수 시그니처와 변수 선언에 타입 명시. `var x = 1` 금지, `var x: int = 1` 사용.
- **검증:** `godot --headless --check-only` 경고 0건.
- **예외:** for-loop 임시 변수.
- **위반 시 판정:** WARN

### (예시) RP2. class_name 등록 정책
- **선언:** 재사용되는 노드 타입(2회+ 인스턴스화)은 `class_name`으로 등록.
- **검증:** 동일 스크립트가 2개 이상 씬에서 ExtResource로 참조되는데 class_name 없으면 위반.
- **위반 시 판정:** WARN

<!-- 위 예시는 참고용. Planner가 채우면 "(예시)" 블록 삭제. -->
