---
name: kickoff-docs
description: 3D 게임(Godot 4) Kickoff 3대 문서(why.md / what.md / how.md)의 표준 템플릿과 작성 규칙. Scribe가 팀 합의를 문서로 정리할 때 반드시 이 스킬을 사용하며, 어떤 섹션이 필수이고 어떤 표현이 금지되는지 정의한다. "킥오프 문서 작성", "why/what/how 템플릿", "게임 기획 문서", "게임 제품 정의 문서", "코어루프 문서화", "3층 훅 문서" 요청에 트리거.
---

# Kickoff Docs — 3D 게임(Godot 4) 3대 문서 템플릿

세 문서는 서로 다른 질문에 답한다. 섞이지 않게 한다. 본 하네스는 **2D/3D Godot 4 게임 전용**이며, 모든 문서의 첫 줄은 `**프로젝트 종류:** {2D|3D} 게임 (Godot 4)` 로 시작한다 (차원은 `_meta.md` `project_type` 값으로 치환).

| 문서 | 답하는 질문 | 주요 독자 |
|------|------------|----------|
| why.md | 왜 이 게임을 만드는가 | 팀, 퍼블리셔, 미래의 자신 |
| what.md | 무엇을 만드는가 (코어 버브·코어루프·시스템) | 팀, 디자이너, PD |
| how.md | 어떻게 만드는가 (Godot 4 기술·마일스톤) | 엔지니어, Reviewer |

## 공통 규칙

1. **모호한 단어 금지:** "재미있다", "몰입감 있는", "많은", "쉬운" 대신 측정 가능한 기술. 예: "재미있다" 대신 "60분 세션에서 코어 버브 100회 이상 발동, Day-1 Retention 30%+".
2. **가설은 가설로 표시:** "X이다" 대신 "가설: X. 검증 방법: Y".
3. **1플레이어 원형·1코어 결핍·1코어 버브 원칙 위반 금지.** Niche Enforcer(`niche-enforcer` 에이전트(§통합 프로토콜)의 게임 테이블 참조)의 승인 없이 확장 금지.
4. **세 문서의 일관성:** why의 플레이어 원형 = what의 대상 유저 = how의 타깃 플랫폼/입력 가정. why의 코어 결핍 = what의 코어 버브가 해소하는 감정. 불일치 시 QA가 거부한다.
5. **모든 외부 사실 주장에는 각주를 단다.** 수치·경쟁작·Steam 리뷰·동시접속자·유사 게임 리뷰 패턴 등 "검증 가능한 사실" 문장 끝에 `[^n]`을 붙이고, 문서 하단 `## 근거 (Sources)` 섹션에 대응 항목을 채운다. 팀 내부 합의·가설·의견은 각주 대상이 아니다.
6. **프로젝트 종류 헤더 의무:** 모든 문서 첫 줄에 `**프로젝트 종류:** {2D|3D} 게임 (Godot 4)` 명시 (`_meta.md` 값으로 치환).

### 각주 규칙
- **형식:** 본문 `... 동시접속자 피크 3,200명[^1] ...` → 하단 `[^1]: {제목/요지} — {출처}` 형태.
- **출처 표기:**
  - 내부 문서 참조: `_workspace/research_memo.md §2.A` (섹션 번호까지)
  - 외부 URL: `https://... (접근 2026-04-16)` (접근 날짜 필수)
  - 플레이 영상: `YouTube {제목} — {URL} @ {타임스탬프} (접근 YYYY-MM-DD)`
  - 팀원 인터뷰/플레이어 원문: `Founder 원문 (2026-04-16)` 또는 `플레이테스트 — {이름 또는 가명} (2026-04-16)`
- **금지:**
  - URL만 달랑 남기기 (무엇에 대한 출처인지 제목 필수)
  - Steam 리뷰 캡처 없이 "유저들이 불만" 주장
  - research_memo 한 줄만 가리키고 섹션 번호 생략
  - 내부 합의 사항에 각주 달기
- **연속성:** 같은 출처가 여러 번 쓰이면 같은 번호 재사용.

---

## why.md 템플릿

