#!/usr/bin/env bash
# Auto-names Claude Code sessions after the first exchange.
# Called by the Stop hook — receives JSON on stdin.
# Extracts the first user message, asks Haiku to generate a slug-style
# session name, and writes a custom-title entry to the conversation JSONL.
set -euo pipefail

if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT="$(cat)"

SESSION_ID="$(echo "${INPUT}" | jq -r '.session_id // empty')"
CWD="$(echo "${INPUT}" | jq -r '.cwd // empty')"

if [[ -z "${SESSION_ID}" || -z "${CWD}" ]]; then
  exit 0
fi

# Validate session ID is a UUID (prevent path traversal)
if [[ ! "${SESSION_ID}" =~ ^[a-f0-9-]+$ ]]; then
  exit 0
fi

# --- Locate the conversation JSONL file ---
PROJECTS_DIR="${HOME}/.claude/projects"
PROJECT_SLUG="$(echo "${CWD}" | sed 's|/|-|g')"
JSONL_FILE="${PROJECTS_DIR}/${PROJECT_SLUG}/${SESSION_ID}.jsonl"

if [[ ! -f "${JSONL_FILE}" ]]; then
  exit 0
fi

# Skip if session already has a name
if grep -q '"type":"custom-title"' "${JSONL_FILE}" 2>/dev/null; then
  exit 0
fi

# --- Extract the first user message ---
FIRST_MESSAGE="$( (grep '"type":"user"' "${JSONL_FILE}" || true) \
  | head -5 \
  | jq -r '.message.content | if type == "string" then . elif type == "array" then [.[] | select(.type == "text") | .text] | join(" ") else empty end' 2>/dev/null \
  | (grep -v "^<" || true) \
  | head -1)"

if [[ -z "${FIRST_MESSAGE}" ]]; then
  exit 0
fi

# Trim to first 500 chars to keep the prompt small
FIRST_MESSAGE="${FIRST_MESSAGE:0:500}"

# --- Generate session name via Haiku ---
SESSION_NAME="$(claude -p --model haiku --no-session-persistence \
  --system-prompt "You generate short slug-style names. Reply with ONLY the slug, nothing else." \
  "Name this session based on what the user asked: ${FIRST_MESSAGE}. Reply with a 3-6 word lowercase hyphenated slug (e.g. fix-auth-timeout-bug, build-session-namer-plugin)." \
  2>/dev/null || true)"

# Clean up — trim whitespace, take first line only
SESSION_NAME="$(echo "${SESSION_NAME}" | head -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

# Validate: must look like a slug and be reasonable length
if [[ -z "${SESSION_NAME}" || ${#SESSION_NAME} -gt 60 || ! "${SESSION_NAME}" =~ ^[a-z0-9][a-z0-9-]*[a-z0-9]$ ]]; then
  exit 0
fi

# --- Append custom-title entry ---
jq -n -c \
  --arg title "${SESSION_NAME}" \
  --arg sid "${SESSION_ID}" \
  '{"type":"custom-title","customTitle":$title,"sessionId":$sid}' \
  >> "${JSONL_FILE}"
