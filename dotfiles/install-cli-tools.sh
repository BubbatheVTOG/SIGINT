#!/bin/sh
# Install the modern CLI toolkit referenced by dotfiles/common/AGENTS.md and
# wired up (existence-guarded) in dotfiles/common/.zshrc.local.
#
# Idempotent: safe to re-run. Maps package names per distro:
#   Fedora (sigint) -> dnf       Arch (matt) -> pacman
set -eu

# intentional word splitting on the package lists
# shellcheck disable=SC2086
FEDORA_PKGS="fd-find atuin git-delta tldr gh direnv just hyperfine duf procs fzf ripgrep bat eza zoxide starship btop ncdu jq"
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

echo "==> done. Shell init lives in dotfiles/common/.zshrc.local (guarded, so"
echo "    hosts missing a tool still boot clean). Restart the shell to pick up"
echo "    starship/zoxide/atuin/direnv/fzf/herdr integrations."
