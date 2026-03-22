# dev-conventions

General development conventions automatically injected into every Claude Code session via a `SessionStart` hook.

## What it does

When a session starts, the plugin loads `rules.md` and injects it as additional context. The rules cover:

- **Agent Autonomy** — disagree when a proposed approach is wrong
- **Clean Code** — no copy-paste, extract shared utilities
- **Systems Thinking** — reuse before creating, respect architecture
- **Documentation** — capture tribal knowledge proactively
- **Git** — atomic commits

## Installation

```bash
/plugin install dev-conventions@bartadaniel-plugins
```

## Customization

Edit `rules.md` to add, remove, or modify conventions. Changes take effect on next session start after a plugin update.
