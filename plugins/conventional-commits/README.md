# conventional-commits

A Claude Code plugin that enforces [Conventional Commits](https://www.conventionalcommits.org/) across all AI-generated commit messages and provides tooling to set up git hooks in your project.

## What it does

**On every session start**, the plugin injects conventional commit rules into Claude's context. This means every commit Claude creates will follow the spec — with proper types, scopes, and descriptive bodies that explain the *why*, not just the *what*.

**On demand**, the `/conventional-commits:setup-hooks` command sets up commitlint + husky in your Node.js project, adding:
- A `commit-msg` hook that validates every commit message at creation time
- A `pre-push` hook that validates all commits before they reach the remote (catches `--no-verify` bypasses)

## Installation

```
/plugin install conventional-commits@bartadaniel-plugins
```

## Usage

### Automatic rules (no action needed)

Once installed, Claude will automatically follow conventional commit formatting. The rules cover:
- Commit message format (`type(scope): subject`)
- Allowed types (feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert)
- Body quality guidelines (reasoning, alternatives considered, root cause)

### Setting up git hooks

Run the command in any Node.js project:

```
/conventional-commits:setup-hooks
```

This installs commitlint + husky and creates the git hooks. Supports npm, yarn, pnpm, and bun.

## Commit types

| Type | When to use |
|------|-------------|
| `feat` | A new feature visible to the end user |
| `fix` | A bug fix |
| `docs` | Documentation-only changes |
| `style` | Formatting, whitespace — no logic change |
| `refactor` | Code restructuring, no behavior change |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `build` | Build system or dependency changes |
| `ci` | CI/CD configuration |
| `chore` | Maintenance tasks |
| `revert` | Reverts a previous commit |
