[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

`CLAUDE.md` — це «контракт» між вами та агентом. Правильно написаний файл усуває потребу повторювати правила щоразу та радикально підвищує якість роботи AI. Головний принцип: стисло, конкретно, без очевидного.

## Навіщо вкладати зусилля в CLAUDE.md?

Агент читає `CLAUDE.md` автоматично на початку **кожної** сесії. Це єдиний механізм, який гарантовано доноситиме ваші конвенції до AI без жодних нагадувань. Усе, що ви не зафіксуєте тут, агент буде вигадувати самостійно — з непередбачуваним результатом.

## Структура CLAUDE.md для Spring Boot проєкту

```markdown
# Project: <назва>

## Stack
- Java 21, Spring Boot 3.x, Gradle 8
- PostgreSQL 16, Kafka 3.x, Flyway
- JUnit 5, Testcontainers, AssertJ, DbRider, Awaitility

## Project layout
src/
  main/java/com/company/app/
    domain/        # Entities, Value Objects (чисті POJO, без Spring)
    application/   # Services, Use Cases (транзакційний шар)
    infrastructure/ # Repositories, Kafka consumers/producers, REST clients
    api/           # Controllers, DTOs, Mappers

## Key rules
- NEVER use H2. Tests run on real Postgres via Testcontainers.
- ALWAYS use AssertJ. Never assertEquals/assertTrue.
- DTOs must NEVER reference domain entities directly.
- Flyway: never edit existing V*.sql. Create a new V<next>__ file.
- Transactions belong in application layer, not in controllers or repositories.

## Testing conventions
- Unit tests (plain JUnit 5): pure business logic, no Spring context.
- @DataJpaTest: repository + SQL correctness.
- @SpringBootTest: only for full integration scenarios with Kafka.
- Each test follows AAA pattern with blank lines between blocks.

## What NOT to do
- Do not add @Transactional to test methods.
- Do not generate Lombok on entity classes without asking.
- Do not change existing migration files.
```

## Що включати — і що ні

| Включати | НЕ включати |
| :--- | :--- |
| Версії стеку та інструментів | Очевидні речі ("Java — об'єктно-орієнтована мова") |
| Нетипові конвенції вашого проєкту | Детальні пояснення "чому" — вони займають місце |
| Явні заборони (anti-patterns) | Правила, які вже є в загальних стандартах |
| Структуру пакетів та її логіку | Деталі, що часто змінюються (версії патчів) |
| Правила для тестів та міграцій | Списки всіх файлів або повний API |

## Модульні правила: `.claude/rules/`

Коли `CLAUDE.md` починає розростатися — виносьте специфіку в окремі файли:

- `.claude/rules/jpa.md` — правила N+1, пагінація, межі транзакцій.
- `.claude/rules/kafka.md` — конвенції топіків, DLQ, серіалізація.
- `.claude/rules/security.md` — авторизація, CORS, обробка секретів.

Агент підвантажує ці файли за необхідністю, не засмічуючи основний контекст.

### Приклад: `.claude/rules/testing.md`

```markdown
## Testing rules

Stack: JUnit 5, AssertJ, Testcontainers, DbRider, Awaitility.

### Test types and when to use each
- Unit test (no Spring context): pure business logic, domain methods, mappers.
- @DataJpaTest: repository queries and SQL correctness. Real Postgres via Testcontainers.
- @SpringBootTest: full integration scenarios involving Kafka or multiple layers together.
  Use sparingly — startup is slow.

### Mandatory conventions
- NEVER use H2. Every test that touches the database must use Testcontainers.
- ALWAYS use AssertJ: assertThat(...).isEqualTo(...). Never assertEquals/assertTrue.
- NEVER put @Transactional on a test method — it hides commit-related bugs.
- DbRider @DataSet must always include cleanBefore = true.
- Follow AAA (Arrange / Act / Assert) with a blank line between each block.

### Naming
- Method name pattern: should_<expectedResult>_when_<condition>
  Example: should_throw_when_order_is_already_cancelled

### Awaitility
- Use Awaitility for any assertion on async Kafka consumers.
  Never use Thread.sleep().
  Default: await().atMost(10, SECONDS).untilAsserted(...)
```

Rule-файли відрізняються від скілів стислістю і директивним тоном: лише "що робити / не робити", без глибоких пояснень "чому". Пояснення — у скілах (див. [✍️ Розробка власного скіла](Skill_Development_Guide.md)).

## Три рівні CLAUDE.md

Claude Code завантажує інструкції з трьох місць одночасно:

| Файл | Scope | Git |
| :--- | :--- | :--- |
| `~/.claude/CLAUDE.md` | Всі проєкти на машині | Ні |
| `CLAUDE.md` | Проєкт, вся команда | Так |
| `CLAUDE.local.md` | Проєкт, тільки ти | Ні |

**`CLAUDE.local.md`** — особистий шар у корені проєкту. Автоматично додається до `.gitignore`. Типові випадки:

- Локальні шляхи (`DB_URL=jdbc:postgresql://localhost:5432/mydb_dev`)
- Особисті переваги, яких не варто нав'язувати команді
- Локальні override командних правил
- WIP-нотатки про поточний контекст задачі

Для архітектора команди це важливе розмежування: `CLAUDE.md` — командний стандарт, `CLAUDE.local.md` — особиста кастомізація кожного розробника без забруднення спільного контракту.

## Ліміт: до 60 рядків у CLAUDE.md

Якщо файл більший — він починає "розмивати" увагу агента. Стислість тут є буквальною технічною перевагою, а не естетичною. Деталі — у `.claude/rules/`, експертиза — у скілах (див. [🛠️ Скіли, плагіни та MCP](Skills_and_MCP.md)).
