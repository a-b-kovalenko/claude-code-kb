[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Auto-memory — це файлова система персистентної пам'яті Claude Code: агент зберігає спостереження між сесіями у `~/.claude/projects/<project>/memory/`. На відміну від `CLAUDE.md` (статичний контракт), auto-memory накопичується динамічно і завжди актуальна для конкретного проєкту і конкретного користувача.

## Розташування файлів

```text
~/.claude/projects/<encoded-path>/memory/
├── MEMORY.md              ← індекс (завжди в контексті)
├── user_role.md           ← хто користувач
├── feedback_testing.md    ← як підходити до роботи
└── project_deadline.md    ← контекст поточної роботи
```

`<encoded-path>` — шлях до проєкту з `/` заміненими на `-`:

```text
/Users/alice/projects/my-app  →  -Users-alice-projects-my-app
```

## Чотири типи пам'яті

| Тип | Що зберігати | Приклад |
| :--- | :--- | :--- |
| **user** | Роль, досвід, уподобання користувача | "Senior Java dev, новачок у React" |
| **feedback** | Як підходити до роботи: що робити і що не робити | "Не мокати БД у тестах — були інциденти" |
| **project** | Поточні цілі, рішення, дедлайни | "Міграція auth-middleware через legal-вимоги" |
| **reference** | Де шукати інформацію в зовнішніх системах | "Баги pipeline — Linear проєкт INGEST" |

## Формат файлу пам'яті

```markdown
---
name: feedback-no-mocking-db
description: Integration tests must use a real database — mocks masked a prod migration failure
metadata:
  type: feedback
---

Never mock the database in integration tests. Use Testcontainers instead.

**Why:** Q3 incident — mocked tests passed, but the prod migration failed silently.

**How to apply:** Any test touching persistence must spin up a real Postgres container.
```

**Правило структури для `feedback` і `project`:** body завжди містить рядки `**Why:**` і `**How to apply:**`. Це дозволяє судити про крайні випадки, а не сліпо слідувати правилу.

## MEMORY.md — індекс

`MEMORY.md` завжди підвантажується в контекст. Обмеження — **200 рядків** (решта обрізається). Кожен запис — один рядок:

```markdown
# Memory Index

- [Feedback: No DB mocking](feedback_no_mocking_db.md) — Testcontainers only; prior prod incident.
- [User: Senior Java dev](user_role.md) — Deep Java/Spring, new to React frontend.
```

Детальний зміст — у файлах. В індексі — тільки hook: достатньо, щоб вирішити, чи варто читати файл.

## Двокроковий процес збереження

1. **Написати файл** у `memory/` з frontmatter і тілом.
2. **Додати рядок** до `MEMORY.md`.

Якщо тема вже є — оновити наявний файл, не створювати дубль.

## Що НЕ зберігати

| Не зберігати | Чому |
| :--- | :--- |
| Структуру коду, патерни, архітектуру | Виводиться з читання файлів |
| Git-історію, хто що змінив | `git log` / `git blame` авторитетніші |
| Рецепти виправлення багів | Фікс у коді; контекст — у коміті |
| Що вже в `CLAUDE.md` | Дублювання без користі |
| Поточний стан задачі, прогрес сесії | Для цього є Tasks API |

## Перевірка актуальності

Пам'ять — знімок у часі. Перед тим як діяти на основі memory:

- Якщо memory посилається на файл → перевірити що файл існує (`Read`).
- Якщо memory описує поведінку функції → перевірити через `grep`.
- Якщо memory конфліктує з тим що видно в коді → довіряти коду, оновити memory.

## Auto-memory vs інші механізми

| Механізм | Scope | Призначення |
| :--- | :--- | :--- |
| Auto-memory | Між сесіями, один проєкт + юзер | Персональні спостереження, feedback |
| `CLAUDE.md` | Кожна сесія, уся команда | Командні стандарти та конвенції |
| Tasks API | Поточна сесія | Прогрес і кроки поточної задачі |
| `.claude/rules/` | Кожна сесія, уся команда | Модульні правила (JPA, Kafka) |

## Зв'язок з іншими нотатками

- Загальна ієрархія пам'яті та цикл компіляції знань: [🧠 Ієрархія пам'яті та синтез](Memory_Hierarchy_and_Synthesis.md).
- Що писати в командний статичний контракт: [📄 Написання CLAUDE.md](CLAUDE_md_Writing_Guide.md).
- Тактичне управління кроками в сесії: [📅 Планування та Tasks API](Planning_and_Tasks.md).
