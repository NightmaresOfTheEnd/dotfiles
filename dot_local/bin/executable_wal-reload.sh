#!/usr/bin/env bash
# Reload pywal colors on login (called from hyprland autostart)
# This script restores cached colors without regenerating them
# If no cached colors exist, generates from X_* wallpaper

set -euo pipefail

WALLPAPER_DIR="${HOME}/Pictures/wallpapers"
STATE_FILE="${HOME}/.cache/current_theme_mode"
CONFIG_DIR="${HOME}/.config"
CACHE_DIR="${HOME}/.cache/wal"

# Find X_* wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f -name "X_*" 2>/dev/null | head -n 1 || true)
CURRENT_MODE="dynamic"

if [[ -f "$STATE_FILE" ]]; then
    CURRENT_MODE=$(cat "$STATE_FILE")
fi

# If no cached colors, generate based on mode
if [[ ! -f "${CACHE_DIR}/colors.sh" ]]; then
    if [[ "$CURRENT_MODE" == "default" ]] && command -v wal &> /dev/null; then
        wal --theme cyberpunk -n -s -t -e
    elif [[ -n "$WALLPAPER" ]] && command -v wal &> /dev/null; then
        wal -i "$WALLPAPER" -n -s -t -e
    fi
fi

# Update hyprpaper.conf with X_* wallpaper (always used as base wallpaper)
if [[ -n "$WALLPAPER" ]]; then
    echo "preload = $WALLPAPER" > "${CONFIG_DIR}/hypr/hyprpaper.conf"
    echo "wallpaper = ,$WALLPAPER" >> "${CONFIG_DIR}/hypr/hyprpaper.conf"
fi

# Source cached colors if they exist (for shell variables)
if [[ -f "${CACHE_DIR}/colors.sh" ]]; then
    # shellcheck source=/dev/null
    source "${CACHE_DIR}/colors.sh"
fi

# ============================================
# Ensure generated configs are in place
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

exit 0
