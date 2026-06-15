[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Claude Code має вбудовану інтеграцію з Git та GitHub CLI (`gh`). Ключ до чистої git-історії — задавати агенту роботу в розрізі одного логічного кроку за раз та фіксувати конвенцію коміт-повідомлень у `CLAUDE.md`.

## Як агент взаємодіє з Git

Claude Code має повний доступ до Git через Bash-інструмент. Він може:

- Читати `git log`, `git diff`, `git status`.
- Створювати коміти та гілки.
- Відкривати PR через `gh pr create`.
- Аналізувати конфлікти та пропонувати їх вирішення.

⚠️ **Важливо:** Агент **не пушить** автоматично. `git push` вимагає явного дозволу або виклику.

## Конвенція коміт-повідомлень

Зафіксуйте стандарт у `CLAUDE.md`, щоб агент використовував його без нагадувань:

```markdown
## Commit convention
Use Conventional Commits: <type>(<scope>): <description>
Types: feat, fix, refactor, test, chore, docs
Example: feat(orders): add Kafka event on order completion
```

Тоді агент генеруватиме повідомлення на зразок:

```text
refactor(user): extract UserMapper from UserService

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

## Один крок — один коміт

Найпоширеніша помилка: давати агенту задачу рівня "реалізуй фічу" і отримувати один гігантський коміт. Натомість:

1. Розбийте задачу на кроки через [режим планування](Planning_and_Tasks.md).
2. Після кожного верифікованого кроку явно попросіть: *"Commit this step."*
3. Агент сам сформулює коміт-повідомлення на основі зроблених змін.

Результат — читабельна git-історія, де кожен коміт має один змістовний diff.

## Workflow відкриття PR

```text
1. Агент виконав задачу та всі тести зелені.
2. "Create a PR for this feature."
3. Агент виконує:
   - git push -u origin <branch>
   - gh pr create --title "..." --body "..."
4. PR-опис генерується на основі git log з поточної гілки.
```

Щоб отримати якісний PR-опис, попросіть агента включити:

- **Summary:** що змінилося і чому.
- **Test plan:** що і як тестувалося.
- **Risk:** які частини системи зачеплені.

## Найменування гілок

Зафіксуйте в `CLAUDE.md` шаблон гілки:

```markdown
## Branch naming
Pattern: <type>/<jira-ticket>-<short-description>
Example: feat/PROJ-123-add-kafka-dlq
```

## Вирішення конфліктів злиття

Claude Code добре справляється з конфліктами, якщо надати контекст:

- *"Resolve merge conflicts in UserService. Prefer changes from feature branch for the business logic, keep main's version for the imports."*
- Завжди перевіряйте результат `git diff` після вирішення — агент може неправильно інтерпретувати семантику конфліктних блоків.

## Захист від небезпечних git-операцій

`bash-guard.sh` вже блокує `git push --force` та `git reset --hard`. Додатково рекомендується зафіксувати в `CLAUDE.md`:

```markdown
## Git safety
- Never push directly to main or develop.
- Never use --force without explicit confirmation.
- Always run tests before committing.
```

Детальніше про захисні хуки: [🛡️ Захисні хуки (Guardian)](Guardian_Hooks.md).

Покрокові коміти як Phase 5 у наскрізному прикладі: [🏆 Золотий workflow](Golden_Workflow.md).
