[⬅️](qa_index.md)

## 📝 TL;DR

Для деградованої сесії найефективніше втручання — `/compact` з focus інструкціями: стискає розмову до структурованого резюме, зберігає поточний стан і відкидає застарілі деталі. Нова сесія — остання опція, бо втрачає двогодинний контекст налагодження.

## Original

**Scenario:** A developer has been using the data platform agent in a single extended session for two hours, running complex federated queries, debugging SQL syntax, and iterating on report formatting. The agent now produces noticeably worse SQL and occasionally references table schemas from earlier queries that have since been corrected. What is the most effective intervention?

**A)** Increase the model's temperature parameter to improve creativity and reduce fixation on stale patterns

**B)** Add a system prompt instruction telling the agent to ignore all schema information from more than 30 minutes ago

**C)** Start a completely new session and re-establish all context from scratch

**D)** Use the `/compact` command, optionally passing focus instructions, to summarise the conversation so far and free context budget for current-state reasoning

## Питання

Розробник використовує агента дата-платформи в одній сесії дві години: складні federated запити, налагодження SQL синтаксису, ітерації по форматуванню звітів. Агент тепер генерує помітно гірший SQL і іноді посилається на схеми таблиць з ранніх запитів що вже були виправлені. Яке найефективніше втручання?

**A)** Збільшити параметр temperature моделі щоб покращити креативність і зменшити зациклення на застарілих патернах

**B)** Додати інструкцію в system prompt що наказує агенту ігнорувати всю схемну інформацію старішу за 30 хвилин

**C)** Почати повністю нову сесію і відновити весь контекст з нуля

**D)** Використати команду `/compact` з focus інструкціями щоб стиснути розмову і звільнити контекстний бюджет для reasoning про поточний стан

## Правильна відповідь: D

## Аналіз варіантів

### D — Правильний

`/compact` стискає всю розмову до структурованого резюме, зберігаючи поточний стан і відкидаючи застарілі деталі. З focus інструкціями резюме акцентує на тому що важливо зараз. Двогодинний контекст налагодження зберігається у стислій формі.

### A — Хибний

Temperature впливає на варіативність відповідей, не на якість при переповненому контексті. Підвищення temperature може зробити SQL ще менш точним.

### B — Хибний

System prompt "ігнорувати схеми старші за 30 хвилин" — ненадійна інструкція. Застарілі схеми все одно фізично присутні у контексті. Модель не може надійно ігнорувати частину свого контексту за інструкцією.

### C — Хибний

Нова сесія означає втрату двох годин debugging context: всі виявлені патерни, виправлені помилки, поточний стан запитів. `/compact` вирішує проблему зберігаючи цінний контекст у стислій формі.

## Ключові концепції

### /compact з focus інструкціями

```bash
/compact "focus on: current table schemas, active query structure, report format requirements"
```

Focus інструкції гарантують що резюме збереже найважливіший поточний стан, а не просто перші пункти розмови. Без focus — компактуватиметься рівномірно, може втратити критичні деталі.

### Коли /compact vs нова сесія

| Ситуація | Рішення |
| --- | --- |
| Деградація але цінний debugging context | `/compact` з focus інструкціями |
| Завдання завершено, починається нове | Нова сесія |
| Контекст забруднений нерелевантними даними | Нова сесія + summary injection |

## Пов'язані нотатки

- [Context degradation: термін і мітигація](d5_context_degradation.md) — що таке context degradation і профілактика
- [Session management](d1_session_management.md) — коли нова сесія з summary injection
- [Контекстне вікно та /compact](../../Context_Window_Management.md) — Lost in the Middle, PreCompact хук
- [Domain 5: Context & Reliability](../domain_5_context.md)
