[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Хук — це shell-скрипт, що отримує JSON через stdin і керує поведінкою агента через exit-код. `exit 2` блокує дію, `exit 0` зі stdout — надсилає агенту зворотний зв'язок без блокування. Хуки дають детерміновані гарантії там, де інструкції в `CLAUDE.md` можуть бути проігноровані.

## Події хуків

| Подія | Коли спрацьовує | Типове використання |
| :--- | :--- | :--- |
| **PreToolUse** | До виконання інструменту | Блокування, перевірки безпеки |
| **PostToolUse** | Після успішного виконання | Форматування, логування, оновлення |
| **Stop** | Коли агент завершує відповідь | Нагадування, пост-перевірки |
| **PreCompact** | Перед стисненням контексту | Збереження важливих даних |
| **Notification** | При системних сповіщеннях | Моніторинг, алерти |

Для більшості захисних задач достатньо **PreToolUse** та **PostToolUse**.

## Анатомія хук-скрипту

### Вхідні дані (stdin)

Кожен хук отримує JSON-об'єкт через stdin. Структура залежить від інструменту:

```json
// PreToolUse для Edit
{
  "session_id": "abc123",
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "/project/src/main/java/com/example/Service.java",
    "old_string": "old code",
    "new_string": "new code"
  }
}

// PreToolUse для Bash
{
  "session_id": "abc123",
  "tool_name": "Bash",
  "tool_input": {
    "command": "git push --force"
  }
}
```

Завжди читайте stdin через `input="$(cat)"` і парсьте через `jq`.

### Exit-коди

| Код | Значення | Що бачить агент |
| :--- | :--- | :--- |
| `0` | Дозволити. Якщо є stdout — агент отримує його як контекст | Інформаційне повідомлення |
| `1` | Некритична помилка | stderr як попередження |
| `2` | **Заблокувати дію** | stderr як причина відмови |

### Зворотний зв'язок без блокування (exit 0 + stdout)

Хук може надіслати агенту інформацію, не зупиняючи дію:

```bash
#!/usr/bin/env bash
input="$(cat)"
file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"

# Попередити агента про складний файл, але не блокувати
if echo "$file" | grep -q "SecurityConfig"; then
  echo "NOTE: SecurityConfig.java has 3 known security reviewers. Consider tagging them in the PR."
fi

exit 0
```

Агент прочитає цей stdout і врахує в наступних кроках.

## Конфігурація в settings.json

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/my-guard.sh\""
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/change-logger.sh\"",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

**`matcher`** — регулярний вираз або рядок. `"Edit|Write"` спрацює на обидва інструменти.
**`timeout`** — секунди. Якщо скрипт не завершився — вважається успіхом (exit 0).

## Практичний приклад 1: захист `.env`-файлів

```bash
#!/usr/bin/env bash
# .claude/hooks/env-guard.sh
set -euo pipefail

input="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0

file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
[ -z "$file" ] && exit 0

case "$file" in
  *.env|*.env.local|*.env.production|*secrets*)
    echo "BLOCKED by env-guard: '$file' may contain secrets. Edit manually." >&2
    exit 2
    ;;
esac

exit 0
```

## Практичний приклад 2: логування змін у файл

```bash
#!/usr/bin/env bash
# .claude/hooks/change-logger.sh — PostToolUse
set -euo pipefail

input="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0

file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
tool="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
[ -z "$file" ] && exit 0

log="$CLAUDE_PROJECT_DIR/.claude/agent-changes.log"
echo "$(date -u +%FT%TZ)  $tool  $file" >> "$log"

exit 0
```

Додайте `.claude/agent-changes.log` до `.gitignore`. Отримаєте хронологію всіх файлів, які торкав агент у поточній сесії.

## Відлагодження хуків

Хуки не показують stdout у терміналі під час нормальної роботи. Для налагодження:

```bash
# Тимчасово увімкнути детальне логування в скрипті
exec 2>>"/tmp/hook-debug.log"
set -x
```

Або протестуйте скрипт вручну, передавши тестовий JSON:

```bash
echo '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.env"}}' \
  | bash .claude/hooks/env-guard.sh
echo "Exit: $?"
```

## Безпека

- Хуки виконуються з правами вашого користувача — аудитуйте скрипти перед використанням.
- Не кладіть секрети напряму в команди `settings.json` — використовуйте змінні середовища.
- `CLAUDE_PROJECT_DIR` — єдина надійна змінна для побудови шляхів усередині хука.
- Зберігайте скрипти в `.claude/hooks/` і версіюйте в Git — команда повинна бачити всі перевірки.

## Зв'язок з іншими нотатками

- Готові захисні хуки (bash-guard, flyway-guard): [🛡️ Захисні хуки (Guardian)](Guardian_Hooks.md).
- Порівняння хуків з іншими механізмами контролю: [🛠️ Скіли, плагіни та MCP](Skills_and_MCP.md).
