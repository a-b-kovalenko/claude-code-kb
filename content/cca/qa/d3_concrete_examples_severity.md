[⬅️](qa_index.md)

## 📝 TL;DR

Розмиті прозові визначення ("critical means dangerous") дають непослідовні рейтинги бо різні запуски моделі інтерпретують їх по-різному. Рішення — конкретні приклади коду для кожного рівня серйозності: вони задають об'єктивні точки калібрації.

## Original

**Scenario:** Your Claude Code review prompt for the TypeScript monorepo classifies severity using prose descriptions like 'critical means the code is dangerous' and 'minor means the code is slightly suboptimal'. Developers complain that identical code patterns receive different severity ratings across runs.

**Question:** What is the most effective improvement?

**A)** Add a confidence threshold so only findings above 90% confidence are reported, filtering out uncertain severity ratings

**B)** Add a second model pass that re-evaluates each finding's severity to catch inconsistencies

**C)** Replace prose severity descriptions with concrete code examples for each severity level, showing actual TypeScript snippets that qualify as critical, major, and minor

**D)** Lower the model temperature to 0 to ensure deterministic severity ratings

## Питання

Промпт для code review TypeScript монорепо класифікує серйозність через прозові визначення: "critical означає що код небезпечний", "minor означає що код злегка субоптимальний". Розробники скаржаться що однакові патерни коду отримують різні рейтинги серйозності між запусками.

**Question:** Яке найефективніше покращення?

**A)** Додати поріг впевненості — звітувати лише знахідки вище 90% впевненості

**B)** Додати другий прохід моделі що переоцінює серйозність кожної знахідки

**C)** Замінити прозові описи серйозності конкретними прикладами коду для кожного рівня — реальні TypeScript сніпети що кваліфікуються як critical, major і minor

**D)** Знизити температуру моделі до 0 для детермінованих рейтингів серйозності

## Правильна відповідь: C

## Аналіз варіантів

### C — Правильний

Конкретні приклади коду задають об'єктивні точки калібрації. "Critical — ось цей патерн з SQL injection" однозначно, на відміну від "critical означає небезпечний". Модель порівнює код що розглядається з конкретними прикладами — результат послідовніший між запусками.

### A — Хибний

Confidence threshold відфільтровує невпевнені знахідки але не фіксує калібрацію. Якщо "minor" і "critical" визначені розмито — модель може бути впевнено неправильною в обох напрямках.

### B — Хибний

Другий прохід може виявляти очевидні непослідовності але не вирішує кореневу причину: розмиті визначення серйозності. Обидва проходи будуть розмито інтерпретувати ті самі прозові описи.

### D — Хибний

Temperature=0 зменшує випадковість але не вирішує проблему калібрації. Детермінований вибір з погано визначених категорій дасть детерміновано неправильні або непослідовні між різними типами коду результати.

## Ключові концепції

### Прозові визначення vs конкретні приклади

```text
ПОГАНО (прозове):
"critical — код небезпечний, може призвести до серйозних наслідків"

ДОБРЕ (конкретний приклад):
"critical — наприклад:
  const query = `SELECT * FROM users WHERE id = ${userId}`
  (SQL injection: user input directly interpolated)"
```

### Чому приклади ефективніші за інструкції

- Інструкція описує категорію абстрактно — інтерпретація залежить від контексту
- Приклад задає конкретну точку в просторі можливих кодів — порівняння об'єктивне
- Few-shot calibration: модель калібрує свою оцінку відносно наданих прикладів

### Застосування в промпт-інженерії

Замість "X означає Y" → "X — ось приклади X". Принцип поширюється на будь-яку задачу класифікації де потрібна послідовність: sentiment analysis, code quality, document categorization.

## Пов'язані нотатки

- [Few-shot для послідовної екстракції](d3_few_shot_extraction_consistency.md) — few-shot для послідовності в іншому сценарії
- [Domain 3: Prompt Engineering](../domain_3_prompts.md) — calibration та structured output
