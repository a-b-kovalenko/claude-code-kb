[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

"Золотий workflow" — повторювана схема сесії з п'яти фаз: Explore → Plan → Implement → Verify → Commit. Кожна фаза має чітку умову входу, конкретний інструмент або субагента та машинно-перевірюваний критерій завершення. Освоєння цієї послідовності усуває два найпоширеніші збої: дрейф контексту та коміти без перевірки.

## Яку проблему це вирішує

Два патерни стабільно завдають болю при роботі з Claude Code:

**Дрейф контексту (Context Drift)** — ви сказали "реалізуй фічу", агент зробив 20 правок в одній сесії, і в кінці ні ви, ні агент точно не пам'ятаєте, що і чому змінено. Перший коміт — монстр на 600 рядків, який неможливо ревʼювати.

**Пропуск верифікації (Verify-Skip)** — агент написав код, ви прийняли зміни, потім CI впав. Між кроками ніхто не запускав тести.

Золотий workflow — системна відповідь на обидва патерни.

## Сценарій (наскрізний приклад)

Усі п'ять фаз ілюструються однією конкретною задачею, знайомою кожному Java-розробнику:

```text
Task PROJ-412
Додати DLQ-обробник для Kafka-топіку `order.payment.failed`.
Після 3 послідовних збоїв: перемістити повідомлення в `order.dlq`,
емітувати доменну подію DlqRouted, записати інцидент у таблицю `dlq_incidents`.
```

Цей приклад охоплює Kafka consumer, доменну подію, Flyway-міграцію, сервісний шар та інтеграційні тести — типова крос-шарова зміна, де workflow окупається повністю.

## Огляд — 5 фаз

```text
┌────────────────────────────────────────────────────────────────┐
│                    GOLDEN WORKFLOW SESSION                     │
└────────────────────────────────────────────────────────────────┘

 ┌──────────┐  ┌──────────┐  ┌─────────────┐  ┌──────────┐  ┌────────┐
 │  ФАЗА 1  │─▶│  ФАЗА 2  │─▶│   ФАЗА 3    │─▶│  ФАЗА 4  │─▶│ ФАЗА 5 │
 │ EXPLORE  │  │   PLAN   │  │  IMPLEMENT  │  │  VERIFY  │  │ COMMIT │
 └──────────┘  └──────────┘  └─────────────┘  └──────────┘  └────────┘
 субагент       /plan +        основний          субагент      субагент
 explorer       think hard     агент +           test-runner   reviewer
 (read-only)    (write-lock)   Tasks API         (green або    + git commit
                               (по одному        діагноз)      на кожен крок
                                кроку)
```

| Фаза      | Інструмент / субагент     | Критерій завершення                             |
| :-------- | :------------------------ | :---------------------------------------------- |
| Explore   | субагент `explorer`       | Структурована карта: файли, потік даних, ризики |
| Plan      | Plan Mode + `think hard`  | Ви схвалюєте список задач                       |
| Implement | Tasks API, основний агент | Кожна задача має зелений тест                   |
| Verify    | субагент `test-runner`    | Увесь модуль зелений                            |
| Commit    | субагент `reviewer` + git | Вердикт APPROVE, чистий коміт на крок           |

## Фаза 0 — Підготовка

**Умова входу:** до відкриття сесії Claude Code.

Агент, що стартує на нестабільній базі, не може відрізнити свої регресії від вже існуючих проблем. Перед початком переконайтесь що `main` чистий і поточні тести зелені. Деталі: [Чеклист перед задачею](Pre_Task_Checklist.md).

## Фаза 1 — Explore

**Умова входу:** у вас є тікет, ви відкрили нову сесію Claude Code.

**Чому субагент?** [Explorer](Explorer_Subagent_Example.md) читає 30+ файлів у власному вікні контексту. Якщо робити це в основному треді — ви витратите половину контексту на сирі дані ще до початку планування.

Запит до explorer-а з конкретною метою, а не розмитим "подивися":

```text
Use the explorer subagent to map everything related to the `order.payment.failed`
Kafka topic: consumer class, handler, service layer, repository, DB tables.
Include Flyway migration history. Identify all files that will need changes
for a DLQ handler and flag any transactional boundaries.
```

Очікуваний output (скорочено):

```text
Files to change:
- PaymentFailedConsumer.java     — add retry counter + DLQ routing
- DlqIncidentRepository.java     — new file
- DlqRouted.java                 — new domain event (domain/ package)
- V12__dlq_incidents.sql         — new migration (last applied: V11__)

Data flow:
  Kafka → PaymentFailedConsumer → PaymentService.handleFailure() → OrderRepository

Risks:
- PaymentService is @Transactional — DLQ routing MUST happen outside this boundary
- V11__payments.sql was last migration — next must be V12__
```

Цей звіт стає основою для Фази 2.

Для великих проєктів запускайте кілька Explorer-субагентів паралельно: один досліджує сервісний шар, інший — persistence або інфраструктуру. Детальніше: [Паралельні субагенти](Parallel_Subagents.md).

Детальніше: [Архітектура субагентів](Subagents_Architecture.md), [Приклад субагента: Explorer](Explorer_Subagent_Example.md)

## Фаза 2 — Plan

**Умова входу:** звіт explorer-а є в контексті.

Відкрийте Plan Mode і використайте `think hard` для нетривіального архітектурного питання (транзакційна межа для DLQ):

```text
/plan

think hard: Based on the explorer report, design the implementation task list
for PROJ-412. Key constraint: DLQ routing must happen outside the PaymentService
transaction. Define a verify step for each task.
```

Агент генерує список задач. Саме тут ви бачите "що Claude зрозумів" — до того, як написано рядок коду:

```text
Task 1: Create V12__dlq_incidents.sql migration
  Verify: ./gradlew :payment-service:flywayMigrate runs without error

Task 2: Create DlqIncident entity + DlqIncidentRepository
  Verify: unit test — save and findByOrderId

Task 3: Create DlqRouted domain event (pure POJO, no Spring annotations)
  Verify: reviewer checks domain/ — no @Component, no @Service

Task 4: Add DLQ routing to PaymentFailedConsumer (outside @Transactional boundary)
  Verify: test-runner on PaymentFailedConsumerTest

Task 5: Integration test — 3 failures → DLQ message + DB record + event
  Verify: test-runner, full payment module green
```

Якщо список задач показує неправильне розміщення транзакції або пропущену міграцію — виправте це зараз, а не після 200 рядків коду.

**Умова виходу:** ви явно схвалюєте план. Plan Mode блокує всі записи до цього моменту.

Детальніше: [Планування та Tasks API](Planning_and_Tasks.md), [Extended Thinking та /think](Extended_Thinking.md)

## Фаза 3 — Implement

**Умова входу:** схвалений список задач.

**Ритм:** одна задача — одне підтвердження — один git-checkpoint.

```text
Implement Task 1 only. Do not proceed to Task 2 until I confirm.
```

Після підтвердження:

```text
Commit this step with a conventional commit message.
```

Потім повторити для кожної задачі.

**Між задачами — `/compact`, якщо сесія затягнулась:**

```text
/compact Focus on preserving: current task index (Task 3 of 5), DLQ routing
constraint (outside PaymentService transaction), agreed migration version V12__.
```

Стискайте тільки на чистих межах між задачами — summary буде когерентним.

**Слідкуйте за дрейфом:** агент може "спростити" Task 3, додавши `@Component` до доменної події. Саме для цього існують Фаза 4 і Фаза 5.

Детальніше: [Контекстне вікно та /compact](Context_Window_Management.md)

## Фаза 4 — Verify

**Умова входу:** остання задача реалізована.

Делегуйте [`test-runner`](Test_Runner_Subagent_Example.md). Основний контекст залишається чистим — жодних сирих стектрейсів:

```text
Use the test-runner subagent to run the full payment module tests and report back.
Command: ./gradlew :payment-service:test --info
```

**Сценарій А — зелено:**

```text
Status: PASSED
Tests run: 47, Failures: 0, Errors: 0
```

Переходимо до Фази 5.

**Сценарій Б — збій:**

```text
Status: FAILED
Test: PaymentFailedConsumerTest#shouldRouteToDlqAfterThreeFailures
Failure: NullPointerException
Root cause: DlqIncidentRepository not injected in PaymentFailedConsumer
Suggested fix: add constructor injection in PaymentFailedConsumer (line ~78)
```

Основний агент читає тільки "Root cause" і "Suggested fix" — виправляє конкретне місце без 200 рядків стектрейсу.

**Якщо test-runner не може локалізувати root cause** — спустіться на рівень нижче: запустіть тест вручну з детальнішим виводом (`--info` або `--debug`) або додайте `logging.level.com.example=DEBUG` у `application-test.properties`. Після цього делегуйте `test-runner` знову з явним уточненням: *"Root cause is unknown — analyze the full log output."*

Детальніше: [Верифікаційний цикл](Agentic_Verification_Loop.md), [Приклад субагента: Test-runner](Test_Runner_Subagent_Example.md)

## Фаза 5 — Commit

**Умова входу:** всі задачі верифіковані та зелені.

Запустіть [reviewer](Reviewer_Subagent_Example.md) перед фінальним комітом:

```text
Use the reviewer subagent to review all changes before committing.
Check: DLQ routing is outside PaymentService @Transactional boundary,
all new public methods have tests, migration is V12__ (not modifying existing).
```

Очікуваний APPROVE:

```text
Verdict: APPROVE
Summary: DLQ handler for order.payment.failed with correct tx boundary separation
Violations: none
Risk: low — new consumer path, isolated from existing PaymentService transaction
```

Якщо REJECT — виправте тільки вказані порушення, запустіть reviewer знову. Не переписуйте все.

Після APPROVE git-історія виглядає так — а не як один монстр:

```text
feat(payment): add dlq_incidents migration V12
feat(payment): add DlqIncident entity and repository
feat(payment): add DlqRouted domain event
feat(payment): implement DLQ routing in PaymentFailedConsumer
test(payment): add integration test for 3-strike DLQ flow
```

Детальніше: [Git та PR Workflow](Git_PR_Workflow.md), [Приклад субагента: Reviewer](Reviewer_Subagent_Example.md)

## Коли відхилятись від схеми

Senior-розробник не сліпо слідує рецептам. Ось коли скорочення виправдані:

| Ситуація | Що можна пропустити |
| :-------- | :------------------ |
| Тривіальна зміна (Javadoc, опечатка, rename) | Explorer і Plan. Пряме виконання. |
| Знайомий модуль, без змін у БД або Kafka | Explorer. Одразу до Plan. |
| < 3 файлів, жодного нового публічного API | Субагент reviewer — достатньо `git diff` власноруч. |
| Новий модуль, крос-шарова зміна | Повний 5-фазний workflow, без скорочень. |
| Хотфікс у production під тиском часу | Повний workflow, але `think hard` тільки на сам фікс. |

**Правило вибору:** якщо ви можете відповісти "яких файлів торкнеться ця зміна?" без допомоги Explorer — Фазу 1 можна пропустити. Якщо ні — не пропускайте.

## Швидка шпаргалка

```text
ФАЗА 1 — Explore
  "Use the explorer subagent to map [topic]: files, data flow, risks."

ФАЗА 2 — Plan
  /plan
  "think hard: design task list for [feature]. Define verify step per task."

ФАЗА 3 — Implement
  "Implement Task N only. Stop and wait for confirmation."
  Між задачами: /compact Focus on preserving: [ключові constraints, поточний крок]
  Після кожної задачі: "Commit this step with a conventional commit message."

ФАЗА 4 — Verify
  "Use the test-runner subagent to run [module] tests."

ФАЗА 5 — Commit
  "Use the reviewer subagent to review all changes."
  Після APPROVE: push / відкрити PR.
```

## Зв'язок з іншими нотатками

- Ролі субагентів (Explorer / Test-runner / Reviewer): [Архітектура субагентів](Subagents_Architecture.md)
- Готовий файл субагента [Explorer](Explorer_Subagent_Example.md)
- Готовий файл субагента [Test-runner](Test_Runner_Subagent_Example.md)
- Готовий файл субагента [Reviewer](Reviewer_Subagent_Example.md)
- Plan Mode та Tasks API в деталях: [Планування та Tasks API](Planning_and_Tasks.md)
- Верифікаційний цикл та Testcontainers: [Верифікаційний цикл](Agentic_Verification_Loop.md)
- Управління контекстним вікном та `/compact`: [Контекстне вікно та /compact](Context_Window_Management.md)
- Конвенції комітів та PR-опис: [Git та PR Workflow](Git_PR_Workflow.md)
- `/think` та extended thinking: [Extended Thinking та /think](Extended_Thinking.md)