```markdown
**프로젝트 종류:** {2D|3D} 게임 (Godot 4)

# Why

## 한 줄 카피
{플레이어 원형 + 코어 버브 + 감정적 결과. 차원별 어휘·예시는 `references/{2d,3d}.md` (`docs/kickoff/_meta.md`의 `project_type`에 따라 로드)}

## 대상 플레이어 (1플레이어 원형)
- **원형:** {연령대·플레이 세션 길이·플랫폼·게임 경험 중 최소 3개 — 예: "30대 직장인, 퇴근 후 90분 저녁 세션, Steam PC, FromSoftware 작품 전작 클리어"}
- **왜 이 게임을 계속 여는가:** {기대하는 감정 1개 — 긴장 해소 / 탐험 충동 / 성취감 / 사회적 연결 / 표현 욕구 중 하나}
- **비-대상:** {혼동하기 쉬운 인접 원형 중 제외 — 예: "캐주얼 파티 게이머는 대상 아님"}

## 해결할 결핍 (1코어 결핍)
- **감정:** {이 원형이 현 시장에서 못 채우는 감정 1개}[^n]
- **왜 못 채워지나:** (a) 장르가 비어 있음 / (b) 있지만 UX가 나쁨 / (c) 있지만 접근성·가격 장벽 중 하나[^n]
- **증거:** 유사 게임 Steam 리뷰에서 반복되는 불만 패턴 2~3개 (원문 인용 + URL)[^n]

## 코어 버브 (1코어 버브)
- **동사:** {한 단어. 차원별 코어 버브 예시는 `references/{2d,3d}.md` 참조}
- **60분 세션 내 발동 목표:** {횟수, 예: "100회 이상"}
- **Time-to-First-Verb 목표:** 신규 플레이어가 게임 시작 후 코어 버브 첫 성공까지 {3분 이내 권장}

## 3층 훅 요약
hook-design-protocol의 3층을 한 문단씩 요약:
- **0.5초 훅 (캡슐 이미지):** {스크롤 중 멈추게 만드는 단일 비주얼 언어}
- **5초 훅 (트레일러 첫 5초):** {플레이 영상이 시작되자마자 전달되는 코어 버브 프루프}
- **30초 훅 (스트리머 클립):** {방송에서 "이거 뭐야" 반응이 터지는 순간}

## 왜 지금, 왜 우리
- **왜 지금:** {엔진·입력·플랫폼·청중 변화 근거}[^n]
- **왜 우리:** {팀이 이 장르/감정을 설계할 수 있는 고유 역량 — 경험·선호·기술 스택}

## 성공의 정의 (North Star)
단일 게임 지표 1개를 숫자와 함께 명시:
- 출시 후 3개월 내 누적 플레이어 수 (Steam 다운로드) / **or**
- Day-1 Retention {%} / **or**
- Median Session Length {분} / **or**
- Steam Review Score {긍정 %} / **or**
- Wishlist → Day-1 Conversion {%}

## 명시적 비-목표
- {하지 않을 것들. Niche Enforcer가 거부한 항목을 여기에 기록 — 추가 장르, 멀티, 추가 플랫폼 등}

## Open Questions
- {Sellability Auditor의 Pre-mortem 중 미해결 항목}

## 근거 (Sources)
<!-- 본문 [^n] 각주에 대응. 최소 "결핍·증거·왜 지금·North Star 기준치" 4개 항목은 근거가 있어야 한다. -->
[^1]: {주제/한 줄 요지} — `_workspace/research_memo.md §X.X` 또는 `https://... (접근 YYYY-MM-DD)`
[^2]: ...
```

## what.md 템플릿

```markdown
**프로젝트 종류:** {2D|3D} 게임 (Godot 4)

# What

## 한 문장 요약
{이 게임에서 플레이어가 가장 자주 하는 동사 1개 + 그 동사의 감정적 결과}

## 대상 플레이어
{why.md의 1플레이어 원형과 완전히 동일}

## 코어 버브 + 코어루프 (1Action)
- **코어 버브:** {why.md와 동일}
- **60분 세션 내 버브 발동 목표:** {why.md와 동일}
- **코어루프 4단계** (game-design-loop 스킬 참조):
  1. **Anticipation:** {플레이어가 "뭘 할 수 있지?"를 인지하는 순간 — 예: "적 위치·약점 식별, 패턴 학습"}
  2. **Action:** {코어 버브 수행 — 예: "타이밍 맞춰 베기 입력"}
  3. **Feedback:** {감각 피드백 — 예: "참격 이펙트 + 타격음 + 체력바 변화 + 히트스톱 0.15s"}
  4. **Progress:** {다음 루프 트리거 — 예: "경험치 획득 + 다음 적 접근 + 환경 변화"}
