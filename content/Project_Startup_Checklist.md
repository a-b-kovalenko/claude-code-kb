[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Покроковий чеклист для старту будь-якого проєкту з підтримкою Claude Code: від `git init` до першого push. Охоплює git, CLAUDE.md, Claude Code конфігурацію та архітектурну документацію. Для автоматизації — [bootstrap-команда `/init-project`](Project_Bootstrap_Command.md).

---

## Новий проєкт

### ☐ 1. Git

- `git init`, `.gitignore` (під мову/фреймворк)
- Конвенція гілок — `main` завжди стабільний (проходить CI, потенційно deployable):
  - `feature/short-description` — нова функціональність
  - `fix/short-description` — виправлення бага
  - `chore/short-description` — інфраструктура, залежності, конфіг (без впливу на поведінку)
  - `docs/short-description` — тільки документація
  - Гілки короткоживучі: дні, не тижні; мерджаться у `main` через PR
- Конвенція комітів (Conventional Commits): `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`
- Для командних проєктів: pre-push хук у `.git/hooks/pre-push`, що блокує push прямо в `main`

### ☐ 2. CLAUDE.md

- Опис проєкту та tech stack
- Мова спілкування з агентом
- Структура директорій проєкту
- Workflow планування: плани в `.plans/` (gitignored)
- Заборонені дії (не коммітити в `main`, не видаляти міграції тощо)

Детальніше: [Написання CLAUDE.md](CLAUDE_md_Writing_Guide.md)

### ☐ 3. Claude Code налаштування

- `.claude/settings.json`: `plansDirectory: ".plans"`, `allowedTools`
- `.plans/` у `.gitignore`
- MCP-сервери в `.mcp.json` якщо стек потребує: БД, GitHub, браузер тощо
- Template Repository: якщо старти повторюються — тримати GitHub-шаблон з базовим `.gitignore`, `CLAUDE.md`, `.claude/settings.json` та структурою `docs/adr/`
- Хуки за потреби: md-lint, flyway-guard

Детальніше: [Ієрархія артефактів](Project_Artifacts_Hierarchy.md), [MCP-сервери](MCP_Server_Development.md), [Guardian хуки](Guardian_Hooks.md)

### ☐ 4. Архітектурна документація

- `docs/adr/` + `docs/adr/README.md` з шаблоном ADR
- Написати ADR-0001 (вибір tech stack або рішення прийняти цей підхід)
- Якщо потрібна документація-сайт (Antora): `antora.yml` у корені, `docs/modules/ROOT/pages/`; ADR кладуться в `docs/modules/ROOT/pages/adr/`

Детальніше: [ADR Guide](ADR_Guide.md)

### ☐ 5. Quality gates

- Linting та форматування (залежить від стеку)
- CI/CD за потреби

Детальніше: [CI/CD інтеграція](CI_CD_Integration.md)

### ☐ 6. Перший коміт та push

```bash
git add .
git commit -m "chore: init project"
git remote add origin <url>
git push -u origin main
```

---

## Retrofit існуючого проєкту

Git та remote вже є — пропускаємо кроки 1 і 6. Спочатку аудит поточної структури, потім:

- `CLAUDE.md` — створити якщо немає, доповнити якщо є
- `.claude/settings.json` — `plansDirectory`, `allowedTools`, хуки
- `.plans/` у `.gitignore`
- Pre-push хук у `.git/hooks/pre-push` (для командних проєктів)
- `docs/adr/` — ADR-0001 документує рішення прийняти цей підхід
- MCP якщо потрібно

```bash
git add .
git commit -m "chore: add Claude Code project setup"
```

---

## Зв'язок з іншими нотатками

- [☑️ Чеклист перед задачею](Pre_Task_Checklist.md) — для кожної окремої задачі в рамках проєкту
- [📐 ADR Guide](ADR_Guide.md) — методологія ведення рішень
- [🚀 Bootstrap-команда /init-project](Project_Bootstrap_Command.md) — автоматизований варіант цього чеклисту
- [📄 Написання CLAUDE.md](CLAUDE_md_Writing_Guide.md)
- [🗂️ Ієрархія артефактів](Project_Artifacts_Hierarchy.md)
