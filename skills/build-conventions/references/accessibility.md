# Accessibility Conventions

**상태:** 정적 레퍼런스 (플러그인 유지보수자만 수정)
**최종 수정:** -
**수정 이력:**
| 날짜 | 변경 | 사유 |
|------|------|------|
| - | - | - |

## 적용 범위

UI가 있는 스프린트. 백엔드 전용 Feature에서는 "해당 없음".

## 채우기 가이드

WCAG 2.1 AA를 기본 목표로 삼되, 실제 검증 가능한 항목만 규칙화한다. "친화적인 UI" 같은 주관 규칙은 넣지 않는다.

### 카테고리 체크리스트
- [ ] **시맨틱 마크업**: 의미 있는 태그 사용 (button, nav, main 등), div/span 남용 금지
- [ ] **키보드 조작**: Tab 순서, Focus 표시, 모든 기능 키보드만으로 접근 가능
- [ ] **스크린 리더**: aria-label, aria-describedby, alt 텍스트
- [ ] **대비(contrast)**: 텍스트 4.5:1, 큰 텍스트 3:1
- [ ] **폼 접근성**: label 연결, 에러 메시지 aria-live
- [ ] **모션/애니메이션**: `prefers-reduced-motion` 대응

## 검증 도구 (참고)

- `axe-core` (자동화)
- Lighthouse Accessibility 스코어
- 수동: 키보드만으로 flow 재현, 스크린리더(VoiceOver/NVDA) 스팟 체크

## 규칙

<!-- 규칙을 아래 포맷으로 채운다. 예시는 Planner가 프로젝트에 맞게 대체. -->

### (예시) R1. 모든 대화형 요소는 키보드 접근 가능
- **선언:** `onClick`이 있는 `<div>`/`<span>` 금지. `<button>` 또는 적절한 role + tabindex + 키 이벤트.
- **검증:** `rg "onClick" src/ --type tsx` 결과의 각 위치가 button/a/input 중 하나인지 수동 확인, 또는 린트 규칙(`jsx-a11y/click-events-have-key-events`) 0건
- **예외:** 장식 전용 요소로 aria-hidden="true" + tabindex=-1 명시 시
- **위반 시 판정:** FAIL

### (예시) R2. 이미지는 alt 속성 필수
- **선언:** `<img>`에 `alt` 속성이 반드시 있어야 한다. 장식용이면 `alt=""`.
- **검증:** `rg "<img(?![^>]*\\balt=)" src/`가 0건
- **예외:** 없음
- **위반 시 판정:** FAIL

<!-- 위 예시는 참고용. Planner가 채우면 "(예시)" 블록 삭제. -->
