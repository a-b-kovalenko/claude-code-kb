#!/usr/bin/env bash

input=$(cat)
file=$(printf '%s' "$input" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('file_path', ''))
" 2>/dev/null || true)

[[ "$file" == *.md ]] || exit 0
[[ "$file" == "$CLAUDE_PROJECT_DIR"/* ]] || exit 0

if ! result=$(markdownlint "$file" 2>&1); then
  echo "$result"
  exit 2
fi