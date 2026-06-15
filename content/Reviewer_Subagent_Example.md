[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Субагент `reviewer` аналізує фінальний diff перед комітом або PR: перевіряє відповідність архітектурним межам, правилам `CLAUDE.md` та наявність тестів. Повертає вердикт **APPROVE** або **REJECT** зі списком конкретних порушень. Не змінює код — лише судить.

## Файл `.claude/agents/reviewer.md`

```markdown
---
name: reviewer
description: >
  MUST BE USED before every commit or PR to review code changes.
  Use after implementation is done to verify: architectural boundaries,
  CLAUDE.md rule compliance, test coverage, and production safety.
  Reads git diff and source files, returns APPROVE or REJECT verdict
  with specific findings. NEVER modifies files.
model: claude-sonnet-4-6
tools:
  - Bash
  - Read
  - Grep
  - Glob
---

You are a senior code reviewer for a Spring Boot / Java project.
Your job is to verify that changes meet project standards before they reach the repository.

## Step 1 — Understand what changed

Run: git diff HEAD (or git diff main...HEAD for a full branch review)
Also run: git log --oneline -5

Read all modified files in full before making judgments.

## Step 2 — Check against these rules (from CLAUDE.md)

Architecture:
- Domain layer (domain/) must contain only pure POJOs — no Spring annotations, no JPA, no DTOs.
- Application layer (application/) owns transactions — @Transactional belongs here only.
- DTOs in api/ must NEVER directly reference domain entities.
- Infrastructure layer (infrastructure/) is the only place for @Repository, Kafka consumers/producers, REST clients.

Testing:
- Every new public method in application/ must have at least one test.
- Tests must use AssertJ — never assertEquals/assertTrue.
- Integration tests must use Testcontainers — never H2.
- @Transactional must NOT appear on test methods.
- DbRider @DataSet must use cleanBefore = true.

Database:
- Existing Flyway migration files (V*__*.sql) must NEVER be modified.
- Schema changes require a new V<next>__*.sql file.

Git hygiene:
- Each commit must represent one logical change.
- No commented-out code, no TODO left without a ticket reference.

## Step 3 — Output format

Always return exactly this structure:

**Verdict:** APPROVE / REJECT
**Summary:** one sentence — what was changed and why
**Violations:** (list each as "file:line — rule violated — suggested fix")
  - none / or list
**Missing:**
  - Tests: list methods without test coverage
  - Migrations: schema changes without a migration file
**Risk:** what could break in production if this is merged as-is
**Decision rationale:** one sentence explaining the verdict
```

## Розбір ключових полів

### `description` — вердиктний тригер

Фраза "MUST BE USED before every commit or PR" гарантує авто-делегування у двох ключових моментах: коли головний агент збирається зробити коміт і коли задача позначена як завершена. Без цього агент може пропустити рев'ю.

### `model` — Sonnet як єдиний варіант

Reviewer виконує синтетичну роботу: читає зміни, утримує в пам'яті правила з `CLAUDE.md`, перевіряє архітектурні інваріанти і формулює вердикт. Haiku не має достатньої глибини контексту для цього — він пропускає неочевидні порушення на кшталт "транзакція у репозиторії замість сервісу".

### `tools` — Bash для git, без права на запис

`Bash` необхідний для `git diff` та `git log`. `Edit` і `Write` відсутні навмисно: reviewer, який може вносити правки, порушує принцип розділення відповідальності та може "заглушити" порушення замість того щоб їх зафіксувати.

### ⚠️ Правила в system prompt vs CLAUDE.md

Дублювання правил у system prompt субагента — свідоме рішення. Reviewer повинен мати повний checklist прямо в контексті, не покладаючись на те, чи підвантажиться `CLAUDE.md` у його вікно. Якщо правила у вашому проєкті змінюються — оновлюйте обидва місця.

## Як викликати

**Авто-делегування** — спрацьовує коли головний агент вирішує зробити коміт або повідомляє що задача виконана.

**Явний виклик перед комітом:**
> *"Use the reviewer subagent to review all changes before committing."*

**Явний виклик для всієї гілки:**
> *"Use the reviewer subagent to review the full diff against main."*

**Зі збереженням контролю:**
> *"Use the reviewer subagent and wait for APPROVE before pushing."*

## Робочий цикл з reviewer

```text
Головний агент виконав задачу
        ↓
test-runner: всі тести зелені? → якщо ні, повернутись
        ↓
reviewer: APPROVE чи REJECT?
        ↓
REJECT → головний агент виправляє порушення → знову reviewer
        ↓
APPROVE → коміт → PR
```

Цей цикл гарантує, що жоден коміт не містить порушень архітектури або відсутніх тестів — навіть якщо головний агент "забув" про правило у процесі довгої задачі.

## Design-рев'ю: reviewer на фазі планування

Той самий субагент можна використати **до** реалізації — для перевірки плану в Plan Mode, а не фінального diff:

```text
Оркестратор у Plan Mode → пропонує дизайн
        ↓
reviewer: перевіряє план на відповідність архітектурі
        ↓
REJECT → оркестратор коригує план → знову reviewer
        ↓
APPROVE → ви підтверджуєте ExitPlanMode → реалізація
```

System prompt reviewer'а для цього режиму відрізняється: замість `git diff` він отримує текст плану і перевіряє не "що зроблено", а "що планується зробити". Корисні запитання до плану:

- Чи не порушує запропонована структура класів межі між шарами?
- Чи передбачений тест для кожного нового публічного методу?
- Чи потрібна Flyway-міграція для запланованих змін схеми?
- Чи реалістичний обсяг — чи не пропущено неочевидних залежностей?

Агент-рев'юер як перший фільтр скорочує час вашого design-рев'ю: ви бачите вже відфільтрований план і фокусуєтесь на бізнес-логіці та пріоритетах, а не на технічних порушеннях.

**Ключова відмінність від code review:** вердикт reviewer'а на фазі планування — рекомендація для вас, а не для агента. Рішення про `ExitPlanMode` завжди лишається за вами.

## Зв'язок з іншими нотатками

- Ролі всіх трьох субагентів у системі: [👥 Архітектура субагентів](Subagents_Architecture.md).
- Як reviewer вписується у верифікаційний цикл: [🔄 Верифікаційний цикл](Agentic_Verification_Loop.md).
- Plan Mode і контрольна точка ExitPlanMode: [📅 Планування та Tasks API](Planning_and_Tasks.md).
- Приклади інших субагентів: [🔍 Explorer](Explorer_Subagent_Example.md), [🧪 Test-runner](Test_Runner_Subagent_Example.md).
