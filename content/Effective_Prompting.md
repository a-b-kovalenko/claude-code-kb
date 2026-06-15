[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Якість відповіді Claude прямо залежить від якості запиту. Сім правил ефективного промптингу для задач розробки: вказуйте файли явно, формулюйте constraints мовою коду, задавайте критерій Done у самому запиті, обмежуйте scope словом "Stop", посилайтесь на конкретні рядки, а не абстрактні описи, та явно забороняйте небажані дії через негативні обмеження.

## Чому промпт вирішує більше ніж здається

Claude не читає думок. Він інтерпретує текст максимально доброзичливо — і якщо у запиті є двозначність, заповнює її своїм судженням. Для побутових завдань це чудово. Для коду — небезпечно: агент "допомагає" там, де ви не просили, або вирішує не ту проблему з упевненим виглядом.

Наведені нижче правила — не про стиль, а про передбачуваність результату.

---

## Правило 1. Вказуйте файли явно

**Погано:**

```text
Fix the payment processing bug.
```

**Добре:**

```text
Fix the bug in PaymentService.java, method processRefund().
Do not touch any other files.
```

Без явного переліку файлів агент самостійно вирішує що "пов'язане" із задачею — і може торкнутись OrderService, PaymentMapper та тестів, яких ви не просили чіпати.

Коли scope заздалегідь невідомий — спочатку запустіть [Приклад субагента: Explorer](Explorer_Subagent_Example.md), щоб отримати точний список файлів, а вже потім давайте завдання на реалізацію.

---

## Правило 2. Формулюйте constraints мовою коду

Абстрактний constraint агент може проігнорувати або зрозуміти не так. Конкретний — важко неправильно інтерпретувати.

| Абстрактно (погано) | Конкретно (добре) |
| :------------------ | :---------------- |
| "Не використовуй мок" | `"Do not use Mockito. Use a real Testcontainers PostgreSQL instance."` |
| "Збережи транзакційність" | `"DLQ routing must happen outside the @Transactional boundary of PaymentService."` |
| "Не ламай існуючий API" | `"Do not change the signature of any public method in PaymentService."` |
| "Дотримуйся стилю проєкту" | `"Follow the pattern in OrderService.java: constructor injection, no field injection."` |

Найефективніший формат: **що робити** + **обмеження** + **приклад звідки взяти зразок**.

---

## Правило 3. "Stop and wait" для контролю scope

Без явної зупинки агент виконає всі кроки підряд — і ви отримаєте 5 задач в одному diff.

**Погано:**

```text
Implement the DLQ handler for order.payment.failed.
```

**Добре:**

```text
Implement Task 1 only: create V12__dlq_incidents.sql migration.
Stop after this step and wait for my confirmation before proceeding.
```

Фраза `"Stop and wait for confirmation"` — це явний контракт. Агент її розуміє і дотримується. Після підтвердження: `"Proceed to Task 2."`

Детальніше: [Антипатерни](Anti_Patterns.md) (п. "Без checkpoint-стратегії"), [Золотий workflow](Golden_Workflow.md)

---

## Правило 4. "Fix the code", а не "fix the test"

Це одна з найнебезпечніших двозначностей.

| Формулювання | Що може зробити агент |
| :----------- | :-------------------- |
| `"Fix the failing test"` | Видалити assertion, закоментувати тест, замінити на `assertTrue(true)` |
| `"Fix the code so the failing test passes"` | Виправити логіку у production-коді |

Завжди формулюйте від продакшн-коду, а не від тесту:

```text
The test PaymentServiceTest#shouldRefundOnTimeout is failing.
Fix the bug in PaymentService so this test passes.
Do not modify the test itself.
```

---

## Правило 5. Критерій Done у самому запиті

Якщо ви не вказали критерій завершення — агент вирішує сам коли зупинитись. Зазвичай він зупиняється занадто рано (код написано, але тести не запущені) або занадто пізньо (тести запущені, але агент почав "поліпшувати" суміжний код).

**Погано:**

```text
Add the DlqIncident entity and repository.
```

**Добре:**

```text
Add the DlqIncident entity and DlqIncidentRepository.
Done when: unit test passes — save a DlqIncident and find it by orderId.
Stop after the test is green.
```

Формат критерію: `"Done when: [машинно-перевірюваний результат]."` Зелений тест завжди кращий за суб'єктивне "реалізовано".

---

## Правило 6. Конкретні файли і рядки замість абстрактних описів

Чим точніше посилання — тим менше агент домислює.

**Абстрактно:**

```text
Add retry logic similar to what we have for other Kafka consumers.
```

**Конкретно:**

```text
Add retry logic to PaymentFailedConsumer.java following the pattern in
OrderFailedConsumer.java lines 45–78 (RetryTemplate with ExponentialBackoff).
```

Те саме стосується помилок:

```text
// Погано
Fix the NullPointerException in the payment flow.

// Добре
Fix the NullPointerException at PaymentService.java:134 —
field dlqIncidentRepository is null because it's not injected in the constructor.
```

Якщо ви самі не знаєте де проблема — попросіть [субагент test-runner](Test_Runner_Subagent_Example.md) надати "Root cause" та "Suggested fix area" і потім давайте завдання на виправлення.

**Увага щодо номерів рядків:** перед посиланням на конкретний рядок переконайтесь що він актуальний — файл міг змінитись після попередніх правок. Швидка перевірка через `Read` або `Grep` збереже агента від виправлення "не того місця".

---

## Правило 7. Негативні обмеження

Правило 2 описує *що робити*. Правило 7 — *що категорично не робити*. Це різні семантичні класи: агент може виконати позитивний constraint і водночас зробити щось небажане, якщо не заборонити явно.

**Типові негативні обмеження для Java-проєктів:**

```text
Do not add new dependencies to pom.xml or build.gradle.
Do not use non-standard or third-party libraries not already in the project.
Do not add Javadoc to private methods.
Do not change the database schema — use only the existing tables.
Do not modify any existing @Entity class.
```

Включайте негативні обмеження в шаблон разом із позитивними — особливо коли агент має доступ до широкого scope (наприклад, читає весь `src/`).

---

## Готові шаблони

### Завдання на реалізацію

```text
Implement [конкретна функціональність] in [файл, метод].
Constraints: [список обмежень мовою коду].
Do not touch: [перелік файлів/методів поза scope].
Done when: [зелений тест або інший машинно-перевірюваний результат].
Stop and wait for confirmation before proceeding to the next step.
```

### Виправлення бага

```text
Fix the bug in [файл]:[рядок або метод].
Root cause: [опис якщо відомо].
Fix the code, not the test.
Done when: [назва тесту] passes.
Do not modify any other files.
```

### Рефакторинг із обмеженнями

```text
Refactor [метод/клас] in [файл].
Follow the pattern in [файл-зразок], lines [N–M].
Constraints: [список].
Do not change the public API — all existing callers must compile without changes.
Done when: all tests in [модуль] are green.
```

## Зв'язок з іншими нотатками

- Антипатерни розмитих промптів та scope creep: [Антипатерни](Anti_Patterns.md)
- Як Explorer знімає невизначеність у scope: [Приклад субагента: Explorer](Explorer_Subagent_Example.md)
- Критерій Done у контексті верифікаційного циклу: [Верифікаційний цикл](Agentic_Verification_Loop.md)
- Повний workflow, де ці правила застосовуються на практиці: [Золотий workflow](Golden_Workflow.md)
