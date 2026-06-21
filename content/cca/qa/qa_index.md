[⬅️](../CCA_Foundations.md)

## 📝 TL;DR

Розбір реальних питань іспиту CCA-F: кожна нотатка — одне питання з аналізом усіх варіантів, правильною відповіддю і посиланнями на теоретичні нотатки доменів.

## Оцінка якості питань

Питання тестують принципи і практичне мислення, а не зубріння. Дистрактори plausible — промахуються по одному ключовому пункту, що є ознакою якісного дизайну.

**Найсильніше питання** — [Детерміновані guardrails](d1_deterministic_guardrails.md): формулювання "cannot be left to model discretion" елегантно сигналізує правильну відповідь тим хто розуміє різницю між instruction і enforcement.

**Де можна посперечатись:**

- [Few-shot для послідовної екстракції](d3_few_shot_extraction_consistency.md) — temperature=0 теж впливає на послідовність, варіант C не настільки очевидно хибний.
- [MCP error handling](d4_mcp_error_handling.md) — вимагає знання специфіки протоколу більше ніж reasoning; ближче до "зубріння".

## Питання за доменами

### Domain 1 · Agentic AI (22%)

| Нотатка | Тема |
| --- | --- |
| [Наступний крок в agentic loop](d1_agentic_loop_next_tool.md) | Як модель вирішує який інструмент викликати далі |
| [Детерміновані guardrails](d1_deterministic_guardrails.md) | Compliance-правила через хуки, а не промпти |

### Domain 3 · Prompt Engineering (20%)

| Нотатка | Тема |
| --- | --- |
| [Стратегія batch processing](d4_batch_api_strategy.md) | Batch API vs real-time: cost-efficiency при дедлайні |
| [Few-shot для послідовної екстракції](d3_few_shot_extraction_consistency.md) | Непослідовне поле — few-shot, не зміна моделі |

### Domain 5 · Context & Memory (15%)

| Нотатка | Тема |
| --- | --- |
| [Гібридне управління контекстом](d5_context_management_hybrid.md) | Різні стратегії для різних типів інформації при скороченні токенів |
| [Prompt versioning для multi-session](d5_prompt_versioning_sessions.md) | Оновлення промпту не ламає активні розмови — тільки нові |

### Domain 4 · Tool Design & MCP (18%)

| Нотатка | Тема |
| --- | --- |
| [Стратегія batch processing](d4_batch_api_strategy.md) | Batch API vs real-time: cost-efficiency при дедлайні |
| [Hybrid routing: Batch vs real-time](d4_batch_vs_realtime_routing.md) | Маршрутизація за latency-вимогами для різних типів документів |
| [Structured output через tool schema](d4_structured_output_tool_schema.md) | Tool use як надійний механізм екстракції структурованих даних |
| [Дизайн помилок інструментів](d4_tool_error_design.md) | Structured errors з `retriable` усувають марні retries агента |
| [MCP error handling](d4_mcp_error_handling.md) | Protocol errors vs tool result `isError: true` — два рівні помилок |
