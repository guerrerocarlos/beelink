# 007 - Aider with Ollama

This document records the local Aider setup on the Beelink WSL2 machine using Ollama as the model backend.

## Goal

- Run Aider locally inside WSL.
- Use Ollama as the model backend.
- Default to the local `qwen2.5-coder:14b` model.

## Current State

- Aider version: `0.86.2`
- Aider binary: `/home/gnu/.local/bin/aider`
- User bin path added to: `/home/gnu/.bashrc`
- Ollama API base: `http://127.0.0.1:11434`
- Default Aider model: `ollama_chat/qwen2.5-coder:14b`
- Raw binary alias: `aider-bin`

## Installation

Aider was installed using the official installer:

```bash
curl -LsSf https://aider.chat/install.sh | sh
```

This installed:

- `uv`
- `uvx`
- `aider`

into:

```text
/home/gnu/.local/bin
```

## Shell Setup

The following was added to `/home/gnu/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
export OLLAMA_API_BASE="http://127.0.0.1:11434"

aider() {
    if [ "$#" -gt 0 ]; then
        /home/gnu/.local/bin/aider --model ollama_chat/qwen2.5-coder:14b --no-show-model-warnings "$@"
    else
        /home/gnu/.local/bin/aider --model ollama_chat/qwen2.5-coder:14b --no-show-model-warnings
    fi
}

alias aider-bin='/home/gnu/.local/bin/aider'
```

This makes `aider` use the Ollama-backed Qwen model by default while keeping the raw binary accessible as `aider-bin`.

## Why `ollama_chat/`

Per Aider’s Ollama docs, `ollama_chat/<model>` is recommended over `ollama/<model>`.

## Validation

One-shot validation command:

```bash
cd /home/gnu
aider --message "Reply with exactly: aider-ok" --exit
```

Observed result:

```text
aider-ok
```

## Usage

After opening a fresh shell:

```bash
cd /path/to/repo
aider
```

One-shot message:

```bash
cd /path/to/repo
aider --message "Summarize this repository" --exit
```

Run the raw binary directly:

```bash
aider-bin
```

## Notes

- Use Aider from the repository root, not `/home/gnu`, so repo mapping and git integration work properly.
- Ollama must be running locally for Aider to connect.
- The default local model is `qwen2.5-coder:14b`, which is a better fit for coding than the local Gemma model on this machine.
