[⬅️](qa_index.md)

## 📝 TL;DR

`cache_control` breakpoint встановлюється після статичного префікса. 12k-токенний system prompt кешується один раз і використовується для всіх наступних запитів — платиш повну ціну лише при першому, решта — ~10% вартості.

## Original

**Scenario:** A structured data extraction pipeline processes 500 documents per hour. Each request sends the same 12k-token system prompt with extraction schemas, followed by the document content which varies per request. The team wants to reduce API costs. Which prompt caching strategy is most effective?

**A)** Split each request into two API calls: one for the cached system prompt and one for the document, then combine the results

**B)** Send the document content first so the model processes it before the extraction instructions, then cache the extraction at the end

**C)** Place the 12k-token system prompt and extraction schemas first, set a `cache_control` breakpoint after them, then append the variable document content. The static prefix caches across all 500 requests per hour

**D)** Cache the entire prompt including document content, since many documents have similar structures

## Питання

Пайплайн екстракції обробляє 500 документів на годину. Кожен запит надсилає однаковий 12k-токенний system prompt зі схемами екстракції, після якого йде контент документу що змінюється per request. Яка стратегія prompt caching найефективніша?

**A)** Розбити кожен запит на два API виклики: один для кешованого system prompt, інший для документу, потім об'єднати результати

**B)** Надіслати контент документу першим щоб модель обробила його до інструкцій екстракції, потім закешувати екстракцію в кінці

**C)** Розмістити 12k-токенний system prompt і схеми екстракції спочатку, встановити `cache_control` breakpoint після них, потім додати змінний контент документу. Статичний префікс кешується для всіх 500 запитів на годину

**D)** Кешувати весь промпт включно з контентом документу — багато документів мають схожу структуру

## Правильна відповідь: C

## Аналіз варіантів

### C — Правильний

`cache_control` breakpoint явно маркує кінець кешованого префікса. 12k статичного system prompt кешується після першого запиту → 499 запитів платять ~10% від 12k замість повної ціни. Документи після breakpoint не кешуються — але вони й змінюються.

### A — Хибний

Два окремих API виклики per request = подвійний overhead на latency і network. Prompt caching не вимагає розбиття — все в одному запиті.

### B — Хибний

Документ першим ламає кешування: статичний system prompt стоїть після динамічного документу → починається у різних позиціях у різних запитах → cache miss кожен раз.

### D — Хибний

Схожа структура документів ≠ ідентичний контент. Навіть мінімальна відмінність між документами інвалідує кеш. Кешувати можна лише те що гарантовано незмінне.

## Ключові концепції

### cache_control breakpoint у API

```json
{
  "role": "user",
  "content": [
    {
      "type": "text",
      "text": "...12k system prompt + extraction schemas...",
      "cache_control": {"type": "ephemeral"}
    },
    {
      "type": "text",
      "text": "Document: ..."
    }
  ]
}
```

Блок з `cache_control` = кінець кешованого префікса. Наступний блок — поза кешем.

### Економія при 500 документах/год

| Запит | Без caching | З caching |
| --- | --- | --- |
| 1-й (cache write) | Повна ціна 12k + doc | Повна ціна 12k + doc |
| 2–500 (cache hit) | Повна ціна 12k + doc | ~10% від 12k + повна doc |

Cache TTL — 5 хвилин. 500 документів/год = ~8 на хвилину, кеш не встигає протухнути.

## Пов'язані нотатки

- [Prompt Caching API](../../claude_api/prompt_caching_api.md) — cache_control синтаксис, TTL, pricing, де ставити breakpoints
- [Prompt cache: статичне першим](d3_prompt_cache_static_first.md) — чому порядок контенту важливий
- [Domain 3: Prompt Engineering](../domain_3_prompts.md) — оптимізація промптів
- [Вибір моделі та оптимізація вартості](../../Model_Selection_and_Cost.md) — стратегії економії
