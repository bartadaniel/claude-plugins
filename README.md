# @bartadaniel/claude-code-plugins

A continuously evolving personal Claude Code infrastructure.

## Plugins

| Plugin&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Description |
|------|-------------|
| [git-poster](plugins/git-poster) | Generate creative poster-style visualizations of your git contributions across 17 artistic styles |
| [apple-notes](plugins/apple-notes) | Access and manage Apple Notes — list, create, read, update, delete, search, tag, batch operations, export, and organize with AI-suggested folder structure and tagging |
| [billingo](plugins/billingo) | Manage invoices, partners, products, and expenses via the Billingo Hungarian invoicing API — includes guided invoice creation and spending entry workflows |
| [dev-conventions](plugins/dev-conventions) | General development conventions automatically injected into every session via a SessionStart hook |
| [grill-me](plugins/grill-me) | Interview relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree |
| [ghostty-session](plugins/ghostty-session) | Auto-save and auto-resume Claude Code sessions across terminal restarts with Ghostty |
| [conventional-commits](plugins/conventional-commits) | Enforce conventional commit messages and set up commitlint + husky git hooks |
| [image-optimizer](plugins/image-optimizer) | Automatically downsize and compress images from MCP tools to reduce session size — configurable resolution and JPEG quality |

## Installation

1. Add the marketplace:

```bash
/plugin marketplace add bartadaniel/claude-plugins
```

2. Install a plugin:

```bash
/plugin install billingo@bartadaniel-plugins
```

## License

MIT
