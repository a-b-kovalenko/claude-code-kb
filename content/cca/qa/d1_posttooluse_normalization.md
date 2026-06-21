[⬅️](qa_index.md)

## 📝 TL;DR

Коли різні backend системи повертають дані в різних форматах (Unix timestamp, ISO 8601, DD/MM/YYYY) — PostToolUse hook нормалізує результати до єдиного формату перш ніж вони потраплять до моделі. Код вирішує трансформацію, не модель.

## Original

**Scenario:** A customer support agent integrates with three different backend systems via MCP tools. One system returns dates as Unix timestamps, another returns ISO 8601 strings, and the third returns dates in 'DD/MM/YYYY' format. The agent occasionally misinterprets dates, leading to incorrect order lookup results.

**Question:** What is the correct fix?

**A)** Add instructions to the system prompt explaining the three date formats and how to interpret each one

**B)** Implement a PostToolUse hook that normalises all date formats to ISO 8601 before the model processes the results

**C)** Standardise the backend APIs to all return the same date format

**D)** Implement a PreToolUse hook that converts all dates to ISO 8601 before passing them to the tools

## Питання

Агент customer support інтегрується з трьома різними backend системами через MCP інструменти. Одна повертає дати як Unix timestamps, інша — рядки ISO 8601, третя — формат 'DD/MM/YYYY'. Агент іноді неправильно інтерпретує дати, що призводить до помилок у пошуку замовлень. Який правильний виправлення?

**A)** Додати в system prompt інструкції що пояснюють три формати дат і як їх інтерпретувати

**B)** Реалізувати PostToolUse hook, що нормалізує всі формати дат до ISO 8601 перш ніж модель обробляє результати

**C)** Стандартизувати backend API щоб усі повертали однаковий формат дати

**D)** Реалізувати PreToolUse hook, що конвертує всі дати до ISO 8601 перед передачею інструментам

## Правильна відповідь: B

## Аналіз варіантів

### B — Правильний

PostToolUse hook отримує результат кожного tool call і може трансформувати його до того як модель побачить. Нормалізація дат на цьому рівні: детерміністична (завжди ISO 8601), прозора для моделі (вона завжди бачить один формат), не потребує змін у backend.

### A — Хибний

System prompt з поясненням форматів — модельна дискреція. Модель вже "іноді неправильно інтерпретує" — тобто знання форматів не гарантує правильної інтерпретації у всіх випадках.

### C — Хибний

Стандартизація backend API — концептуально правильно, але вимагає змін у зовнішніх системах. На практиці legacy системи часто не можна змінити. PostToolUse hook вирішує проблему без зміни backend.

### D — Хибний

PreToolUse hook виконується до виклику інструменту — він бачить вхідні параметри запиту, а не результати. Дати у відповідях від backend надходять після виклику, тому PreToolUse не може їх нормалізувати.

## Ключові концепції

### PostToolUse hook для нормалізації даних

```text
[Інструмент get_order_by_date повертає: {"date": 1718956800}]
     ↓
[PostToolUse hook]
  → Детектує Unix timestamp
  → Конвертує до "2024-06-21T00:00:00Z"
  → Модель отримує нормалізований результат
```

### Коли PostToolUse, коли PreToolUse

| Hook | Доступ до | Застосовувати для |
| --- | --- | --- |
| PreToolUse | Вхідних параметрів запиту | Валідація/трансформація того що надсилаємо |
| PostToolUse | Результатів відповіді | Нормалізація/збагачення того що отримали |

### Принцип: normalize at the boundary

Нормалізацію варто робити якомога раніше — одразу при отриманні даних з зовнішнього джерела. PostToolUse hook — ідеальна межа: зовнішній формат трансформується в уніфікований внутрішній до того як модель починає розмірковувати.

## Пов'язані нотатки

- [PreToolUse hook для людського затвердження](d1_pretooluse_human_approval.md) — PreToolUse vs PostToolUse
- [Детерміновані guardrails](d1_deterministic_guardrails.md) — hooks як enforcement механізм
- [Domain 1: Agentic AI](../domain_1_agentic.md)
