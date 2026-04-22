#!/usr/bin/env bash
# Claude Code status line script
# Receives JSON on stdin with session context

input=$(cat)

# --- Model & effort ---
model=$(echo "$input" | jq -r '.model.display_name // "Unknown model"')
effort=$(echo "$input" | jq -r '.output_style.name // empty')

# --- Context window ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# --- Directory ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
if [ -n "$cwd" ]; then
  # Shorten home directory to ~
  short_cwd="${cwd/#$HOME/~}"
else
  short_cwd=$(pwd | sed "s|$HOME|~|")
fi

# --- Git branch (skip locking to avoid blocking) ---
git_branch=""
if [ -n "$cwd" ] && [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || \
               GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# --- Rate limits (Claude.ai subscribers only) ---
five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# --- Vim mode ---
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')

# ── Build the status line ──────────────────────────────────────────────────

# ANSI colors (will render dimmed in the status bar area)
RESET='\033[0m'
BOLD='\033[1m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
MAGENTA='\033[35m'
BLUE='\033[34m'
RED='\033[31m'
DIM='\033[2m'

parts=()

# 1. Directory
if [ -n "$git_branch" ]; then
  parts+=("$(printf "${CYAN}%s${RESET} ${DIM}on${RESET} ${MAGENTA}%s${RESET}" "$short_cwd" "$git_branch")")
else
  parts+=("$(printf "${CYAN}%s${RESET}" "$short_cwd")")
fi

# 2. Model + effort
if [ -n "$effort" ] && [ "$effort" != "default" ] && [ "$effort" != "Default" ]; then
  parts+=("$(printf "${GREEN}%s${RESET} ${DIM}[%s]${RESET}" "$model" "$effort")")
else
  parts+=("$(printf "${GREEN}%s${RESET}" "$model")")
fi

# 3. Context window usage
if [ -n "$used_pct" ]; then
  # Color-code by usage level
  used_int=$(printf "%.0f" "$used_pct")
  if [ "$used_int" -ge 80 ]; then
    ctx_color="$RED"
  elif [ "$used_int" -ge 50 ]; then
    ctx_color="$YELLOW"
  else
    ctx_color="$GREEN"
  fi
  parts+=("$(printf "ctx: ${ctx_color}%s%%${RESET}" "$(printf "%.0f" "$used_pct")")")
fi

# 4. Rate limits (only when present)
rate_parts=()
[ -n "$five_h" ] && rate_parts+=("$(printf "5h:${YELLOW}%.0f%%${RESET}" "$five_h")")
[ -n "$seven_d" ] && rate_parts+=("$(printf "7d:${YELLOW}%.0f%%${RESET}" "$seven_d")")
if [ ${#rate_parts[@]} -gt 0 ]; then
  parts+=("$(printf "limits: %s" "$(IFS=' '; echo "${rate_parts[*]}")")")
fi

# 5. Vim mode (only when active)
if [ -n "$vim_mode" ]; then
  if [ "$vim_mode" = "INSERT" ]; then
    parts+=("$(printf "${GREEN}-- INSERT --${RESET}")")
  elif [ "$vim_mode" = "NORMAL" ]; then
    parts+=("$(printf "${BLUE}-- NORMAL --${RESET}")")
  fi
fi

# Join parts with separator
sep="$(printf " ${DIM}|${RESET} ")"
result=""
for part in "${parts[@]}"; do
  if [ -z "$result" ]; then
    result="$part"
  else
    result="$result$sep$part"
  fi
done

printf "%b\n" "$result"
