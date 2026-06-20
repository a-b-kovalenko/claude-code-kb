[⬅️](../Commands_Reference.md)

## 📝 TL;DR

`/init-project` — повний bootstrap проєкту під Claude Code. Запитує тип проєкту (новий чи існуючий) і послідовно налаштовує git, CLAUDE.md, settings, ADR. Охоплює більше ніж вбудований `/init`.

## Синтаксис

```text
/init-project
```

Без аргументів — скіл сам ставить запитання.

## Де живе скіл

`~/.claude/skills/init-project/SKILL.md` — персональний, доступний у всіх проєктах.

## Вміст скіла

````markdown
Ти допомагаєш ініціалізувати проєкт з підтримкою Claude Code та найкращими практиками агентської розробки.

**Перший крок — постав одне запитання:**

> Це новий проєкт чи існуючий?

Наявність `.git` не є надійною ознакою: проєкт може мати git без єдиного коміту або не мати git взагалі. Тип проєкту визначає користувач.

- **Існуючий** → проведи повний аудит: git-історія, build-файли, структура, CI/CD, конфіги, код. Після аудиту постав лише одне запитання: **чи потрібна документація Antora?**
- **Новий** → постав такі запитання **всі одразу**:
  1. Назва та короткий опис проєкту (1–2 речення)
  2. Стек / мова — Java/Spring Boot, TypeScript/Node, Python, інше?
  3. Командний чи соло? (впливає на pre-push хук)
  4. Потрібна документація Antora? (сайт документації)
  5. Є вже remote-репозиторій?

Після відповідей послідовно виконай відповідний сценарій нижче.

### Сценарій: Новий проєкт

**Git:**

- Виконай `git init`
- Створи `.gitignore` для вказаного стеку
- Якщо командний: створи `.git/hooks/pre-push` з таким вмістом і виконай `chmod +x .git/hooks/pre-push`:

```bash
#!/usr/bin/env bash
while read local_ref local_sha remote_ref remote_sha; do
  if [[ "$remote_ref" == "refs/heads/main" ]]; then
    echo "Direct push to main is not allowed. Use a feature branch and merge."
    exit 1
  fi
done
exit 0
```

Після створення хука повідом користувача: хук є локальним захистом і може бути обійдений командою `git push --no-verify`. Для надійного захисту на рівні репозиторію — використовувати GitHub/GitLab branch protection rules.

**CLAUDE.md:**

Створи `CLAUDE.md` з розділами: опис проєкту та tech stack (з відповідей), мова спілкування з агентом (українська), структура директорій, workflow планування (`.workspace/` gitignored), заборонені дії.

**Claude Code налаштування:**

- Створи `.claude/settings.json` з `"plansDirectory": ".workspace"`
- Додай `.workspace/` у `.gitignore`
- Якщо стек потребує БД/GitHub/браузер: створи `.mcp.json` з відповідними MCP-серверами

**Архітектурна документація:**

- Створи `docs/adr/README.md` з шаблоном ADR (Title / Status / Context / Decision / Alternatives Considered / Consequences)
- Якщо Antora: створи `antora.yml` та `docs/modules/ROOT/pages/adr/`
- Напиши `docs/adr/0001-project-setup.md` зі статусом `Accepted`, що документує рішення прийняти цей підхід

**Перший коміт та push:**

```bash
git add .
git commit -m "chore: init project"
```

Якщо є remote (з відповіді 5):

```bash
git remote add origin <url>
git push -u origin main
```

---

### Сценарій: Retrofit існуючого проєкту

Git та remote вже є — ініціалізацію пропускаємо. Спочатку проаудитуй поточну структуру проєкту, потім:

- `CLAUDE.md` — створи якщо немає, доповни якщо є
- `.claude/settings.json` — `plansDirectory`, `allowedTools`
- `.workspace/` у `.gitignore`
- Якщо командний: додай pre-push хук (скрипт вище)
- `docs/adr/` якщо немає; ADR-0001 документує рішення прийняти цей підхід
- MCP якщо стек потребує

```bash
git add .
git commit -m "chore: add Claude Code project setup"
```
````
