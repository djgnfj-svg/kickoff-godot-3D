# Godot MCP Capability Matrix

**MCP 서버:** bradypp/godot-mcp (v0.1.0)
**Godot 버전:** 4.6.1-stable
**최종 갱신:** 2026-04-16

## 지원 기능 (CAN DO)

| 카테고리 | 도구 | 설명 | 상태 |
|----------|------|------|------|
| **시스템** | `get_godot_version` | Godot 버전 조회 | OK |
| **프로젝트** | `launch_editor` | Godot 에디터 실행 | OK |
| | `run_project` | 디버그 모드 실행 + 출력 캡처 | OK |
| | `stop_project` | 실행 중 프로젝트 중지 | OK |
| | `get_debug_output` | 콘솔 출력/에러 조회 | OK |
| | `list_projects` | 디렉토리 내 프로젝트 탐색 | OK |
| | `get_project_info` | 프로젝트 메타데이터 조회 | OK |
| **씬 관리** | `create_scene` | 루트 노드 타입 지정 씬 생성 | OK |
| | `add_node` | 씬에 노드 추가 + 속성 설정 | OK |
| | `edit_node` | 노드 속성 수정 (위치/스케일/텍스처 등) | OK |
| | `remove_node` | 노드 제거 | OK |
| | `load_sprite` | Sprite2D에 텍스처 로드 | OK |
| | `export_mesh_library` | 3D 씬 → MeshLibrary 변환 | OK |
| | `save_scene` | 씬 복사/버전 관리 | OK |
| **UID** | `get_uid` | 리소스 UID 조회 (4.4+) | OK |
| | `update_project_uids` | UID 참조 갱신 | OK |

## 미지원 기능 (CANNOT DO)

| 카테고리 | 필요 기능 | Fallback |
|----------|----------|----------|
| **3D 모델링** | 메시 생성/편집 | Blender MCP 또는 placeholder primitive |
| **셰이더** | 비주얼 셰이더 편집 | `.gdshader` 텍스트 직접 편집 |
| **애니메이션** | AnimationPlayer 키프레임 | `.tscn` 텍스트 편집 또는 사용자 위임 |
| **물리** | 물리 레이어 자동 설정 | `project.godot` 텍스트 편집 |
| **입력맵** | InputMap 설정 | `project.godot` 텍스트 편집 |
| **자동로드** | Autoload 등록 | `project.godot` 텍스트 편집 |
| **GDExtension** | 네이티브 플러그인 | 사용자 위임 |
| **테스트** | GUT/GdUnit4 실행 | `godot --headless --script` CLI |

## 3단계 Fallback 순서

1. **Godot MCP** — 위 "지원 기능" 테이블 내에 있으면 MCP로 실행
2. **godot --headless CLI** — `godot --headless --script res://script.gd` 로 자동화
3. **텍스트 직접 편집** — `.tscn`/`.tres`/`.gd`/`project.godot` 파일을 직접 편집
4. **사용자 위임** — 위 3가지로 불가능한 경우 사용자에게 안내
