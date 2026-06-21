[⬅️](qa_index.md)

## 📝 TL;DR

Для незворотних операцій (видалення акаунту) що потребують людського затвердження — PreToolUse hook перехоплює виклик інструменту ДО виконання і маршрутизує до черги затвердження. PostToolUse занадто пізно — дія вже сталась.

## Original

**Scenario:** A customer support agent handles account deletion requests. The company policy requires explicit human approval before any account is permanently deleted. Currently, the agent sometimes processes deletions autonomously when the customer is insistent.

**Question:** What approval mechanism should the architect implement?

**A)** Implement a PreToolUse hook on the delete_account tool that pauses execution and routes the request to a human approval queue before proceeding

**B)** Remove the delete_account tool from the agent entirely and require customers to call a separate phone line

**C)** Implement a PostToolUse hook that reviews the deletion after it has been processed and reverts it if no approval was recorded

**D)** Add a system prompt instruction: 'Always get manager approval before processing account deletions'

## Питання

Агент customer support обробляє запити на видалення акаунтів. Політика компанії вимагає явного людського затвердження перед будь-яким постійним видаленням. Наразі агент іноді обробляє видалення автономно, якщо клієнт наполягає. Який механізм затвердження повинен реалізувати архітектор?

**A)** Реалізувати PreToolUse hook на `delete_account`, що призупиняє виконання і маршрутизує запит до черги людського затвердження

**B)** Повністю прибрати інструмент `delete_account` і вимагати від клієнтів телефонувати на окрему лінію

**C)** Реалізувати PostToolUse hook, що переглядає видалення після виконання і відкочує якщо не було зафіксовано затвердження

**D)** Додати в system prompt інструкцію: "Завжди отримуй затвердження менеджера перед видаленням акаунтів"

## Правильна відповідь: A

## Аналіз варіантів

### A — Правильний

PreToolUse hook виконується до виклику інструменту. Він може: (1) зупинити виконання, (2) поставити запит у чергу, (3) заблокувати доти поки не прийде затвердження. Видалення акаунту — незворотна дія, тому перехоплення до виконання є єдиним правильним моментом.

### B — Хибний

Видалення функціональності — over-engineering. Задача не в тому, щоб унеможливити видалення, а в тому щоб додати обов'язкове затвердження перед ним.

### C — Хибний

PostToolUse виконується після видалення. "Відкотити якщо не було затвердження" — ненадійно: видалення могло бути частково незворотним, відкат може провалитись, у вікні між видаленням і відкатом виникає нестабільний стан.

### D — Хибний

System prompt instruction — модельна дискреція. Сценарій прямо показує: "агент іноді обробляє автономно коли клієнт наполягає" — тобто інструкція вже не допомагає під тиском.

## Ключові концепції

### PreToolUse vs PostToolUse для критичних дій

| Hook | Момент виконання | Може запобігти дії? |
| --- | --- | --- |
| PreToolUse | До виклику інструменту | Так |
| PostToolUse | Після виклику інструменту | Ні (тільки реагувати) |

### Human-in-the-loop через PreToolUse

```text
[Агент викликає delete_account]
     ↓
[PreToolUse hook]
  → Ставить запит у чергу затвердження
  → Повертає "pending_approval" агенту
  → Виконання заблоковано
     ↓
[Human approves]
     ↓
[delete_account виконується]
```

### Відмінність від d1_deterministic_guardrails і d1_prerequisite_gate

- d1_deterministic_guardrails: автоматичне рішення на основі threshold ($500)
- d1_prerequisite_gate: workflow ordering (крок A перед кроком B)
- d1_pretooluse_human_approval: **людина** приймає рішення, код лише гарантує що без неї не відбудеться

## Пов'язані нотатки

- [Детерміновані guardrails](d1_deterministic_guardrails.md) — автоматичне enforcement через хуки
- [Prerequisite gate](d1_prerequisite_gate.md) — блокування до верифікації
- [Domain 1: Agentic AI](../domain_1_agentic.md)
