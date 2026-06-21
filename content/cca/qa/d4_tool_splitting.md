[⬅️](qa_index.md)

## 📝 TL;DR

Розмитий інструмент з широкою назвою і описом змушує агента здогадуватись як його використовувати — і він використовує його неправильно. Рішення: розбити на purpose-specific інструменти з вузькими описами і чіткими input/output контрактами.

## Original

**Scenario:** A developer productivity platform has a tool called `analyze_content` with the description 'Analyses content from various sources.' Logs show the agent uses it for web scraping, document parsing, and code analysis indiscriminately, leading to poor results for each use case.

**Question:** What is the most effective fix?

**A)** Improve the tool description to list all supported content types and their expected formats

**B)** Add detailed few-shot examples to the system prompt showing which types of content the tool handles well and which it does not

**C)** Implement a routing layer that inspects the input content type and dispatches to the appropriate internal processing function within `analyze_content`

**D)** Split `analyze_content` into purpose-specific tools — `extract_web_results`, `parse_document`, and `analyze_code` — each with a narrow description and defined input/output contracts

## Питання

Платформа продуктивності розробника має інструмент `analyze_content` з описом "Analyses content from various sources." Логи показують що агент використовує його для web scraping, парсингу документів і аналізу коду без розбору — з поганими результатами для кожного з випадків. Яке найефективніше виправлення?

**A)** Покращити опис інструменту перелічивши всі підтримувані типи контенту

**B)** Додати детальні few-shot приклади в system prompt

**C)** Реалізувати routing layer всередині `analyze_content` для диспетчеризації до відповідних функцій

**D)** Розбити `analyze_content` на purpose-specific інструменти: `extract_web_results`, `parse_document`, `analyze_code` — кожен з вузьким описом і визначеними input/output контрактами

## Правильна відповідь: D

## Аналіз варіантів

### D — Правильний

Три окремих інструменти вирішують проблему в корені: агент бачить чіткі назви і вузькі описи — вибір очевидний без здогадок. Кожен інструмент оптимізований для свого типу контенту. Вузький input/output контракт → агент формулює правильні параметри.

### A — Хибний

Довший опис `analyze_content` покращить розуміння але не вирішить проблему: один інструмент все ще намагається робити три різних речі. Агент все одно буде вибирати між режимами через єдину точку входу.

### B — Хибний

Few-shot приклади навчають модель "коли що використовувати" але залишають модельну дискрецію. Інструмент все ще один — помилки у граничних випадках залишаються можливими.

### C — Хибний

Internal routing layer вирішує проблему на рівні коду (правильна функція виконається), але не допомагає агенту: він все ще бачить один розмитий `analyze_content` і може передавати неправильні параметри або використовувати його недоречно.

## Ключові концепції

### Single responsibility для інструментів

```text
ПОГАНО: analyze_content(source, type="web|doc|code")
  → агент повинен знати коли який type вибрати

ДОБРЕ:
  extract_web_results(url) → web content
  parse_document(file_path) → structured data
  analyze_code(file_path, language) → code issues
```

Назва інструменту + опис повинні однозначно сказати агенту: "для цієї задачі використовуй мене".

### Вузький опис vs широкий

| Тип опису | Результат |
| --- | --- |
| Широкий ("analyses various content") | Агент здогадується про застосування |
| Вузький ("parses PDF and DOCX into structured text") | Агент точно знає коли використовувати |

### Зв'язок з tool description (Q2)

Обидва питання тестують одну ідею: tool design визначає якість агентських рішень. Q2 — проблема в недостатньому описі одного інструменту. Q18 — проблема в тому що один інструмент робить надто багато.

## Пов'язані нотатки

- [Tool Use API](../../claude_api/tool_use_api.md) — як description впливає на вибір інструменту моделлю
- [Tool description та SQL діалект](d4_tool_description_dialect.md) — якість опису визначає якість використання
- [Structured output через tool schema](d4_structured_output_tool_schema.md) — input schema як контракт
- [Domain 4: Tool Design & MCP](../domain_4_mcp_tools.md)
