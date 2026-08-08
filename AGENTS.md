# AGENTS.md

GNU stow dotfiles repo for two Hyprland hosts. No build system, no tests —
edits land directly in live configs via symlinks. Read `README.md` first.

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

# system-wide (/etc) — needs sudo, clears a pre-existing real file first
sudo stow -R -t / system-sigint # on sigint
sudo stow -R -t / system-matt   # on matt
```

**Stow conflicts:** if the target path is a real file (not a symlink), stow
aborts. Back it up (`cp -a file file.bak`) and `rm` it, then re-run stow so
the managed symlink can take over. This is expected for `/etc/greetd/config.toml`
and `~/.config/btop/btop.conf` on first stow.

## The common/ rule (critical)

`common/` is stowed on **both** hosts — Arch x86_64 and Fedora Asahi ARM,
different OSes. Anything in `common/` must be either:

1. byte-identical on both hosts, or
2. **guarded** — e.g. `[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"`,
   or a `case "$(hostname)"` branch.

Host-divergent values (usernames, binary paths, hardware quirks) go in the
host package (`sigint/` or `matt/`), never in `common/`. Violations break
the other host silently. Past breakage: unguarded `. "$HOME/.cargo/env"`
warned on every zsh startup on sigint; a shared `system/` greetd config used
Arch's `greeter` user + bare `Hyprland` (neither exists/works on Fedora Asahi,
which needs `greetd` + `start-hyprland`).

## Theme state is live, not committed (usually)

`toggle-theme.sh` (SUPER+SHIFT+R) rewrites color values in-place across
kitty, rofi, waybar, tmux, hyprland borders, and hyprpaper wallpaper via
`sed --follow-symlinks` — directly into the stowed repo working tree. It
cycles 6 themes: teal, red, green, yellow, orange, purple. State lives in
`~/.cache/current_theme` (one of those six names).

Consequence: `git status` on a host commonly shows uncommitted diffs that are
**the live theme state**, not real edits. When pulling across hosts:
- stash the local theme diffs (`git stash`),
- pull,
- pop — overlapping hunks merge cleanly because the sed edits target
  non-overlapping color lines.

Some theme states have been committed to the repo (red is currently baked
into `common/` kitty/rofi/waybar/tmux; yellow is the live theme as of commit
time). The `sigint/` hyprland borders and hyprpaper wallpaper may also be
committed in a themed state. If the live theme differs from the repo state,
`git status` will show a diff after toggling — that's expected.

To add a theme: append one matching value (indexed identically in every
array) to each color palette in `toggle-theme.sh`, add it to `THEMES` and
`IDX`, and drop a matching `<name>.jpg` into
`common/.config/hypr/wallpapers/`.

## Pulling across hosts

```bash
cd ~/git/SIGINT && git stash && git pull --ff-only && git stash pop
cd dotfiles && stow -R -t ~ common <host>
# then sudo stow for the system package if it changed
```

After pull, always re-run the home stow to refresh symlinks (files may have
been added/removed/renamed in a package). Check `git status` — remaining
diffs should be only live theme state.

## Config format quirks

- **Hyprland config is Lua** (`hyprland.lua`), not `.conf`. Uses a custom
  `hl.` DSL. Validate syntax: `luajit -e 'assert(loadfile("path"))'`.
- **waybar config is JSONC** (`config.jsonc`) — `//` comments and trailing
  commas are valid for waybar but break strict `json.load`. Strip comments
  before validating with Python.
- **greetd config is TOML** — validate with `python3 -c "import tomllib; ..."`.
- **grml zshrc is vendored** in `common/.zshrc` (1400+ lines, don't edit).
  Personal zsh additions go in `common/.zshrc.local`, which grml sources via
  `zrclocal()`. A double-source guard prevents fastfetch/PATH duplication
  when both `/etc/zsh/zshrc` and `~/.zshrc` are grml.

## Per-host facts that matter

- **sigint**: greeter user is `greetd`; Hyprland launches via
  `start-hyprland` (Asahi GPU wrapper, not the bare `Hyprland` binary).
  Single monitor `eDP-1`. Has lid/battery handlers in hyprland.lua.
- **matt**: greeter user is `greeter`; Hyprland launches via
  `start-hyprland` (Hyprland recommends the wrapper over the bare binary).
  Three monitors DP-4/DP-5/DP-6 with rotations. GPU passthrough.
  `OPENCODE_BIN_PATH` workaround for a Bun crash on Ryzen 5800X3D
  (matt-only, set conditionally in `common/.zshrc.local`).

## Secrets

`~/.config/secrets` (gitignored) is sourced by the shell. Configs reference
values via opencode's `{env:VAR_NAME}` substitution. Required:
`HTB_TOKEN`, `VLLM_API_KEY`. Never commit secrets; never hardcode keys.

## Git

- Default branch: `main` (not `master`). No `master` branch exists.
- `.gitconfig` requires `git-lfs` (LFS filter is `required = true`).
- Gitignored: `.config/secrets`, `bun.lock`, `.zcompdump*`, `.zdirs`, `*.bak`.
- No CI, no pre-commit hooks, no test suite. Verification is manual: check
  symlinks resolve (`readlink -f`, `find ~ -type l ! -exec test -e {} \;`),
  validate config syntax, run `zsh -c true` to check shell startup is clean.
