[⬅️](../../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Теорія Claude API для CCA-F іспиту. Покриває три механіки що найчастіше тестуються в доменах 3 і 4: tool use (agentic loop), prompt caching (cost optimization) та Batch API (async processing).

---

## 🏗️ Нотатки

### 🌐 Основи

*Що таке Claude API і для чого воно потрібне.*

- [🌐 Огляд Claude API](claude_api_overview.md) — що це, для чого, API vs Claude Code CLI, базова структура запиту, аутентифікація.
- [☕ Java SDK](java_sdk.md) — встановлення, builder pattern, sync/async, streaming, tool use через анотації, pagination, error handling.

### ⚙️ Tool Use

*Як модель викликає зовнішні функції через messages API.*

- [⚙️ Tool Use API](tool_use_api.md) — `tools[]` у запиті, `tool_use` block (id/name/input), `tool_result`, `tool_choice` (auto/any/tool), parallel calls, повний agentic loop.

### 💰 Prompt Caching

*Кешування статичного префікса для зниження вартості повторних запитів.*

- [💰 Prompt Caching API](prompt_caching_api.md) — `cache_control` breakpoint, що кешується, TTL 5 хв, cache hit ~10% ціни, де ставити breakpoints, приклад pipeline 500 запитів/год.

### 📦 Batch Processing

*Асинхронна обробка тисяч запитів зі знижкою 50%.*

- [📦 Batch Messages API](batch_api.md) — lifecycle (processing → ended → results), `custom_id`, JSONL результати, ліміти 10k/32MB, термін зберігання 29 днів, коли не підходить.

---

## Пов'язані нотатки vault

- [🛠️ Скіли, плагіни та MCP](../Skills_and_MCP.md) — реєстрація MCP серверів через `.mcp.json`
- [🔌 Розробка власного MCP-сервера](../MCP_Server_Development.md) — TypeScript SDK, scopes
- [💰 Вибір моделі та оптимізація вартості](../Model_Selection_and_Cost.md) — pricing стратегії
