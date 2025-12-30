#!/usr/bin/env bash
# Toggle between Default (Cyberpunk) and Dynamic (Wallpaper) themes
# Usage: toggle-theme.sh

STATE_FILE="$HOME/.cache/current_theme_mode"
DEFAULT_WALLPAPER_PATTERN="X_*"
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

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
    notify-send "Theme" "Switched to Default (Cyberpunk)"
    
elif [[ "$CURRENT_STATE" == "default" ]]; then
    echo "Switching to Dynamic (Wallpaper) theme..."
    
    # 1. Find current wallpaper (from hyprpaper config or X_* default)
    # We'll just run wal-reload.sh logic which finds the wallpaper
    WALLPAPER=$(grep "wallpaper =" ~/.config/hypr/hyprpaper.conf | cut -d',' -f2 | xargs)
    
    if [[ -z "$WALLPAPER" || ! -f "$WALLPAPER" ]]; then
        WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f -name "$DEFAULT_WALLPAPER_PATTERN" 2>/dev/null | head -n 1)
    fi
    
    if [[ -f "$WALLPAPER" ]]; then
        wal -i "$WALLPAPER" -n -s -t -e
        echo "dynamic" > "$STATE_FILE"
        notify-send "Theme" "Switched to Dynamic Mode"
    else
        notify-send "Theme Error" "No wallpaper found to generate colors from."
        exit 1
    fi
fi

# ============================================
# Re-apply templates (Standard wal-set.sh logic)
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

# ============================================
# Reload components
# ============================================

# Reload Hyprland (triggers color update)
hyprctl reload &>/dev/null

# Restart waybar
pkill waybar
sleep 0.2
waybar &>/dev/null & disown

# Reload mako
makoctl reload &>/dev/null
