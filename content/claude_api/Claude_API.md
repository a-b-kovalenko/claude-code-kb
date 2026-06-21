[⬅️](../../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Теорія Claude API для CCA-F іспиту. Покриває три механіки що найчастіше тестуються в доменах 3 і 4: tool use (agentic loop), prompt caching (cost optimization) та Batch API (async processing).

## Нотатки

| Нотатка | Домен CCA-F | Тема |
| --- | --- | --- |
| [Tool Use API](tool_use_api.md) | Domain 4 | tools[], tool_use block, tool_result, tool_choice, parallel calls |
| [Prompt Caching API](prompt_caching_api.md) | Domain 3 | cache_control breakpoint, TTL, pricing, де ставити |
| [Batch Messages API](batch_api.md) | Domain 4 | lifecycle, custom_id, ліміти, 50% знижка, коли не підходить |

## Пов'язані нотатки vault

- [Скіли, плагіни та MCP](../Skills_and_MCP.md) — реєстрація MCP серверів через `.mcp.json`
- [Розробка власного MCP-сервера](../MCP_Server_Development.md) — TypeScript SDK, scopes
- [Вибір моделі та оптимізація вартості](../Model_Selection_and_Cost.md) — pricing стратегії

## Scope цього розділу

Тут лише концепти що виносяться на іспит CCA-F. Не охоплює:

- Auth та rate limits
- Vision / multimodal
- Streaming
- Model comparison
