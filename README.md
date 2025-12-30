# Dotfiles - Hyprland Stealth Cyberpunk Desktop

Personal dotfiles for a Hyprland-based Wayland desktop environment with dynamic theming via pywal.

## Quick Start

These dotfiles are managed by [chezmoi](https://chezmoi.io/). After running the tarchy playbook, they will be automatically deployed.

### Manual Installation

```bash
chezmoi init --apply https://github.com/NightmaresOfTheEnd/dotfiles.git
```

## Directory Structure

```
dot_config/
├── hypr/           # Hyprland window manager
│   ├── hyprland.conf   # Main config (keybinds, animations, rules)
│   ├── hypridle.conf   # Idle daemon (lock after 5min, screen off 10min)
│   ├── hyprlock.conf   # Lock screen styling
│   ├── hyprpaper.conf  # Wallpaper config (auto-generated)
│   └── colors.conf     # Pywal-generated colors (auto-generated)
├── waybar/         # Status bar
├── rofi/           # Application launcher
├── foot/           # Terminal emulator
├── mako/           # Notification daemon
├── wlogout/        # Logout menu
├── wal/            # Pywal templates for dynamic theming
├── nvim/           # Neovim configuration
├── gtk-3.0/        # GTK3 theme settings
├── gtk-4.0/        # GTK4 theme settings
├── qt5ct/          # Qt5 theme settings
├── qt6ct/          # Qt6 theme settings
└── fastfetch/      # System info display

dot_local/bin/      # Helper scripts
├── wal-set.sh      # Set wallpaper + regenerate all colors
├── wal-reload.sh   # Reload cached colors on login
└── toggle-theme.sh # Toggle between Cyberpunk and Dynamic themes

dot_zshrc           # Zsh configuration with Oh My Zsh
dot_gitconfig       # Git configuration
```

## Theming System

### How It Works

1. **Wallpapers**: Place wallpapers in `~/Pictures/wallpapers/`
2. **Active Wallpaper**: Rename your preferred wallpaper to start with `X_` (e.g., `X_cyberpunk.png`)
3. **Pywal Integration**: Colors are extracted from the wallpaper and applied everywhere

### Theme Modes

| Mode | Description | Activate |
|------|-------------|----------|
| **Dynamic** | Colors from current wallpaper | `wal-set.sh /path/to/wallpaper.jpg` |
| **Cyberpunk** | Predefined dark theme | `toggle-theme.sh` (when in Dynamic mode) |

### Scripts

```bash
# Set a new wallpaper and regenerate all colors
wal-set.sh ~/Pictures/wallpapers/my_wallpaper.jpg

# Toggle between Cyberpunk (default) and Dynamic themes
toggle-theme.sh

# Reload colors on login (called automatically by Hyprland)
wal-reload.sh
```

## Keybindings

### General

| Keybind | Action |
|---------|--------|
| `Super + Q` | Open terminal (foot) |
| `Super + E` | Open file manager (thunar) |
| `Super + R` | Open app launcher (rofi) |
| `Super + C` | Close active window |
| `Super + V` | Toggle floating mode |
| `Super + L` | Lock screen |
| `Super + X` | Logout menu (wlogout) |

### Workspaces

| Keybind | Action |
|---------|--------|
| `Super + 1-0` | Switch to workspace 1-10 |
| `Super + Shift + 1-0` | Move window to workspace 1-10 |
| `Super + Scroll` | Cycle through workspaces |
| `Super + S` | Toggle scratchpad |
| `Super + Shift + S` | Move window to scratchpad |

### Window Management

| Keybind | Action |
|---------|--------|
| `Super + Arrow Keys` | Move focus |
| `Super + P` | Toggle pseudo-tiling |
| `Super + J` | Toggle split direction |
| `Super + Mouse LMB` | Move window |
| `Super + Mouse RMB` | Resize window |

### Media Keys

| Key | Action |
|-----|--------|
| `XF86AudioRaiseVolume` | Volume up 5% |
| `XF86AudioLowerVolume` | Volume down 5% |
| `XF86AudioMute` | Toggle mute |
| `XF86MonBrightnessUp` | Brightness up 5% |
| `XF86MonBrightnessDown` | Brightness down 5% |
| `XF86AudioPlay/Pause` | Play/pause media |
| `XF86AudioNext/Prev` | Next/previous track |

## Shell Aliases

Defined in `.zshrc`:

```bash
# System
update          # Update system (pacman -Syu)
cleanup         # Clean package cache
pacs            # Search packages
paci            # Install package

# Hyprland
hc              # Edit hyprland.conf
hr              # Reload hyprland
wbc             # Edit waybar config
wbs             # Edit waybar style
reload-waybar   # Restart waybar

# Git
gs              # git status
gd              # git diff
glog            # Pretty git log
```

## Customization

### Change Default Theme Colors

Edit `~/.config/wal/colorschemes/dark/cyberpunk.json` to modify the default Cyberpunk theme.

### Modify Pywal Templates

Templates in `~/.config/wal/templates/` control how colors are applied:

- `colors-hyprland.conf` - Window borders
- `colors-waybar.css` - Status bar
- `colors-foot.ini` - Terminal
- `colors-rofi.rasi` - App launcher
- `colors-mako.conf` - Notifications
- `colors-hyprlock.conf` - Lock screen
- `colors-wlogout.css` - Logout menu

### Window Opacity

Edit `~/.config/hypr/hyprland.conf`:

```ini
decoration {
    active_opacity = 0.85    # Active window transparency
    inactive_opacity = 0.80  # Inactive window transparency
}
```

## Troubleshooting

### Colors Not Applying

1. Ensure pywal cache exists: `ls ~/.cache/wal/`
2. Regenerate colors: `wal-set.sh`
3. Check template errors: `wal -r` (restore from cache)

### Hyprland Won't Start

1. Check for config errors: `hyprctl reload` from TTY
2. Verify colors.conf exists: `cat ~/.config/hypr/colors.conf`
3. Review logs: `journalctl --user -u hyprland`

### Waybar Not Showing

```bash
# Restart waybar
pkill waybar && waybar &
```

### Lock Screen Issues

```bash
# Test hyprlock
hyprlock --immediate
```

## Dependencies

Installed by the tarchy playbook:

- **WM**: hyprland, hyprpaper, hypridle, hyprlock
- **Bar**: waybar
- **Launcher**: rofi-wayland (AUR)
- **Terminal**: foot
- **Notifications**: mako
- **Theming**: python-pywal (AUR), papirus-icon-theme, bibata-cursor-theme
- **Shell**: zsh, oh-my-zsh, zsh-autosuggestions, zsh-syntax-highlighting
- **Utils**: grim, slurp, wl-clipboard, brightnessctl, playerctl

## License

MIT
