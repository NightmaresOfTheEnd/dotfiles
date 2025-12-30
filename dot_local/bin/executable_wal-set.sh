#!/usr/bin/env bash
# Wallpaper setter with pywal integration - Stealth Cyberpunk Theme
# Usage: wal-set.sh [/path/to/wallpaper.jpg]
#
# If no argument provided, automatically finds wallpaper matching X_* pattern
# This script is the SINGLE SOURCE OF TRUTH for theming.
# One command updates: foot, waybar, rofi, mako, hyprlock, wlogout

set -euo pipefail

WALLPAPER_DIR="${HOME}/Pictures/wallpapers"
CONFIG_DIR="${HOME}/.config"
CACHE_DIR="${HOME}/.cache/wal"

# If argument provided, use it; otherwise find X_* wallpaper
if [[ -n "${1:-}" ]]; then
    WALLPAPER="$1"
else
    # Find wallpaper with X_* naming pattern
    WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f -name "X_*" 2>/dev/null | head -n 1 || true)

    if [[ -z "$WALLPAPER" ]]; then
        echo "Error: No wallpaper found matching 'X_*' pattern in $WALLPAPER_DIR" >&2
        echo "Usage: wal-set.sh [/path/to/wallpaper.jpg]" >&2
        echo "" >&2
        echo "Either:" >&2
        echo "  1. Rename your preferred wallpaper to start with 'X_' (e.g., X_dark_forest.jpg)" >&2
        echo "  2. Provide a wallpaper path as argument" >&2
        exit 1
    fi
fi

# Check if wallpaper exists
if [[ ! -f "$WALLPAPER" ]]; then
    echo "Error: Wallpaper not found: $WALLPAPER" >&2
    echo "Usage: wal-set.sh [/path/to/wallpaper.jpg]" >&2
    exit 1
fi

# Check if pywal is installed
if ! command -v wal &> /dev/null; then
    echo "Error: pywal not installed. Please install python-pywal." >&2
    exit 1
fi

echo "Setting wallpaper: $WALLPAPER"
echo ""

# Generate colorscheme from wallpaper
# -n: skip setting wallpaper (we use hyprpaper)
# -s: skip setting terminal colors (we use templates)
# -t: skip setting tty colors
# -e: skip reloading gtk theme
wal -i "$WALLPAPER" -n -s -t -e

# Update theme state for toggle script
echo "dynamic" > "$HOME/.cache/current_theme_mode"

echo "Applying generated colors..."

# ============================================
# Copy generated templates to their destinations
# ============================================

# Foot terminal
if [[ -f "${CACHE_DIR}/colors-foot.ini" ]]; then
    cp "${CACHE_DIR}/colors-foot.ini" "${CONFIG_DIR}/foot/colors.ini"
    echo "  [ok] foot"
fi

# Waybar
if [[ -f "${CACHE_DIR}/colors-waybar.css" ]]; then
    cp "${CACHE_DIR}/colors-waybar.css" "${CONFIG_DIR}/waybar/colors-waybar.css"
    echo "  [ok] waybar"
fi

# Hyprland colors (optional sourcing)
if [[ -f "${CACHE_DIR}/colors-hyprland.conf" ]]; then
    cp "${CACHE_DIR}/colors-hyprland.conf" "${CONFIG_DIR}/hypr/colors.conf"
    echo "  [ok] hyprland colors"
fi

# Rofi
if [[ -f "${CACHE_DIR}/colors-rofi.rasi" ]]; then
    cp "${CACHE_DIR}/colors-rofi.rasi" "${CONFIG_DIR}/rofi/colors.rasi"
    echo "  [ok] rofi"
fi

# Mako
if [[ -f "${CACHE_DIR}/colors-mako.conf" ]]; then
    cp "${CACHE_DIR}/colors-mako.conf" "${CONFIG_DIR}/mako/config"
    echo "  [ok] mako"
fi

# Hyprlock
if [[ -f "${CACHE_DIR}/colors-hyprlock.conf" ]]; then
    cp "${CACHE_DIR}/colors-hyprlock.conf" "${CONFIG_DIR}/hypr/hyprlock.conf"
    echo "  [ok] hyprlock"
fi

# wlogout
if [[ -f "${CACHE_DIR}/colors-wlogout.css" ]]; then
    cp "${CACHE_DIR}/colors-wlogout.css" "${CONFIG_DIR}/wlogout/style.css"
    echo "  [ok] wlogout"
fi

# ============================================
# Update hyprpaper configuration
# ============================================
echo "preload = $WALLPAPER" > "${CONFIG_DIR}/hypr/hyprpaper.conf"
echo "wallpaper = ,$WALLPAPER" >> "${CONFIG_DIR}/hypr/hyprpaper.conf"
echo "  [ok] hyprpaper config"

# ============================================
# Reload components
# ============================================
echo ""
echo "Reloading components..."

# Reload Hyprland
if command -v hyprctl &> /dev/null; then
    hyprctl reload 2>/dev/null && echo "  [ok] hyprland" || true
fi

# Restart waybar
if pgrep waybar > /dev/null; then
    pkill waybar
    sleep 0.3
    waybar &
    disown
    echo "  [ok] waybar restarted"
fi

# Restart hyprpaper
if pgrep hyprpaper > /dev/null; then
    pkill hyprpaper
    sleep 0.3
    hyprpaper &
    disown
    echo "  [ok] hyprpaper restarted"
fi

# Reload mako
if command -v makoctl &> /dev/null; then
    makoctl reload 2>/dev/null && echo "  [ok] mako reloaded" || true
fi

echo ""
echo "Theme applied successfully!"
echo "Wallpaper: $WALLPAPER"
