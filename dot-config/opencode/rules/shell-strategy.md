# Shell Strategy

- Assume `CI=true` and fully headless execution.
- Never wait for user interaction during execution.
- Continue workflows autonomously until task completion.

# Execution Rules

- Never use editors, pagers, REPLs, or interactive shells.
- Never use interactive flags/prompts (`-i`, confirmations, editors, pagers).
- Always prefer non-interactive/force/yes flags.
- Prefer deterministic machine-readable output.
- Prefer scripted/one-shot commands over interactive sessions.
- Use timeouts for commands that may block.
- Use pipes/heredocs for unavoidable stdin prompts.

# File Operations

- Prefer OpenCode Read/Write/Edit tools over shell text manipulation.
- Avoid inline editing pipelines when dedicated tools exist.

# Environment

- Assume:
  - `CI=true`
  - `DEBIAN_FRONTEND=noninteractive`
  - `GIT_TERMINAL_PROMPT=0`
  - `GIT_EDITOR=true`
  - `GIT_PAGER=cat`
  - `PAGER=cat`
  - `GCM_INTERACTIVE=never`
  - `npm_config_yes=true`
  - `PIP_NO_INPUT=1`

# Commands

- Package managers must use non-interactive flags/options.
- Git workflows must avoid interactive commit/rebase/staging modes.
- Filesystem operations should prefer force/overwrite flags.
- SSH/SCP must use batch/non-interactive mode.
- Never start interactive runtimes (`python`, `node`, shells`) without script/command mode.
- Docker must avoid TTY/interative flags (`-it`).

# Cognitive Strategy

- Prefer explicit actionable commands over prohibitions.
- Treat blocking prompts as execution failures.
- Follow repository-specific instructions over generic defaults.
- Prefer known-safe command variants over inferred alternatives.
