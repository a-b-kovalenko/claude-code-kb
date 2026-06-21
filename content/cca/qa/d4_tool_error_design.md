[⬅️](qa_index.md)

## 📝 TL;DR

Інструмент має розрізняти transient і permanent помилки структурно — через поле `retriable`, а не через текст повідомлення. Structured error відповідь з `retriable: false` усуває марні retries, а customer-friendly пояснення дає агенту готову мову для відповіді користувачу.

## Original

**Scenario:** Your process_refund tool returns two types of errors: technical errors ("503 Service Unavailable", "Connection timeout") that are transient (5% of calls), and business errors ("Order exceeds 30-day return window", "Item already refunded") that are permanent (12% of calls). Monitoring shows the agent wastes 3–4 turns retrying business errors that can never succeed.

**Question:** What's the most effective way to reduce wasted retries while improving customer-facing response quality?

**A)** Implement automatic retry logic at the tool level for technical errors only, passing business errors to Claude without retries.

**B)** Return structured error responses with retriable: false for business errors and a customer-friendly explanation for Claude to use.

**C)** Add a check_refund_eligibility tool that must be called before process_refund to prevent business rule violations.

**D)** Add few-shot examples showing how to distinguish retriable from non-retriable errors by parsing error message text.

## Питання

Інструмент `process_refund` повертає два типи помилок:

- **Технічні** ("503 Service Unavailable", "Connection timeout") — transient, 5% викликів
- **Бізнес-помилки** ("Order exceeds 30-day return window", "Item already refunded") — permanent, 12% викликів

Моніторинг показує: агент витрачає 3–4 ходи на retry бізнес-помилок, які ніколи не успішні.

Який найефективніший спосіб скоротити марні retries і покращити якість відповіді клієнту?

**A)** Реалізувати автоматичну retry-логіку на рівні інструменту тільки для технічних помилок, передаючи бізнес-помилки до Claude без retry.

**B)** Повертати structured error відповіді з `retriable: false` для бізнес-помилок і customer-friendly поясненням для Claude.

**C)** Додати інструмент `check_refund_eligibility`, який обов'язково викликається перед `process_refund` для запобігання порушенням бізнес-правил.

**D)** Додати few-shot приклади що показують як розрізняти retriable і non-retriable помилки через парсинг тексту помилки.

## Правильна відповідь: B

## Аналіз варіантів

### A — Хибний

Вирішує проблему марних retries, але не покращує якість відповіді. Claude отримує сиру бізнес-помилку і сам має перетворити її у відповідь клієнту — без гарантії якості. Половина рішення.

### B — Правильний

Вирішує обидві проблеми одночасно:

- `retriable: false` — чіткий структурний сигнал, агент не витрачає ходи на retry
- customer-friendly пояснення — готова мова для відповіді, Claude не інтерпретує технічну помилку самостійно

### C — Хибний

Превентивний підхід, але дорогий: кожен виклик `process_refund` тепер вимагає додаткового tool call. Збільшує latency і кількість токенів для happy path (88% випадків). Eligibility також може змінитися між перевіркою і виконанням.

### D — Хибний

Покладається на Claude, що коректно розпарсить текст помилки і зробить правильний висновок. Крихко: зміна формату повідомлення ламає логіку. Структурне поле надійніше за текстовий парсинг.

## Ключові концепції

### Structured error response

Замість сирого тексту помилки — структурований об'єкт що описує семантику помилки:

```json
{
  "error": {
    "type": "business_rule_violation",
    "retriable": false,
    "message": "Order exceeds 30-day return window",
    "customer_explanation": "This order was placed 45 days ago and is outside our 30-day return policy. I can help you explore other options."
  }
}
```

```json
{
  "error": {
    "type": "service_unavailable",
    "retriable": true,
    "message": "503 Service Unavailable",
    "retry_after_ms": 2000
  }
}
```

### Принцип: інструмент керує retry-семантикою

Агент не повинен "здогадуватися" чи варто робити retry — інструмент **явно повідомляє** цю інформацію. Це детермінована логіка на рівні коду, а не модельне міркування.

| Тип помилки | `retriable` | Дія агента |
| --- | --- | --- |
| Технічна (503, timeout) | `true` | Retry з backoff |
| Бізнес-правило | `false` | Відповідь клієнту з `customer_explanation` |

### Зв'язок з дизайном інструментів

Tool response — це не лише "результат або помилка". Це **контракт** між інструментом і агентом: structured помилки є частиною API інструменту і мають бути спроектовані так само ретельно, як і успішна відповідь.

## Пов'язані нотатки

- [Domain 4: Tool Design & MCP](../domain_4_mcp_tools.md) — проектування інструментів
- [Детерміновані guardrails](d1_deterministic_guardrails.md) — code-level enforcement vs модельна дискреція
