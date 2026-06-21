[⬅️](qa_index.md)

## 📝 TL;DR

Для prompt caching статичний контент (системний промпт, схеми) має стояти на початку, динамічний (документ, запит) — в кінці. `cache_control` breakpoint позначає межу кешованого префікса. Зміна будь-чого до breakpoint інвалідує кеш.

## Original

**Scenario A (Q9):** When using prompt caching to optimise a pipeline that processes many documents with the same extraction instructions, where should the static and dynamic content be placed in the prompt?

**A)** Interleave static instructions and dynamic content throughout the prompt for better context

**B)** Static extraction instructions at the beginning, dynamic document content at the end

**C)** Dynamic document content at the beginning, static extraction instructions at the end

**D)** Put all content in a single message with no particular ordering, since prompt caching automatically identifies cacheable sections

---

**Scenario B (Q16):** A structured data extraction pipeline processes 500 documents per hour. Each request sends the same 12k-token system prompt with extraction schemas, followed by the document content which varies per request. The team wants to reduce API costs. Which prompt caching strategy is most effective?

**A)** Split each request into two API calls: one for the cached system prompt and one for the document, then combine the results

**B)** Send the document content first so the model processes it before the extraction instructions, then cache the extraction at the end

**C)** Place the 12k-token system prompt and extraction schemas first, set a `cache_control` breakpoint after them, then append the variable document content. The static prefix caches across all 500 requests per hour

**D)** Cache the entire prompt including document content, since many documents have similar structures

## Питання

**Сценарій A:** При використанні prompt caching для пайплайну що обробляє багато документів з однаковими інструкціями екстракції — де повинні знаходитись статичний і динамічний контент у промпті?

**B)** Статичні інструкції екстракції на початку, динамічний контент документу в кінці ✓

---

**Сценарій B:** Пайплайн обробляє 500 документів на годину. Кожен запит надсилає однаковий 12k-токенний system prompt із схемами екстракції, після якого йде контент документу який змінюється. Яка стратегія prompt caching найефективніша?

**C)** Розмістити 12k-токенний system prompt і схеми екстракції спочатку, встановити `cache_control` breakpoint після них, потім додати змінний контент документу. Статичний префікс кешується для всіх 500 запитів на годину ✓

## Правильна відповідь: B (Q9), C (Q16)

## Аналіз варіантів

### Q9 — правильна відповідь B

Anthropic кешує від початку промпту до cache breakpoint. Щоб кеш спрацьовував — статичний контент має бути на початку (незмінний між запитами), динамічний в кінці (після breakpoint, не кешується). Перемішування (A) ламає кеш. Динамічне першим (C) означає статичне не може бути закешоване. "Автоматичне виявлення" (D) не відповідає реальній поведінці API.

### Q16 — правильна відповідь C

`cache_control` breakpoint явно маркує кінець кешованого префікса. 12k статичного system prompt кешується і використовується для всіх 500 документів — платиш за нього лише раз. Два окремих API виклики (A) додають latency. Документ першим (B) ламає кешування статики. Кешування з документом (D) не дає виграшу — контент змінюється.

## Ключові концепції

### Структура промпту для caching

```text
[System prompt — СТАТИЧНО, 12k токенів]
[Extraction schemas — СТАТИЧНО]
<cache_control breakpoint>
[Document content — ДИНАМІЧНО, змінюється per request]
```

Все до breakpoint = кешований префікс (платиш одноразово при першому запиті).
Все після breakpoint = не кешується (платиш за кожен запит).

### cache_control breakpoint у API

```json
{
  "type": "text",
  "text": "...system prompt...",
  "cache_control": {"type": "ephemeral"}
}
```

Поле `cache_control` з `type: ephemeral` встановлює breakpoint на цьому повідомленні.

### Економія при 500 документах/год

| Підхід | Cost за запит |
| --- | --- |
| Без caching | Повна ціна 12k + document |
| З caching (static first) | Cache hit: ~10% від 12k + повна document |

### Правило: stable content leads

Будь-який контент що залишається незмінним між запитами → на початок промпту до breakpoint. Чим більший і стабільніший префікс — тим більша економія.

## Пов'язані нотатки

- [Domain 3: Prompt Engineering](../domain_3_prompts.md) — оптимізація промптів
- [Вибір моделі та оптимізація вартості](../../Model_Selection_and_Cost.md) — стратегії економії
