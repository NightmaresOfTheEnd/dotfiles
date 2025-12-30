#!/usr/bin/env bash
# Toggle between Default (Cyberpunk) and Dynamic (Wallpaper) themes
# Usage: toggle-theme.sh

set -euo pipefail

STATE_FILE="${HOME}/.cache/current_theme_mode"
DEFAULT_WALLPAPER_PATTERN="X_*"
WALLPAPER_DIR="${HOME}/Pictures/wallpapers"
CONFIG_DIR="${HOME}/.config"
CACHE_DIR="${HOME}/.cache/wal"

# Check for required commands
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: $1 is not installed" >&2
        return 1
    fi
}

check_command wal || exit 1
check_command notify-send || echo "Warning: notify-send not found, notifications disabled" >&2

# Ensure state file exists
if [[ ! -f "$STATE_FILE" ]]; then
    echo "dynamic" > "$STATE_FILE"
fi

CURRENT_STATE=$(cat "$STATE_FILE")

if [[ "$CURRENT_STATE" == "dynamic" ]]; then
    echo "Switching to Default (Cyberpunk) theme..."

    # 1. Apply Cyberpunk colors (using pywal backend)
    wal --theme cyberpunk -n -s -t -e

    # 2. Update state
    echo "default" > "$STATE_FILE"

    # 3. Notify user
    command -v notify-send &> /dev/null && notify-send "Theme" "Switched to Default (Cyberpunk)"

elif [[ "$CURRENT_STATE" == "default" ]]; then
    echo "Switching to Dynamic (Wallpaper) theme..."

    # 1. Find current wallpaper (from hyprpaper config or X_* default)
    WALLPAPER=""
    if [[ -f "${CONFIG_DIR}/hypr/hyprpaper.conf" ]]; then
        WALLPAPER=$(grep "wallpaper =" "${CONFIG_DIR}/hypr/hyprpaper.conf" | cut -d',' -f2 | xargs || true)
    fi

    if [[ -z "$WALLPAPER" || ! -f "$WALLPAPER" ]]; then
        WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f -name "$DEFAULT_WALLPAPER_PATTERN" 2>/dev/null | head -n 1 || true)
    fi

    if [[ -f "$WALLPAPER" ]]; then
        wal -i "$WALLPAPER" -n -s -t -e
        echo "dynamic" > "$STATE_FILE"
        command -v notify-send &> /dev/null && notify-send "Theme" "Switched to Dynamic Mode"
    else
        command -v notify-send &> /dev/null && notify-send "Theme Error" "No wallpaper found to generate colors from."
        exit 1
    fi
fi

# ============================================
# Re-apply templates (Standard wal-set.sh logic)
# ============================================

# Foot terminal
if [[ -f "${CACHE_DIR}/colors-foot.ini" ]]; then
    cp "${CACHE_DIR}/colors-foot.ini" "${CONFIG_DIR}/foot/colors.ini"
fi

# Waybar
if [[ -f "${CACHE_DIR}/colors-waybar.css" ]]; then
    cp "${CACHE_DIR}/colors-waybar.css" "${CONFIG_DIR}/waybar/colors-waybar.css"
fi

# Hyprland colors
if [[ -f "${CACHE_DIR}/colors-hyprland.conf" ]]; then
    cp "${CACHE_DIR}/colors-hyprland.conf" "${CONFIG_DIR}/hypr/colors.conf"
fi

# Rofi
if [[ -f "${CACHE_DIR}/colors-rofi.rasi" ]]; then
    cp "${CACHE_DIR}/colors-rofi.rasi" "${CONFIG_DIR}/rofi/colors.rasi"
fi

# Mako
if [[ -f "${CACHE_DIR}/colors-mako.conf" ]]; then
    cp "${CACHE_DIR}/colors-mako.conf" "${CONFIG_DIR}/mako/config"
fi

# Hyprlock
if [[ -f "${CACHE_DIR}/colors-hyprlock.conf" ]]; then
    cp "${CACHE_DIR}/colors-hyprlock.conf" "${CONFIG_DIR}/hypr/hyprlock.conf"
fi

# wlogout
if [[ -f "${CACHE_DIR}/colors-wlogout.css" ]]; then
    cp "${CACHE_DIR}/colors-wlogout.css" "${CONFIG_DIR}/wlogout/style.css"
fi

# ============================================
# Reload components
# ============================================

# Reload Hyprland (triggers color update)
if command -v hyprctl &> /dev/null; then
    hyprctl reload &>/dev/null || true
fi

# Restart waybar
if pgrep -x waybar > /dev/null 2>&1; then
    pkill -x waybar || true
    sleep 0.2
    waybar &>/dev/null &
    disown
fi

# Reload mako
if command -v makoctl &> /dev/null; then
    makoctl reload &>/dev/null || true
fi

echo "Theme toggle complete!"
