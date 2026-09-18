#!/bin/sh
# Install the modern CLI toolkit referenced by dotfiles/common/AGENTS.md and
# wired up (existence-guarded) in dotfiles/common/.zshrc.local.
#
# Idempotent: safe to re-run. Maps package names per distro:
#   Fedora (sigint) -> dnf       Arch (matt) -> pacman
set -eu

# intentional word splitting on the package lists
# shellcheck disable=SC2086
FEDORA_PKGS="fd-find atuin git-delta tldr gh direnv just hyperfine duf procs fzf ripgrep bat eza zoxide starship btop ncdu jq asahi-audio"
# shellcheck disable=SC2086
ARCH_PKGS="fd atuin git-delta tldr github-cli direnv just hyperfine duf procs fzf ripgrep bat eza zoxide starship btop ncdu jq"

if command -v dnf >/dev/null 2>&1; then
    echo "==> Fedora: dnf install"
    sudo dnf install -y $FEDORA_PKGS
elif command -v pacman >/dev/null 2>&1; then
    echo "==> Arch: pacman install (--needed skips up-to-date packages)"
    sudo pacman -S --needed $ARCH_PKGS
else
    echo "install-cli-tools.sh: no dnf or pacman found; add a mapping for this distro" >&2
    exit 1
fi

# hunk (hunk.dev) — terminal diff viewer for agent-authored changesets. Not in a
# package manager; the official script installs a checksum-verified standalone
# binary into ~/.hunk/bin and manages its own PATH entry in the shell rc.
if command -v hunk >/dev/null 2>&1 || [ -x "$HOME/.hunk/bin/hunk" ]; then
    echo "==> hunk: already installed, skipping"
else
    echo "==> hunk: install script (telemetry off)"
    DO_NOT_TRACK=1 curl -fsSL https://hunk.dev/install.sh | sh
fi

echo "==> done. Shell init lives in dotfiles/common/.zshrc.local (guarded, so"
echo "    hosts missing a tool still boot clean). Restart the shell to pick up"
echo "    starship/zoxide/atuin/direnv/fzf/herdr integrations."
