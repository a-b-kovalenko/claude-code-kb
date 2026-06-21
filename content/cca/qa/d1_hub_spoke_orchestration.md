[⬅️](qa_index.md)

## 📝 TL;DR

Hub-and-spoke — патерн оркестрації де всі комунікації йдуть через центральний координатор (hub), субагенти (spokes) ніколи не спілкуються між собою напряму. Це забезпечує централізований контроль та аудит.

## Original

**Question:** In a hub-and-spoke orchestration pattern, how does inter-agent communication flow?

**A)** All communication flows through the coordinator — subagents never communicate directly with each other

**B)** Subagents share a common message bus that all agents read from and write to

**C)** Each subagent communicates directly with every other subagent as needed

**D)** Subagents pass results to the next agent in a predefined sequence, forming a chain

## Питання

В патерні оркестрації hub-and-spoke як відбувається міжагентна комунікація?

**A)** Вся комунікація йде через координатор — субагенти ніколи не спілкуються між собою напряму

**B)** Субагенти поділяють спільну message bus, з якої всі агенти читають і в яку пишуть

**C)** Кожен субагент спілкується напряму з кожним іншим субагентом за потреби

**D)** Субагенти передають результати наступному агенту у визначеній послідовності, утворюючи ланцюг

## Правильна відповідь: A

## Аналіз варіантів

### A — Правильний

Hub-and-spoke за визначенням: hub (координатор) — центральний вузол, spokes (субагенти) — периферійні вузли. Комунікація завжди hub ↔ spoke, ніколи spoke ↔ spoke. Це і є суть патерну.

### B — Хибний

Message bus — окремий патерн (publish-subscribe / event-driven). Спільна шина дозволяє будь-якому агенту читати повідомлення будь-якого іншого — протилежність hub-and-spoke.

### C — Хибний

Прямі зв'язки між усіма агентами — це **mesh** патерн. У великих системах стає некерованим: O(n²) з'єднань, складна координація.

### D — Хибний

Передача результатів по ланцюгу — це **pipeline** (sequential chain) патерн. Відрізняється від hub-and-spoke: у pipeline немає центрального координатора, є лінійна послідовність.

## Ключові концепції

### Три патерни оркестрації

| Патерн | Комунікація | Коли застосовувати |
| --- | --- | --- |
| Hub-and-spoke | Всі через coordinator | Потрібен централізований контроль |
| Pipeline (chain) | A→B→C→D | Задачі залежать одна від одної по черзі |
| Mesh | Всі з усіма | Незалежні агенти з динамічними зв'язками |

### Переваги hub-and-spoke

- Координатор бачить повну картину стану
- Легко логувати та аудитувати всі дії
- Координатор вирішує які субагенти запустити і коли
- Субагенти ізольовані один від одного — менше coupling

### Hub-and-spoke у Claude Code

Реалізується через Agent tool: оркестратор (coordinator) запускає субагентів через `Agent(...)`, отримує результати, вирішує наступний крок. Субагенти не знають один про одного.

## Пов'язані нотатки

- [Domain 1: Agentic AI](../domain_1_agentic.md) — архітектурні патерни оркестрації
- [Архітектура субагентів](../../Subagents_Architecture.md) — Explorer, Runner, Reviewer ролі
