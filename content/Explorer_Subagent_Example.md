[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Практичний приклад створення субагента `explorer`. Найважливіше поле — `description`: від неї залежить авто-делегування. Поле `tools` обов'язково вказувати явно — без нього субагент успадкує всі інструменти треда, включно з MCP та правами на запис.

## Файл `.claude/agents/explorer.md`

```markdown
---
name: explorer
description: >
  MUST BE USED before any code changes to an unfamiliar area.
  Use to map the codebase: find relevant files, trace data flows
  (controller → service → repository → DB, Kafka consumer → handler → DB),
  identify class dependencies and migration history.
  Returns a concise structured summary. NEVER modifies files.
model: claude-haiku-4-5-20251001
tools:
  - Read
  - Glob
  - Grep
  - Bash
---

You are a read-only code exploration specialist for a Spring Boot / Java project.

Your job:
1. Find all files relevant to the given topic (services, repositories, DTOs, Kafka consumers/producers, Flyway migrations).
2. Trace data flows: from REST controller → service → repository → DB, or from Kafka consumer → handler → DB.
3. Map dependencies: which classes call which, which tables are affected.

Output format — always a structured summary:
- **Files to change:** list with full paths and one-line reason for each.
- **Data flow:** short diagram or numbered steps.
- **Risks:** anything that could break if changed (shared beans, transactional boundaries, Kafka topic contracts).

Rules:
- NEVER use Edit or Write tools.
- Do NOT explain how to fix — only describe what exists.
- Keep the summary under 30 lines. The main agent reads it, not a human.
```

## Розбір ключових полів

### `description` — найважливіше поле

Саме вона керує **авто-делегуванням**: Claude Code обирає перший субагент, чий опис збігається з наміром запиту. Тому:

- Розмиті описи (`"explores code"`) — ігноруються.
- Ключові слова та патерни `"MUST BE USED for…"` підвищують пріоритет.
- Вказуйте тригери (коли викликати) і заборони (чого не робить агент).

Порівняння:

| Слабко | Сильно |
| :--- | :--- |
| `Explores the codebase` | `MUST BE USED before code changes. Finds files, traces data flows, maps dependencies.` |

### `tools` — явний allowlist

Якщо поле `tools` **пропустити**, субагент успадковує **всі** інструменти поточного треда, включно з MCP-серверами та `Edit`/`Write`. Для read-only ролі це критична помилка — агент отримає права на запис, яких ви не планували давати. Завжди вказуйте whitelist явно.

### `model` — Haiku для пошуку

- **`claude-haiku-4-5-20251001`** — ідеально для explorer: дешево, швидко, завдання нескладне.
- **`inherit`** — субагент бере модель головної сесії (за замовчуванням, якщо поле відсутнє).
- **`CLAUDE_CODE_SUBAGENT_MODEL`** — змінна середовища для встановлення дефолтної моделі всіх субагентів одразу.

Sonnet виправданий лише якщо explorer має також аналізувати складну бізнес-логіку.

### Інші поля (для довідки)

`disallowedTools`, `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `color` — для explorer не потрібні, але існують.

### ⚠️ Офіційна документація vs реальність

Офіційна дока і те, що генерує `/agents`, історично трохи розходяться (наприклад, згенеровані агенти додають `color`, multiline-описи). Якщо субагент не підхоплюється — звірте формат через `/agents` UI: він показує канонічний вигляд.

## Як викликати

**Авто-делегування** — якщо `description` влучна, головний агент сам викличе `explorer` перед початком змін, без явної вказівки.

**Явний виклик:**
> *"Use the explorer subagent to find all classes involved in processing the `OrderCreated` Kafka event."*

Claude Code запустить `explorer` у власному вікні контексту та поверне його підсумок головному агенту.

## Чому read-only тут принципово

Сенс `explorer` — **ізоляція контексту**: замість читати 30 файлів у головний тред, головна сесія спавнить субагент, який робить важке читання й повертає лише висновок.

Якщо дати йому write-права — він почне "заодно полагоджу". Ви втрачаєте одразу два інваріанти:

- **Чистоту контексту** — головний агент тепер не єдине джерело змін.
- **Контроль** — зміни відбулись поза вашим планом і без верифікації.

Тому: явний `tools` whitelist без `Edit`/`Write` **і** пряма заборона в system prompt — обидва рівні захисту разом.

## Зв'язок з архітектурою субагентів

Детальніше про ролі Explorer, Test-runner та Reviewer — у нотатці [👥 Архітектура субагентів](Subagents_Architecture.md).
