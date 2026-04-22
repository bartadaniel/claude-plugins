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
| [conventional-commits](plugins/conventional-commits) | Enforce conventional commit messages and set up commitlint + husky git hooks |
| [image-optimizer](plugins/image-optimizer) | Automatically downsize and compress images from MCP tools to reduce session size — configurable resolution and JPEG quality |
| [bell](plugins/bell) | Play a configurable sound when Claude Code finishes responding — choose from macOS system sounds or a custom audio file |
| [my-settings](plugins/my-settings) | Sync global Claude Code settings (model, env, status line, MCP servers, plugins) to a fresh machine via `/sync-my-settings` |

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
