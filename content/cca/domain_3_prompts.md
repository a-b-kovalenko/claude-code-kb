[⬅️](CCA_Foundations.md)

## 📝 TL;DR

Домен (20%): prompt engineering та structured output. Підступний домен — неправильні відповіді звучать як хороша інженерія. Фокус: XML-теги, JSON schema design, validation-retry loop, few-shot patterns.

## Prompt Hierarchy

Claude Code обробляє інструкції у такому порядку пріоритетів:

```text
1. System prompt (найвищий пріоритет)
2. CLAUDE.md (global → project → rules)
3. Human turn (запит користувача)
4. Tool results
```

Якщо є конфлікт між рівнями — вищий пріоритет перемагає. CLAUDE.md є частиною system prompt.

## XML-теги для структурування

Anthropic рекомендує XML-теги для чіткого розмежування секцій у промпті:

```xml
<instructions>
  Проаналізуй наступний код і знайди вразливості.
</instructions>

<code>
  {{code}}
</code>

<output_format>
  Поверни JSON масив об'єктів: {line, severity, description}
</output_format>
```

**Чому це важливо:** без розмежування модель може змішати інструкцію і дані (prompt injection ризик).

## JSON Schema Design

### Required vs. Nullable

```json
{
  "type": "object",
  "required": ["id", "status"],
  "properties": {
    "id": { "type": "string" },
    "status": { "type": "string", "enum": ["active", "inactive"] },
    "description": { "type": ["string", "null"] }
  }
}
```

- `required` — поле обов'язкове, але може бути `null` якщо тип включає `"null"`
- Відсутність у `required` — поле можна не повертати взагалі

**Типова помилка:** очікувати що необов'язкове поле буде `null` — воно може бути відсутнє зовсім.

## Validation-Retry Loop

```text
Prompt → Response → Validate schema → OK? → Done
                          ↓ FAIL
                   Retry prompt з описом помилки
                          ↓ (max 3 спроби)
                   Escalate / fallback
```

У retry prompt треба включати:

1. Оригінальне завдання
2. Що саме повернула модель
3. Чому це не відповідає схемі
4. Що очікується замість цього

**Типова помилка:** retry без пояснення помилки — модель повторює те саме.

## Few-Shot Patterns

Few-shot приклади допомагають коли:

- Формат виводу нетривіальний
- Є edge cases які потрібно явно показати
- Завдання має неочевидну семантику

Структура few-shot:

```text
<examples>
<example>
<input>Клієнт написав: "не працює кнопка"</input>
<output>{"category": "bug", "priority": "medium", "component": "ui"}</output>
</example>
<example>
<input>Клієнт написав: "додайте темну тему"</input>
<output>{"category": "feature", "priority": "low", "component": "ui"}</output>
</example>
</examples>
```

## Production Failure Patterns

### 1. Vague confidence instructions → false positives

"Відповідай тільки якщо впевнений" — модель завжди вважає себе впевненою.

**Виправлення:** замість subjective confidence — конкретний критерій: "якщо в тексті немає явної дати — поверни `null` у полі `date`".

### 2. Schema без enum для обмежених значень

Поле `status` як `string` замість `enum: ["open", "closed", "pending"]` — модель вигадує власні значення.

**Виправлення:** завжди використовувати `enum` для полів з обмеженим набором значень.

### 3. Few-shot без негативного прикладу

Тільки позитивні приклади — модель не знає що є неприйнятним.

**Виправлення:** додати хоча б один приклад з edge case або граничним значенням.

## Пов'язані нотатки Claude API

- [Prompt Caching API](../claude_api/prompt_caching_api.md) — cache\_control breakpoint, TTL, pricing, приклад pipeline
