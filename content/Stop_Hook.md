[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

`Stop`-хук спрацьовує коли агент завершив відповідь і збирається зупинитись. `exit 0` — дозволити зупинку; `exit 2` зі stdout — змусити агента продовжити з вашим повідомленням. Типові задачі: нагадування перед зупинкою, пост-перевірки, десктопні сповіщення про завершення довгої задачі.

## Коли спрацьовує

Після кожної завершеної відповіді агента — не тільки після великих задач, а й після кожного звичайного повідомлення. Якщо хук важкий, додайте перевірку чи варто щось робити перед основною логікою.

## Stdin JSON

```json
{
  "session_id": "abc123",
  "stop_reason": "end_turn"
}
```

На відміну від PreToolUse/PostToolUse, тут немає `tool_input` — хук реагує на факт зупинки, а не на конкретний інструмент.

## Exit-коди

| Код | Ефект |
| :--- | :--- |
| `exit 0` | Агент зупиняється. Якщо є stdout — агент побачить його, але не зобов'язаний реагувати |
| `exit 2` | Агент отримує stdout хука як нове повідомлення і продовжує відповідь |

`exit 2` — це спосіб сказати агенту: "ти ще не закінчив, ось що залишилось зробити."

## Реєстрація в settings.json

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/stop-check.sh\""
          }
        ]
      }
    ]
  }
}
```

`Stop` не має `matcher` — спрацьовує на будь-яку зупинку.

## Приклад 1: десктопне сповіщення (macOS)

Корисно для довгих автономних задач — агент працює у фоні, сповіщення приходить коли готово:

```bash
#!/usr/bin/env bash
# .claude/hooks/stop-notify.sh

osascript -e 'display notification "Claude Code завершив задачу" with title "Claude Code"' 2>/dev/null || true
exit 0
```

## Приклад 2: нагадування перед зупинкою

Хук перевіряє чи залишились незакомічені зміни і нагадує агенту:

```bash
#!/usr/bin/env bash
# .claude/hooks/stop-remind.sh

cd "$CLAUDE_PROJECT_DIR" || exit 0

if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
  echo "Uncommitted changes detected. Did you mean to commit before stopping?"
  exit 2
fi

exit 0
```

Агент отримає повідомлення і вирішить: закомітити зміни або пояснити чому вони навмисно незакомічені.

## Приклад 3: лог завершення сесії

```bash
#!/usr/bin/env bash
# .claude/hooks/stop-logger.sh

log="$CLAUDE_PROJECT_DIR/.claude/session.log"
echo "$(date -u +%FT%TZ)  session stopped" >> "$log"
exit 0
```

Разом з `change-logger.sh` (PostToolUse) дає повну хронологію: які файли змінив агент і коли зупинився.

## Обережно зі зворотним зв'язком через exit 2

Якщо хук завжди повертає `exit 2` — виникне нескінченний цикл: агент відповідає, хук знову блокує, агент знову відповідає. Завжди додавайте умову виходу:

```bash
# Погано — нескінченний цикл:
echo "Don't forget to run tests"
exit 2

# Добре — перевірка перед блокуванням:
if [ -n "$(git diff --name-only '*.java' 2>/dev/null)" ]; then
  echo "Java files changed. Run tests before finishing."
  exit 2
fi
exit 0
```

## Зв'язок з іншими нотатками

- Анатомія хуків, всі події та exit-коди: [🔧 Розробка власного хука](Hook_Development_Guide.md).
- Інші хуки vault'у: [🛡️ Захисні хуки (Guardian)](Guardian_Hooks.md), [📋 MD Lint Hook](MD_Lint_Hook.md).
- `PreCompact` — суміжна подія для збереження стану перед стисненням: [🪟 Контекстне вікно та /compact](Context_Window_Management.md).
