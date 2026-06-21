[⬅️](Claude_API.md)

## 📝 TL;DR

Batch Messages API — асинхронна обробка до 10 000 запитів за 50% знижки. Клієнт відправляє batch, отримує `batch_id`, пізніше завантажує JSONL з результатами. `custom_id` зв'язує кожну відповідь з вихідним запитом.

## Lifecycle

```text
1. POST /v1/messages/batches
   → {"id": "msgbatch_01...", "processing_status": "in_progress"}

2. GET  /v1/messages/batches/{id}
   → processing_status: "in_progress" | "ended"

3. GET  /v1/messages/batches/{id}/results  (після ended)
   → JSONL: одна відповідь на рядок
```

Batch обробляється до 24 годин. Polling або webhook (якщо налаштований).

## Структура запиту

```json
{
  "requests": [
    {
      "custom_id": "invoice-001",
      "params": {
        "model": "claude-sonnet-4-6",
        "max_tokens": 1024,
        "messages": [{"role": "user", "content": "Extract data from: ..."}]
      }
    },
    {
      "custom_id": "invoice-002",
      "params": { ... }
    }
  ]
}
```

`custom_id` — довільний рядок для ідентифікації запиту у результатах. Унікальний у межах batch.

## Структура результатів (JSONL)

```jsonl
{"custom_id": "invoice-001", "result": {"type": "succeeded", "message": {...}}}
{"custom_id": "invoice-002", "result": {"type": "errored", "error": {"type": "...", "message": "..."}}}
{"custom_id": "invoice-003", "result": {"type": "canceled"}}
{"custom_id": "invoice-004", "result": {"type": "expired"}}
```

Типи результатів: `succeeded`, `errored`, `canceled`, `expired`.

## Ліміти

| Параметр | Значення |
| --- | --- |
| Максимум запитів у batch | 10 000 |
| Максимальний розмір batch | 32 MB |
| Термін зберігання результатів | 29 днів |
| Максимальний час обробки | 24 години |

## Pricing

50% знижка від стандартної ціни Messages API. Застосовується до всіх типів токенів (input, output, cache).

## Matching rule: Batch vs Synchronous

Ключовий критерій — не тип задачі, а чи хтось **блокує виконання** в очікуванні результату:

| Synchronous API | Batch API |
| --- | --- |
| Хтось чекає результат прямо зараз | Результат буде спожито пізніше |
| Pre-merge checks, real-time code review | Нічні звіти технічного боргу |
| Developer-blocking сценарії | Тижневі аудити, генерація тестів |

**Правило:** якщо workflow блокується в очікуванні — sync. Якщо latency-tolerant — batch.

## Коли НЕ використовувати

- Streaming responses
- Залежні запити (результат A потрібен для B)
- Tool use з негайним виконанням інструментів
- Multi-turn tool calling у межах одного batch запиту

## Стратегія: sample перед batch

```text
1. Відправити 1 000 запитів через real-time API
2. Перевірити якість і патерни помилок
3. Виправити промпти/схеми
4. Тоді відправити повний обсяг через batch
```

Вплив якості промптів на вартість:

| First-pass success | Повторні запити на 20 документів |
| --- | --- |
| 90% | ~2 retry |
| 60% | ~8 retry (4× дорожче) |

## Обробка збоїв

Тристепова стратегія після отримання JSONL результатів:

1. Ідентифікувати збої за `custom_id` (тип `errored` або семантично невалідні)
2. Перевідправити **лише невдалі** запити з цільовими змінами (більше токенів, chunking, format examples)
3. Уточнити промпти на 5–10 зразках перед наступним повним batch

## SLA розрахунок

Для SLA з фіксованим дедлайном:

```text
SLA вікно - 24h (максимум обробки) = буфер
Приклад: 30h SLA → 30 - 24 = 6h буфер
Відправляти batch кожні 4–6 годин щоб гарантувати дедлайн
```

## Пов'язані нотатки

- [Стратегія batch processing](../cca/qa/d4_batch_api_strategy.md) — sample-first + batch для масової обробки
- [Hybrid routing: Batch vs real-time](../cca/qa/d4_batch_vs_realtime_routing.md) — маршрутизація за latency-вимогами
- [Claude API — Огляд](Claude_API.md)
