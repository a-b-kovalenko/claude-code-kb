[⬅️](qa_index.md)

## 📝 TL;DR

`allowedTools` у `settings.json` (або через CLI прапор) задає whitelist дозволених інструментів на рівні сесії — жоден інструмент поза списком не виконається фізично. Це детерміноване обмеження, а не інструкція моделі. Plan mode просить підтвердження але не блокує; CLAUDE.md правило — модельна дискреція.

## Original

**Scenario:** A junior developer is using Claude Code to refactor a payment processing module. The team lead wants to ensure Claude Code cannot accidentally delete production configuration files or modify the database migration directory during the refactoring session.

**Question:** What is the most appropriate approach?

**A)** Instruct the developer to use plan mode so Claude Code will ask for approval before each file change

**B)** Add a rule in CLAUDE.md stating 'Never modify files in the config/ or migrations/ directories'

**C)** Configure allowedTools to restrict the session to only Read, Grep, Glob, and Write for files within the payment module directory

**D)** Set the repository to read-only mode at the filesystem level before starting the session

## Питання

Молодший розробник використовує Claude Code для рефакторингу модуля обробки платежів. Team lead хоче гарантувати що Claude Code не зможе випадково видалити продакшн конфігурації або модифікувати директорію міграцій бази даних під час сесії рефакторингу. Який найбільш доречний підхід?

**A)** Інструктувати розробника використовувати plan mode щоб Claude Code питав підтвердження перед кожною зміною файлу

**B)** Додати правило в CLAUDE.md: "Ніколи не модифікуй файли в директоріях config/ або migrations/"

**C)** Налаштувати `allowedTools` щоб обмежити сесію лише на Read, Grep, Glob і Write для файлів у директорії payment module

**D)** Встановити репозиторій у read-only режим на рівні файлової системи перед початком сесії

## Правильна відповідь: C

## Аналіз варіантів

### C — Правильний

`allowedTools` задає whitelist на рівні конфігурації — інструменти поза списком просто недоступні агенту. Можна поєднати з glob-паттернами: Write дозволений тільки для `payment/**`. Модель фізично не може торкнутись config/ або migrations/ незалежно від своїх рішень.

### A — Хибний

Plan mode показує план і просить підтвердження — але розробник може випадково підтвердити небажану дію. Не блокує, а лише сповіщає.

### B — Хибний

CLAUDE.md правило — модельна дискреція. Модель "знає" що не можна, але може помилитись, неправильно зрозуміти scope або проігнорувати під час складного рефакторингу.

### D — Хибний

Read-only на рівні filesystem заблокує ВСІ записи — Claude Code взагалі не зможе змінювати жодного файлу, включаючи payment module. Занадто широке обмеження.

## Ключові концепції

### allowedTools у settings.json

```json
{
  "allowedTools": [
    "Read",
    "Grep",
    "Glob",
    "Write(payment/**)"
  ]
}
```

Glob-паттерни в allowedTools дозволяють точно визначити які файли можна писати, залишаючи читання без обмежень.

### Різниця підходів за надійністю

| Підхід | Тип | Надійність |
| --- | --- | --- |
| CLAUDE.md правило | Модельна дискреція | Може бути проігноровано |
| Plan mode | Людський approval | Може бути підтверджено помилково |
| allowedTools | Конфігураційне обмеження | Детерміноване |
| Filesystem read-only | Системне обмеження | Детерміноване, але надто широке |

### Сигнал у формулюванні

"Cannot accidentally" — сигнал що питання тестує детерміноване обмеження, а не рекомендацію. Модельні рішення не відповідають на "cannot".

## Пов'язані нотатки

- [Детерміновані guardrails](d1_deterministic_guardrails.md) — код vs модель для enforcement
- [Конфігурація settings.json](../../Settings_JSON_Guide.md) — allowedTools і glob-синтаксис
- [Domain 2: Claude Code Workflows](../domain_2_claude_code.md)
