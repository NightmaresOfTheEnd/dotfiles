#!/usr/bin/env bash
# Wallpaper setter with pywal integration - Stealth Cyberpunk Theme
# Usage: wal-set.sh [/path/to/wallpaper.jpg]
#
# If no argument provided, automatically finds wallpaper matching X_* pattern
# This script is the SINGLE SOURCE OF TRUTH for theming.
# One command updates: foot, waybar, rofi, mako, hyprlock, wlogout

set -euo pipefail

WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# If argument provided, use it; otherwise find X_* wallpaper
if [[ -n "${1:-}" ]]; then
    WALLPAPER="$1"
else
    # Find wallpaper with X_* naming pattern
    WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f -name "X_*" 2>/dev/null | head -n 1)

    if [[ -z "$WALLPAPER" ]]; then
        echo "Error: No wallpaper found matching 'X_*' pattern in $WALLPAPER_DIR"
        echo "Usage: wal-set.sh [/path/to/wallpaper.jpg]"
        echo ""
        echo "Either:"
        echo "  1. Rename your preferred wallpaper to start with 'X_' (e.g., X_dark_forest.jpg)"
        echo "  2. Provide a wallpaper path as argument"
        exit 1
    fi
fi

# Check if wallpaper exists
if [[ ! -f "$WALLPAPER" ]]; then
    echo "Error: Wallpaper not found: $WALLPAPER"
    echo "Usage: wal-set.sh [/path/to/wallpaper.jpg]"
    exit 1
fi

# Check if pywal is installed
if ! command -v wal &> /dev/null; then
    echo "Error: pywal not installed. Please install python-pywal."
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

echo "Applying generated colors..."

# ============================================
# Copy generated templates to their destinations
# ============================================

# Foot terminal
if [[ -f ~/.cache/wal/colors-foot.ini ]]; then
    cp ~/.cache/wal/colors-foot.ini ~/.config/foot/colors.ini
    echo "  [ok] foot"
fi

# Waybar
if [[ -f ~/.cache/wal/colors-waybar.css ]]; then
    cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/colors-waybar.css
    echo "  [ok] waybar"
fi

# Hyprland colors (optional sourcing)
if [[ -f ~/.cache/wal/colors-hyprland.conf ]]; then
    cp ~/.cache/wal/colors-hyprland.conf ~/.config/hypr/colors.conf
    echo "  [ok] hyprland colors"
fi

# Rofi
if [[ -f ~/.cache/wal/colors-rofi.rasi ]]; then
    cp ~/.cache/wal/colors-rofi.rasi ~/.config/rofi/colors.rasi
    echo "  [ok] rofi"
fi

# Mako
if [[ -f ~/.cache/wal/colors-mako.conf ]]; then
    cp ~/.cache/wal/colors-mako.conf ~/.config/mako/config
    echo "  [ok] mako"
fi

# Hyprlock
if [[ -f ~/.cache/wal/colors-hyprlock.conf ]]; then
    cp ~/.cache/wal/colors-hyprlock.conf ~/.config/hypr/hyprlock.conf
    echo "  [ok] hyprlock"
fi

# wlogout
if [[ -f ~/.cache/wal/colors-wlogout.css ]]; then
    cp ~/.cache/wal/colors-wlogout.css ~/.config/wlogout/style.css
    echo "  [ok] wlogout"
fi

# ============================================
# Update hyprpaper configuration
# ============================================
echo "preload = $WALLPAPER" > ~/.config/hypr/hyprpaper.conf
echo "wallpaper = ,$WALLPAPER" >> ~/.config/hypr/hyprpaper.conf
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
