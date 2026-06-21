[⬅️](qa_index.md)

## 📝 TL;DR

Якщо субагент постійно звертається до координатора за простими lookup операціями — дай йому власний scoped інструмент для цих операцій. 85% верифікацій = прості lookups → scoped `verify_fact` у субагента, складні → через координатор. Зменшує latency на 40%.

## Original

**Scenario:** A synthesis agent frequently returns control to the coordinator for simple fact verification, adding 2-3 round trips per task and 40% latency. Analysis shows 85% of verifications are simple lookups.

**Question:** What is the most effective solution?

**A)** Cache all verification results at the coordinator level so repeated lookups are instant

**B)** Remove fact verification from the synthesis workflow to eliminate the latency entirely

**C)** Give the synthesis agent a scoped `verify_fact` tool for simple lookups, routing only complex verifications through the coordinator

**D)** Increase the coordinator's parallelism so it can process verification requests faster

## Питання

Агент синтезу часто повертає контроль до координатора для простої верифікації фактів, додаючи 2-3 round trips на задачу і 40% latency. Аналіз показує що 85% верифікацій — прості lookups. Яке найефективніше рішення?

**A)** Кешувати всі результати верифікації на рівні координатора щоб повторні lookups були миттєвими

**B)** Прибрати верифікацію фактів з workflow синтезу щоб усунути latency повністю

**C)** Дати агенту синтезу scoped інструмент `verify_fact` для простих lookups, маршрутизуючи лише складні верифікації через координатор

**D)** Збільшити паралелізм координатора щоб він міг обробляти запити на верифікацію швидше

## Правильна відповідь: C

## Аналіз варіантів

### C — Правильний

85% верифікацій — прості lookups які субагент може виконати самостійно з власним scoped інструментом. Round trip до координатора потрібен лише для складних 15%. Результат: 85% × (2-3 round trips) = усунення більшої частини overhead.

### A — Хибний

Кешування допомагає при повторних запитах до тих самих фактів. Але якщо факти унікальні для кожної задачі (що типово), кеш не дасть виграшу. Крім того, round trips до координатора за кешованими результатами все одно залишаються.

### B — Хибний

Прибрати верифікацію = прибрати точність. Якщо верифікація потрібна для якості виводу синтезу — це не варіант. Задача оптимізувати latency, не жертвувати якістю.

### D — Хибний

Швидший координатор зменшує тривалість кожного round trip, але не зменшує їх кількість. 2-3 round trips на задачу залишаться — лише кожен буде швидшим.

## Ключові концепції

### Scoped tools для субагентів

Замість того щоб субагент звертався до координатора за кожною операцією — надай йому мінімальний набір інструментів для автономної роботи в межах його завдання.

```text
БЕЗ scoped tool:
  synthesis_agent → coordinator → fact_db → coordinator → synthesis_agent
  (2-3 round trips)

З scoped verify_fact:
  synthesis_agent → fact_db (напряму)
  (0 round trips для 85% верифікацій)
```

### Принцип мінімально необхідного scope

Давати субагенту інструменти обережно:

- Scoped інструменти для операцій в межах його завдання
- Складніші операції → через координатор (де є контроль і аудит)
- Не давати субагенту більше доступу ніж потрібно

### Класифікуй перед делегуванням

Це черговий приклад патерну "класифікуй перед дією": класифікуй верифікацію як просту/складну → прості вирішуй локально, складні делегуй.

## Пов'язані нотатки

- [Hub-and-spoke оркестрація](d1_hub_spoke_orchestration.md) — комунікація субагент ↔ координатор
- [Архітектура субагентів](../../Subagents_Architecture.md) — розподіл ролей
- [Domain 4: Tool Design & MCP](../domain_4_mcp_tools.md)
