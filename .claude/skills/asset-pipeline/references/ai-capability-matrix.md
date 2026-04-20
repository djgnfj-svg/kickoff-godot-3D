# AI Asset Capability Matrix

**최종 갱신:** 2026-04-16

## Blender MCP (ahujasid/blender-mcp v1.5.6)

| 카테고리 | 기능 | 상태 | 비고 |
|----------|------|------|------|
| **오브젝트** | 기본 도형 생성 (큐브/구/실린더/평면) | OK | |
| | 오브젝트 변환 (위치/회전/스케일) | OK | |
| | 오브젝트 삭제 | OK | |
| **머티리얼** | PBR 머티리얼 생성/적용 | OK | |
| | 색상/금속성/거칠기 설정 | OK | |
| **모디파이어** | Subdivision/Bevel 등 적용 | OK | Python 코드 실행 방식 |
| **렌더링** | 씬 렌더링 → 이미지 저장 | OK | |
| **Export** | glTF 2.0 (.glb) 내보내기 | OK | Godot 호환 |
| | OBJ 내보내기 | OK | |
| **복잡 모델링** | 캐릭터/유기체 모델링 | 제한적 | Python 스크립트로 가능하나 품질 보장 어려움 |
| | UV 언래핑 | 제한적 | 자동 UV만 가능 |
| **텍스처링** | 텍스처 페인팅 | 불가 | 사용자 위임 |
| **리깅** | 본/스켈레톤 설정 | 제한적 | Python 가능하나 복잡 |
| **애니메이션** | 키프레임 애니메이션 | 제한적 | Python 가능하나 복잡 |

## 전제 조건

- **Blender 5.0** 사용 (실행 파일: `C:/Program Files/Blender Foundation/Blender 5.0/blender.exe`)
- Blender 실행 시 addon 자동 활성화 (startup script 설치 완료)
- 자동 실행: `.claude/scripts/ensure-running.sh blender`

## 4단계 에셋 폴백 체인

1. **Godot Primitive** — CSGBox3D, CSGSphere3D 등으로 placeholder
2. **무료 라이브러리** — Kenney, Quaternius, Godot Asset Library
3. **Blender MCP** — 기본 도형 조합 + 머티리얼 → glTF export → Godot import
4. **사용자 위임** — 복잡한 캐릭터/유기체 모델은 사용자가 직접 제작
