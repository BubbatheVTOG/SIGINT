# AGENTS.md

This repo holds GNU stow dotfiles for two Hyprland hosts. It has no build
system or tests. Edits go directly into live configs through symlinks. Read
`README.md` first.

## Hosts

| host | OS | arch | home pkgs | system pkg |
|---|---|---|---|---|
| sigint | Fedora (Asahi) | aarch64 | `common sigint` | `system-sigint` |
| matt | Arch | x86_64 | `common matt` | `system-matt` |

## Stow commands (run from `dotfiles/`)

```bash
# home (per host) — no sudo
stow -R -t ~ common sigint      # on sigint
stow -R -t ~ common matt        # on matt

# system-wide (/etc) — needs sudo
sudo stow -R -t / system-sigint # on sigint
sudo stow -R -t / system-matt   # on matt
```

**Stow conflicts.** If the target path is a real file, stow stops. Copy the
file (`cp -a file file.bak`), remove it (`rm file`), and run stow again. This
occurs for `/etc/greetd/config.toml` and `~/.config/btop/btop.conf` on the
first stow.

**SELinux (sigint only).** Fedora SELinux does not let systemd read unit files
and executables that symlink into `/home`. The source files get the
`user_home_t` context. Systemd cannot read or execute files with this context.
This affects any `system-sigint` unit file under `/etc/systemd/system/` or
script under `/usr/local/bin/`. After you stow, apply persistent labels with
`semanage fcontext` and `restorecon`:

```bash
sudo semanage fcontext -a -t systemd_unit_file_t \
  "/home/bubba/git/SIGINT/dotfiles/system-sigint/etc/systemd/system/<unit>\.service"
sudo semanage fcontext -a -t bin_t \
  "/home/bubba/git/SIGINT/dotfiles/system-sigint/usr/local/bin/<script>\.py"
sudo restorecon -rv /etc/systemd/system/<unit>.service /usr/local/bin/<script>.py
sudo systemctl daemon-reload
sudo systemctl enable --now <unit>.service
```

matt (Arch) has no SELinux. Skip this step on matt.

## The common/ rule (critical)

You stow `common/` on **both** hosts — Arch x86_64 and Fedora Asahi ARM.
These hosts run different operating systems. Each item in `common/` must be
either:

1. byte-identical on both hosts, or
2. **guarded** — for example, `[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"`,
   or a `case "$(hostname)"` branch.

Put host-specific values (usernames, binary paths, hardware details) in the
host package (`sigint/` or `matt/`), not in `common/`. Violations break the
other host without a warning.

Past breakage: an unguarded `. "$HOME/.cargo/env"` printed a warning on every
zsh startup on sigint. A shared `system/` greetd config used the Arch
`greeter` user and the bare `Hyprland` binary. Neither exists on Fedora Asahi,
which uses `greetd` and `start-hyprland`.

## Theme state: generated, not committed

`toggle-theme.sh` (SUPER+SHIFT+R) generates 8 palette files in
`~/.config/theme/`. Git ignores this directory. You do not stow or commit it.
The script cycles 7 themes: teal, red, green, yellow, orange, purple, white.
The current theme name is in `~/.cache/current_theme`.

The committed configs contain **no color values**. Each config has one include
line that loads a palette file from `~/.config/theme/`:

| tool | include line in committed config | palette file |
|---|---|---|
| kitty | `include ~/.config/theme/kitty.conf` | themed color lines (cursor, selection, borders, color4/6/12/14) |
| tmux | `source-file -q ~/.config/theme/tmux.conf` | `set -g status-style` |
| waybar | `@import "../theme/waybar.css";` | `@define-color teal`/`teal-dim` |
| rofi | `?import "~/.config/theme/rofi.rasi"` (optional import) | foreground, selected-background, border-color |
| hyprland.lua | `dofile(... "/.config/theme/hyprland.lua")` (pcall-guarded) | `R_PRI`/`R_SEC`/`R_DIM` rgba strings |
| hyprlock | `source = ~/.config/theme/hyprlock.conf` | `$accent` variable |
| hyprpaper | `source = ~/.config/theme/hyprpaper.conf` | `$wallpaper` variable |
| fastfetch | sources `~/.config/theme/fastfetch-palette.sh` from `.zshrc.local` | `FF_KEYS`/`FF_TITLE`/`FF_SEP`/`FF_LOGO` |

