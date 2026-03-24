#!/usr/bin/env bash
# Saves Claude Code session metadata on exit so it can be auto-resumed later.
# Called by the SessionEnd hook — receives JSON on stdin.
set -euo pipefail

if ! command -v jq &>/dev/null; then
  echo "ghostty-session: jq is required but not found" >&2
  exit 0
fi

STORE_DIR="${CLAUDE_PLUGIN_DATA}"
mkdir -p "${STORE_DIR}"

INPUT="$(cat)"

SESSION_ID="$(echo "${INPUT}" | jq -r '.session_id // empty')"
CWD="$(echo "${INPUT}" | jq -r '.cwd // empty')"

if [[ -z "${SESSION_ID}" || -z "${CWD}" ]]; then
  exit 0
fi

TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
REAL_CWD="$(cd "${CWD}" 2>/dev/null && pwd -P || echo "${CWD}")"
DIR_HASH="$(echo -n "${REAL_CWD}" | shasum -a 256 | cut -d' ' -f1)"

jq -n \
  --arg sid "${SESSION_ID}" \
  --arg cwd "${REAL_CWD}" \
  --arg ts "${TIMESTAMP}" \
  '{session_id: $sid, cwd: $cwd, timestamp: $ts}' \
  > "${STORE_DIR}/${DIR_HASH}.json"

INDEX="${STORE_DIR}/index.jsonl"
if [[ -f "${INDEX}" ]]; then
  grep -v "\"dir_hash\":\"${DIR_HASH}\"" "${INDEX}" > "${INDEX}.tmp" 2>/dev/null || true
  mv "${INDEX}.tmp" "${INDEX}"
fi
jq -n -c \
  --arg dh "${DIR_HASH}" \
  --arg sid "${SESSION_ID}" \
  --arg cwd "${REAL_CWD}" \
  --arg ts "${TIMESTAMP}" \
  '{dir_hash: $dh, session_id: $sid, cwd: $cwd, timestamp: $ts}' \
  >> "${INDEX}"

exit 0