- **한 루프 목표 소요:** {15초~3분 권장}

## 게임 메타 정보
- **장르:** {1개 확정 — 서브장르는 괄호로, 예: "액션 RPG (소울라이크)"}
- **플랫폼:** {MVP 플랫폼 1개 — 예: "Steam PC"}
- **플레이 시간 예상:** {10시간 이하 / 10~30시간 / 30시간+ 중 하나}
- **시점/카메라:** {차원별 시점 어휘는 `references/{2d,3d}.md` 참조}
- **멀티 여부:** {솔로 전용 / 코옵 / PvP — MVP는 솔로 권장}

## Features (우선순위) — 게임 시스템 단위
각 Feature는 **반드시 코어루프 4단계 중 최소 1개를 지탱/확장**해야 한다. 무관 Feature는 거부된다.

### F1. {시스템 이름 — 예: "플레이어 이동 & 카메라 시스템"}
- **설명:** {한 문장 — 코어 버브와의 관계 명시}
- **코어루프 기여:** Anticipation | Action | Feedback | Progress (복수 선택 가능, 최소 1개 필수)
- **수용 기준:**
  - [ ] {검증 가능한 기준 — 예: "WASD 입력 → 캐릭터 이동 시작까지 100ms 이내"}
  - [ ] ...
- **우선순위:** P0 | P1 | P2
- **비-범위:** {이 Feature가 "하지 않을 것"}

### F2. ...

## 보조 시스템 (코어루프 지원)
- {UI/HUD, 세이브/로드, 설정 메뉴, 옵션, 튜토리얼 등. 코어 버브를 추가하지 않는다}

## 플레이테스트 시나리오 3개
1. **Time-to-First-Verb 시나리오:** 신규 플레이어가 코어 버브 첫 성공까지 3분 이내 골든 패스
2. **실패 회복 시나리오:** 첫 죽음/실패 후 재도전 마찰 측정
3. **세션 엔드 시나리오:** 45~60분 지점에서 "다시 열고 싶은 끝" 구간 도달

## 명시적 비-목표 (이번 Kickoff 범위 밖)
- {로드맵으로 이동한 장르 요소 / 멀티 / 추가 플랫폼 / 포스트 론치 콘텐츠}

## 근거 (Sources)
<!-- Feature 우선순위나 수용 기준을 정한 근거(경쟁작 부재/플레이어 원형 피드백/Steam 리뷰 불만 패턴 등)가 외부 사실이면 각주로 연결한다. 팀 내부 판단은 각주 없이 본문에 적는다. -->
[^1]: {주제/한 줄 요지} — `_workspace/research_memo.md §X.X` 또는 `https://... (접근 YYYY-MM-DD)`
```

## how.md 템플릿

```markdown
**프로젝트 종류:** {2D|3D} 게임 (Godot 4)

# How

## 대상 플레이어 & 코어 버브 (확인)
{why/what과 동일한지 Scribe가 재확인 후 복사}

## 기술 스택 — Godot 4
| 층위 | 선택 | 이유 |
|------|-----|------|
| 엔진 | Godot **4.x.y** (정확한 minor·patch 명시) | 오픈소스·GDScript·경량 |
| 언어 | GDScript (1차) / C# (옵션) | Godot 1차 시민, 빠른 반복 |
| 렌더러 | **Forward+** / Mobile / Compatibility (택 1) | 타깃 플랫폼·그래픽 품질 기반 |
| 시점 | {차원별 시점 어휘는 `references/{2d,3d}.md` 참조} | why/what과 일치 |
| 에디터 작업 | `.tscn`/`.gd`/`.tres` 텍스트 직접 편집 + 시각 확인 사용자 위임 | Generator/Evaluator 자동화 |
| 테스트 | GUT 또는 GdUnit4 | GDScript TDD |
| 빌드/CI | `godot --headless --export` | 무인 빌드 |
| 에셋 소스 | `asset-pipeline` 2단계 폴백 체인 | placeholder-first |

