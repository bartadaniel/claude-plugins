#!/usr/bin/env bash
# Play the configured completion sound.
# Config: ${CLAUDE_PLUGIN_DATA}/config (single line: sound name or absolute path)
# Defaults to "Glass" (macOS system sound). Set to "none" to disable.
set -euo pipefail

CONFIG_FILE="${CLAUDE_PLUGIN_DATA:-${HOME}/.claude/bell}/config"

if [ -f "$CONFIG_FILE" ]; then
  SOUND="$(head -1 "$CONFIG_FILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
else
  SOUND=""
fi

# Default to Glass if unconfigured
SOUND="${SOUND:-Glass}"

play_sound() {
  if command -v afplay >/dev/null 2>&1; then
    afplay -t 5 "$1" 2>/dev/null &
  else
    printf '\a'
  fi
}

case "$SOUND" in
  none|off)
    # Disabled — do nothing
    ;;
  bell)
    printf '\a'
    ;;
  /*)
    # Absolute path to a sound file
    if [ -f "$SOUND" ]; then
      play_sound "$SOUND"
    else
      printf '\a'
    fi
    ;;
  *)
    # Treat as macOS system sound name
    SYSTEM_SOUND="/System/Library/Sounds/${SOUND}.aiff"
    if [ -f "$SYSTEM_SOUND" ]; then
      play_sound "$SYSTEM_SOUND"
    else
      printf '\a'
    fi
    ;;
esac