The `--init` flag applies the current theme. It does not cycle the themes.
Use it on the first boot to set the initial theme. Hyprland autostart runs
`[ -f ~/.config/theme/kitty.conf ] || toggle-theme.sh --init`. This generates
the palette files automatically on a fresh install.

`git status` is always clean after a theme toggle. Color values never touch
the committed tree. You do not need to stash, pull, or pop across hosts.

Use `dofile` (not `require`) in hyprland.lua. The `require` function caches
modules in `package.loaded` across `hyprctl reload`, which leaves stale colors
after a theme switch. The `dofile` function re-reads the file on every reload.
The `pcall` guard handles the case where the file does not exist on first
boot. It falls back to inline teal defaults.

To add a theme: append one value to each color palette in
`toggle-theme.sh`. Index the value identically in every array. Add the theme
name to `THEMES` and `IDX`. Put a matching `<name>.jpg` into
`common/.config/hypr/wallpapers/`.

## Pull across hosts

```bash
cd ~/git/SIGINT && git stash && git pull --ff-only && git stash pop
cd dotfiles && stow -R -t ~ common <host>
# then sudo stow for the system package if it changed
```

After a pull, always run the home stow command again to refresh the symlinks.
A pull may add, remove, or rename files in a package. Check `git status`. The
remaining diffs are live theme state only.

## Config format notes

- **Hyprland config is Lua** (`hyprland.lua`), not `.conf`. It uses a custom
  `hl.` DSL. Validate the syntax: `luajit -e 'assert(loadfile("path"))'`.
- **waybar config is JSONC** (`config.jsonc`). `//` comments and trailing
  commas are valid for waybar but break strict `json.load`. Strip comments
  before you validate with Python.
- **greetd config is TOML**. Validate it:
  `python3 -c "import tomllib; ..."`.
- **grml zshrc is vendored** in `common/.zshrc` (1400+ lines). Do not edit it.
  Put personal zsh additions in `common/.zshrc.local`. grml sources this file
  through `zrclocal()`. A double-source guard prevents fastfetch and PATH
  duplication when both `/etc/zsh/zshrc` and `~/.zshrc` are grml.
- **hypridle is managed by Hyprland autostart**, not systemd. Hyprland starts
  hypridle through `pidof hypridle || hypridle` in `hyprland.lua`. Do not start
  or enable the systemd user service (`systemctl --user start hypridle`) —
  a second instance causes conflicting idle timers and screen blackouts. The
  `pidof` guard prevents duplicates on `hyprctl reload`.

## Per-host facts

- **sigint**: The greeter user is `greetd`. Hyprland starts through
  `start-hyprland` (the Asahi GPU wrapper, not the bare `Hyprland` binary).
  Single monitor: `eDP-1`. Lid and battery handlers are in hyprland.lua.
- **matt**: The greeter user is `greeter`. Hyprland starts through
  `start-hyprland`. Three monitors: DP-4, DP-5, DP-6, each with a rotation.
  GPU passthrough. `OPENCODE_BIN_PATH` works around a Bun crash on the
  Ryzen 5800X3D. `common/.zshrc.local` sets it conditionally.

## Secrets

The shell sources `~/.config/secrets` (gitignored). Configs get these values
through the opencode `{env:VAR_NAME}` substitution. Required variables:
`HTB_TOKEN`, `VLLM_API_KEY`. Do not commit secrets. Do not hardcode keys.

## Git

- Default branch: `main`. No `master` branch exists.
- `.gitconfig` requires `git-lfs` (the LFS filter is `required = true`).
- Gitignored: `.config/secrets`, `bun.lock`, `.zcompdump*`, `.zdirs`, `*.bak`.
- No CI, no pre-commit hooks, no test suite. Verification is manual: check
  that symlinks resolve (`readlink -f`,
  `find ~ -type l ! -exec test -e {} \;`), validate config syntax, run
  `zsh -c true` to confirm the shell starts clean.
