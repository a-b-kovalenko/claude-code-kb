[⬅️](../Commands_Reference.md)

## 📝 TL;DR

`/statusline` налаштовує рядок статусу в інтерфейсі Claude Code. Під капотом — shell-скрипт у `~/.claude/statusline-command.sh`, тому показати можна будь-що. Головна цінність — доступ до змінних середовища `$CLAUDE_*` з даними поточної сесії.

## Синтаксис

```text
/statusline
```

Без аргументів — запускає інтерактивне налаштування через `statusline-setup` агента.

## Змінні середовища $CLAUDE_*

Доступні у скрипті під час сесії:

| Змінна | Що містить |
| :--- | :--- |
| `$CLAUDE_MODEL` | Назва поточної моделі (`claude-sonnet-4-6`) |
| `$CLAUDE_CONTEXT_TOKENS_USED` | Кількість використаних токенів контексту |
| `$CLAUDE_CONTEXT_TOKENS_LIMIT` | Ліміт контекстного вікна |
| `$CLAUDE_COST_USD` | Вартість поточної сесії в USD |

Поля відсутні до першої відповіді — враховуйте це у скрипті (перевірка на порожнє значення).

## Shell-джерела

Оскільки скрипт — звичайний bash, можна додати будь-що зі shell:

| Що показати | Як отримати |
| :--- | :--- |
| Поточна директорія | `pwd` зі скороченням `$HOME` → `~` |
| Git-гілка | `git rev-parse --abbrev-ref HEAD` |
| Git-статус (є зміни?) | `git status --short` + підрахунок рядків |
| Час | `date +%H:%M` |
| Node версія | `node -v` |
| Python venv | `basename "$VIRTUAL_ENV"` |

Комбінований рядок з усіх джерел:

```text
~/project | main* | Sonnet 4.6 | 42k/200k tokens | $0.12
```

## Приклад скрипту

```bash
#!/usr/bin/env bash
parts=()
[ -n "$CLAUDE_MODEL" ]                && parts+=("$CLAUDE_MODEL")
[ -n "$CLAUDE_CONTEXT_TOKENS_USED" ]  && parts+=("${CLAUDE_CONTEXT_TOKENS_USED} / ${CLAUDE_CONTEXT_TOKENS_LIMIT} tokens")
[ -n "$CLAUDE_COST_USD" ]             && parts+=("\$${CLAUDE_COST_USD}")
printf '%s' "$(IFS=' | '; echo "${parts[*]}")"
```

Результат: `claude-sonnet-4-6 | 42000 / 200000 tokens | $0.0023`

## Де живе скрипт

`~/.claude/statusline-command.sh` — підключається через `statusLine.command` у `~/.claude/settings.json`.
