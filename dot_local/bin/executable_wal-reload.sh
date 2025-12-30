#!/usr/bin/env bash
# Reload pywal colors on login (called from hyprland autostart)
# This script restores cached colors without regenerating them
# If no cached colors exist, generates from X_* wallpaper

WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Find X_* wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f -name "X_*" 2>/dev/null | head -n 1)

# If no cached colors, generate from X_* wallpaper
if [[ ! -f ~/.cache/wal/colors.sh ]]; then
    if [[ -n "$WALLPAPER" ]] && command -v wal &> /dev/null; then
        wal -i "$WALLPAPER" -n -s -t -e
    fi
fi

# Update hyprpaper.conf with X_* wallpaper
if [[ -n "$WALLPAPER" ]]; then
    echo "preload = $WALLPAPER" > ~/.config/hypr/hyprpaper.conf
    echo "wallpaper = ,$WALLPAPER" >> ~/.config/hypr/hyprpaper.conf
fi

# Source cached colors if they exist (for shell variables)
if [[ -f ~/.cache/wal/colors.sh ]]; then
    source ~/.cache/wal/colors.sh
fi

# ============================================
# Ensure generated configs are in place
# ============================================

# Foot terminal
if [[ -f ~/.cache/wal/colors-foot.ini ]]; then
    cp ~/.cache/wal/colors-foot.ini ~/.config/foot/colors.ini
fi

# Waybar
if [[ -f ~/.cache/wal/colors-waybar.css ]]; then
    cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/colors-waybar.css
fi

# Hyprland colors
if [[ -f ~/.cache/wal/colors-hyprland.conf ]]; then
    cp ~/.cache/wal/colors-hyprland.conf ~/.config/hypr/colors.conf
fi

# Rofi
if [[ -f ~/.cache/wal/colors-rofi.rasi ]]; then
    cp ~/.cache/wal/colors-rofi.rasi ~/.config/rofi/colors.rasi
fi

# Mako
if [[ -f ~/.cache/wal/colors-mako.conf ]]; then
    cp ~/.cache/wal/colors-mako.conf ~/.config/mako/config
fi

# Hyprlock
if [[ -f ~/.cache/wal/colors-hyprlock.conf ]]; then
    cp ~/.cache/wal/colors-hyprlock.conf ~/.config/hypr/hyprlock.conf
fi

# wlogout
if [[ -f ~/.cache/wal/colors-wlogout.css ]]; then
    cp ~/.cache/wal/colors-wlogout.css ~/.config/wlogout/style.css
fi

# Exit cleanly even if files don't exist
exit 0
