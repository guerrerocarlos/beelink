# 005 - tmux for VS Code Terminals

This document records the `tmux` setup used to give each VS Code integrated terminal its own isolated `tmux` session.

## Goal

- Auto-start `tmux` when opening a new VS Code terminal.
- Keep each terminal in a separate `tmux` session.
- Avoid changing behavior for normal non-VS Code shells.

## Current State

- `tmux` version: `3.4`
- Bash config file: `/home/gnu/.bashrc`
- tmux config file: `/home/gnu/.tmux.conf`
- Trigger condition: `TERM_PROGRAM=vscode`
- Session naming pattern: `<cwd>-<tty>`

## Bash Auto-Attach Hook

The following function was added near the end of `/home/gnu/.bashrc`:

```bash
tmux_vscode_auto_attach() {
    [ -n "${TMUX:-}" ] && return
    [ "${TERM_PROGRAM:-}" = "vscode" ] || return
    command -v tmux >/dev/null 2>&1 || return

    local tty_name session_name cwd_slug
    tty_name="$(tty 2>/dev/null)" || return
    [ -n "$tty_name" ] || return

    tty_name="${tty_name#/dev/}"
    tty_name="${tty_name//\//-}"
    cwd_slug="${PWD##*/}"
    [ -n "$cwd_slug" ] || cwd_slug="shell"
    cwd_slug="${cwd_slug//[^[:alnum:]_.-]/-}"
    session_name="${cwd_slug}-${tty_name}"

    exec tmux new-session -A -s "$session_name"
}

tmux_vscode_auto_attach
```

## tmux Defaults

The `/home/gnu/.tmux.conf` file contains:

```tmux
set -g mouse on
set -g history-limit 100000
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g set-clipboard on
set -g detach-on-destroy off
setw -g aggressive-resize on
```

## Why This Shape

- `TMUX` guard prevents nested `tmux` sessions.
- `TERM_PROGRAM=vscode` limits auto-attach to VS Code integrated terminals.
- Per-TTY session names isolate terminals from each other.
- `new-session -A` allows the same terminal to reconnect to its previous session if that exact session name is reused.

## Validation

Syntax and config checks used:

```bash
bash -n /home/gnu/.bashrc
tmux -f /home/gnu/.tmux.conf start-server
```

## Usage

Open a new VS Code integrated terminal. Bash should immediately `exec` into its own `tmux` session.

Useful commands:

```bash
tmux ls
tmux attach -t <session>
tmux kill-session -t <session>
```

## Notes

- This setup does not depend on the `code` CLI being available in WSL.
- Normal login shells, SSH sessions, and non-VS Code terminals are left alone.
