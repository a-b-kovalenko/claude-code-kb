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

## Коли використовувати

| Підходить | Не підходить |
| --- | --- |
| Незалежні запити (кожен не залежить від інших) | Streaming responses |
| Нечутливо до latency (часу відповіді) | Залежні запити (результат A потрібен для B) |
| Масова обробка: класифікація, екстракція | Tool use з негайним виконанням |
| Cost-sensitive workloads | Real-time user-facing запити |

## Стратегія: sample перед batch

```text
1. Відправити 1 000 запитів через real-time API
2. Перевірити якість і патерни помилок
3. Виправити промпти/схеми
4. Тоді відправити 50 000 через batch
```

Batch не підходить для виявлення проблем — зворотний зв'язок надходить з великою затримкою.

## Пов'язані нотатки

- [Стратегія batch processing](../cca/qa/d4_batch_api_strategy.md) — sample-first + batch для масової обробки
- [Hybrid routing: Batch vs real-time](../cca/qa/d4_batch_vs_realtime_routing.md) — маршрутизація за latency-вимогами
- [Claude API — Огляд](Claude_API.md)
