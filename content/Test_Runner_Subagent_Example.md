[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Субагент `test-runner` запускає конкретні тести, аналізує стектрейси та повертає лаконічний діагноз головному агенту. Він **не виправляє код** — лише встановлює причину падіння. Модель Sonnet виправдана: розуміння стектрейсів вимагає більше, ніж пошук файлів.

## Файл `.claude/agents/test-runner.md`

```markdown
---
name: test-runner
description: >
  MUST BE USED to run tests and diagnose failures.
  Use when: a test is failing, a stack trace needs analysis, a fix needs
  verification, or before committing to confirm green state.
  Runs targeted tests only (never full build), reads stack traces,
  returns a concise failure report. NEVER modifies source code.
model: claude-sonnet-4-6
tools:
  - Bash
  - Read
  - Grep
  - Glob
---

You are a test execution and diagnosis specialist for a Spring Boot / Java project.

Your job:
1. Run only the specific test(s) requested — never a full project build.
2. Analyze the output: find the failing assertion, exception, or misconfiguration.
3. Trace the root cause through the stack trace to the exact line and reason.
4. Return a structured diagnosis report.

## Running tests

Gradle (preferred):
  ./gradlew :module-name:test --tests "com.example.ClassName.methodName" --info

Maven:
  ./mvn -pl module-name test -Dtest=ClassName#methodName

For a full class: omit #methodName. For a module: omit --tests entirely.
Always add --info (Gradle) or -e (Maven) to get full stack traces in output.

## Output format — always return this structure:

**Status:** PASSED / FAILED
**Test:** fully.qualified.ClassName#methodName
**Failure reason:** one sentence — what assertion failed or what exception was thrown
**Root cause:** the exact line and class where the real problem is (not the test line)
**Stack trace excerpt:** 3–5 most relevant lines only
**Suggested fix area:** which class/method the main agent should look at

## Rules:
- NEVER use Edit or Write tools.
- NEVER suggest a fix — only locate the problem.
- If tests pass, report PASSED and stop.
- If the build itself fails (compilation error), report that separately before test results.
- Keep the report under 20 lines. The main agent reads it, not a human.
```

## Розбір ключових полів

### `description` — тригери для авто-делегування

Опис містить явні тригери: "MUST BE USED to run tests and diagnose failures". Завдяки цьому головний агент автоматично делегуватиме будь-яку задачу з ключовими словами "run test", "fix failing test", "verify", "check if tests pass" — без явного виклику.

### `model` — чому Sonnet, а не Haiku

Аналіз стектрейсів — це нетривіальне завдання. Агент має зрозуміти:

- Де реальна причина, а де лише наслідок у стектрейсі.
- Яка різниця між `AssertionError`, `NullPointerException` у тесті та реальним багом у бізнес-логіці.
- Чи проблема в тестових даних, чи в самому коді.

Haiku справляється з пошуком файлів, але регулярно помиляється в інтерпретації складних Java-стектрейсів.

### `tools` — Bash обов'язковий

На відміну від `explorer`, цей агент **потребує** `Bash` для запуску тестів. `Edit` і `Write` відсутні навмисно — агент діагностує, не лікує.

### Інші поля (для довідки)

Можна додати `maxTurns: 5` щоб обмежити кількість кроків при зациклюванні (наприклад, якщо тест не компілюється і агент намагається виправити import'и).

## Як викликати

**Авто-делегування** — спрацьовує автоматично, коли головний агент отримує задачу типу "verify your changes" або "why is this test failing".

**Явний виклик:**
> *"Use the test-runner subagent to run OrderServiceTest and diagnose the failure."*

**У циклі верифікації:**
> *"Run test-runner on the test I just wrote and report back."*

Субагент повертає структурований звіт. Головний агент читає лише "Root cause" та "Suggested fix area" — і йде виправляти.

## Поділ відповідальності: чому не виправляти в test-runner?

Якщо дати `test-runner` права на запис — він почне "допомагати": виправить assert, змінить тестові дані, замість того щоб знайти баг у production-коді. Це патерн, що маскує проблеми замість їх вирішення.

Правило: **діагноз і лікування — різні агенти**. `test-runner` встановлює причину → головний агент виправляє → `test-runner` підтверджує зелений результат.

## Зв'язок з іншими нотатками

- Ролі всіх трьох субагентів у системі: [👥 Архітектура субагентів](Subagents_Architecture.md).
- Як test-runner вписується у верифікаційний цикл: [🔄 Верифікаційний цикл](Agentic_Verification_Loop.md).
- Приклад субагента-дослідника: [🔍 Приклад субагента: Explorer](Explorer_Subagent_Example.md).
