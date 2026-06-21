[⬅️](qa_index.md)

## 📝 TL;DR

`--output-format` керує форматом stdout Claude Code у headless-режимі. `--output-format json` виводить структурований JSON який CI/CD пайплайни можуть парсити програмно — замість stream тексту призначеного для людини.

## Original

**Question:** What does the `--output-format` flag control when running Claude Code in CI/CD pipelines?

**A)** It configures the log level verbosity of Claude Code's diagnostic output

**B)** It specifies the format of Claude Code's stdout output, such as JSON for structured parsing by downstream pipeline steps

**C)** It determines the programming language used in generated code output

**D)** It sets the file encoding for any files that Claude Code creates during the session

## Питання

Що контролює прапор `--output-format` при запуску Claude Code в CI/CD пайплайнах?

**A)** Налаштовує рівень verbosity діагностичного виводу Claude Code

**B)** Визначає формат stdout виводу Claude Code, наприклад JSON для структурованого парсингу наступними кроками пайплайну

**C)** Визначає мову програмування, яка використовується у згенерованому коді

**D)** Встановлює кодування файлів, які Claude Code створює під час сесії

## Правильна відповідь: B

## Аналіз варіантів

### B — Правильний

`--output-format` визначає як Claude Code форматує свій stdout. Опція `json` дає структурований вивід — масив подій з типами, що CI/CD скрипти можуть парсити для визначення успіху/помилки, витягнення результатів, тригерування наступних кроків.

### A — Хибний

Рівень verbosity логів контролюється окремим механізмом. `--output-format` не про кількість діагностики, а про формат основного виводу.

### C — Хибний

Мова програмування у генерованому коді не є функцією цього прапора — вона визначається завданням і промптом.

### D — Хибний

Кодування файлів — інша налаштування, не пов'язана з форматом виводу stdout.

## Ключові концепції

### Опції --output-format

| Значення | Вивід | Де використовувати |
| --- | --- | --- |
| `text` (default) | Stream тексту для людини | Інтерактивна сесія |
| `json` | JSON з типізованими подіями | CI/CD, парсинг скриптами |
| `stream-json` | Потокові JSON події | Real-time моніторинг пайплайну |

### Приклад у CI/CD

```bash
claude --print --output-format json "Run tests and report status" \
  | jq '.[] | select(.type == "result") | .content'
```

### Зв'язок з headless mode

`--output-format` найбільш корисний у поєднанні з `--print` (headless): `--print` забирає інтерактивний режим, `--output-format json` робить вивід машиночитабельним.

## Пов'язані нотатки

- [Headless Mode](../../Headless_Mode.md) — `--print`, ключові прапори CI/CD
- [CI/CD інтеграція](../../CI_CD_Integration.md) — GitHub Actions, автентифікація
- [Domain 2: Claude Code Workflows](../domain_2_claude_code.md)
