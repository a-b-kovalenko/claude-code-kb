[⬅️](qa_index.md)

## 📝 TL;DR

Єдиний поріг впевненості для всіх типів полів не враховує що модель може бути однаково "впевненою" у правильній і неправильній екстракції залежно від типу поля. Потрібна калібрація порогів per field type на основі labeled validation sets.

## Original

**Scenario:** A contract extraction system reports 96% overall accuracy. The team plans to auto-approve all extractions where model confidence exceeds 90%. A pilot reveals party name extraction achieves 99% accuracy but indemnification clause extraction only 71%, even though the model reports high confidence on both.

**Question:** What should they implement before automating?

**A)** Exclude indemnification clauses from automation entirely and continue automating all other field types at the 90% threshold

**B)** Calibrate confidence thresholds per field type using labelled validation sets, and implement stratified sampling to continuously monitor accuracy by document type and field segment

**C)** Raise the automation confidence threshold from 90% to 99% to ensure only the most reliable extractions are automated

**D)** Train a separate classification model to predict extraction accuracy before deciding whether to automate each extraction

## Питання

Система екстракції контрактів має 96% загальну точність. Команда планує авто-затверджувати всі екстракції де впевненість моделі перевищує 90%. Пілот виявляє: назви сторін — 99% точність, але умови відшкодування (indemnification clauses) — лише 71%, хоча модель повідомляє про високу впевненість в обох. Що потрібно реалізувати перед автоматизацією?

**A)** Виключити умови відшкодування з автоматизації і продовжувати автоматизувати всі інші типи полів при 90% порозі

**B)** Калібрувати пороги впевненості per field type використовуючи labeled validation sets, і реалізувати stratified sampling для безперервного моніторингу точності по типах документів і сегментах полів

**C)** Підвищити поріг автоматизації з 90% до 99%

**D)** Навчити окрему модель класифікації для передбачення точності екстракції

## Правильна відповідь: B

## Аналіз варіантів

### B — Правильний

Пілот показав що confidence score моделі не корелює рівномірно з точністю між типами полів. Для party names 90% впевненість → 99% реальна точність. Для indemnification 90% впевненість → 71% реальна точність. Рішення: окремі пороги для кожного типу поля, визначені на основі labeled validation data. Stratified sampling забезпечує що деградація буде виявлена до масштабування.

### A — Хибний

Повне виключення indemnification clauses — занадто агресивне рішення. Мета — калібрувати автоматизацію, не відмовлятись від неї. Можливо після калібрації indemnification clauses теж можна автоматизувати при вищому порозі.

### C — Хибний

Глобальне підвищення порогу до 99% заблокує більшість party names (що мають 99% реальну точність при 90% threshold) без необхідності. Проблема не у загальному порозі — а у тому що один поріг не підходить для всіх типів полів.

### D — Хибний

Окрема модель класифікації — надскладне рішення. Кореневу причину (некалібрований confidence score) вирішує per-field calibration. Додаткова модель додає maintenance overhead без вирішення структурної проблеми.

## Ключові концепції

### Calibrated vs uncalibrated confidence

Некалібрований confidence: модель повідомляє "90% впевнений" і для простих і для складних полів — але реальна точність різна.

Per-field calibration:

```text
party_names:       confidence 85% → accuracy ~99% → автоматизувати
indemnification:   confidence 85% → accuracy ~71% → потребує review
payment_terms:     confidence 85% → accuracy ~94% → автоматизувати
```

### Stratified sampling для моніторингу

Після запуску: рандомно відбирати N% екстракцій кожного типу для ручної перевірки. Виявляє drift (деградацію точності) до того як він стає масовою проблемою.

### Сигнал у питанні

"High confidence on both" + різна реальна точність = confidence не відкалібрований для типів полів. Перша думка: потрібна per-field калібрація, а не глобальна зміна порогу.

## Пов'язані нотатки

- [Стратегія batch processing](d4_batch_api_strategy.md) — sample-first before mass processing
- [Domain 5: Context & Reliability](../domain_5_context.md)
