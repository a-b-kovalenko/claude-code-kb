[⬅️](qa_index.md)

## 📝 TL;DR

Skill з `context: fork` у frontmatter запускається як subagent, ізолюючи його verbose вивід від основної розмови. Розміщення у `.claude/skills/` (version-controlled) робить skill доступним усій команді через git clone — на відміну від `~/.claude/skills/` який особистий.

## Original

**Scenario:** A documentation team creates a `/generate-api-docs` skill that reads source code files and produces Markdown API reference pages. The skill generates verbose output (200+ lines per endpoint) and should be available to every team member who clones the repository.

**Question:** How should the skill be configured?

**A)** Create a SKILL.md in `~/.claude/skills/` with `context: fork` frontmatter, and instruct each team member to copy it locally

**B)** Create a SKILL.md in `.claude/skills/` with `context: fork` frontmatter so it is shared via version control and isolates verbose output from the main conversation

**C)** Create a SKILL.md in `.claude/skills/` without any frontmatter, relying on the team to manually manage context overflow

**D)** Add the documentation generation instructions to the root CLAUDE.md so they load automatically in every session

## Питання

Команда документації створює skill `/generate-api-docs`, що читає вихідний код і генерує Markdown сторінки API-довідки. Skill генерує verbose вивід (200+ рядків на endpoint) і має бути доступний кожному члену команди при клонуванні репозиторію. Як налаштувати skill?

**A)** Створити SKILL.md у `~/.claude/skills/` з `context: fork` у frontmatter і попросити кожного члена команди скопіювати його локально

**B)** Створити SKILL.md у `.claude/skills/` з `context: fork` у frontmatter — шерується через version control і ізолює verbose вивід від основної розмови

**C)** Створити SKILL.md у `.claude/skills/` без frontmatter, покладаючись на команду для ручного управління переповненням контексту

**D)** Додати інструкції генерації документації в кореневий CLAUDE.md щоб вони завантажувались автоматично в кожній сесії

## Правильна відповідь: B

## Аналіз варіантів

### B — Правильний

`.claude/skills/` — version-controlled директорія, git clone автоматично надає skill всім. `context: fork` запускає skill як субагент в ізольованому форку контексту — 200+ рядків виводу не потрапляють в основну розмову.

### A — Хибний

`~/.claude/skills/` — особиста директорія, не шерується. Ручне копіювання нівелює переваги version control і ризикує розсинхронізацією версій у команді.

### C — Хибний

Без `context: fork` skill виконується в основному контексті. 200+ рядків на endpoint × кількість endpoints = потенційне переповнення контексту основної сесії.

### D — Хибний

CLAUDE.md — для правил і конвенцій, що завжди активні. Додавання документаційного skill туди: (1) завантажує інструкції в кожну сесію навіть коли вони не потрібні, (2) не вирішує проблему ізоляції verbose виводу.

## Ключові концепції

### context: fork у frontmatter

```yaml
---
description: Generates Markdown API docs from source code
context: fork
---
```

З `context: fork` Claude Code запускає skill як окремий субагент. Субагент має власне контекстне вікно — весь verbose вивід залишається там, в основну сесію повертається лише фінальний результат.

### Де розміщувати skills

| Директорія | Шерується? | Для чого |
| --- | --- | --- |
| `.claude/skills/` | Так (git) | Командні skills |
| `~/.claude/skills/` | Ні | Особисті skills |

### Дві ролі frontmatter у skill

- `context: fork` — ізолює виконання (захист від context overflow)
- `description:` — Claude Code показує skill у `/` меню, модель розуміє коли застосовувати

## Пов'язані нотатки

- [Розробка власного скіла](../../Skill_Development_Guide.md) — анатомія skill-файлу, frontmatter
- [Ієрархія артефактів проєкту](../../Project_Artifacts_Hierarchy.md) — .claude/skills/ у структурі
- [Domain 2: Claude Code Workflows](../domain_2_claude_code.md)
