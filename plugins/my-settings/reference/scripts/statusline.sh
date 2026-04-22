#!/bin/bash
input=$(cat)

# Directory and git branch
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir=$(basename "$cwd")
branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
    [ -n "$branch" ] && branch=" ($branch)"
fi

# Model, output style, effort
model=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name')
effort=$(echo "$input" | jq -r '.effort_level // empty')

# Context percentage
context=""
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ]; then
    current=$(echo "$usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    size=$(echo "$input" | jq '.context_window.context_window_size')
    if [ "$current" -gt 0 ] 2>/dev/null && [ "$size" -gt 0 ] 2>/dev/null; then
        pct=$((current * 100 / size))
        context="${pct}% context"
    fi
fi

# Cost (formatted to 2 decimals)
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
cost_display=$(printf "\$%.2f" "$cost")

# Build effort display
effort_display=""
[ -n "$effort" ] && effort_display=" | effort:$effort"

printf "%s%s | %s | %s | %s | %s%s" "$dir" "$branch" "$model" "$output_style" "$context" "$cost_display" "$effort_display"
