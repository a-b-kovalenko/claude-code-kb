#!/usr/bin/env bash
# .claude/hooks/bash-guard.sh
# PreToolUse hook (matcher: Bash). Читає JSON зі stdin, перевіряє команду
# на небезпечні патерни. exit 2 = заблокувати (причина в stderr йде до Claude).
#
# Залежність: jq. Якщо jq немає — hook пропускає перевірку (fail-open), щоб не
# ламати workflow; для строгого режиму заміни на fail-closed (exit 2).

set -euo pipefail

input="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  # jq відсутній — не блокуємо (fail-open). Для строгості: >&2 echo "..."; exit 2
  exit 0
fi

cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"

[ -z "$cmd" ] && exit 0

# Небезпечні патерни. Розширюй під свій проєкт.
deny() { echo "BLOCKED by bash-guard: $1" >&2; exit 2; }

case "$cmd" in
  *"rm -rf /"*|*"rm -rf ~"*|*"rm -rf ."*)
    deny "destructive rm detected" ;;
  *"DROP TABLE"*|*"DROP DATABASE"*|*"TRUNCATE"*)
    deny "destructive SQL detected" ;;
  *"git push"*"--force"*|*"git push -f"*)
    deny "force push detected" ;;
  *"git reset --hard"*)
    deny "hard reset detected — confirm manually" ;;
esac

# Заборона звертатись до prod-конекшна (приклад — підправ під свої env/hosts).
case "$cmd" in
  *"prod"*|*"production"*)
    case "$cmd" in
      *"psql"*|*"flyway"*|*"kafka"*)
        deny "command targets a production resource" ;;
    esac ;;
esac

exit 0
