# Bell

Play a configurable sound when Claude Code finishes responding.

## Requirements

- **macOS** (uses the built-in `afplay` command for system sounds)
- On other platforms, falls back to terminal bell (`\a`)

## Installation

```bash
/plugin install bell@bartadaniel-plugins
```

## Commands

```bash
/bell:configure   # choose a sound, disable, or reset to default
```

## Defaults

Plays the **Glass** macOS system sound out of the box. No configuration needed.

## Available sounds

| Sound | Description |
|-------|-------------|
| `Glass` | A bright glass clink (default) |
| `Basso` | A low-pitched, serious error tone |
| `Blow` | A short, airy whoosh |
| `Bottle` | A hollow bottle pop |
| `Frog` | A frog croak |
| `Funk` | A muted, low thud |
| `Hero` | A triumphant ascending chime |
| `Morse` | A short morse code beep |
| `Ping` | A clean, bright ping |
| `Pop` | A quick, snappy pop |
| `Purr` | A gentle, rolling purr |
| `Sosumi` | The iconic Mac "so sue me" alert |
| `Submarine` | A deep sonar ping |
| `Tink` | A quiet, delicate tap |
| `bell` | Terminal bell (depends on terminal settings) |
| `none` | Disabled — no sound |

You can also use an absolute path to any audio file `afplay` supports (`.aiff`, `.mp3`, `.wav`, etc.).

## How it works

1. `Stop` hook fires when Claude Code finishes responding
2. Script reads the configured sound from `${CLAUDE_PLUGIN_DATA}/config`
3. Plays the sound via `afplay` (backgrounded, 5s timeout) or falls back to terminal bell

## Limitations

- **macOS only** for system sounds — `afplay` is not available on Linux/Windows
- On non-macOS platforms, all sounds fall back to terminal bell
- Paths with spaces work, but terminal bell is the only cross-platform option
