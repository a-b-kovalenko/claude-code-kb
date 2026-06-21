[⬅️](Claude_API.md)

## 📝 TL;DR

Tool use у Claude API — механізм виклику зовнішніх функцій. Модель повертає `tool_use` content block (id, name, input), клієнт виконує функцію і повертає `tool_result` у наступному user-повідомленні. Цикл повторюється до відповіді без `tool_use`.

## Визначення інструментів

У запиті передається масив `tools[]`:

```json
{
  "tools": [
    {
      "name": "get_weather",
      "description": "Returns current temperature and conditions for a city. Use when the user asks about weather.",
      "input_schema": {
        "type": "object",
        "properties": {
          "city": {"type": "string", "description": "City name, e.g. 'Kyiv'"},
          "units": {"type": "string", "enum": ["celsius", "fahrenheit"]}
        },
        "required": ["city"]
      }
    }
  ]
}
```

Три поля: `name`, `description` (модель читає щоб вирішити чи викликати), `input_schema` (JSON Schema для аргументів).

## Agentic loop

```text
1. POST /v1/messages  → tools[], messages[user]
   stop_reason: "tool_use"
   content: [{type: "tool_use", id: "toolu_01...", name: "get_weather", input: {...}}]

2. Клієнт виконує функцію: result = get_weather(input)

3. POST /v1/messages  → messages[user, assistant, user(tool_result)]
   {role: "user", content: [{type: "tool_result", tool_use_id: "toolu_01...", content: "..."}]}

4. Повторювати до stop_reason: "end_turn"
```

`stop_reason: "tool_use"` — сигнал що модель чекає на результат виклику.

## tool_use content block

```json
{
  "type": "tool_use",
  "id": "toolu_01XF...",
  "name": "get_weather",
  "input": {
    "city": "Kyiv",
    "units": "celsius"
  }
}
```

`id` — унікальний ідентифікатор виклику. Використовується у `tool_result` для зіставлення.

## tool_result

```json
{
  "role": "user",
  "content": [
    {
      "type": "tool_result",
      "tool_use_id": "toolu_01XF...",
      "content": "12°C, cloudy"
    }
  ]
}
```

Або у випадку помилки:

```json
{
  "type": "tool_result",
  "tool_use_id": "toolu_01XF...",
  "content": "Error: city not found",
  "is_error": true
}
```

## tool_choice

Контролює поведінку вибору інструменту:

| Значення | Поведінка |
| --- | --- |
| `{"type": "auto"}` | Модель вирішує (за замовчуванням) |
| `{"type": "any"}` | Модель повинна викликати хоч один інструмент |
| `{"type": "tool", "name": "X"}` | Модель повинна викликати саме інструмент X |

```json
{"tool_choice": {"type": "tool", "name": "get_weather"}}
```

## Parallel tool calls

Модель може повернути кілька `tool_use` блоків в одній відповіді:

```json
"content": [
  {"type": "tool_use", "id": "toolu_01", "name": "get_weather", "input": {"city": "Kyiv"}},
  {"type": "tool_use", "id": "toolu_02", "name": "get_weather", "input": {"city": "Berlin"}}
]
```

Клієнт виконує обидва паралельно, повертає два `tool_result` в одному user-повідомленні.

## Пов'язані нотатки

- [Structured output через tool schema](../cca/qa/d4_structured_output_tool_schema.md) — tool use для надійної екстракції JSON
- [Nullable fields у schema](../cca/qa/d4_nullable_fields_schema.md) — required vs nullable у input_schema
- [Claude API — Огляд](Claude_API.md)
