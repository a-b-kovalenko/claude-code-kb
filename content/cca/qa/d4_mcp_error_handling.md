[⬅️](qa_index.md)

## 📝 TL;DR

MCP розрізняє два рівні помилок: JSON-RPC protocol errors — для некоректних викликів на рівні протоколу (malformed request, відсутні параметри), і tool results з `isError: true` — для помилок під час виконання (API повернув 404, 503). Критерій: чи міг інструмент взагалі почати виконуватись?

## Original

**Scenario:** Your MCP server implements a check_availability tool that queries an external calendar API. During testing, you encounter three error conditions: 1) the tool is called with a malformed request missing the required user email parameter, 2) the calendar API returns a 404 because the specified user doesn't exist in the calendar system, and 3) the calendar API returns a 503 because the service is temporarily unavailable.

**Question:** How should each error be reported according to MCP's error handling design?

**A)** Report error 1 as a JSON-RPC protocol error; report errors 2 and 3 as tool results with isError: true.

**B)** Report all three as tool results with isError: true.

**C)** Report errors 1 and 2 as JSON-RPC protocol errors; report error 3 as a tool result with isError: true.

**D)** Report all three as JSON-RPC protocol errors.

## Питання

MCP-сервер реалізує інструмент `check_availability`, що запитує зовнішній Calendar API. Під час тестування — три умови помилок:

1. Інструмент викликається з malformed запитом, де відсутній обов'язковий параметр `user_email`
2. Calendar API повертає 404 — вказаного користувача не існує в системі
3. Calendar API повертає 503 — сервіс тимчасово недоступний

Як слід звітувати кожну помилку відповідно до дизайну MCP error handling?

**A)** Помилку 1 — як JSON-RPC protocol error; помилки 2 і 3 — як tool results з `isError: true`.

**B)** Усі три — як tool results з `isError: true`.

**C)** Помилки 1 і 2 — як JSON-RPC protocol errors; помилку 3 — як tool result з `isError: true`.

**D)** Усі три — як JSON-RPC protocol errors.

## Правильна відповідь: A

## Аналіз варіантів

### A — Правильний

- Помилка 1: відсутній обов'язковий параметр — запит некоректний на рівні протоколу, інструмент не може навіть почати виконуватись → JSON-RPC protocol error
- Помилки 2 і 3: інструмент виконався, надіслав запит до API, отримав відповідь — операція провалилась під час виконання → tool result з `isError: true`

### B — Хибний

Помилка 1 — не помилка виконання, а помилка виклику. Інструмент не може запуститись без обов'язкового параметра. Це protocol-level, не execution-level.

### C — Хибний

404 — це відповідь зовнішнього API, що означає успішний запит з боку інструменту. Інструмент виконався коректно, але ресурс не знайдений. Це execution-level outcome, не protocol error.

### D — Хибний

503 і 404 — результати успішних HTTP-запитів від інструменту. Зовнішній сервіс відповів — інструмент виконався. JSON-RPC protocol error тут неправильний рівень абстракції.

## Ключові концепції

### Два рівні помилок у MCP

| Тип | Коли | Приклади |
| --- | --- | --- |
| JSON-RPC protocol error | Запит некоректний, інструмент не може запуститись | Відсутній параметр, невідомий метод, malformed JSON |
| Tool result `isError: true` | Інструмент виконався, операція провалилась | API 404/503, бізнес-помилка, timeout зовнішнього сервісу |

### Критерій розрізнення

**Ключове питання: чи міг інструмент почати виконуватись?**

```text
Некоректний виклик (missing param, unknown method)
  → Інструмент не запускається
  → JSON-RPC protocol error

Коректний виклик → інструмент виконується → зовнішній API відповідає
  → Операція провалилась (404, 503, бізнес-правило)
  → tool result { isError: true, content: [...] }
```

### Tool result з isError: true

```json
{
  "content": [
    {
      "type": "text",
      "text": "Calendar API error 404: User 'john@example.com' not found in the calendar system"
    }
  ],
  "isError": true
}
```

Цей формат дозволяє Claude отримати деталі помилки і прийняти рішення — retry, ескалація або відповідь користувачу.

## Пов'язані нотатки

- [Domain 4: Tool Design & MCP](../domain_4_mcp_tools.md) — MCP архітектура і інструменти
- [Дизайн помилок інструментів](d4_tool_error_design.md) — structured errors для управління поведінкою агента
