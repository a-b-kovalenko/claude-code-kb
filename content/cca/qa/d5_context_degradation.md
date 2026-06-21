[⬅️](qa_index.md)

## 📝 TL;DR

Context degradation — зниження якості відповідей після тривалого дослідження великої кодової бази. Первинна мітигація у Claude Code: scratchpad файли для key findings поза контекстом + субагенти для ізоляції verbose дослідження. Для активної деградації в сесії — `/compact` з focus інструкціями.

## Original

**Scenario A (Q11):** A documentation team working across a 500,000-line codebase notices that Claude Code's responses become less specific after extensive file exploration. What is the term for this degradation and what is the primary mitigation in Claude Code?

**A)** Token exhaustion — mitigated by increasing the model's max_tokens parameter

**B)** Hallucination drift — mitigated by lowering the temperature to zero for deterministic output

**C)** Prompt injection — mitigated by sanitising file contents before they enter the context window

**D)** Context degradation — mitigated by using scratchpad files to persist key findings outside the conversation context, and delegating exploration to subagents to isolate verbose output

---

**Scenario B (Q17):** A developer has been using the data platform agent in a single extended session for two hours, running complex federated queries, debugging SQL syntax, and iterating on report formatting. The agent now produces noticeably worse SQL and occasionally references table schemas from earlier queries that have since been corrected. What is the most effective intervention?

**A)** Increase the model's temperature parameter to improve creativity and reduce fixation on stale patterns

**B)** Add a system prompt instruction telling the agent to ignore all schema information from more than 30 minutes ago

**C)** Start a completely new session and re-establish all context from scratch

**D)** Use the `/compact` command, optionally passing focus instructions, to summarise the conversation so far and free context budget for current-state reasoning

## Питання

**Сценарій A:** Команда документації помічає що відповіді Claude Code стають менш специфічними після тривалого дослідження файлів 500k-рядкової кодової бази. Як називається ця деградація і яка первинна мітигація?

**D)** Context degradation — scratchpad файли + субагенти для ізоляції ✓

---

**Сценарій B:** Розробник використовує агента дві години. Агент тепер генерує гірший SQL і посилається на застарілі схеми. Яке найефективніше втручання?

**D)** Команда `/compact` з focus інструкціями — стискає розмову і звільняє контекстний бюджет ✓

## Правильна відповідь: D (обидва)

## Аналіз варіантів

### Q11 — чому D правильний

Context degradation — коректний термін: контекст переповнений verbose exploration output → "Lost in the Middle" ефект → специфічність відповідей знижується. Scratchpad файли виносять key findings за межі розмови. Субагенти ізолюють verbose дослідження у власних контекстних вікнах. Token exhaustion (A) — інша проблема (закінчились токени). Hallucination drift (B) — не стандартний термін. Prompt injection (C) — security проблема.

### Q17 — чому D правильний

`/compact` стискає всю розмову до структурованого резюме, зберігаючи поточний стан і відкидаючи застарілі деталі. З focus інструкціями ("focus on current table schemas") — особливо ефективний. Температура (A) не впливає на стале знання. System prompt "ігнорувати старі схеми" (B) — ненадійна інструкція, застарілі схеми все одно в контексті. Нова сесія (C) — втрата двох годин контексту налагодження.

## Ключові концепції

### Context degradation vs token exhaustion

| Проблема | Симптом | Рішення |
| --- | --- | --- |
| Context degradation | Знижується специфічність, модель "губиться" | Scratchpad + субагенти + /compact |
| Token exhaustion | Помилка "context limit exceeded" | Новий чистий контекст |

### Профілактична мітигація (великі кодові бази)

```text
1. Scratchpad файли: після кожного блоку дослідження
   → записати key findings у .workspace/findings.md
   → контекст не переповнюється verbose output

2. Субагенти для дослідження:
   → Explorer субагент читає файли у своєму контексті
   → Повертає лише summary до основної розмови
```

### Реактивна мітигація (деградована сесія)

```bash
/compact "focus on: current table schemas, active query, report structure"
```

Focus інструкції гарантують що резюме збереже найважливіший поточний стан, а не тільки перші пункти розмови.

## Пов'язані нотатки

- [Гібридне управління контекстом](d5_context_management_hybrid.md) — стратегії для різних типів даних
- [Контекстне вікно та /compact](../../Context_Window_Management.md) — Lost in the Middle, PreCompact хук
- [Session management](d1_session_management.md) — коли нова сесія з summary injection
- [Domain 5: Context & Reliability](../domain_5_context.md)
