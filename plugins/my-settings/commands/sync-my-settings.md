---
description: "Sync global Claude Code settings (model, env, status line, MCP servers, plugins) from this plugin's reference config"
argument-hint: ""
---

# Sync My Settings

Sync the user's global Claude Code config at `~/.claude/` to match this plugin's reference files. Compute a diff, show a plan, ask for confirmation, then apply. Never write without explicit confirmation. Never delete keys that aren't in the reference — this is purely additive/updating.

## 1. Locate the reference directory

Use Glob to find this plugin's install directory:

```
~/.claude/plugins/cache/*/my-settings/*/reference/settings.json
```

The parent directory of that match (containing `settings.json`, `mcp-servers.json`, `statusline-command.sh`, and `zshrc-snippet.sh`) is the reference root. Call it `$REF`.

## 2. Read all sources in parallel

**Reference** (from `$REF`):
- `settings.json`
- `mcp-servers.json`
- `statusline-command.sh`
- `zshrc-snippet.sh`

**Current state:**
- `~/.claude/settings.json`
- `mcpServers` from `~/.claude.json` — use `jq '.mcpServers' ~/.claude.json` (do NOT Read the full file; it's large)
- `~/.claude/statusline-command.sh` (may not exist on a fresh machine)
- `~/.claude/plugins/installed_plugins.json` (to see which plugins are already installed)
- `~/.zshrc` (may not exist on a fresh machine)

## 3. Compute the diff

### settings.json merge rules

For each top-level key in the reference:
- **Scalars** (`model`, `voiceEnabled`, `skipAutoPermissionPrompt`, `skipDangerousModePermissionPrompt`): if current value differs, mark `update`; if missing, mark `add`.
- **Objects** (`env`, `attribution`, `permissions`, `enabledPlugins`): apply the scalar rule per sub-key. Reference wins on conflict. **Preserve existing sub-keys not in the reference.**
- **`statusLine`**: deep-compare the whole block; if different or missing, mark `update`/`add`.

**Never touch top-level keys the reference doesn't specify** (e.g., `hooks`, `extraKnownMarketplaces`, `mcpServers`).

### MCP servers

For each server in `$REF/mcp-servers.json`:
- Not in current `mcpServers`: `install`
- Present with different `command`/`args`/`env`: `update`
- Identical: `unchanged`

### Plugins (from reference `enabledPlugins`)

For each plugin:
- Not in `installed_plugins.json`: `install + enable`
- Installed but not `true` in current `enabledPlugins`: `enable`
- Already installed and enabled: `unchanged`

### Statusline script

Compare content byte-for-byte. If different or target missing: `replace`.

### Zshrc snippet

The reference file `$REF/zshrc-snippet.sh` is a managed block delimited by sentinel markers:

```
# >>> claude-my-settings >>>
...
# <<< claude-my-settings <<<
```

Locate the block in `~/.zshrc`:
- File or block missing entirely → `add` (append the snippet on its own, separated by a blank line if the file doesn't already end with one).
- Block present but its content (markers + body) differs from the reference → `update` (replace the block in place, preserving everything outside the markers).
- Identical → `unchanged`.

**Never touch lines outside the sentinel markers.** If `~/.zshrc` contains an existing `alias claude=...` outside the managed block, flag it in the plan but do not modify it — the user can resolve the conflict.

## 4. Present the plan

Print a grouped summary, skipping empty sections. Example:

```
Proposed changes:

Settings (~/.claude/settings.json):
  + env.CLAUDE_CODE_EFFORT_LEVEL = "xhigh"
  ~ model: "sonnet" → "opus[1m]"
  + voiceEnabled = true
  ...

MCP servers (~/.claude.json):
  + install chrome-devtools

Plugins (will auto-install on Claude Code restart):
  + enable typescript-lsp@claude-plugins-official
  + enable clangd-lsp@claude-plugins-official
  + enable vercel@claude-plugins-official

Files:
  + write ~/.claude/statusline-command.sh

Shell (~/.zshrc):
  + add managed block (alias claude='claude --allow-dangerously-skip-permissions')
```

For scalar updates, always show `old → new`. For adds, show the value being added.

If the diff is empty everywhere, print **"Everything is already in sync."** and stop.

## 5. Ask for confirmation

Ask exactly: **"Apply all changes? (y/n)"**

Wait for explicit `y`/`yes`. Any other response = abort without writing.

## 6. Apply (only after confirmation)

### Backup first

Create `~/.claude/backups/sync-<timestamp>/` using `date +%Y%m%d-%H%M%S`. Copy:
- `~/.claude/settings.json` → `<backup>/settings.json`
- `~/.claude.json` → `<backup>/claude.json`
- `~/.claude/statusline-command.sh` → `<backup>/statusline-command.sh` (if exists)
- `~/.zshrc` → `<backup>/zshrc` (if exists)

### Merge `~/.claude/settings.json`

1. Read the current file.
2. Apply the merge rules from step 3, producing the new JSON in memory.
3. Write pretty-printed JSON (2-space indent).

### Merge MCP servers in `~/.claude.json`

Use `jq` to deep-merge — don't Read/Write the whole file:

```bash
jq --slurpfile ref "$REF/mcp-servers.json" '.mcpServers = ((.mcpServers // {}) * $ref[0])' ~/.claude.json > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json
```

Verify with `jq '.mcpServers' ~/.claude.json`.

### Copy statusline script

```bash
cp "$REF/statusline-command.sh" ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
```

### Update `~/.zshrc` managed block

Algorithm:

1. `touch ~/.zshrc` if missing.
2. Check whether `~/.zshrc` already contains the start marker `# >>> claude-my-settings >>>`.
3. **If the block exists**: produce a new file by copying every line from `~/.zshrc`, except replace the run from the start marker through the end marker (inclusive) with the contents of `$REF/zshrc-snippet.sh`. `awk` is a clean way to do this — gate output on a flag flipped by the markers, and emit the snippet when the start marker is seen.
4. **If the block does not exist**: copy `~/.zshrc` verbatim, ensure it ends with a newline, append a blank separator line if the previous content was non-empty, then append `$REF/zshrc-snippet.sh`.
5. Write to `~/.zshrc.tmp` first, then `mv` atomically over `~/.zshrc`.

Do **not** `chmod` or `source` the file — the user's next shell will pick it up.

### Plugins

Plugin installation is handled by Claude Code itself. Writing `enabledPlugins` to `settings.json` (step above) is sufficient — missing plugins will auto-install on next Claude Code start.

## 7. Report

Print:
- Summary of what was applied (one line per category)
- Backup path
- **"Restart Claude Code for changes to take effect (especially plugins and MCP servers)."**

## Safety rules

- Never delete keys from current state that aren't in the reference.
- Never write anything without creating the backup directory first.
- Never apply without explicit user confirmation (`y`/`yes`).
- On any error mid-apply, stop immediately and point the user to the backup. Do not attempt partial rollback.
