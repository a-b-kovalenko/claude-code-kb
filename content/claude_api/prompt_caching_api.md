[⬅️](Claude_API.md)

## 📝 TL;DR

Prompt caching знижує вартість повторних запитів з однаковим статичним префіксом. `cache_control: {type: "ephemeral"}` маркує кінець кешованого блоку. Cache hit коштує ~10% від повної ціни input токенів.

## Як працює

Claude API кешує від початку запиту до блоку з `cache_control`. При наступному запиті з ідентичним префіксом — cache hit, модель не обробляє його повторно.

```text
[System prompt — 12k токенів]  ← cache_control тут
                               ← все що ДО = кешований префікс
[Document content — змінюється] ← не кешується
```

Ключова умова: **зміна будь-чого до cache_control breakpoint інвалідує кеш**.

## cache_control у запиті

```json
{
  "system": [
    {
      "type": "text",
      "text": "You are an expert data analyst. [12k token instructions and schemas]",
      "cache_control": {"type": "ephemeral"}
    }
  ],
  "messages": [
    {
      "role": "user",
      "content": "Analyze this document: [variable content]"
    }
  ]
}
```

`cache_control` додається до блоку контенту — не до повідомлення цілком.

## Де ставити breakpoints

| Місце | Коли доцільно |
| --- | --- |
| Кінець system prompt | Статичні інструкції + схеми (найчастіший кейс) |
| Після `tools[]` | Довгий список інструментів що не змінюється |
| У messages | Довга незмінна конвенція (multi-turn з фіксованим початком) |

Можна мати **кілька breakpoints** в одному запиті — кожен маркує межу кешованого шару.

## Ліміти та TTL

| Параметр | Значення |
| --- | --- |
| Мінімум токенів для кешування | 1024 (Sonnet/Opus), 2048 (Haiku) |
| TTL | 5 хвилин після останнього звернення |
| Максимум breakpoints | 4 на запит |

Cache miss після 5 хвилин неактивності — prefix обробляється заново, нова cache write.

## Pricing

| Тип | Вартість відносно стандартної ціни |
| --- | --- |
| Cache write (перший запит) | ~125% (premium за запис) |
| Cache hit | ~10% |
| Cache miss (після TTL) | 100% (стандарт) + 125% write |

При 500 запитах/год: cache не встигає протухнути → 499 запитів по ~10% від 12k system prompt.

## Приклад: pipeline екстракції

```python
response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    system=[
        {
            "type": "text",
            "text": EXTRACTION_INSTRUCTIONS,  # 12k static
            "cache_control": {"type": "ephemeral"}
        }
    ],
    messages=[
        {
            "role": "user",
            "content": f"Extract from: {document}"  # variable
        }
    ]
)
# response.usage.cache_read_input_tokens > 0 → cache hit
```

`usage.cache_read_input_tokens` у відповіді показує скільки токенів прийшло з кешу.

## Пов'язані нотатки

- [🔢 Токени та токенізація](../Tokens_and_Tokenization.md) — що рахується і як оцінити обсяг до кешування
- [Prompt cache: статичне першим](../cca/qa/d3_prompt_cache_static_first.md) — чому порядок контенту важливий
- [Prompt cache: cache\_control breakpoint](../cca/qa/d3_prompt_cache_breakpoint.md) — приклад з 500 запитами/год
- [Claude API — Огляд](Claude_API.md)
