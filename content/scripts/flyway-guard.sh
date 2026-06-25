#!/usr/bin/env bash
# .claude/hooks/flyway-guard.sh
# PreToolUse hook (matcher: Edit|Write|MultiEdit). Блокує зміну вже наявних
# Flyway-міграцій — застосовану міграцію редагувати не можна, лише додавати нову.
# exit 2 = заблокувати.
#
# Залежність: jq (fail-open якщо немає).

set -euo pipefail

input="$(cat)"

command -v jq >/dev/null 2>&1 || exit 0

path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
tool="$(printf '%s' "$input" | jq -r '.tool_name // empty')"

[ -z "$path" ] && exit 0

case "$path" in
  *..*)
    echo "BLOCKED by flyway-guard: path traversal detected in '$path'" >&2
    exit 2
    ;;
esac

# Каталог міграцій — підправ під свою структуру.
# Типово: src/main/resources/db/migration/V*__*.sql
case "$path" in
  *db/migration/V*__*.sql)
    # Якщо це Edit/MultiEdit наявного файлу або Write поверх існуючого — блок.
    if [ "$tool" = "Edit" ] || [ "$tool" = "MultiEdit" ] || { [ "$tool" = "Write" ] && [ -f "$path" ]; }; then
      echo "BLOCKED by flyway-guard: '$path' is an existing migration. Applied migrations are immutable — create a NEW V<next>__*.sql instead." >&2
      exit 2
    fi
    ;;
esac

exit 0
