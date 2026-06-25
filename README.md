# Claude Code Knowledge Base

База знань про [Claude Code](https://claude.ai/code) для Senior Java-розробника. 113 нотаток: від основ агентської розробки до production-ready workflow, захисних хуків, прикладів субагентів та підготовки до сертифікації CCA-F.

## Що всередині

| Розділ | Зміст |
| :----- | :----- |
| 🤖 Методологія Agentry | Основи, IDE-інтеграції, Extended Thinking, планування, архітектура субагентів, REPL-шорткати, headless-режим |
| 💡 Кращі практики | Золотий workflow, антипатерни, ефективні промпти, чеклист перед задачею |
| 🔬 Субагенти та оркестрація | Готові приклади Explorer / Test-runner / Reviewer, паралельність, worktree, Claude Code SDK |
| 🧠 Контекст та пам'ять | CLAUDE.md (три рівні), auto-memory, управління контекстним вікном, вибір моделі, MCP-сервери, Playwright MCP |
| 🧪 Інженерна якість | Spring Boot тестування, Git/PR workflow, верифікаційний цикл |
| 🛡️ Інфраструктура та безпека | Хуки (security best practices), дозволи, settings.json, CI/CD + GitHub Actions, Remote Control, Desktop App |
| 🏁 Старт проєкту | Чеклист старту, методологія ADR, bootstrap-команда `/init-project`, аудит існуючого проєкту |
| 🌐 Claude API | Tool use, prompt caching, Batch API — механіки для доменів CCA-F |
| 🎓 CCA-F | Підготовка до сертифікації: 5 доменів, 34 розбори питань іспиту |

## Як використовувати

**В Obsidian:** клонуйте репозиторій і відкрийте папку як vault. Конфігурація `.obsidian/` включена в репо (крім `workspace.json`) — налаштування, плагіни та тема підхоплюються автоматично.

**На GitHub:** починайте з [Map of Content](Claude_Code_Knowledge_Base.md) — центрального вузла з посиланнями на всі нотатки.

## Залежності

Хук `.claude/hooks/md-lint.sh` автоматично перевіряє markdown при кожному записі файлу у межах проєкту через Claude Code. Для його роботи потрібен `markdownlint-cli`:

```bash
npm install -g markdownlint-cli
```

## Структура

```text
├── Claude_Code_Knowledge_Base.md   # MOC — центральний реєстр нотаток
├── content/                        # Основні нотатки (53 файли)
│   ├── commands/                   # Нотатки окремих команд (8 файлів)
│   ├── scripts/                    # Bash-скрипти (bash-guard, flyway-guard)
│   ├── cca/                        # Підготовка до CCA-F (12 файлів)
│   │   └── qa/                     # Розбори питань іспиту (34 файли)
│   └── claude_api/                 # Claude API механіки (6 файлів)
├── CLAUDE.md                       # Інструкції для Claude Code агента
├── .obsidian/                      # Конфіг Obsidian (без workspace.json)
└── .claude/
    ├── settings.json               # Конфігурація дозволів та хуків
    ├── settings.local.json         # Особисті дозволи (gitignored)
    └── hooks/md-lint.sh            # Авто-перевірка markdown при кожному записі
```
