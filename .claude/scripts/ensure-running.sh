#!/bin/bash
# Usage: ensure-running.sh [godot|blender|both]
# Checks if the target app is running, launches it if not.
# Portable: uses env vars or auto-detect. No hardcoded paths.

# --- Path resolution (env var > auto-detect) ---

find_godot() {
    if [[ -n "$GODOT_PATH" && -f "$GODOT_PATH" ]]; then
        echo "$GODOT_PATH"; return
    fi
    # Auto-detect: common Windows locations
    for p in \
        "$HOME/Desktop/godot_games/base_file"/Godot_v*_win64.exe \
        "$HOME/.aipe/godot"/Godot_v*_win64.exe \
        "/c/Program Files/Godot"/Godot_v*.exe \
        "$(which godot 2>/dev/null)"; do
        [[ -f "$p" ]] && echo "$p" && return
    done
    echo ""
}

find_blender() {
    if [[ -n "$BLENDER_PATH" && -f "$BLENDER_PATH" ]]; then
        echo "$BLENDER_PATH"; return
    fi
    # Auto-detect: common Windows locations (newest first)
    for p in \
        "/c/Program Files/Blender Foundation/Blender 5.0/blender.exe" \
        "/c/Program Files/Blender Foundation/Blender 4.5/blender.exe" \
        "/c/Program Files/Blender Foundation/Blender 4.4/blender.exe" \
        "$(which blender 2>/dev/null)"; do
        [[ -f "$p" ]] && echo "$p" && return
    done
    echo ""
}

# --- Process detection (Windows) ---

check_process() {
    local output
    output=$(tasklist //FI "IMAGENAME eq $1" 2>/dev/null)
    local name_no_ext="${1%.exe}"
    echo "$output" | grep -qi "$name_no_ext" 2>/dev/null
}

# --- Godot exe name detection ---

godot_exe_name() {
    local gpath="$1"
    basename "$gpath"
}

# --- Ensure functions ---

ensure_godot() {
    local gpath
    gpath=$(find_godot)
    if [[ -z "$gpath" ]]; then
        echo "[ERROR] Godot not found. Set GODOT_PATH env var or install Godot."
        return 1
    fi
    local exe_name
    exe_name=$(godot_exe_name "$gpath")
    if check_process "$exe_name"; then
        echo "[OK] Godot is already running"
    else
        echo "[LAUNCH] Starting Godot ($gpath)..."
        "$gpath" &
        echo "[OK] Godot launched"
    fi
}

ensure_blender() {
    local bpath
    bpath=$(find_blender)
    if [[ -z "$bpath" ]]; then
        echo "[ERROR] Blender not found. Set BLENDER_PATH env var or install Blender."
        return 1
    fi
    if check_process "blender.exe"; then
        echo "[OK] Blender is already running"
    else
        echo "[LAUNCH] Starting Blender ($bpath)..."
        "$bpath" &
        sleep 5
        echo "[OK] Blender launched (MCP addon auto-enabled via startup script)"
    fi
}

# --- Main ---

case "${1:-both}" in
    godot)   ensure_godot ;;
    blender) ensure_blender ;;
    both)    ensure_godot; ensure_blender ;;
    *)       echo "Usage: $0 [godot|blender|both]"; exit 1 ;;
esac
