# 006 - OpenCode with Ollama

This document records the local OpenCode setup on the Beelink WSL2 machine using Ollama as the model provider.

## Goal

- Run OpenCode locally inside WSL.
- Use Ollama as the model backend.
- Default to the local `qwen3:14b-q4_K_M` model.
- Launch OpenCode through `ollama launch opencode`, following the Ollama integration workflow.

## Current State

- OpenCode version: `1.14.19`
- OpenCode binary: `/home/gnu/.opencode/bin/opencode`
- PATH export added to: `/home/gnu/.bashrc`
- Shell wrapper command: `opencode`
- Global config: `/home/gnu/.config/opencode/opencode.json`
- Ollama version: `0.21.0`
- Ollama service: enabled and running under systemd
- Default local model: `qwen3:14b-q4_K_M`
- Secondary local models: `qwen2.5-coder:14b`, `gemma4:e4b`

## Installation

OpenCode was installed with the official installer:

```bash
curl -fsSL https://opencode.ai/install | bash
```

The installer added this to `/home/gnu/.bashrc`:

```bash
export PATH=/home/gnu/.opencode/bin:$PATH
```

To follow the Ollama-recommended integration flow, `/home/gnu/.bashrc` also defines:

```bash
opencode() {
    if [ "$#" -gt 0 ]; then
        ollama launch opencode --model qwen3:14b-q4_K_M -- "$@"
    else
        ollama launch opencode --model qwen3:14b-q4_K_M
    fi
}

alias opencode-bin='/home/gnu/.opencode/bin/opencode'
```

This makes `opencode` use the Ollama integration path by default while keeping the raw binary available as `opencode-bin`.

## OpenCode Config

Global config file:

```text
/home/gnu/.config/opencode/opencode.json
```

Current contents:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "ollama/qwen3:14b-q4_K_M",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (local)",
      "options": {
        "baseURL": "http://127.0.0.1:11434/v1"
      },
      "models": {
        "qwen3:14b-q4_K_M": {
          "name": "Qwen 3 14b Q4_K_M (local)"
        },
        "qwen2.5-coder:14b": {
          "name": "Qwen 2.5 Coder 14b (local)"
        },
        "gemma4:e4b": {
          "name": "Gemma 4 e4b (local)"
        }
      }
    }
  }
}
```

## Validation

List the configured local model:

```bash
PATH=/home/gnu/.opencode/bin:$PATH opencode models ollama
```

Expected output:

```text
ollama/gemma4:e4b
ollama/qwen2.5-coder:14b
ollama/qwen3:14b-q4_K_M
```

Run a simple prompt through the local model:

```bash
/home/gnu/.opencode/bin/opencode run -m ollama/qwen3:14b-q4_K_M "Reply with exactly: qwen3-opencode-ok"
```

Observed result:

```text
qwen3-opencode-ok
```

The request completed successfully through the local Ollama model.

## Usage

After opening a fresh shell:

```bash
opencode
```

Run non-interactively:

```bash
opencode run "Explain this repository"
```

Override the model for one run:

```bash
opencode run -m ollama/gemma4:e4b "Summarize the current directory"
```

Run the raw OpenCode binary directly if needed:

```bash
opencode-bin
```

## Notes

- OpenCode is configured globally, so any project can use the local Ollama provider by default.
- `qwen3:14b-q4_K_M` is now the default OpenCode model.
- `qwen2.5-coder:14b` and `gemma4:e4b` remain installed as secondary local options.
- The preferred entrypoint is now `ollama launch opencode`, exposed through the shell wrapper `opencode`.
