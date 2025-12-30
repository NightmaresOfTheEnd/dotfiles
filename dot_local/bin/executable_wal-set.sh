#!/usr/bin/env bash
# Wallpaper setter with pywal integration
# Usage: wal-set.sh /path/to/wallpaper.jpg

set -euo pipefail

WALLPAPER="${1:-$HOME/Pictures/wallpapers/gruvbox_spac.jpg}"

# Check if wallpaper exists
if [[ ! -f "$WALLPAPER" ]]; then
    echo "Error: Wallpaper not found: $WALLPAPER"
    echo "Usage: wal-set.sh /path/to/wallpaper.jpg"
    exit 1
fi

# Check if pywal is installed
if ! command -v wal &> /dev/null; then
    echo "Error: pywal not installed. Please install python-pywal."
    exit 1
fi

echo "Setting wallpaper: $WALLPAPER"

# Generate colorscheme from wallpaper
# -n: skip setting wallpaper (we use hyprpaper)
# -s: skip setting terminal colors (we use templates)
# -t: skip setting tty colors
# -e: skip reloading gtk theme
wal -i "$WALLPAPER" -n -s -t -e

# Copy generated templates to their destinations
echo "Applying generated colors..."

if [[ -f ~/.cache/wal/colors-foot.ini ]]; then
    cp ~/.cache/wal/colors-foot.ini ~/.config/foot/colors.ini
    echo "  - foot colors updated"
fi

if [[ -f ~/.cache/wal/colors-waybar.css ]]; then
    cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/colors-waybar.css
    echo "  - waybar colors updated"
fi

if [[ -f ~/.cache/wal/colors-hyprland.conf ]]; then
    cp ~/.cache/wal/colors-hyprland.conf ~/.config/hypr/colors.conf
    echo "  - hyprland colors updated"
fi

# Update hyprpaper configuration
echo "preload = $WALLPAPER" > ~/.config/hypr/hyprpaper.conf
echo "wallpaper = ,$WALLPAPER" >> ~/.config/hypr/hyprpaper.conf
echo "  - hyprpaper config updated"

# Reload components
echo "Reloading components..."

# Reload Hyprland
hyprctl reload 2>/dev/null || echo "  - hyprctl not available"

# Restart waybar
if pgrep waybar > /dev/null; then
    pkill waybar
    sleep 0.2
    waybar &
    disown
    echo "  - waybar restarted"
fi

# Restart hyprpaper
if pgrep hyprpaper > /dev/null; then
    pkill hyprpaper
    sleep 0.2
    hyprpaper &
    disown
    echo "  - hyprpaper restarted"
fi

echo "Theme applied successfully from: $WALLPAPER"
