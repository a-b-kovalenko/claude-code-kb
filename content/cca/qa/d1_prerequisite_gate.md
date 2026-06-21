[⬅️](qa_index.md)

## 📝 TL;DR

Якщо агент систематично пропускає обов'язковий крок (8% випадків) — інструкції і few-shot не виправлять це. Потрібен programmatic prerequisite gate: наступний інструмент фізично заблокований поки попередній не повернув підтвердження.

## Original

**Scenario:** Production data shows that in 8% of cases, a customer support agent processes refunds without verifying account ownership, occasionally leading to refunds on wrong accounts.

**Question:** What is the most appropriate fix?

**A)** Implement a programmatic prerequisite gate that blocks process_refund until get_customer has returned a verified customer ID

**B)** Add few-shot examples showing the correct verification-then-refund workflow

**C)** Add stronger instructions to the system prompt emphasising the importance of verification before refunds

**D)** Implement a routing classifier that sends refund requests to a specialised verification pipeline

## Питання

Дані показують: у 8% випадків агент customer support обробляє відшкодування без верифікації власника акаунту — іноді кошти повертають на неправильні акаунти. Який найбільш доречний виправлення?

**A)** Реалізувати programmatic prerequisite gate, який блокує `process_refund` поки `get_customer` не повернув верифікований customer ID

**B)** Додати few-shot приклади правильного workflow "верифікація → відшкодування"

**C)** Додати сильніші інструкції у system prompt про важливість верифікації

**D)** Реалізувати routing classifier, що надсилає запити відшкодувань до спеціалізованого пайплайну верифікації

## Правильна відповідь: A

## Аналіз варіантів

### A — Правильний

Prerequisite gate — детерміноване enforcement на рівні коду: `process_refund` недоступний або повертає помилку якщо `get_customer` ще не виконано з валідним результатом. 8% failure rate означає модель вже знає правило але іноді його ігнорує — саме тому модельна дискреція є проблемою.

### B — Хибний

Few-shot показують "як правильно" але не примушують. Модель, яка вже порушує правило у 8% випадків, не стане надійнішою від прикладів — залишається модельна дискреція.

### C — Хибний

Аналогічно B: "сильніша інструкція" — той самий тип рішення (модельна дискреція). Якщо наявна інструкція вже не дає 100%, "ще сильніша" теж не гарантує.

### D — Хибний

Routing classifier додає складності, але не вирішує: агент може обійти класифікатор або класифікатор може помилитися. Крім того, мета — не маршрутизація, а порядок виконання.

## Ключові концепції

### Prerequisite gate vs model instruction

| Підхід | Механізм | Надійність |
| --- | --- | --- |
| System prompt instruction | Модельна дискреція | Не 100% |
| Few-shot examples | Модельна дискреція | Не 100% |
| Prerequisite gate (код) | Детермінований | 100% |

### Реалізація

Gate реалізується як:

- Перевірка стану в orchestrator перед викликом `process_refund`
- Tool wrapper, що відхиляє виклик якщо немає `verified_customer_id` у контексті
- PreToolUse hook, що перевіряє наявність попередньо верифікованих даних

### Відмінність від d1_deterministic_guardrails

d1_deterministic_guardrails — про compliance threshold ($500 → ескалація). Тут — про **workflow ordering**: обов'язкову послідовність кроків незалежно від значень.

## Пов'язані нотатки

- [Детерміновані guardrails](d1_deterministic_guardrails.md) — compliance-правила через хуки
- [PreToolUse hook для людського затвердження](d1_pretooluse_human_approval.md) — hook як gate перед критичною дією
- [Domain 1: Agentic AI](../domain_1_agentic.md)
