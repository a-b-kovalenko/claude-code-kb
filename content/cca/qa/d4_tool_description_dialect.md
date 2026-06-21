[⬅️](qa_index.md)

## 📝 TL;DR

Tool description — основне джерело знань агента про те як правильно використовувати інструмент. Якщо агент надсилає неправильний SQL діалект — рішення в розширенні опису: вказати діалект, навести приклади підтримуваних функцій, зазначити відмінності від PostgreSQL.

## Original

**Scenario:** The data platform's `query_snowflake` tool has a description that reads: 'Queries Snowflake data warehouse. Accepts SQL.' The agent correctly uses the tool but frequently sends queries using PostgreSQL-specific syntax (e.g. ILIKE, string_agg) that Snowflake rejects.

**Question:** What is the most effective fix?

**A)** Have the MCP server automatically translate PostgreSQL syntax to Snowflake syntax before executing the query

**B)** Expand the tool description to specify that the tool accepts Snowflake SQL dialect, include examples of supported functions (e.g. LISTAGG instead of string_agg, ILIKE is supported), and note dialect differences from PostgreSQL

**C)** Add a SQL syntax validation layer in front of the MCP tool that rejects non-Snowflake syntax before execution

**D)** Add a system prompt instruction listing all Snowflake-specific SQL functions the agent should use

## Питання

Інструмент `query_snowflake` платформи даних має опис: "Queries Snowflake data warehouse. Accepts SQL." Агент коректно використовує інструмент але часто надсилає запити з PostgreSQL-специфічним синтаксисом (ILIKE, string_agg) який Snowflake відхиляє. Яке найефективніше виправлення?

**A)** MCP сервер автоматично транслює PostgreSQL синтаксис у Snowflake перед виконанням

**B)** Розширити опис інструменту: вказати що приймається Snowflake SQL діалект, навести приклади підтримуваних функцій (LISTAGG замість string_agg, ILIKE підтримується), зазначити відмінності від PostgreSQL

**C)** Додати шар валідації SQL синтаксису перед MCP інструментом, що відхиляє не-Snowflake синтаксис

**D)** Додати в system prompt інструкцію зі списком Snowflake-специфічних SQL функцій

## Правильна відповідь: B

## Аналіз варіантів

### B — Правильний

Tool description — це специфікація інструменту для моделі. Агент читає опис щоразу перед використанням. Розширений опис з діалектом і прикладами функцій вирішує проблему в джерелі: агент генерує правильний синтаксис одразу, а не виправляє після відхилення.

### A — Хибний

Авто-трансляція PostgreSQL→Snowflake — складне рішення з власними помилками. Деякий PostgreSQL синтаксис немає еквіваленту в Snowflake. Правильніше вчити агента генерувати правильний SQL одразу.

### C — Хибний

Валідаційний шар відхиляє неправильний синтаксис але не навчає агента що правильно. Результат: цикл "відправив → відхилено → retry" замість генерації правильного SQL з першого разу.

### D — Хибний

System prompt дає загальні інструкції для всієї сесії. Tool description — контекстна специфікація безпосередньо для цього інструменту. Інструкція в tool description більш доречна і ефективна ніж глобальна в system prompt.

## Ключові концепції

### Tool description як специфікація

Опис інструменту — не просто документація для людини. Це пряма специфікація для моделі:

- Що робить інструмент
- Які вхідні дані очікуються (формат, діалект, обмеження)
- Типові помилки і як їх уникнути

### Шаблон ефективного опису для SQL інструменту

```text
Queries Snowflake data warehouse using Snowflake SQL dialect.
IMPORTANT: Use Snowflake-specific syntax, not PostgreSQL:
- Use LISTAGG() instead of string_agg()
- Use ILIKE for case-insensitive matching (supported)
- Use QUALIFY instead of subqueries for window function filtering
Accepts: valid Snowflake SQL SELECT statements
```

### Де розміщувати специфіку інструменту

| Місце | Коли підходить |
| --- | --- |
| Tool description | Специфіка цього конкретного інструменту |
| System prompt | Загальні правила для всіх інструментів |
| Input schema | Структурні обмеження на параметри |

## Пов'язані нотатки

- [Structured output через tool schema](d4_structured_output_tool_schema.md) — input schema як специфікація
- [Domain 4: Tool Design & MCP](../domain_4_mcp_tools.md)
