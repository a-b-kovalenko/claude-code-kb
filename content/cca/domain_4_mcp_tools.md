[⬅️](CCA_Foundations.md)

## 📝 TL;DR

Домен (18%): дизайн інструментів та інтеграція MCP. Найчастіше недооцінений домен — опис інструменту важливіший за його реалізацію. Модель обирає інструмент за описом, не за кодом.

## MCP Primitives

Model Context Protocol надає три типи примітивів:

| Primitive | Що це | Приклад |
| --- | --- | --- |
| **Tools** | Дії, що виконує модель | `create_ticket`, `run_query` |
| **Resources** | Дані доступні для читання | `file://`, `db://table` |
| **Prompts** | Готові шаблони промптів | `code-review-template` |

**Правило:** tools — для дій зі сайд-ефектами, resources — для read-only даних, prompts — для повторюваних шаблонів.

## Tool Description Design

Опис інструменту — це те, що модель читає щоб вирішити чи використовувати цей інструмент.

### Поганий опис

```json
{
  "name": "process_data",
  "description": "Processes data"
}
```

### Хороший опис

```json
{
  "name": "process_data",
  "description": "Transforms raw CSV rows into normalized records. Use when you have unstructured tabular input that needs validation and deduplication before storage. Returns {processed: number, skipped: number, errors: string[]}."
}
```

**Хороший опис містить:**

- Що саме робить інструмент (не загально)
- Коли його використовувати (use case)
- Що повертає (output format)

**Типова помилка:** vague description → модель обирає не той інструмент або не обирає взагалі.

## MCP Server Configuration

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["./server.js"],
      "env": { "API_KEY": "${MY_API_KEY}" }
    }
  }
}
```

Скоупи конфігурації:

- **project** (`.mcp.json`) — специфічні для проєкту, в репо
- **local** (`.claude/mcp.json`) — локальні, не в репо (секрети)
- **user** (`~/.claude/mcp.json`) — особисті інструменти розробника

## Batch vs. Synchronous Execution

| | Synchronous | Batch |
| --- | --- | --- |
| Коли | Результат потрібен відразу | Незалежні операції |
| Порядок | Гарантований | Не гарантований |
| Latency | Вище (послідовно) | Нижче (паралельно) |
| Типовий use case | Залежні кроки | Масова обробка |

**Правило:** якщо N інструментів не залежать один від одного — batch. Якщо результат першого потрібен для другого — sync.

## Production Failure Patterns

### 1. Vague tool descriptions causing misrouting

Модель викликає `search_documents` замість `search_code` тому що обидва описані як "шукає контент".

**Виправлення:** в описі явно вказувати тип даних і обмеження: "searches only source code files (`.java`, `.ts`), not documentation".

### 2. Tool без опису output format

Модель не знає що робити з результатом — починає його інтерпретувати довільно.

**Виправлення:** у description або в окремому полі `returns` завжди описувати структуру відповіді.

### 3. Secrets у project-scope config

API ключі у `.mcp.json` (який потрапляє в репо).

**Виправлення:** секрети — тільки у local-scope або через env variables з `.env` (gitignored).
