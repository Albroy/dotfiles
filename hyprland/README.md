# Hyprland

Complete Hyprland environment (compositor + Waybar bar), inspired by the [ML4W](https://github.com/mylinuxforwork/dotfiles) dotfiles

Each component is linked to its standard path

```
~/.config/hypr       -> ~/.dotfiles/hyprland/hypr
~/.config/waybar     -> ~/.dotfiles/hyprland/waybar
~/.config/rofi       -> ~/.dotfiles/hyprland/rofi
~/.config/swaync     -> ~/.dotfiles/hyprland/swaync
~/.config/wlogout    -> ~/.dotfiles/hyprland/wlogout
~/.config/waypaper   -> ~/.dotfiles/hyprland/waypaper
~/.config/kitty      -> ~/.dotfiles/hyprland/kitty
~/.config/fastfetch  -> ~/.dotfiles/hyprland/fastfetch
~/.config/gtk-3.0    -> ~/.dotfiles/hyprland/gtk-3.0
~/.config/gtk-4.0    -> ~/.dotfiles/hyprland/gtk-4.0
~/.config/qt6ct      -> ~/.dotfiles/hyprland/qt6ct
~/.config/xsettingsd -> ~/.dotfiles/hyprland/xsettingsd
```

| Component | Role |
|---|---|
| `rofi/` | Menu styling (app launcher, clipboard, pickers); the `rofi-{font,border,border-radius}.rasi` internalized from the ML4W settings |
| `swaync/` | Notification center (frozen `colors.css` palette) |
| `wlogout/` | Power menu (background = blurred wallpaper from `~/.cache/hypr-dotfiles/`) |
| `waypaper/` | Wallpaper picker (swww backend, `post_command` → `wallpaper.sh`) |
| `kitty/` | Terminal |
| `fastfetch/` | System info |
| `gtk-3.0/`, `gtk-4.0/`, `qt6ct/`, `xsettingsd/` | GTK/Qt theming |

## hypr/

| Path | Role |
|---|---|
| `hyprland.conf` | Entry point, sources the files in `conf/` |
| `conf/custom.conf` | Free-form additional config |
| `conf/keyboard.conf` | AZERTY keyboard (`kb_layout = fr`), mouse, touchpad |
| `conf/windowrules-apps.conf` | Application window rules (float, size, position) |
| `conf/*.conf` | Switchers: each file sources a chosen variation |
| `conf/{animations,decorations,environments,keybindings,layouts,monitors,windows,workspaces}/` | Available variations |
| `conf/monitors/maison.conf` | Monitor layout: 1080p HDMI on the left, laptop on the right |
| `conf/keybindings/fr.conf` | AZERTY-adapted keybindings (workspaces on `&é"'(-è_çà`) |
| `scripts/` | Utility scripts (screenshots, wallpaper, hyprshade, focus…) |
| `effects/` | Wallpaper effects (ImageMagick) |
| `hypridle.conf`, `hyprlock.conf` | Idle and lock screen (wallpaper handled by waypaper/swww) |

## Remaining external dependencies

- direct app binds: `kitty`, `firefox`, `nautilus`, `gnome-calculator`
- runtime state in `~/.cache/hypr-dotfiles/` (current wallpaper, effect,
  hyprshade filter, hyprlock images)

## Installation

```sh
./setup hyprland
```
