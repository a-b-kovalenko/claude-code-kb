[⬅️](qa_index.md)

## 📝 TL;DR

Найнадійніший спосіб отримати структурований вивід від Claude — визначити tool з input schema. Claude змушений продукувати аргументи що точно відповідають схемі на рівні API, а не "намагатися" вивести JSON за інструкцією в промпті.

## Original

**Scenario:** The system needs to extract candidate information (name, contact details, skills, work experience, education) from uploaded resumes.

**Question:** What is the most reliable approach to ensure Claude's output consistently matches the schema?

**A)** Parse Claude's text response with regex patterns to extract JSON objects, using retry logic for malformed responses.

**B)** Define a tool with an input schema matching your required JSON structure and extract the data from Claude's tool use response.

**C)** Make two separate API calls — first extracting information as text, then asking Claude to format that text as JSON.

**D)** Include detailed JSON formatting instructions and a template example in the system prompt, asking Claude to output only valid JSON.

## Питання

Система витягує дані кандидатів із завантажених резюме: ім'я, контактні дані, навички, досвід роботи, освіта.

Який підхід найнадійніше гарантує, що вивід Claude відповідатиме схемі?

**A)** Парсити текстову відповідь Claude regex-патернами для екстракції JSON-об'єктів, з retry-логікою при malformed responses.

**B)** Визначити tool з input schema, що відповідає потрібній JSON-структурі, і екстрагувати дані з відповіді tool use.

**C)** Зробити два окремі API-дзвінки: спочатку витягти інформацію як текст, потім попросити Claude відформатувати цей текст як JSON.

**D)** Включити детальні JSON-інструкції і шаблон-приклад у системний промпт, попросивши Claude виводити тільки валідний JSON.

## Правильна відповідь: B

## Аналіз варіантів

### A — Хибний

Regex-парсинг текстових відповідей — крихкий підхід. Модель може змінити форматування, додати пояснення навколо JSON або пропустити поле. Retry-логіка зменшує проблему, але не усуває її. Це боротьба з моделлю замість використання її можливостей.

### B — Правильний

Tool use з input schema — це контракт на рівні API. Claude конструює аргументи tool call, що точно відповідають визначеній схемі (required fields, типи даних). Схема валідується не промптом, а механізмом tool use. Для structured data extraction — це канонічний підхід.

### C — Хибний

Два API-дзвінки: дорожче, повільніше, і другий дзвінок все одно покладається на instruction-following для форматування. Жодної переваги надійності порівняно з B.

### D — Хибний

Детальні інструкції + шаблон краще за A, але надійність залежить від того, наскільки точно Claude слідує інструкції в конкретному контексті. В edge cases модель може додати коментар, змінити структуру або пропустити поле.

## Ключові концепції

### Що таке tool з input schema

Механізм **function calling** у Claude API. Замість того щоб просити модель "виведи JSON", ти описуєш функцію яку Claude може "викликати" — з назвою, описом і схемою параметрів (JSON Schema):

```json
{
  "name": "extract_candidate_info",
  "description": "Extract structured data from a resume",
  "input_schema": {
    "type": "object",
    "properties": {
      "name":   { "type": "string" },
      "email":  { "type": "string" },
      "skills": { "type": "array", "items": { "type": "string" } }
    },
    "required": ["name", "skills"]
  }
}
```

Коли Claude вирішує використати інструмент, API повертає не текст, а структурований `tool_use` блок з аргументами що відповідають схемі. Claude читає резюме → викликає цю функцію → ти отримуєш гарантовано валідний об'єкт.

### Tool use як механізм structured output

```text
Без tool use:
  prompt → Claude → текст (може бути JSON, може ні)

З tool use:
  prompt + tool schema → Claude → tool call з аргументами
                                   ↑ відповідає схемі гарантовано
```

Claude не "виводить JSON" — він викликає інструмент з аргументами. API-рівень забезпечує відповідність схемі.

### Приклад схеми для резюме

```json
{
  "name": "extract_candidate_info",
  "input_schema": {
    "type": "object",
    "properties": {
      "name": { "type": "string" },
      "email": { "type": "string" },
      "skills": { "type": "array", "items": { "type": "string" } },
      "experience": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "company": { "type": "string" },
            "role": { "type": "string" },
            "years": { "type": "number" }
          }
        }
      }
    },
    "required": ["name", "skills", "experience"]
  }
}
```

### Коли який підхід

| Потреба | Підхід |
| --- | --- |
| Гарантована відповідність схемі | Tool use з input schema |
| Швидкий прототип, проста структура | System prompt з шаблоном (D) |
| Аналіз готових text-відповідей | Regex з retry (A) — останній варіант |

## Пов'язані нотатки

- [Tool Use API](../../claude_api/tool_use_api.md) — повний agentic loop, tool_choice, parallel calls
- [Nullable fields у schema](d4_nullable_fields_schema.md) — required vs nullable у input_schema
- [Domain 4: Tool Design & MCP](../domain_4_mcp_tools.md) — проектування інструментів
- [Hybrid routing: Batch vs real-time](d4_batch_vs_realtime_routing.md) — вибір транспорту для обробки документів
