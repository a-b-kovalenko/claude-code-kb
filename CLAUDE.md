# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Що це за репозиторій

Obsidian vault — база знань про Claude Code для Senior Java-розробника.

## Структура

- `Claude_Code_Knowledge_Base.md` — головний MOC (Map of Content), єдиний реєстр усіх нотаток.
- `content/` — усі технічні нотатки.
- `content/scripts/` — приклади захисних скриптів (bash-guard, flyway-guard).
- `GEMINI.md` — правила ведення бази знань.

## Конвенції нотаток

Кожна нотатка в `content/` **обов'язково**:

1. Починається з навігаційного посилання: `[⬅️](../Claude_Code_Knowledge_Base.md)`
2. Має першим розділом `## 📝 TL;DR` (2–3 речення резюме)
3. **Не** містить заголовка H1 — назва файлу є заголовком
4. Реєструється в `Claude_Code_Knowledge_Base.md` у відповідній секції

## Правила посилань

- Тільки стандартний Markdown: `[Назва](content/назва.md)` — wiki-links `[[...]]` заборонені.
- Текст посилань (у квадратних дужках) — українською.
- Шляхи — відносні, з розширенням `.md`.

## Мова

- Спілкування з користувачем: **українська**.
- Технічний зміст нотаток та код: **англійська** (для точності).

## Планування та тимчасові файли

- Плани, TODO та робочі нотатки зберігати у `.plans/` — ця папка gitignored і не потрапляє в репо.
- `/plan` автоматично зберігає файли у `.plans/` завдяки `plansDirectory` у `.claude/settings.json`.

## Структура MOC

`Claude_Code_Knowledge_Base.md` використовує стандартні `###` заголовки для секцій — **не** Obsidian callouts (`[!abstract]` тощо). Це забезпечує однаковий вигляд в Obsidian і на GitHub.

## Markdownlint

Хук `.claude/hooks/md-lint.sh` перевіряє кожен записаний `.md` файл. При порушенні — запис блокується (exit 2). Потрібен `markdownlint-cli`:

```bash
npm install -g markdownlint-cli
```

## Додавання нової нотатки

1. Створити файл у `content/<назва>.md` з дотриманням конвенцій вище.
2. Додати рядок у відповідну секцію `Claude_Code_Knowledge_Base.md`.
