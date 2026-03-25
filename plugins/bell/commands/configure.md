---
name: configure
description: Configure which sound plays when Claude Code finishes responding
arguments: []
---

# Configure Bell Sound

Help the user choose which sound to play when Claude Code finishes responding.

## Prerequisites

- macOS (system sounds use `afplay`; on other platforms only terminal bell is available)

## Available sounds

### Special values
- `none` — disable the sound completely
- `bell` — terminal bell character (`\a`). Depends on your terminal emulator's settings; many terminals have this muted by default.

### macOS system sounds
- `Basso` — a low-pitched, serious error tone
- `Blow` — a short, airy whoosh
- `Bottle` — a hollow bottle pop
- `Frog` — a frog croak
- `Funk` — a muted, low thud (like a denied action)
- `Glass` — a bright glass clink (default)
- `Hero` — a triumphant ascending chime
- `Morse` — a short morse code beep
- `Ping` — a clean, bright ping
- `Pop` — a quick, snappy pop
- `Purr` — a gentle, rolling purr
- `Sosumi` — the iconic Mac "so sue me" alert
- `Submarine` — a deep sonar ping
- `Tink` — a quiet, delicate tap

### Custom sound file
Any absolute path to an audio file (`.aiff`, `.mp3`, `.wav`, etc.) that `afplay` can play.

## Steps

1. Show the user the list of available sounds above.
2. Play sounds for the user so they can hear the options before choosing. Run `afplay /System/Library/Sounds/<Name>.aiff` for each sound they want to preview. If they want to hear all of them, play them one by one with a brief pause between each.
3. Once they've picked a sound, write their choice to the plugin's config file:
   - First ensure the directory exists: `mkdir -p "${CLAUDE_PLUGIN_DATA}"`
   - Then write the value to `${CLAUDE_PLUGIN_DATA}/config`:
     - To disable: write `none`
     - For terminal bell: write `bell`
     - For a system sound: write the sound name (e.g., `Glass`)
     - For a custom file: write the absolute path (e.g., `/Users/me/sounds/ding.mp3`)
   - To reset to default: delete the config file (`rm "${CLAUDE_PLUGIN_DATA}/config"`)
4. Test it by running: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/play.sh"`
5. Confirm it's working.
