[⬅️](qa_index.md)

## 📝 TL;DR

При prompt caching статичний контент (системний промпт, схеми) має стояти на початку промпту, динамічний (документ, запит) — в кінці. Кеш прив'язаний до незмінного префікса від початку до breakpoint.

## Original

**Question:** When using prompt caching to optimise a pipeline that processes many documents with the same extraction instructions, where should the static and dynamic content be placed in the prompt?

**A)** Interleave static instructions and dynamic content throughout the prompt for better context

**B)** Static extraction instructions at the beginning, dynamic document content at the end

**C)** Dynamic document content at the beginning, static extraction instructions at the end

**D)** Put all content in a single message with no particular ordering, since prompt caching automatically identifies cacheable sections

## Питання

При використанні prompt caching для пайплайну що обробляє багато документів з однаковими інструкціями екстракції — де повинні знаходитись статичний і динамічний контент у промпті?

**A)** Перемішати статичні інструкції і динамічний контент по всьому промпту для кращого контексту

**B)** Статичні інструкції екстракції на початку, динамічний контент документу в кінці

**C)** Динамічний контент документу на початку, статичні інструкції екстракції в кінці

**D)** Розмістити весь контент в одному повідомленні без будь-якого порядку — prompt caching автоматично визначає кешовані секції

## Правильна відповідь: B

## Аналіз варіантів

### B — Правильний

Anthropic кешує від початку промпту до cache breakpoint. Щоб кеш спрацьовував між запитами — статичний контент має бути на початку (незмінний), динамічний в кінці (після breakpoint, не кешується). Будь-яка зміна до breakpoint інвалідує весь кеш.

### A — Хибний

Перемішування статики і динаміки ламає кеш. Якщо між двома статичними блоками є динамічний — весь рядок після першої зміни не кешується.

### C — Хибний

Динамічне першим означає статичне йде після нього. Кеш прив'язаний до фіксованого префікса від початку — якщо початок змінюється per request, кеш ніколи не спрацьовує.

### D — Хибний

Prompt caching не визначає кешовані секції автоматично. `cache_control` breakpoint потрібно встановлювати явно, і кешується лише те що стоїть до нього.

## Ключові концепції

### Правило: stable content leads

```text
[System prompt — СТАТИЧНО]     ← кешується
[Extraction schemas — СТАТИЧНО] ← кешується
<cache_control breakpoint>
[Document content — ДИНАМІЧНО] ← не кешується, змінюється per request
```

Будь-який контент що залишається незмінним між запитами → на початок до breakpoint. Чим більший стабільний префікс — тим більша економія.

### Сигнал у питанні

"Same extraction instructions" + "many documents" = є великий статичний блок що повторюється. Відповідь завжди: статичне першим.

## Пов'язані нотатки

- [Prompt cache: cache_control breakpoint](d3_prompt_cache_breakpoint.md) — як встановити breakpoint і порахувати економію
- [Domain 3: Prompt Engineering](../domain_3_prompts.md) — оптимізація промптів
- [Вибір моделі та оптимізація вартості](../../Model_Selection_and_Cost.md) — стратегії економії
