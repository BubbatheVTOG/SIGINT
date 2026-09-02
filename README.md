# SIGINT Dotfiles

GNU stow manages these dotfiles for two Hyprland hosts: `sigint` (Asahi/Fedora
ARM laptop) and `matt` (Arch x86_64 desktop).

## Layout

```
dotfiles/
├── common/    # Shared configs (stowed on both hosts). Only host-safe content:
│              #   identical files, or existence-guarded logic (see below).
├── sigint/         # Laptop-specific (Asahi, lid, battery, eDP-1)
├── matt/           # Desktop-specific (3 monitors DP-4/5/6, GPU passthrough, no laptop keys)
├── system-sigint/  # sigint system-wide configs (/etc). Stowed to / with sudo.
└── system-matt/    # matt system-wide configs (/etc). Stowed to / with sudo.
```

> **Why two system packages?** The greetd software differs by OS. Fedora Asahi
> runs the greeter as user `greetd` and starts Hyprland via the
> `start-hyprland` wrapper (Asahi GPU setup). Arch uses user `greeter` and the
> bare `Hyprland` binary. A single shared `system/` package would break one
> host.

### The common/ rule

These two hosts use different operating systems (Arch x86_64 vs Fedora Asahi
ARM). Each file in `common/` must be one of the following:

1. **Identical on both hosts**, or
2. **Guarded** — e.g. `[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"`, or a
   `case "$(hostname)"` branch (see `toggle-theme.sh`).

Put host-specific paths, binaries, workarounds, and hardware quirks in the
host package (`matt/` or `sigint/`). Do not put them in `common/`. Example:
`OPENCODE_BIN_PATH` is a matt-only workaround. Set it conditionally in
`common/.zshrc.local` only when the binary exists.

## Install

On **sigint**:
```bash
stow -R -t ~ common sigint
sudo stow -R -t / system-sigint
```

On **matt**:
```bash
stow -R -t ~ common matt
sudo stow -R -t / system-matt
```

Install the packages `greetd` and `greetd-tuigreet`. Then run `systemctl enable greetd`.

### SELinux labels (sigint only)

Fedora SELinux does not let systemd (`init_t`) read unit files and
executables that symlink into `/home`. These files inherit the `user_home_t`
context, which systemd cannot read or execute. This affects any
`system-sigint` file that stow puts into `/etc/systemd/system/` or
`/usr/local/bin/`. After you stow the files, apply persistent labels (these
labels survive a relabel) with `semanage fcontext` + `restorecon`:

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

## CLI Toolkit

`common/.zshrc.local` configures modern CLI tools (starship, zoxide, atuin, fzf,
eza, bat, fd, duf, procs, direnv, herdr completions). `common/AGENTS.md`
(stowed to `~/AGENTS.md`) tells agents to use them instead of GNU defaults.

Install everything on either host:

```bash
cd ~/git/SIGINT/dotfiles && ./install-cli-tools.sh
```

Package names differ per distro (`fd-find`/`fd`, `gh`/`github-cli`, …). The
script maps them. Every init line and alias in `.zshrc.local` uses an
existence guard. Thus, hosts that lack a tool still boot cleanly.

## Theme Toggle

`SUPER + SHIFT + R` cycles through the themes teal, red, green, yellow,
orange, purple, and white. Each theme applies to Hyprland, Waybar, Kitty,
Rofi, Tmux, and the Hyprpaper wallpaper.

Each theme has a wallpaper in `common/.config/hypr/wallpapers/` (`teal.jpg`,
`red.jpg`, `green.jpg`, `yellow.jpg`, `orange.jpg`, `purple.jpg`,
`white.jpg`). You can also use `teal_web.jpg` as an extra option there.

## Per-host reference

### sigint (Asahi MacBook Air)

- **Screen auto-dim**: `screen-dim.sh` and `screen-restore.sh`
  (`sigint/.local/bin/`) run from `hypridle.conf`. After 2.5 minutes of
  inactivity, the screen dims to 10% over 0.8 seconds. If the brightness is
  at or below 10%, the dim does not occur. On resume, the screen restores to
  its prior brightness instantly.
- **Keyboard backlight auto-dim**: `kbd-backlight-daemon.service`
  (`system-sigint/`) runs as a root systemd service. When you press a key,
  the keyboard backlight brightens to level 26. After 10 seconds of
  inactivity, the backlight dims to level 5 over 0.8 seconds. The daemon
  reads the keyboard evdev node and writes the sysfs brightness file
  directly. It has no external dependencies.
- **Lid and battery**: The handlers are in `hyprland.lua`. The lid event
  turns the screen off and locks the session. The battery handler shows
  low-power warnings.
- **Monitor**: The single display is `eDP-1`.
- **Greeter**: The user is `greetd`. `start-hyprland` (the Asahi GPU wrapper)
  starts Hyprland.

### matt (Arch desktop)

- **Monitors**: Three displays — DP-4, DP-5, DP-6. The file
  `matt/.config/hypr/hyprland.lua` sets the rotation for each display. The
  setup matches `hyprctl monitors` output.
- **GPU passthrough**: A dedicated GPU passes through to a virtual machine.
- **Greeter**: The user is `greeter`. `start-hyprland` starts Hyprland.
- **OPENCODE_BIN_PATH**: This variable works around a Bun crash on the Ryzen
  5800X3D. Set it conditionally in `common/.zshrc.local` only when the binary
  exists.
- **No laptop hardware**: matt has no lid, no battery, and no keyboard
  backlight. The screen auto-dim and keyboard backlight scripts do not apply.

## Secrets

Secrets (API keys, tokens) are in `~/.config/secrets` (gitignored). The
shell sources this file. Configs reference the values via opencode's
`{env:VAR_NAME}` substitution. Required variables:

```bash
export HTB_TOKEN="..."      # HackTheBox MCP bearer token
export VLLM_API_KEY="..."   # vllm provider key
```

## Notes

- The opencode config is per-host (`matt/.config/opencode/`,
  `sigint/.config/opencode/`): `opencode.json` + `package.json`. `bun.lock`
  is gitignored (`bun install` regenerates it).
- `bun.lock`, `.zdirs`, `.zcompdump*`, `*.bak`, and `.config/secrets` are
  gitignored.
- After you pull changes, re-run the `stow` command for your host. This
  refreshes the symlinks.
