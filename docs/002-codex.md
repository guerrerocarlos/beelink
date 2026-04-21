# 002 - Codex CLI

This document records the Codex CLI setup inside the fresh `UbuntuClean` WSL2 distro.

## Current State

- WSL distro: `UbuntuClean`
- Linux user: `gnu`
- Node.js: `v22.22.2`
- npm: `10.9.7`
- Codex CLI: `codex-cli 0.122.0`
- Codex binary: `/usr/bin/codex`
- Bubblewrap: `bubblewrap 0.9.0`
- Codex auth status: logged in using ChatGPT
- Codex config: `/home/gnu/.codex/config.toml`

## Node.js Installation

Ubuntu 24.04 apt provided Node 18, so NodeSource Node 22 was installed instead:

```bash
sudo apt-get install -y ca-certificates curl gnupg
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -
sudo apt-get install -y nodejs
```

Verify:

```bash
node --version
npm --version
```

## Codex CLI Installation

Codex CLI was installed globally with npm:

```bash
sudo npm install -g @openai/codex
```

Verify:

```bash
command -v codex
codex --version
codex --help
```

Expected binary:

```text
/usr/bin/codex
```

## Authentication

The existing Windows Codex auth file was copied into the Linux user's Codex config folder:

```text
Windows source:
C:\Users\bee\.codex\auth.json

Linux target:
/home/gnu/.codex/auth.json
```

Verify:

```bash
codex login status
```

Expected result:

```text
Logged in using ChatGPT
```

If login is ever lost, run:

```bash
codex login
```

or use an API key:

```bash
printenv OPENAI_API_KEY | codex login --with-api-key
```

## Config

Codex config lives at:

```text
/home/gnu/.codex/config.toml
```

Current trusted project entries:

```toml
[projects.'/mnt/c/Users/bee/Documents/Codex']
trust_level = "trusted"

[projects.'/home/gnu']
trust_level = "trusted"
```

Recommended permissions:

```bash
chmod 700 /home/gnu/.codex
chmod 600 /home/gnu/.codex/config.toml
chmod 600 /home/gnu/.codex/auth.json
```

## Bubblewrap

Bubblewrap was installed so Codex can use the native Linux sandbox helper:

```bash
sudo apt-get install -y bubblewrap
```

Verify:

```bash
command -v bwrap
bwrap --version
```

Smoke test:

```bash
bwrap \
  --ro-bind /usr /usr \
  --ro-bind /lib /lib \
  --ro-bind /lib64 /lib64 \
  --ro-bind /bin /bin \
  --proc /proc \
  --dev /dev \
  --tmpfs /tmp \
  /usr/bin/env bash -lc 'echo bwrap-ok; id -u; test -w /tmp && echo tmp-writable'
```

Expected result:

```text
bwrap-ok
1000
tmp-writable
```

## Bash Completion

Codex bash completion was installed at:

```text
/etc/bash_completion.d/codex
```

Setup command:

```bash
sudo apt-get install -y bash-completion
sudo codex completion bash > /etc/bash_completion.d/codex
```

## Launching Codex

From inside WSL:

```bash
codex
```

From Windows PowerShell:

```powershell
wsl -d UbuntuClean -- codex
```

Run a non-interactive command:

```bash
codex exec "Summarize this repository"
```

## Important Path Note

Before the native Linux install, WSL found the Windows Codex app binary under `/mnt/c/...`, which failed with permission denied.

The correct Linux binary is:

```text
/usr/bin/codex
```

If Codex ever resolves to a Windows path, check:

```bash
type -a codex
echo "$PATH"
```
