---
name: configure
description: Configure which sound plays when Claude Code finishes responding
arguments: []
---

# Configure Bell Sound

Help the user choose which sound to play when Claude Code finishes responding.

## Available sounds

### Terminal bell (default)
- `bell` — the standard terminal bell character (`\a`). The actual sound depends on your terminal emulator's settings.

### macOS system sounds
- `Basso` — low-pitched error tone
- `Blow` — a soft blow
- `Bottle` — a bottle pop
- `Frog` — a frog croak
- `Funk` — a funky error tone
- `Glass` — a glass clink (classic Mac alert)
- `Hero` — a heroic chime
- `Morse` — a morse code beep
- `Ping` — a clean, bright ping
- `Pop` — a short pop
- `Purr` — a gentle purr
- `Sosumi` — the iconic Mac "so sue me" sound
- `Submarine` — a submarine sonar ping
- `Tink` — a tiny tink

### Custom sound file
Any absolute path to an audio file (`.aiff`, `.mp3`, `.wav`, etc.) that `afplay` can play.

## Steps

1. Show the user the list of available sounds above.
2. Ask which sound they'd like. If they want to hear one first, run: `afplay /System/Library/Sounds/<Name>.aiff`
3. Once they pick a sound, write their choice (just the name, e.g. `Glass`) to `~/.claude/bell.conf`:
   - For terminal bell: write `bell`
   - For a system sound: write the sound name (e.g. `Glass`)
   - For a custom file: write the absolute path (e.g. `/Users/me/sounds/ding.mp3`)
4. Test it by running: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/play.sh"`
5. Confirm it's working.
