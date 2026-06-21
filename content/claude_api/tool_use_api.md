[⬅️](Claude_API.md)

## 📝 TL;DR

Tool use — механізм що дозволяє моделі викликати зовнішні функції: читати БД, звертатись до API, виконувати обчислення. Модель повертає `tool_use` block (id, name, input), клієнт виконує функцію і повертає `tool_result`. Також використовується для форсованого структурованого output.

## Для чого

Без tool use модель може лише генерувати текст з того що знає. Tool use вирішує чотири класи задач:

**1. Доступ до актуальних даних** — модель не знає поточний стан системи. Інструменти дають їй доступ:

```text
Модель: "Який статус замовлення #1234?"
→ tool: get_order_status(order_id="1234")
← result: {"status": "shipped", "eta": "2026-06-24"}
Модель: "Ваше замовлення відправлено, очікується 24 червня."
```

**2. Виконання дій** — модель не може сама писати в БД, надсилати email або створювати тікети. Це робить клієнтський код:

```text
Модель вирішує: потрібно ескалювати → tool: create_ticket(priority="high", ...)
Клієнт: реально створює тікет у Jira
```

**3. Структурована екстракція** — замість ненадійного "поверни JSON у тексті", tool use гарантує що модель сформує аргументи відповідно до `input_schema`. `tool_choice: tool` примушує виклик:

```text
Задача: витягти дані з рахунку-фактури
→ tool_choice: {"type": "tool", "name": "extract_invoice"}
← model завжди повертає tool_use з валідним JSON під схему
```

**4. Детерміноване розгалуження** — класифікація як інструмент дозволяє клієнту детерміновано обирати гілку обробки на основі рішення моделі:

```text
tools: [route_to_billing, route_to_technical, route_to_returns]
→ модель викликає route_to_technical(reason="...")
Клієнт: routing без парсингу тексту
```

## Класи задач і приклади інструментів

| Клас | Приклади інструментів |
| --- | --- |
| Читання даних | `get_user`, `search_products`, `run_sql_query`, `get_order_status` |
| Запис / дії | `create_ticket`, `send_email`, `update_record`, `post_comment` |
| Обчислення | `calculate_price`, `validate_discount`, `convert_currency` |
| Класифікація / routing | `classify_intent`, `detect_language`, `assess_severity` |
| Екстракція структури | `extract_invoice`, `parse_contract`, `extract_entities` |

## Визначення інструментів

У запиті передається масив `tools[]`:

```json
{
  "tools": [
    {
      "name": "get_order_status",
      "description": "Returns current status and ETA for an order. Use when the user asks about order status or delivery.",
      "input_schema": {
        "type": "object",
        "properties": {
          "order_id": {"type": "string", "description": "Order ID, e.g. '1234'"}
        },
        "required": ["order_id"]
      }
    }
  ]
}
```

`description` — ключове поле: модель читає його щоб вирішити чи викликати інструмент. Погана description → неправильний або пропущений виклик.

## Agentic loop

```text
1. POST /v1/messages  → tools[], messages[user: "статус замовлення 1234?"]
   ← stop_reason: "tool_use"
      content: [{type: "tool_use", id: "toolu_01", name: "get_order_status", input: {"order_id": "1234"}}]

2. Клієнт виконує: result = get_order_status("1234")  → {"status": "shipped", "eta": "2026-06-24"}

3. POST /v1/messages  → messages[user, assistant(tool_use), user(tool_result)]
   ← stop_reason: "end_turn"
      content: [{type: "text", text: "Ваше замовлення відправлено..."}]
```

Цикл повторюється поки `stop_reason != "end_turn"`. Модель може зробити кілька послідовних викликів перед фінальною відповіддю.

## tool_use content block

```json
{
  "type": "tool_use",
  "id": "toolu_01XF...",
  "name": "get_order_status",
  "input": {"order_id": "1234"}
}
```

`id` — унікальний per-виклик. Обов'язково використовувати у `tool_result` для зіставлення.

## tool_result

```json
{
  "role": "user",
  "content": [
    {
      "type": "tool_result",
      "tool_use_id": "toolu_01XF...",
      "content": "{\"status\": \"shipped\", \"eta\": \"2026-06-24\"}"
    }
  ]
}
```

У випадку помилки:

```json
{
  "type": "tool_result",
  "tool_use_id": "toolu_01XF...",
  "content": "Order not found",
  "is_error": true
}
```

`is_error: true` — модель бачить що виклик провалився і може або повідомити користувача, або спробувати інший підхід.

## tool_choice

