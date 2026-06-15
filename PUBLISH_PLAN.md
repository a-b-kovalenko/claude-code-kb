# Plan: Публікація vault на GitHub

## Context

Obsidian vault з базою знань про Claude Code (38+ нотаток) потрібно опублікувати як public GitHub-репозиторій. Репо не існує — потрібно ініціалізувати git, налаштувати `.gitignore`, створити `README.md`, створити репо через `gh` та запушити.

---

## Крок 1: `.gitignore`

Створити `.gitignore` у кореневій папці vault:

```gitignore
# IDE
.idea/

# Obsidian personal settings
.obsidian/

# Claude Code local/session files
.claude/settings.local.json
.claude/plans/

# OS
.DS_Store
```

Включити у репо:

- `.claude/settings.json` — конфіг дозволів та хуків (корисний для команди)
- `.claude/hooks/md-lint.sh` — скрипт автоперевірки markdown

---

## Крок 2: `README.md`

Створити `README.md` — GitHub-орієнтований, відрізняється від `CLAUDE.md`.

Структура README:

- Заголовок + одноречна мета (база знань про Claude Code для Senior Java-розробника)
- Короткий опис: 38+ нотаток, охоплює від основ до production workflow
- Секції vault (6 розділів із MOC) — bullet list з emoji
- **Як використовувати**: клонувати → відкрити в Obsidian як vault; або читати на GitHub, починаючи з `Claude_Code_Knowledge_Base.md`
- Структура папок (дерево)

---

## Крок 3: `git init` + initial commit

```bash
cd "/Users/akovalenko/Documents/Obsidian/Claude Code"
git init
git add CLAUDE.md Claude_Code_Knowledge_Base.md GEMINI.md TODO.md README.md PUBLISH_PLAN.md
git add .gitignore .markdownlint.json
git add content/
git add .claude/settings.json .claude/hooks/
git commit -m "feat: initial publish of Claude Code knowledge base"
```

---

## Крок 4: Створення GitHub-репо та push

```bash
gh repo create claude-code-kb \
  --public \
  --description "База знань про Claude Code для Senior Java-розробника. 38+ нотаток: workflow, субагенти, хуки, best practices." \
  --source . \
  --push
```

Ім'я репо: **`claude-code-kb`**

---

## Верифікація

1. `gh repo view --web` — відкрити репо у браузері
2. Перевірити що `.obsidian/`, `.idea/`, `.claude/settings.local.json` відсутні
3. Перевірити що `README.md` відображається на головній сторінці
4. Перевірити що посилання у `Claude_Code_Knowledge_Base.md` коректно клікаються на GitHub
