#!/usr/bin/env bash
# Sets up ghostty-session plugin:
#   1. Copies shell integration to a stable path (with resolved data dir)
#   2. Adds source line to ~/.zshrc
#   3. Adds recommended Ghostty settings
set -euo pipefail

DEST_DIR="${HOME}/.claude/ghostty-session"
DATA_DIR="${CLAUDE_PLUGIN_DATA}"
SRC="${CLAUDE_PLUGIN_ROOT}/scripts/claude-resume.zsh"
SOURCE_LINE="source \"${DEST_DIR}/claude-resume.zsh\""
ZSHRC="${HOME}/.zshrc"

# --- 1. Copy shell integration with resolved data path ---
mkdir -p "${DEST_DIR}"
mkdir -p "${DATA_DIR}"
sed "s|__CLAUDE_SESSION_STORE__|${DATA_DIR}|g" "${SRC}" > "${DEST_DIR}/claude-resume.zsh"

# --- 2. Add source line to .zshrc ---
if ! grep -qF "ghostty-session/claude-resume.zsh" "${ZSHRC}" 2>/dev/null; then
  if printf '\n# Claude Code session resume (ghostty-session plugin)\n%s\n' "${SOURCE_LINE}" >> "${ZSHRC}" 2>/dev/null; then
    echo "Added shell integration to ${ZSHRC}"
  else
    echo "Could not write to ${ZSHRC}. Add this line manually:"
    echo "  ${SOURCE_LINE}"
  fi
fi

# --- 3. Configure Ghostty ---
GHOSTTY_DIR="${HOME}/Library/Application Support/com.mitchellh.ghostty"
GHOSTTY_CONFIG=""

for name in "config.ghostty" "config"; do
  if [[ -f "${GHOSTTY_DIR}/${name}" ]]; then
    GHOSTTY_CONFIG="${GHOSTTY_DIR}/${name}"
    break
  fi
done

if [[ -z "${GHOSTTY_CONFIG}" ]]; then
  mkdir -p "${GHOSTTY_DIR}"
  GHOSTTY_CONFIG="${GHOSTTY_DIR}/config.ghostty"
fi

GHOSTTY_SETTINGS=(
  "window-save-state = always"
  "shell-integration = detect"
)

added=()
for setting in "${GHOSTTY_SETTINGS[@]}"; do
  key="${setting%% =*}"
  if ! grep -q "^${key}" "${GHOSTTY_CONFIG}" 2>/dev/null; then
    added+=("${setting}")
  fi
done

if [[ ${#added[@]} -gt 0 ]]; then
  if {
    printf '\n# Added by ghostty-session plugin\n'
    for setting in "${added[@]}"; do
      printf '%s\n' "${setting}"
    done
  } >> "${GHOSTTY_CONFIG}" 2>/dev/null; then
    echo "Added Ghostty settings to ${GHOSTTY_CONFIG}: ${added[*]}"
  else
    echo "Could not write to ${GHOSTTY_CONFIG}. Add these settings manually:"
    for setting in "${added[@]}"; do
      echo "  ${setting}"
    done
  fi
fi
