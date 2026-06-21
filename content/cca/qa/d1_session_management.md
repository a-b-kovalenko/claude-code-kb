[⬅️](qa_index.md)

## 📝 TL;DR

Коли агент зайшов у глухий кут після кількох невдалих спроб, правильна стратегія — нова сесія з summary injection: чиста стартова точка + знання про те, що вже не спрацювало. Повністю нова сесія без контексту змушує переоткривати помилки з нуля.

## Original

**Scenario:** A CI/CD agent has spent 30 minutes debugging a failing test suite, trying three different approaches that each modified configuration files. None worked, and its context now holds three sets of conflicting modifications and failed outputs. The developer wants to try a completely different strategy.

**Question:** What session management approach should they use?

**A)** Continue in the current session and ask the agent to ignore all previous attempts and start fresh

**B)** Start a fresh session with a summary injection that lists the three failed approaches and why each failed, then pursue the new strategy with clean context

**C)** Start a completely new session with no context, re-read the failing tests, and apply the new strategy

**D)** Use fork_session from the point before the first debugging attempt to explore the new strategy

## Питання

Агент CI/CD витратив 30 хвилин на налагодження набору тестів, випробовуючи три різних підходи, кожен з яких змінював конфігураційні файли. Жоден не спрацював. Контекст тепер містить три набори конфліктуючих змін і невдалих виводів. Розробник хоче спробувати принципово інший підхід. Яку стратегію управління сесією використати?

**A)** Продовжити в поточній сесії і попросити агента ігнорувати попередні спроби

**B)** Розпочати нову сесію з summary injection — список трьох невдалих підходів і причини провалу — і потім реалізувати нову стратегію з чистим контекстом

**C)** Розпочати нову сесію без жодного контексту, перечитати тести, застосувати нову стратегію

**D)** Використати fork_session з точки до першої спроби налагодження для дослідження нової стратегії

## Правильна відповідь: B

## Аналіз варіантів

### B — Правильний

Summary injection вирішує обидві проблеми: (1) чистий контекст без трьох наборів конфліктуючих змін, (2) збережене знання "що вже пробували і чому не спрацювало". Агент не витрачатиме час на повторення тих самих помилок.

### A — Хибний

"Ігноруй попередні спроби" — ненадійна інструкція: три набори конфліктуючих модифікацій фізично присутні в контексті і впливають на генерацію відповідей. Модель не може справді "забути" контекст.

### C — Хибний

Повністю нова сесія без контексту — агент не знатиме що вже пробували. Доведеться заново відкривати ті самі помилки, витрачаючи час на підходи які вже довели свою неефективність.

### D — Хибний

fork_session — концептуально правильна ідея (повернутися до чистої точки), але на практиці повертає агента до стану до початку налагодження — він знову не знатиме що три підходи вже провалились.

## Ключові концепції

### Summary injection pattern

```text
[Нова сесія]
System: "Previous debugging session summary:
- Approach 1: Modified jest.config.ts — failed because X
- Approach 2: Changed tsconfig paths — failed because Y
- Approach 3: Updated package.json scripts — failed because Z
Now try approach: [new strategy]"
```

Summary injection — це ручне компактування попередньої сесії: ти берешь найважливіше з провального контексту і вставляєш як структуровану передісторію.

### Коли використовувати яку стратегію

| Ситуація | Стратегія |
| --- | --- |
| Контекст забруднений, але є корисне знання | Fresh session + summary injection |
| Контекст чистий, але задача змінилась | /compact + нові інструкції |
| Агент в правильному напрямку | Продовжити сесію |
| Нова незалежна задача | Нова сесія без контексту |

## Пов'язані нотатки

- [Гібридне управління контекстом](d5_context_management_hybrid.md) — стратегії збереження інформації
- [Деградація контексту та /compact](d5_context_degradation.md) — коли контекст заважає
- [Domain 1: Agentic AI](../domain_1_agentic.md)
