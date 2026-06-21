[⬅️](qa_index.md)

## 📝 TL;DR

Single-pass аналіз великої кількості файлів розпорошує увагу моделі і дає непослідовні результати. Рішення — розбити на focused passes: спочатку кожен файл окремо (локальні проблеми), потім окремий прохід для cross-file інтеграції. Більший контекст не вирішує проблему розподілу уваги.

## Original

**Scenario:** A pull request modifies 14 files across the stock tracking module. Your single-pass review analyzing all files together produces inconsistent results: detailed feedback for some files but superficial comments for others, obvious bugs missed, and contradictory feedback — flagging a pattern as problematic in one file while approving identical code elsewhere in the same PR.

**Question:** How should you restructure the review?

**A)** Split into focused passes: analyze each file individually for local issues, then run a separate integration-focused pass examining cross-file data flow.

**B)** Require developers to split large PRs into smaller submissions of 3-4 files before the automated review runs.

**C)** Switch to a higher-tier model with a larger context window to give all 14 files adequate attention in one pass.

**D)** Run three independent review passes on the full PR and only flag issues that appear in at least two of the three runs.

## Питання

PR змінює 14 файлів у модулі відстеження акцій. Single-pass огляд всіх файлів разом дає непослідовні результати: одні файли — детальний фідбек, інші — поверхові коментарі, очевидні баги пропущені, суперечливі оцінки — один і той самий патерн позначається проблемою в одному файлі і схвалюється в іншому.

Як реструктурувати огляд?

**A)** Розбити на focused passes: аналізувати кожен файл окремо для локальних проблем, потім запустити окремий інтеграційний прохід для cross-file data flow.

**B)** Вимагати від розробників розбивати великі PR на менші сабмішени (3–4 файли) перед автоматичним оглядом.

**C)** Перейти на потужнішу модель з більшим контекстним вікном щоб охопити всі 14 файлів за один прохід.

**D)** Запустити три незалежних проходи по всьому PR і позначати тільки ті проблеми, що з'являються принаймні у двох з трьох.

## Правильна відповідь: A

## Аналіз варіантів

### A — Правильний

Вирішує корінну причину: увага моделі розпорошена по 14 файлах одночасно. Розбивка на passes дає кожному файлу повну увагу при локальному аналізі. Окремий інтеграційний прохід фокусується на cross-file взаємодіях — data flow між модулями, суперечності між файлами.

### B — Хибний

Переносить проблему на розробника, а не вирішує її технічно. Обмеження у 3–4 файли може бути нереалістичним для великих фіч. Не вирішує проблему якості аналізу — тільки зменшує розмір вхідних даних.

### C — Хибний

Більше контекстне вікно дозволяє "бачити" всі 14 файлів, але не вирішує проблему розподілу уваги. Модель, що аналізує 14 файлів одночасно у великому вікні, все одно дає непослідовну глибину аналізу — бо задача залишається занадто широкою для одного проходу.

### D — Хибний

Три незалежних проходи по всьому PR матимуть ті самі проблеми розпорошення уваги. Голосування більшістю зменшує шум, але не гарантує що кожен файл отримає глибокий аналіз — систематичні пропуски будуть однаковими у всіх трьох проходах.

## Ключові концепції

### Multi-pass pattern для складних задач аналізу

```text
Single-pass (проблема):
  14 файлів → модель → непослідовний результат

Multi-pass (рішення):
  файл 1 → модель → локальні проблеми
  файл 2 → модель → локальні проблеми
  ...
  файл 14 → модель → локальні проблеми
  всі результати → модель → інтеграційні проблеми
```

### Два типи passes для code review

| Pass | Фокус | Що шукаємо |
| --- | --- | --- |
| File-level | Кожен файл окремо | Локальні баги, style, logic errors |
| Integration-level | Cross-file взаємодії | Data flow, inconsistencies, API contracts |

### Зв'язок з декомпозицією задач (Domain 1)

Це класичний приклад декомпозиції складної задачі: замість одного великого агентського кроку — кілька менших з чіткими межами. Кожен субагент/прохід отримує **тільки необхідний контекст**, а не весь стан системи.

## Пов'язані нотатки

- [Domain 1: Agentic AI](../domain_1_agentic.md) — декомпозиція задач і передача контексту
- [Наступний крок в agentic loop](d1_agentic_loop_next_tool.md) — як модель обирає наступну дію
