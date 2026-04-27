# Beelink WSL2 Machine Runbook

This folder documents the clean `UbuntuClean` WSL2 setup on the Beelink machine.

The goal is repeatability: if this machine, distro, or WSL setup needs to be rebuilt, these notes should make the next setup faster and less fragile.

## Current Distro

- Windows host: Beelink
- WSL distro: `UbuntuClean`
- Linux user: `gnu`
- Home folder: `/home/gnu`
- Machine docs folder: `/home/gnu/beelink`
- Tailscale hostname: `beelink`
- Tailscale IPv4: `100.92.158.40`

## Docs

- `docs/001-tailscale-keys.md`: Tailscale, SSH service, and key-based access.
- `docs/002-codex.md`: Codex CLI, Node.js, auth, config, and bubblewrap.
- `docs/003-backups.md`: WSL VHDX backup and restore commands.
- `docs/004-keepalive.md`: WSL keepalive service and Windows boot startup task.
- `docs/005-tmux-vscode.md`: `tmux` auto-attach setup for VS Code integrated terminals.
- `docs/006-opencode-ollama.md`: OpenCode configured to use local Ollama models.
- `docs/007-aider-ollama.md`: Aider configured to use local Ollama models.

## Important Principles

- Keep the broken legacy `Ubuntu` distro untouched until its data is no longer needed.
- Prefer configuring new infrastructure inside `UbuntuClean`.
- Record exact commands and versions after each setup step.
- Put machine-specific fixes in this folder before they become folklore.
