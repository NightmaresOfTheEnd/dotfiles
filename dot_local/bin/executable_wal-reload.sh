#!/usr/bin/env bash
# Reload pywal colors on login (called from hyprland autostart)
# This script restores cached colors without regenerating them

# Source cached colors if they exist
if [[ -f ~/.cache/wal/colors.sh ]]; then
    source ~/.cache/wal/colors.sh
fi

# Ensure generated configs are in place
if [[ -f ~/.cache/wal/colors-foot.ini ]]; then
    cp ~/.cache/wal/colors-foot.ini ~/.config/foot/colors.ini
fi

if [[ -f ~/.cache/wal/colors-waybar.css ]]; then
    cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/colors-waybar.css
fi

if [[ -f ~/.cache/wal/colors-hyprland.conf ]]; then
    cp ~/.cache/wal/colors-hyprland.conf ~/.config/hypr/colors.conf
fi

# Exit cleanly even if files don't exist
exit 0
