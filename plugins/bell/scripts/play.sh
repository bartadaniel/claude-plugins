#!/usr/bin/env bash
# Play the configured bell sound.
# Config file: ~/.claude/bell.conf (single line: sound name or absolute path)
# Defaults to terminal bell if no config or sound is "bell".

CONFIG_FILE="${HOME}/.claude/bell.conf"

if [ -f "$CONFIG_FILE" ]; then
  SOUND="$(head -1 "$CONFIG_FILE" | tr -d '[:space:]')"
else
  SOUND="bell"
fi

case "$SOUND" in
  ""|"bell")
    printf '\a'
    ;;
  /*)
    # Absolute path to a sound file
    if [ -f "$SOUND" ]; then
      afplay "$SOUND" &
    else
      printf '\a'
    fi
    ;;
  *)
    # Treat as macOS system sound name
    SYSTEM_SOUND="/System/Library/Sounds/${SOUND}.aiff"
    if [ -f "$SYSTEM_SOUND" ]; then
      afplay "$SYSTEM_SOUND" &
    else
      printf '\a'
    fi
    ;;
esac
