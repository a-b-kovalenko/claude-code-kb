[⬅️](qa_index.md)

## 📝 TL;DR

Поле `required` у JSON schema тисне на модель щоб заповнити його — навіть якщо даних немає, модель вигадує правдоподібні значення. Рішення: `nullable` або `optional` поля дозволяють повернути `null` замість fabrication. Це schema-level fix, а не post-hoc validation.

## Original

**Scenario:** Your extraction system uses tool_use with a strict JSON schema. All fields are marked as required. Testers report that the model invents plausible-looking dates and amounts when processing documents that lack this information.

**Question:** What is the best fix?

**A)** Add a validation step that checks all values against the source document

**B)** Switch from tool_use to prompt-based JSON extraction

**C)** Make fields optional/nullable when source documents may not contain the information

**D)** Add an instruction telling the model not to hallucinate

## Питання

Система екстракції використовує tool_use зі строгою JSON schema. Всі поля позначені як required. Тестери повідомляють що модель вигадує правдоподібні дати і суми для документів де ця інформація відсутня. Яке найкраще виправлення?

**A)** Додати крок валідації що перевіряє всі значення відносно вихідного документу

**B)** Перейти з tool_use на prompt-based JSON екстракцію

**C)** Зробити поля optional/nullable для випадків коли вихідний документ може не містити інформацію

**D)** Додати інструкцію що забороняє моделі галюцинувати

## Правильна відповідь: C

## Аналіз варіантів

### C — Правильний

`nullable` або `optional` поля дозволяють моделі повернути `null` коли дані відсутні в документі. Без цієї можливості модель відчуває schema-рівневий тиск заповнити `required` поле — і вигадує правдоподібні значення. Nullable fix усуває причину fabrication на рівні контракту.

### A — Хибний

Post-hoc валідація корисна, але не усуває причину. Модель продовжуватиме вигадувати — просто деякі значення будуть відхилені. Доводиться обробляти fabrication після факту, а не запобігати їй.

### B — Хибний

Крок назад у надійності. Prompt-based JSON вводить ризик синтаксичних помилок, неповних об'єктів і неправильної структури — і не вирішує проблему fabrication (модель так само відчуває тиск "придумати" значення для відсутніх полів).

### D — Хибний

Vague instructions не переважають schema constraint. Поле позначене `required` — schema-рівневий тиск сильніший за інструкцію "не галюцинуй". Модель сприймає required поле як сигнал що значення ПОВИННО бути.

## Ключові концепції

### Required fields → fabrication pressure

```json
// ПРОБЛЕМА: required тисне на заповнення
{
  "type": "object",
  "properties": {
    "invoice_date": {"type": "string"},
    "amount": {"type": "number"}
  },
  "required": ["invoice_date", "amount"]
}
// Модель: "invoice_date required → треба щось написати" → вигадує "2024-01-15"
```

### Nullable fields → дозвіл на null

```json
// РІШЕННЯ: nullable дозволяє повернути null
{
  "type": "object",
  "properties": {
    "invoice_date": {"type": ["string", "null"]},
    "amount": {"type": ["number", "null"]}
  }
}
// Модель: "invoice_date nullable → можна null якщо відсутнє" → повертає null
```

### Два рівні schema design для extraction

| Рівень | Питання | Рішення |
| --- | --- | --- |
| Надійність формату | Чи повернеться валідний JSON? | tool_use > prompt-based |
| Надійність контенту | Чи не вигадає модель значення? | nullable/optional fields |

Перший рівень — тема [d4_structured_output_tool_schema](d4_structured_output_tool_schema.md). Цей сценарій — другий рівень.

### Правило: nullable для всіх необов'язкових даних

Якщо поле може бути відсутнє в реальних документах → воно повинно бути `nullable`. `required` тільки для полів що гарантовано присутні у всіх документах.

## Пов'язані нотатки

- [Structured output через tool schema](d4_structured_output_tool_schema.md) — tool_use як механізм надійної екстракції
- [Domain 4: Tool Design & MCP](../domain_4_mcp_tools.md)
