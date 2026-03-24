#!/usr/bin/env zsh
# Shell integration for the ghostty-session plugin.
# Installed to: ~/.claude/ghostty-session/claude-resume.zsh

if ! command -v jq &>/dev/null; then
  echo "ghostty-session: jq is required but not found. Install with: brew install jq" >&2
fi

CLAUDE_SESSION_STORE="__CLAUDE_SESSION_STORE__"

# c — smart Claude launcher
# In a directory with a saved session: resumes it.
# Otherwise: starts a new session, forwarding all arguments.
c() {
  if ! command -v jq &>/dev/null; then
    echo "ghostty-session: jq required. Install with: brew install jq" >&2
    claude "$@"
    return
  fi

  local real_cwd dir_hash session_file session_id saved_ts

  real_cwd="$(pwd -P)"
  dir_hash="$(echo -n "${real_cwd}" | shasum -a 256 | cut -d' ' -f1)"
  session_file="${CLAUDE_SESSION_STORE}/${dir_hash}.json"

  if [[ -f "${session_file}" ]]; then
    session_id="$(jq -r '.session_id' "${session_file}")"
    saved_ts="$(jq -r '.timestamp' "${session_file}")"

    if [[ ! "${session_id}" =~ ^[a-f0-9-]+$ ]]; then
      echo "ghostty-session: invalid session ID, starting fresh."
      rm -f "${session_file}"
      claude "$@"
      return
    fi

    echo "Resuming session ${session_id:0:8}… (saved ${saved_ts})"
    claude --resume "${session_id}"
    local rc=$?

    # Only consume the saved session if resume succeeded
    if [[ $rc -eq 0 ]]; then
      rm -f "${session_file}"
      local index="${CLAUDE_SESSION_STORE}/index.jsonl"
      if [[ -f "${index}" ]]; then
        grep -v "\"dir_hash\":\"${dir_hash}\"" "${index}" > "${index}.tmp" 2>/dev/null || true
        mv "${index}.tmp" "${index}"
      fi
    fi
  else
    claude "$@"
  fi
}

# cs — list all saved sessions
cs() {
  local index="${CLAUDE_SESSION_STORE}/index.jsonl"

  if [[ ! -f "${index}" || ! -s "${index}" ]]; then
    echo "No saved sessions."
    return 0
  fi

  echo "Saved Claude sessions:"
  echo ""
  printf "%-50s %-10s %s\n" "DIRECTORY" "SESSION" "SAVED AT"
  printf "%-50s %-10s %s\n" "---------" "-------" "--------"

  while IFS= read -r line; do
    local cwd sid ts
    cwd="$(echo "${line}" | jq -r '.cwd')"
    sid="$(echo "${line}" | jq -r '.session_id')"
    ts="$(echo "${line}" | jq -r '.timestamp')"
    cwd="${cwd/#$HOME/~}"
    printf "%-50s %-10s %s\n" "${cwd}" "${sid:0:8}…" "${ts}"
  done < "${index}"
}

# cx — clear saved session for current directory without resuming
cx() {
  local real_cwd dir_hash session_file

  real_cwd="$(pwd -P)"
  dir_hash="$(echo -n "${real_cwd}" | shasum -a 256 | cut -d' ' -f1)"
  session_file="${CLAUDE_SESSION_STORE}/${dir_hash}.json"

  if [[ -f "${session_file}" ]]; then
    rm -f "${session_file}"
    local index="${CLAUDE_SESSION_STORE}/index.jsonl"
    if [[ -f "${index}" ]]; then
      grep -v "\"dir_hash\":\"${dir_hash}\"" "${index}" > "${index}.tmp" 2>/dev/null || true
      mv "${index}.tmp" "${index}"
    fi
    echo "Cleared saved session for $(pwd)."
  else
    echo "No saved session for $(pwd)."
  fi
}
