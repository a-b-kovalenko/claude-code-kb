[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

User-level slash команда `/init-project`: запускаєш у папці проєкту, відповідаєш на запитання — агент самостійно проходить чеклист і створює всі файли. Працює як для нових проєктів, так і для retrofit існуючих.

---

## Встановлення

Скопіюй вміст секції "Текст команди" нижче у файл:

```text
~/.claude/commands/init-project.md
```

Після цього `/init-project` доступна в будь-якому проєкті без додаткового налаштування.

---

## Текст команди

Ти допомагаєш ініціалізувати проєкт з підтримкою Claude Code та найкращими практиками агентської розробки.

**Перший крок — визнач тип проєкту:**

Перевір чи існує `.git` у поточному каталозі.

- **Якщо `.git` є** → це retrofit існуючого проєкту. Проаудитуй проєкт самостійно: прочитай README, build-файли (`pom.xml`, `package.json`, `build.gradle`, `requirements.txt` тощо), `git remote -v`, `git log --format="%ae" | sort -u` (кількість авторів → командний чи соло). Постав лише одне запитання: **чи потрібна документація Antora?**
- **Якщо `.git` немає** → це новий проєкт. Постав такі запитання **всі одразу**:
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

Створи `CLAUDE.md` з розділами: опис проєкту та tech stack (з відповідей), мова спілкування з агентом (українська), структура директорій, workflow планування (`.plans/` gitignored), заборонені дії.

**Claude Code налаштування:**

- Створи `.claude/settings.json` з `"plansDirectory": ".plans"`
- Додай `.plans/` у `.gitignore`
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

Якщо є remote (з відповіді 6):

```bash
git remote add origin <url>
git push -u origin main
```

---

### Сценарій: Retrofit існуючого проєкту

Git та remote вже є — ініціалізацію пропускаємо. Спочатку проаудитуй поточну структуру проєкту, потім:

- `CLAUDE.md` — створи якщо немає, доповни якщо є
- `.claude/settings.json` — `plansDirectory`, `allowedTools`
- `.plans/` у `.gitignore`
- Якщо командний: додай pre-push хук (скрипт вище)
- `docs/adr/` якщо немає; ADR-0001 документує рішення прийняти цей підхід
- MCP якщо стек потребує

```bash
git add .
git commit -m "chore: add Claude Code project setup"
```

---

## Зауваження

- Команда виконується у **вже відкритій папці** проєкту — Claude Code читає поточний каталог
- Для нового проєкту: спочатку `mkdir my-project && cd my-project`, потім `claude` → `/init-project`
- Remote не пушить автоматично якщо url не вказано — агент запитає
- **Pre-push хук — локальний захист:** його можна обійти через `git push --no-verify`. Це свідоме порушення конвенції, а не вразливість. Для командних проєктів надійнішим захистом є branch protection rules на рівні GitHub/GitLab — вони діють незалежно від локальних хуків

---

## Зв'язок з іншими нотатками

- [☑️ Чеклист старту проєкту](Project_Startup_Checklist.md) — повний ручний чеклист
- [📐 ADR Guide](ADR_Guide.md) — деталі методології ADR
- [⚡ Кастомні Slash-команди](Custom_Slash_Commands.md) — як влаштовані slash команди