## 입력 매핑 (InputMap)
ProjectSettings → InputMap 액션 이름을 미리 고정한다.
| Action | 기본 키 | 게임패드 | 설명 |
|--------|--------|---------|-----|
| move_forward | W | LS Up | 전진 |
| core_verb | 좌클릭 | RT | **코어 버브 트리거** |
| ... | ... | ... | ... |

## Physics Layers (번호 고정)
| Layer # | 이름 | 용도 |
|---------|-----|-----|
| 1 | World | 정적 지형 |
| 2 | Player | 플레이어 캐릭터 |
| 3 | Enemy | 적 |
| 4 | Hitbox | 데미지 판정 |
| ... | ... | ... |

## 시스템 아키텍처 (씬 그래프 고수준)
{루트 씬 + 주요 하위 씬 + Autoload 목록. `godot-scene-handoff` 스킬의 표준 레이아웃 참조. Autoload는 4개 이하로 제한 권장.}

## 데이터 모델 (핵심 Resource)
- **PlayerState** (체력·스태미나·위치) — Resource
- **EnemyData** — Resource
- **SaveData** (포맷: JSON / 바이너리 — 택 1)
- **GameConfig** — Resource

## 에디터 작업 방식
- `.tscn`/`.gd`/`.tres` 텍스트 직접 편집
- `godot --headless --import` smoke로 import 검증
- 시각 확인·복잡 에셋 import는 사용자 위임 (Godot 에디터에서 직접)

## 에셋 정책
- **1차:** Godot 내장 primitive / ColorRect (placeholder)
- **2차:** 사용자 위임 (외부 에셋 라이선스 포함 manifest 기록)
- 모든 에셋은 `docs/build/F{N}/assets/manifest.md`에 라이선스 기록
- `asset-pipeline` 스킬 참조

## 성능 타깃
- **타깃 FPS:** {60fps (PC) / 90fps (VR) / 30fps (모바일)} — 하나 확정
- **타깃 하드웨어:** {최소 사양 예: "GTX 1060, 16GB RAM, SSD"}
- **Frame budget:** {16.7ms (60fps) / 11.1ms (90fps)}
- **Draw call 상한:** {대략적 상한}

## 마일스톤

**M0는 2단계 필수 (환경 검증 → Walking Skeleton).** M0a를 코드 0줄로 선행하여 Godot 환경이 먼저 돌아가는지 확인한 뒤에만 M0b로 넘어간다.

| M | 기간 | 산출물 | 완료 조건 |
|---|-----|-------|----------|
| **M0a** | 0.5~1일 | 환경 검증 (코드 0줄) | ① 빈 Godot 프로젝트 생성 + `godot --headless --import` 성공 ② Smoke 씬(빈 씬) `godot --headless --quit-after 5` 실행 → 종료코드 0 + 에러 로그 0 |
| **M0b** | 1~2주 | Walking Skeleton | 플레이어가 게임 공간에서 **코어 버브 1회** 수행 가능 (primitive 에셋, smoke 씬 headless 통과). 차원별 Walking Skeleton 구체 예시는 `references/{2d,3d}.md` 참조 |
| **M1** | ... | 코어루프 닫힘 | 4단계 루프 한 사이클 완주 + TTFV 3분 이내 + headless smoke + 60fps 유지 |
| **M2** | ... | F{N} 완성 | 해당 Feature 수용 기준 전부 통과 + 플레이테스트 시나리오 3개 통과 |

**M0a가 실패하면 M0b 진입 불가.** Godot CLI 환경이 안 돌면 코드 작성해도 검증 경로가 없다. 환경 문제는 사용자 에스컬레이션.

## 테스트 전략
- **Smoke (필수):** `godot --headless --quit-after 5 scenes/__dev/smoke.tscn` 종료코드 0 + 에러 로그 0
- **단위 (GUT/GdUnit4):** 핵심 유틸·데미지 계산·상태 머신 전이
- **통합:** 씬 헤드리스 실행 → 종료코드·로그 검증
- **시각 회귀:** 사용자 위임 (Godot 에디터에서 직접)
- **플레이테스트:** 플레이테스트 시나리오 3개 (what.md 정의)

