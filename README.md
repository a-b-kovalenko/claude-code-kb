# Claude Code Knowledge Base

База знань про [Claude Code](https://claude.ai/code) для Senior Java-розробника. 40+ нотаток: від основ агентської розробки до production-ready workflow, захисних хуків та прикладів субагентів.

## Що всередині

| Розділ | Зміст |
| :----- | :----- |
| 🤖 Методологія Agentry | Основи, IDE-інтеграції, Extended Thinking, планування, архітектура субагентів, headless-режим |
| 💡 Кращі практики | Золотий workflow, антипатерни, ефективні промпти, чеклист перед задачею |
| 🔬 Субагенти та оркестрація | Готові приклади Explorer / Test-runner / Reviewer, паралельність, worktree |
| 🧠 Контекст та пам'ять | CLAUDE.md, auto-memory, управління контекстним вікном, вибір моделі |
| 🧪 Інженерна якість | Spring Boot тестування, Git/PR workflow, верифікаційний цикл |
| 🛡️ Інфраструктура та безпека | Хуки, дозволи, settings.json, CI/CD інтеграція, MD lint |

## Як використовувати

**В Obsidian:** клонуйте репозиторій і відкрийте папку як vault.

**На GitHub:** починайте з [Map of Content](Claude_Code_Knowledge_Base.md) — центрального вузла з посиланнями на всі нотатки.

## Залежності

Хук `.claude/hooks/md-lint.sh` автоматично перевіряє markdown при кожному записі файлу через Claude Code. Для його роботи потрібен `markdownlint-cli`:

```bash
npm install -g markdownlint-cli
```

## Структура

```text
├── Claude_Code_Knowledge_Base.md   # MOC — центральний реєстр нотаток
├── content/                        # Всі нотатки (40+ файлів .md)
│   └── scripts/                    # Bash-скрипти (bash-guard, flyway-guard)
├── CLAUDE.md                       # Інструкції для Claude Code агента
└── .claude/
    ├── settings.json               # Конфігурація дозволів та хуків
    └── hooks/md-lint.sh            # Авто-перевірка markdown при кожному записі
```
