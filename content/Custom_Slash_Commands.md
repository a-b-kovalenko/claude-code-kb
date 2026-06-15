[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Кастомні slash-команди — це збережені prompt-шаблони, доступні через `/команда` прямо в чаті. Вони перетворюють повторювані запити (генерація тестів, міграцій, DTO) на одне натискання клавіші та версіюються в Git разом із проєктом.

## Де зберігаються команди?

| Розташування | Область дії |
| :--- | :--- |
| `.claude/commands/*.md` | Проєктні — доступні всій команді через Git |
| `~/.claude/commands/*.md` | Персональні — доступні у всіх ваших проєктах |

Виклик: наберіть `/` у чаті — Claude Code покаже список доступних команд.

## Синтаксис

Команда — це звичайний Markdown-файл. Вміст файлу стає prompt-ом, що надсилається агенту. Аргументи, введені після назви команди, підставляються через `$ARGUMENTS`.

**Приклад:** `.claude/commands/add-test.md`

```markdown
Create an integration test for the class: $ARGUMENTS

Rules:
- Use @DataJpaTest if the class is a repository, @SpringBootTest only if Kafka is involved.
- Follow the AAA pattern with blank lines between blocks.
- Use AssertJ for all assertions.
- Use DbRider @DataSet with cleanBefore = true for data setup.
- Test must be in the same package as the class under test.
```

Виклик у чаті: `/add-test OrderRepositoryImpl`

## Практичні команди для Java-розробника

### `/migration`

```markdown
Create a Flyway migration for the following change: $ARGUMENTS

Rules:
- File must be named V<next_version>__<snake_case_description>.sql
- Find the latest version by listing files in src/main/resources/db/migration/
- Use standard SQL compatible with PostgreSQL 16.
- Add a comment at the top of the file explaining the business reason for the change.
- NEVER modify existing migration files.
```

### `/dto`

```markdown
Generate a DTO class for: $ARGUMENTS

Rules:
- Use Java record if the DTO is read-only (response).
- Use a regular class with builder if the DTO is for input (request).
- DTO must NOT reference domain entities.
- Place in the api/ package alongside the relevant controller.
- Add Bean Validation annotations where appropriate (@NotNull, @NotBlank, @Size).
```

### `/explain`

```markdown
Explain the business logic of: $ARGUMENTS

Structure your explanation as:
1. What problem does this class/method solve?
2. Key inputs and outputs.
3. Side effects (DB writes, Kafka events, external calls).
4. Edge cases and error handling.
```

## Команди vs Скіли: що обрати?

| | Slash-команда | Скіл (`SKILL.md`) |
| :--- | :--- | :--- |
| **Суть** | Шаблон промпту для одноразового завдання | Документ з глибокою експертизою |
| **Коли вантажиться** | Тільки при виклику `/команда` | Тільки коли агент вирішить, що тема релевантна |
| **Найкраще для** | "Зроби X для Y" — генерація, трансформація | "Як правильно" — правила, архітектурні патерни |
| **Приклад** | `/add-test UserService` | Скіл про правила JPA та N+1 |

## Пов'язані нотатки

- Повний довідник вбудованих команд і скілів Claude Code: [📖 Довідник команд](Commands_Reference.md).
- Де зберігаються скіли та чим вони відрізняються від команд детально: [🛠️ Скіли, плагіни та MCP](Skills_and_MCP.md).
- Як зафіксувати конвенції, щоб команди завжди їм слідували: [📄 Написання CLAUDE.md](CLAUDE_md_Writing_Guide.md).
