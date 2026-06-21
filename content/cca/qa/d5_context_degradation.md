[⬅️](qa_index.md)

## 📝 TL;DR

Context degradation — зниження якості відповідей після тривалого дослідження великої кодової бази ("Lost in the Middle" ефект). Первинна мітигація: scratchpad файли для key findings поза контекстом + субагенти для ізоляції verbose дослідження.

## Original

**Scenario:** A documentation team working across a 500,000-line codebase notices that Claude Code's responses become less specific after extensive file exploration. What is the term for this degradation and what is the primary mitigation in Claude Code?

**A)** Token exhaustion — mitigated by increasing the model's max_tokens parameter

**B)** Hallucination drift — mitigated by lowering the temperature to zero for deterministic output

**C)** Prompt injection — mitigated by sanitising file contents before they enter the context window

**D)** Context degradation — mitigated by using scratchpad files to persist key findings outside the conversation context, and delegating exploration to subagents to isolate verbose output

## Питання

Команда документації помічає що відповіді Claude Code стають менш специфічними після тривалого дослідження файлів 500k-рядкової кодової бази. Як називається ця деградація і яка первинна мітигація?

**A)** Token exhaustion — збільшити параметр max_tokens моделі

**B)** Hallucination drift — знизити temperature до нуля для детермінованого виводу

**C)** Prompt injection — санітизувати вміст файлів до їх входу в контекстне вікно

**D)** Context degradation — scratchpad файли для збереження key findings поза розмовою + субагенти для ізоляції verbose дослідження

## Правильна відповідь: D

## Аналіз варіантів

### D — Правильний

Context degradation — коректний термін: контекст переповнений verbose exploration output → "Lost in the Middle" ефект → специфічність відповідей знижується. Scratchpad файли виносять key findings за межі розмови. Субагенти ізолюють verbose дослідження у власних контекстних вікнах.

### A — Хибний

Token exhaustion — інша проблема: контекст фізично закінчився, модель повертає помилку. max_tokens контролює довжину відповіді, не розмір контексту.

### B — Хибний

Hallucination drift — не стандартний термін у документації Claude Code. Temperature=0 впливає на варіативність, але не на якість при переповненому контексті.

### C — Хибний

Prompt injection — security проблема (зловмисний контент у файлах намагається змінити поведінку). Санітизація не допомагає при деградації від великого обсягу легітимного контенту.

## Ключові концепції

### Context degradation vs token exhaustion

| Проблема | Симптом | Рішення |
| --- | --- | --- |
| Context degradation | Знижується специфічність, модель "губиться" | Scratchpad + субагенти + /compact |
| Token exhaustion | Помилка "context limit exceeded" | Новий чистий контекст |

### Профілактична мітигація

```text
1. Scratchpad файли: після кожного блоку дослідження
   → записати key findings у .workspace/findings.md
   → контекст не переповнюється verbose output

2. Субагенти для дослідження:
   → Explorer субагент читає файли у своєму контексті
   → Повертає лише summary до основної розмови
```

## Пов'язані нотатки

- [Context degradation: /compact як втручання](d5_context_compact_intervention.md) — реактивна мітигація для деградованої сесії
- [Гібридне управління контекстом](d5_context_management_hybrid.md) — стратегії для різних типів даних
- [Контекстне вікно та /compact](../../Context_Window_Management.md) — Lost in the Middle, PreCompact хук
- [Domain 5: Context & Reliability](../domain_5_context.md)
