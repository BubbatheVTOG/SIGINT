# SIGINT Dotfiles

GNU stow-managed dotfiles for two Hyprland hosts: `sigint` (Asahi laptop) and `matt` (desktop).

## Layout

```
dotfiles/
├── common/    # Shared configs (stowed on both hosts)
├── sigint/    # Laptop-specific (Asahi, lid, battery, eDP-1)
└── matt/      # Desktop-specific (3 monitors, no laptop keys)
```

## Install

On **sigint**:
```bash
stow -R -t ~ common sigint
```

On **matt**:
```bash
stow -R -t ~ common matt
```

## Theme Toggle

`SUPER + SHIFT + R` flips between teal (default) and red across Hyprland, Waybar, Kitty, Rofi, Tmux, and Hyprpaper wallpaper.

## Secrets

Secrets (API keys, tokens) live in `~/.config/secrets` (gitignored) and are sourced by the shell. Configs reference them via opencode's `{env:VAR_NAME}` substitution.

## Notes

- Matt's monitor output names in `matt/.config/hypr/hyprland.lua` are placeholders — run `hyprctl monitors` on matt and update them.
- After pulling changes, re-run the `stow` command for your host to refresh symlinks.
