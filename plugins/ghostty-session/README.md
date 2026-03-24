# ghostty-session

Auto-save and auto-resume Claude Code sessions across terminal restarts.

Designed for a Ghostty + parallel Claude Code workflow on macOS where you run multiple named sessions in split panes and want everything to come back after a reboot.

## How it works

1. A `SessionEnd` hook saves the session ID for each working directory
2. A shell function (`c`) checks for a saved session when you launch Claude and resumes it automatically
3. Ghostty's `window-save-state` restores your pane layout, and `c` reconnects each session

## Installation

```bash
/plugin install ghostty-session@bartadaniel-plugins
```

The `Setup` hook automatically:
- Copies the shell integration to `~/.claude/ghostty-session/claude-resume.zsh`
- Adds a `source` line to `~/.zshrc`
- Adds `window-save-state` and `shell-integration` settings to your Ghostty config

If any step can't write to the target file, it prints what to add manually instead of failing.

After installation, restart your terminal or run `source ~/.zshrc` for the shell commands to become available.

## Usage

| Command | Description |
|---------|-------------|
| `c`     | Launch Claude — auto-resumes the saved session for the current directory, or starts fresh |
| `c -w feat -n "feat"` | All `claude` args are forwarded when no saved session exists |
| `cs`    | List all saved sessions across directories |
| `cx`    | Clear saved session for current directory without resuming |

## Typical workflow

```bash
# Start parallel sessions in Ghostty split panes
c -w auth -n "auth"      # pane 1
c -w api -n "api"        # pane 2

# Work, then close the terminal / reboot

# Ghostty restores the layout and working directories
# In each pane, just run:
c
# → "Resuming session a1b2c3d4… (saved 2026-03-24T14:30:00Z)"
```

## Data storage

Session data is stored in the plugin's data directory (`${CLAUDE_PLUGIN_DATA}`), which is automatically cleaned up when you uninstall the plugin. Each directory gets a JSON file (keyed by path hash) with the last session ID, plus an `index.jsonl` for listing via `cs`.

The `c` function consumes the saved session on resume (deletes the file), so running `c` twice starts a fresh session the second time. If the resume fails (e.g. stale session), the saved session is preserved for retry.

## Uninstall

Claude Code does not currently expose an uninstall hook, so some manual steps are required:

1. `/plugin uninstall ghostty-session@bartadaniel-plugins` — this automatically deletes session data
2. Remove the `source` line and its comment from `~/.zshrc`:
   ```
   # Claude Code session resume (ghostty-session plugin)
   source "~/.claude/ghostty-session/claude-resume.zsh"
   ```
3. Remove the `# Added by ghostty-session plugin` block from your Ghostty config
4. `rm -rf ~/.claude/ghostty-session/`

## Requirements

- macOS
- zsh
- `jq` (`brew install jq`)
- Ghostty

## Credits

Inspired by [Erik Zaadi's auto-resume approach](https://erikzaadi.com/2026/02/15/auto-resume-claude-code-sessions/) using `SessionEnd` hooks and a shell function — packaged here as a Ghostty-native plugin with automated setup.
