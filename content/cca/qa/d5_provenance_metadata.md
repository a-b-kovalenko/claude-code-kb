[⬅️](qa_index.md)

## 📝 TL;DR

Provenance metadata для даних у звітах агента повинна включати і джерело і часовий контекст: звідки дані + за який період + коли останнє оновлення. Лише назва джерела без timestamp — недостатньо, бо застарілі дані з правильного джерела вводять в оману.

## Original

**Scenario:** The data platform agent generates a quarterly business review report that includes claims such as 'Revenue grew 15% YoY' sourced from Snowflake and 'Market expanded by 22%' sourced from a third-party API. The Snowflake data was last refreshed yesterday, whilst the API data is from a report published six months ago.

**Question:** What provenance metadata must accompany these claims?

**A)** Claim-source mappings that include the data source, the date or time period the data represents, and the refresh or publication timestamp, enabling the user to assess temporal relevance

**B)** A confidence score (high/medium/low) for each claim based on the agent's assessment of data quality

**C)** The name of each data source (Snowflake, third-party API) so the user knows where the data came from

**D)** A footnote at the end of the report listing all data sources used, without linking specific claims to specific sources

## Питання

Агент платформи даних генерує квартальний звіт. Включає твердження: "Дохід виріс на 15% р/р" (з Snowflake) і "Ринок розширився на 22%" (зі стороннього API). Дані Snowflake оновлені вчора, дані API — зі звіту шестимісячної давнини. Яка provenance metadata повинна супроводжувати ці твердження?

**A)** Маппінги твердження до джерела: назва джерела + часовий період який представляють дані + timestamp оновлення/публікації — що дозволяє оцінити часову релевантність

**B)** Оцінка впевненості (висока/середня/низька) для кожного твердження

**C)** Назва кожного джерела даних (Snowflake, сторонній API)

**D)** Виноска в кінці звіту зі списком використаних джерел без прив'язки до конкретних тверджень

## Правильна відповідь: A

## Аналіз варіантів

### A — Правильний

Provenance вимагає трьох компонентів: (1) джерело — звідки, (2) часовий період — за що, (3) timestamp оновлення/публікації — наскільки свіжі. "Ринок розширився на 22%" зі звіту 6-місячної давнини — потенційно застаріла інформація. Без timestamp читач не може оцінити актуальність.

### B — Хибний

Confidence score — суб'єктивна оцінка агента, не provenance. Агент може бути впевнений у застарілих даних. Confidence не замінює інформацію про джерело і часовий контекст.

### C — Хибний

Назва джерела (Snowflake) без timestamp — неповна provenance. "Дані з Snowflake" не говорить коли вони оновлені. Snowflake міг містити дані тижневої або місячної давнини.

### D — Хибний

Виноска зі списком джерел без прив'язки до конкретних тверджень — читач не може визначити яке твердження з якого джерела. "Revenue grew 15% YoY" і "Market expanded 22%" можуть вимагати різного рівня довіри.

## Ключові концепції

### Три компоненти provenance metadata

| Компонент | Приклад | Для чого |
| --- | --- | --- |
| Джерело | "Snowflake DWH" | Знати звідки |
| Часовий період | "Q3 2024" | Знати за що |
| Свіжість | "Last refreshed: 2024-06-20" | Знати наскільки актуально |

### Claim-level vs report-level provenance

Виноска в кінці звіту — report-level: всі джерела разом. Claim-level: кожне твердження прив'язане до свого джерела з timestamp. Для BI-звітів з різними джерелами різної свіжості — обов'язково claim-level.

### Приклад у звіті

```text
Revenue grew 15% YoY ¹
Market expanded by 22% ²

¹ Source: Snowflake DWH | Period: Q1-Q4 2024 | Last refreshed: 2024-06-20
² Source: Market Research API | Period: Q3 2024 | Published: 2023-12-15 ⚠️
```

## Пов'язані нотатки

- [Гібридне управління контекстом](d5_context_management_hybrid.md) — що зберігати точно, що стискати
- [Domain 5: Context & Reliability](../domain_5_context.md)
