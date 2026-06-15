[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Хуки — це єдиний спосіб **детермінованого** контролю над агентом. На відміну від інструкцій у `CLAUDE.md`, які AI може "забути", хуки — це shell-скрипти, що виконуються автоматично і можуть фізично заблокувати небезпечну дію.

## Чому інструкцій недостатньо?

AI-моделі працюють імовірно. Навіть якщо ви тричі напишете "Ніколи не видаляй таблиці", в момент сильного "галюцинування" агент може це зробити. Хуки перетворюють ці побажання на **жорсткі обмеження (Enforcement)**.

## Життєвий цикл хука

Для розробки ми використовуємо дві ключові події:

### 1. PreToolUse (Превентивний контроль)

Спрацьовує **ДО** того, як інструмент виконає дію.

- **Блокування:** Якщо скрипт повертає `exit 2`, дія інструмента скасовується.
- **Призначення:** Безпека, захист критичних файлів, перевірка прав доступу.

### 2. PostToolUse (Автоматизація наслідків)

Спрацьовує **ПІСЛЯ** успішного виконання інструмента.

- **Призначення:** Форматування коду, оновлення документації, логування змін.
- **Приклад:** Ви написали код -> спрацював PostToolUse -> код автоматично відформатувався за Spotless.

## Детальний огляд захисних механізмів

### 🛡️ Bash-guard (Security Gate)

Скрипт `bash-guard.sh` аналізує команди, які агент хоче виконати в терміналі.

- **Що блокується:** `rm -rf` на системні папки, `DROP TABLE`, `TRUNCATE`, `git push --force`.
- **Prod Protection:** Блокування будь-яких команд, що містять ключові слова `prod`, `production` або посилаються на продакшн-хости в конфігах.

```bash
#!/usr/bin/env bash
# bash-guard.sh
set -euo pipefail

input="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
[ -z "$cmd" ] && exit 0

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

case "$cmd" in
  *"prod"*|*"production"*)
    case "$cmd" in
      *"psql"*|*"flyway"*|*"kafka"*)
        deny "command targets a production resource" ;;
    esac ;;
esac

exit 0
```

### 🧱 Flyway-guard (Schema Integrity)

Скрипт `flyway-guard.sh` захищає історію міграцій бази даних.

- **Логіка:** Якщо агент намагається змінити або видалити вже існуючий SQL-файл у папці `db/migration/`, хук блокує цю дію.
- **Результат:** Міграції залишаються імутабельними, що запобігає розсинхронізації схем БД між розробниками.

```bash
#!/usr/bin/env bash
# flyway-guard.sh
set -euo pipefail

input="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0

path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
tool="$(printf '%s' "$input" | jq -r '.tool_name // empty')"

[ -z "$path" ] && exit 0

case "$path" in
  *db/migration/V*__*.sql)
    if [ "$tool" = "Edit" ] || { [ "$tool" = "Write" ] && [ -f "$path" ]; }; then
      echo "BLOCKED by flyway-guard: '$path' is an existing migration. Applied migrations are immutable — create a NEW V<next>__*.sql instead." >&2
      exit 2
    fi
    ;;
esac

exit 0
```

### ✨ Auto-formatting (Consistency)

Хук у `.claude/settings.json`, що реагує на інструменти `Edit` та `Write`.

- **Команда:** `./gradlew spotlessApply -q`.
- **Перевага:** Агент просто не може залишити код, що не відповідає стилю проєкту. Це прибирає потребу в ручних зауваженнях щодо форматування під час рев'ю.

```json
{
  "//": "Фрагмент конфігурації для авто-форматування",
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "cd \"$CLAUDE_PROJECT_DIR\" && ./gradlew spotlessApply -q || true",
            "timeout": 90
          }
        ]
      }
    ]
  }
}
```

## Безпека самих хуків

⚠️ **Важливо:** Хуки виконуються з вашими правами користувача.

- Ніколи не додавайте в проєкт хуки зі сторонніх плагінів без попереднього аудиту їхнього коду.
- Скрипти хуків повинні зберігатися в репозиторії, щоб кожен член команди бачив, які перевірки виконуються.

## Налаштування та повна конфігурація

Вся конфігурація зберігається у файлі `.claude/settings.json`. Скрипти для реалізації знаходяться у папці [scripts/](./scripts/).

### 🛠️ Повний settings.json

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "cd \"$CLAUDE_PROJECT_DIR\" && ./gradlew spotlessApply -q || true",
            "timeout": 90
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/bash-guard.sh\""
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/flyway-guard.sh\""
          }
        ]
      }
    ]
  }
}
```
