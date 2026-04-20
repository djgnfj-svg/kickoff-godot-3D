#!/usr/bin/env bash
# Godot MCP 자동 sync + rebuild
#
# 동작:
#   1) ${CLAUDE_PLUGIN_ROOT}/mcp-servers/godot-mcp/ 의 소스와
#      ${CLAUDE_PLUGIN_DATA}/godot-mcp/ 의 이전 빌드를 비교
#   2) 차이가 있으면 소스 복사 + (package.json 변경 시) npm install + npm run build
#   3) .mcp.json 의 godot 서버는 ${CLAUDE_PLUGIN_DATA}/godot-mcp/build/index.js 를 실행
#
# 사용자 자체 업데이트 흐름:
#   - ${CLAUDE_PLUGIN_ROOT}/mcp-servers/godot-mcp/src/... 편집
#   - 새 Claude Code 세션 → 이 훅이 자동으로 재빌드
#
# 조용히 실패해도 세션은 계속되어야 하므로 set -e 는 쓰지 않는다.

if [ -z "${CLAUDE_PLUGIN_ROOT}" ] || [ -z "${CLAUDE_PLUGIN_DATA}" ]; then
  # 플러그인 컨텍스트가 아니면 skip
  exit 0
fi

SRC="${CLAUDE_PLUGIN_ROOT}/mcp-servers/godot-mcp"
DST="${CLAUDE_PLUGIN_DATA}/godot-mcp"

if [ ! -d "$SRC" ]; then
  echo "[kickoff-godot-3d] 경고: godot-mcp 소스 없음: $SRC" >&2
  exit 0
fi

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "[kickoff-godot-3d] 경고: node/npm 없음. Godot MCP 빌드 스킵." >&2
  exit 0
fi

mkdir -p "$DST"

needs_rebuild=false
needs_npm_install=false

# 1) 초기 빌드 없음
if [ ! -f "$DST/build/index.js" ]; then
  needs_rebuild=true
fi

# 2) package.json 변경 → npm install + build
if ! diff -q "$SRC/package.json" "$DST/package.json" >/dev/null 2>&1; then
  needs_rebuild=true
  needs_npm_install=true
fi

# 3) src/ 변경 → build
if ! diff -rq "$SRC/src" "$DST/src" >/dev/null 2>&1; then
  needs_rebuild=true
fi

# 4) node_modules 없음 → npm install
if [ ! -d "$DST/node_modules" ]; then
  needs_rebuild=true
  needs_npm_install=true
fi

if [ "$needs_rebuild" = "false" ]; then
  exit 0
fi

echo "[kickoff-godot-3d] Godot MCP rebuilding..."

# 소스 동기화 (node_modules, build 는 보존)
rm -rf "$DST/src" "$DST/scripts" 2>/dev/null
cp -r "$SRC/src" "$DST/src" || { echo "[kickoff-godot-3d] src 복사 실패" >&2; exit 0; }
[ -d "$SRC/scripts" ] && cp -r "$SRC/scripts" "$DST/scripts"
cp "$SRC/package.json" "$DST/package.json"
cp "$SRC/tsconfig.json" "$DST/tsconfig.json" 2>/dev/null
[ -f "$SRC/package-lock.json" ] && cp "$SRC/package-lock.json" "$DST/package-lock.json"

cd "$DST" || exit 0

if [ "$needs_npm_install" = "true" ]; then
  npm install --silent --no-audit --no-fund 2>&1 | tail -5
fi

npm run build --silent 2>&1 | tail -10

if [ -f "$DST/build/index.js" ]; then
  echo "[kickoff-godot-3d] Godot MCP 빌드 완료 → $DST/build/index.js"
else
  echo "[kickoff-godot-3d] 경고: 빌드 결과물이 생성되지 않았습니다." >&2
fi