Параметр верхнього рівня запиту, що задає **режим вибору інструменту для поточного виклику**. Не успадковується між запитами — треба передавати щоразу.

```json
{
  "model": "claude-sonnet-4-6",
  "tools": [...],
  "tool_choice": {"type": "any"},
  "messages": [...]
}
```

### auto (за замовчуванням)

```json
{"tool_choice": {"type": "auto"}}
```

Модель сама вирішує: викликати інструмент чи відповісти текстом. Якщо запит не потребує зовнішніх даних — відповідає без `tool_use`. Якщо потребує — вибирає з `tools[]` який підходить.

Поведінка: природна для чат-агентів, де більшість запитів — загальні, і лише частина вимагає даних.

### any

```json
{"tool_choice": {"type": "any"}}
```

Модель **зобов'язана** викликати хоча б один інструмент з `tools[]`. Відповісти plain text — заборонено. Яким саме інструментом — модель вирішує сама.

Використання: routing і класифікація, де потрібно гарантувати що модель прийняла рішення через інструмент, а не написала текстову відповідь яку потрібно парсити.

```python
# Гарантований routing — клієнт читає яку функцію викликала модель
tools = [route_billing, route_technical, route_returns]
tool_choice = {"type": "any"}
# stop_reason завжди "tool_use", ніколи "end_turn" без виклику
```

### tool (примусовий виклик конкретного)

```json
{"tool_choice": {"type": "tool", "name": "extract_invoice"}}
```

Модель **зобов'язана** викликати саме вказаний інструмент. Інші інструменти з `tools[]` ігноруються. Відповідь текстом — неможлива.

Це основний патерн **структурованої екстракції**: модель не може написати "ось JSON:", вона змушена сформувати аргументи під `input_schema` — API гарантує валідну структуру.

```python
# Завжди отримуємо структурований об'єкт, не текст
tool_choice = {"type": "tool", "name": "extract_invoice"}
response = client.messages.create(tools=[extract_invoice_tool], tool_choice=tool_choice, ...)
# response.content[0].type завжди == "tool_use"
# response.content[0].input відповідає input_schema
```

### Паралельні виклики і disable_parallel_tool_use

За замовчуванням модель може повернути кілька `tool_use` блоків одночасно. Щоб заборонити це:

```json
{"tool_choice": {"type": "auto", "disable_parallel_tool_use": true}}
```

Корисно коли інструменти мають побічні ефекти і важливий порядок виконання, або коли паралельні виклики створюють конфлікти (наприклад, два записи в одну таблицю).

## Parallel tool calls

Модель може повернути кілька `tool_use` блоків в одній відповіді:

```json
"content": [
  {"type": "tool_use", "id": "toolu_01", "name": "get_weather", "input": {"city": "Kyiv"}},
  {"type": "tool_use", "id": "toolu_02", "name": "get_weather", "input": {"city": "Berlin"}}
]
```

Клієнт виконує обидва паралельно, повертає два `tool_result` в одному user-повідомленні. Порядок `tool_result` у масиві не важливий — зіставлення за `tool_use_id`.

## Практичні сценарії

### Customer support bot

```python
tools = [get_order_status, update_shipping_address, escalate_to_human]
# Модель сама вирішує який інструмент викликати залежно від запиту
# tool_choice: auto — не обмежуємо
```

### Екстракція рахунків-фактур

```python
tools = [extract_invoice_data]  # один інструмент
tool_choice = {"type": "tool", "name": "extract_invoice_data"}
# Модель завжди повертає структурований об'єкт, ніколи — plain text
```

### SQL-агент

```python
tools = [get_schema, run_query, explain_results]
# Модель: get_schema → аналізує → run_query → explain_results
# Кілька послідовних викликів до end_turn
```

### Intent routing

```python
tools = [route_to_billing, route_to_technical, route_to_account]
tool_choice = {"type": "any"}  # гарантуємо що routing відбудеться
# Клієнт читає яку функцію викликала модель → диспатчить далі
```

## Пов'язані нотатки

- [Structured output через tool schema](../cca/qa/d4_structured_output_tool_schema.md) — tool use для надійної екстракції JSON
- [Nullable fields у schema](../cca/qa/d4_nullable_fields_schema.md) — required vs nullable у input_schema
- [Дизайн помилок інструментів](../cca/qa/d4_tool_error_design.md) — структурований `retriable` замість парсингу тексту помилки
- [Розбиття інструменту на цільові](../cca/qa/d4_tool_splitting.md) — вузькоспеціалізовані інструменти vs один широкий
- [Claude API — Огляд](Claude_API.md)
