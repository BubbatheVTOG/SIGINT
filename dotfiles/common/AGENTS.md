# AGENTS.md — CLI preferences for agents on this machine

Prefer these modern tools over GNU defaults when constructing bash commands:

| Instead of | Use   | Notes                                          |
| ---------- | ----- | ---------------------------------------------- |
| grep       | `rg`  | recursive by default                           |
| find       | `fd`  | skips hidden/ignored; add `-H`/`-u` to include |
| ls         | `eza` | `-la --icons` for detail                       |
| cat        | `bat` | add `-p` when output is piped or parsed        |
| df         | `duf` |                                                |
| ps         | `procs` |                                              |
| du         | `ncdu` / `duf` |                                       |
| top        | `btop` | interactive monitoring                        |
| man        | `tldr` | practical examples first, then man            |

Also:

- `jq` for any JSON parsing/filtering
- `gh` for GitHub API/PR/issue operations instead of raw curl
- `just` — if a justfile exists, read it and use `just <recipe>` for common tasks
- `hyperfine` for benchmarking commands
- `git` diffs render via `delta` (configured as the global pager)

Caveats:

- These tools colorize output; when piping or parsing, add `-p`/`--plain` or pipe through `cat`.
- For POSIX sh scripts, still use POSIX utilities.
- If a tool is missing, fall back to the GNU default rather than failing the command.
- Prefer the dedicated Read/Grep/Glob/Edit tools for file operations; these rules apply to bash command construction.
- Package manifest: `~/git/SIGINT/dotfiles/install-cli-tools.sh` installs all of these on either host.

## Herdr

Sessions on this machine may run inside Herdr (terminal workspace manager).
A `herdr` skill is available — use it when parallel agents, background command
monitoring, or extra terminal panes would help. Verify `HERDR_ENV=1` first;
if unset, you are not inside Herdr and its CLI cannot control the session.