## 관측성
- **지표:** Time-to-First-Verb, Verbs-per-Minute, Loop Duration, Session Length, Day-1 Retention
- **로깅:** 크래시 리포트, 런타임 에러, FPS 드롭 이벤트, 입력 지연
- **수집:** 로컬 JSON 로그 (오프라인 빌드) 또는 Sentry/분석 서비스 연동

## 주요 실패 모드
| 실패 | 감지 | 복구 |
|-----|-----|-----|
| 씬 실행 크래시 | headless smoke 실패 | Evaluator FAIL → Generator 재시도 |
| 타깃 FPS 미달 | 벤치 씬 FPS 측정 | Draw call 감축·LOD·occlusion 검토 |
| 입력 데드존/지연 | 플레이테스트 관찰 | 감도·데드존·응답 곡선 조정 |
| 세이브 호환성 | 버전 태그 검증 | 마이그레이션 스크립트 또는 초기화 |
| Import 실패 | godot --headless import 로그 | 리소스 포맷·경로 수정 |

## 팀 & 역량 매칭
- {누가 Godot 4 경험 보유, 누가 GDScript 신규, 3D 에셋 담당, 어떤 학습이 필요한가}
- **GDScript 학습 일정:** 미경험자가 있다면 {기간} 내 {목표 수준}

## Steam 출시 일정 (해당 시)
- Wishlist 오픈: {날짜}
- Early Access 여부: {예/아니오}
- 1.0 출시: {날짜}

## Open Questions / Risks
- 에셋 조달 (사용자가 어디까지 책임지는가)
- 타깃 FPS 달성 가능성 (씬 복잡도에 따라)
- {Sellability Auditor가 제기한 Pre-mortem 중 미해결}

## 근거 (Sources)
<!-- 기술 선택 근거(Godot 4 벤치마크/공식 문서), 유사 게임 기술 스택 사례, 성능 수치에 각주. 팀 내부 선호는 각주 없이 "이유" 칸에 직접. -->
[^1]: {주제/한 줄 요지} — `https://... (접근 YYYY-MM-DD)` 또는 `_workspace/research_memo.md §X.X`
```

---

## 작성 순서

Phase A는 **토론 중심**이다 — 7인 팀(founder / game-market-researcher / core-mechanic-designer / hook-strategist / sellability-auditor / niche-enforcer / scribe)이 why/what/how 3 토픽에 대해 사이클 3회를 돈다. 각 사이클 5단계:

1. **데이터**: game-market-researcher 1회 발화 (해당 토픽 관련 경쟁작·Steam 지표)
2. **1차 발화**: core-mechanic-designer, hook-strategist, sellability-auditor 각자 독립 발화
3. **충돌 1회차**: 자유 토론 (누구든 누구에게나 반박), founder가 중재
4. **충돌 2회차**: 재반박/방어 — 각자 주장 보완 또는 철회
5. **수렴**: niche-enforcer veto 판정 + scribe가 해당 토픽 문서 섹션 작성

토픽 순서:
1. **why.md** — 플레이어 원형·코어 결핍·한 줄 카피·3층 훅·North Star
2. Niche Enforcer 판정 통과 대기
3. **what.md** — 코어 버브·코어루프·Features·플레이테스트 시나리오
4. Niche Enforcer 판정 통과 대기
5. **how.md** — Godot 기술·Physics Layers·InputMap·마일스톤
6. Niche Enforcer 판정 통과 대기
7. Reviewer 팀(build-auditor/qa)에게 how.md 전달

Niche Enforcer 거부 시 해당 문서만 고쳐서 재판정. 다른 문서는 그대로 유지.

## 게임 프로젝트 일관성 체크 (QA용)

- why의 플레이어 원형 = what의 대상 플레이어 = how의 타깃 플랫폼·입력 가정
- why의 코어 결핍 = what의 코어 버브가 해소하는 감정
- what의 F1~FN **모두** 코어루프 4단계 중 하나 이상 지탱 (무관 Feature 금지)
- how의 **M0a 완료 조건 = 환경 검증(`godot --headless --import` 종료코드 0 + smoke 씬 헤드리스 실행 성공)** + **M0b 완료 조건 = 코어 버브 1회 수행 가능** 둘 다 필수 포함
- why의 한 줄 카피 = 3층 훅 중 5초 훅의 요약과 정렬
- what의 장르·플랫폼·시점이 how의 렌더러·InputMap·Physics Layers와 정합
