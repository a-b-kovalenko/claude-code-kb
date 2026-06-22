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

### Обмеження tool_use

Tool use з JSON schema гарантує **синтаксичну** коректність — жодних unparseable JSON, жодних пропущених required полів. Але **семантичні** помилки залишаються:

- Модель вигадує суму яка відсутня в документі
- Значення розміщено у неправильне поле
- Дата взята з невірного контексту

**Захист від семантичних помилок** — на рівні schema design, не на рівні tool use механіки.

### Паттерни schema design для надійної екстракції

**Nullable поля замість required** — якщо дані можуть бути відсутні:

```json
{"payment_terms": {"type": ["string", "null"]}}
```

**"unclear" enum value** — для неоднозначних документів замість вигаданої класифікації:

```json
{"category": {"enum": ["invoice", "receipt", "contract", "unclear"]}}
```

Модель повертає `"unclear"` замість того щоб здогадуватись — детермінований сигнал для downstream обробки.

**"other" + detail string** — для граничних категорій:

```json
{
  "category": {"enum": ["invoice", "receipt", "other"]},
  "category_detail": {"type": ["string", "null"]}
}
```

Якщо `category = "other"` → `category_detail` містить пояснення.

**Format normalisation у промпті** — правила нормалізації поруч зі схемою, не окремо:

```text
Extract invoice data. Schema rules:
- dates: ISO 8601 (YYYY-MM-DD)
- amounts: numeric only, no currency symbols
- vendor_name: as written, no abbreviations
```

## Validation-Retry Loop

```text
Prompt → Response → Validate schema → OK? → Done
                          ↓ FAIL
                   Retry prompt з описом помилки
                          ↓ (max 3 спроби)
                   Escalate / fallback
```

Retry prompt мусить містити три компоненти:

1. **Оригінальний документ** — джерело для повторного аналізу
2. **Провалена екстракція** — що саме повернула модель
3. **Конкретна помилка валідації** — точне формулювання проблеми

Без третього компонента модель не знає що виправляти і повторює ту саму помилку.

### Межі ефективності retry

**Retry допомагає** (помилка в обробці наявних даних):

- Неправильний формат дати чи валюти
- Значення у неправильному полі
- Арифметична помилка (пропущені рядки впливають на суму)

**Retry не допомагає** (інформації немає в джерелі):

- Поле відсутнє в документі → треба `nullable`, не retry
- Дані у зовнішньому документі якого немає в контексті
- Інформація виходить за межі знань моделі

**Правило:** якщо дані відсутні в джерелі — retry лише витрачає токени. Таке поле має бути nullable або flagged для human review.

### Self-correction schema

Вбудована самоперевірка через додаткові поля:

```json
{
  "line_items_sum": 450.00,
  "stated_total": 500.00,
  "conflict_detected": true,
  "conflict_note": "Line items sum (450) differs from stated total (500)"
}
```

`conflict_detected: true` — детермінований сигнал для retry або human review, без потреби парсити текст відповіді.

## Явні категоричні критерії

Найпоширеніша помилка у production prompt engineering — розмиті модифікатори замість явних категорій дій.

### Порівняння

```text
ПОГАНО:
"Review this code. Be conservative. Only report high-confidence findings."

ДОБРЕ:
"Flag: comments that contradict actual code, bugs, security vulnerabilities.
Skip: style preferences, naming conventions, local patterns."
```

Модель не може операціоналізувати "be conservative" — кожен запуск інтерпретує по-різному. Явний список "flag / skip" дає однозначні межі.

**Правило:** замість суб'єктивного прикметника ("careful", "conservative", "thorough") — конкретну категорію дій.

### Ієрархія виправлень

1. Спочатку — явні критерії (що flag, що skip)
2. Потім — severity calibration через приклади коду
3. Наостанок — confidence threshold як додатковий фільтр

Confidence routing не замінює кроки 1–2. LLM-впевненість погано відкалібрована: модель може бути впевнено неправильною.

## Few-Shot Patterns

### Три тригери для few-shot

Few-shot потрібен коли:

1. **Непослідовне форматування** — детальні інструкції є, але модель виробляє різні структури між запусками
2. **Неоднозначні судження** — однотипні ситуації класифікуються по-різному (variable shadowing — "critical" в одному файлі, "minor" в іншому)
3. **Порожні поля при наявних даних** — інформація є, але у неочікуваному форматі (вбудована в наратив, розподілена між абзацами)

### Правила конструювання прикладів

Кількість: 2–4 прикладів. Менше 2 не встановлює патерну; більше 4 витрачає токени без пропорційної користі.

Приклади мають цілитись у **конкретні сценарії що реально падають**: якщо екстракція ламається на нарративному тексті — приклад з нарративом; якщо на вбудованих таблицях — приклад з таблицею. Довільні "хороші" приклади без зв'язку з реальними failures не усувають проблему.

Кожен приклад: input + output + reasoning:

```text
Input: "check my order #12345"
Selected tool: lookup_order
Reasoning: Конкретний номер замовлення вказує на точковий пошук.
Хоча це могло бути загальним запитом, ідентифікатор робить
lookup_order правильним вибором на відміну від get_customer.
```

Без reasoning модель вивчає поверхневий збіг. З reasoning — засвоює загальний принцип і застосовує до нових варіантів.

### Структура few-shot (базова)

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

### Few-shot vs інші техніки

| Проблема | Правильна техніка |
| --- | --- |
| Непослідовне форматування | Few-shot приклади |
| Неправильний JSON | Tool use зі схемою |
| Вигадані значення | Nullable поля схеми |
| Неправильний вибір інструменту | Спочатку кращий опис інструменту; few-shot — якщо проблема залишилась |
| Пропущені дані у нараративі | Few-shot з наративною екстракцією |
| Арифметична помилка в сумі | Validation-retry цикл |

## Production Failure Patterns

### 1. Vague confidence instructions → false positives

"Відповідай тільки якщо впевнений" — модель завжди вважає себе впевненою.

**Виправлення:** замість subjective confidence — конкретний критерій: "якщо в тексті немає явної дати — поверни `null` у полі `date`".

### 2. Schema без enum для обмежених значень

Поле `status` як `string` замість `enum: ["open", "closed", "pending"]` — модель вигадує власні значення.

**Виправлення:** завжди використовувати `enum` для полів з обмеженим набором значень.

### 4. False positives в одній категорії руйнують довіру до всіх

40% помилок у категорії "documentation mismatch" → розробники перестають довіряти навіть категоріям з 98% точністю.

**Стратегія відновлення:**

1. Тимчасово вимкнути проблемну категорію
2. Переписати критерії — замінити прозові описи на конкретні приклади
3. Повторно активувати після підтвердження точності

Тримати всі категорії активними під час ітерацій — помилка: шум продовжує руйнувати довіру.

### 5. Confidence threshold для виправлення непослідовних суджень

Непослідовні severity-оцінки або routing-рішення виникають через відсутність явних критеріїв — не через брак впевненості. Підняття порогу confidence не вирішить проблему: модель може бути впевнено непослідовною.

**Виправлення:** few-shot приклади з reasoning по граничних кейсах + явні категоричні критерії (flag / skip списки).

### 3. Few-shot без негативного прикладу

Тільки позитивні приклади — модель не знає що є неприйнятним.

**Виправлення:** додати хоча б один приклад з edge case або граничним значенням.

## Пов'язані нотатки Claude API

- [Prompt Caching API](../claude_api/prompt_caching_api.md) — cache\_control breakpoint, TTL, pricing, приклад pipeline
