[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Скіл — це Markdown-файл із вузькоспеціалізованими знаннями, який Claude Code підвантажує лише тоді, коли тема релевантна. На відміну від `CLAUDE.md` (завжди в контексті), скіл не засмічує пам'ять агента доти, доки він справді не потрібен.

## Скіл vs інші механізми знань

| Механізм | Коли вантажиться | Найкраще для |
| :--- | :--- | :--- |
| `CLAUDE.md` | Завжди, кожна сесія | Критичні правила та структура проєкту |
| **Скіл** | Тільки при релевантній задачі | Глибока технічна експертиза по конкретній темі |
| Slash-команда | При явному виклику `/команда` | Шаблони для повторюваних дій |
| Hook | При кожній відповідній події | Детерміновані перевірки та автоматизація |

## Де зберігаються скіли

| Розташування | Область дії |
| :--- | :--- |
| `.claude/skills/<name>.md` | Проєктні — версіюються в Git, доступні команді |
| `~/.claude/skills/<name>.md` | Персональні — працюють на всіх проєктах |

## Анатомія скіл-файлу

```markdown
---
name: jpa-patterns
description: >
  Load when working with JPA entities, Hibernate, repositories,
  JPQL/native queries, lazy loading, or database performance issues.
  Covers N+1 prevention, pagination, transaction boundaries, and fetch strategies.
---

(тіло: правила, антипатерни, приклади коду)
```

Поле `description` — найважливіше. Саме по ньому Claude Code вирішує, чи підвантажувати скіл. Пишіть його як перелік ключових слів та сценаріїв, а не загальну фразу.

## Повний приклад: `.claude/skills/jpa-patterns.md`

Frontmatter файлу:

```yaml
---
name: jpa-patterns
description: >
  Load when working with JPA entities, Hibernate, repositories,
  JPQL/native queries, lazy loading, or database performance issues.
  Covers N+1 prevention, pagination, transaction boundaries, and fetch strategies.
---
```

Тіло файлу — звичайний Markdown з правилами та прикладами коду:

---

### N+1 SELECT — головна пастка

N+1 виникає коли колекція ліниво підвантажується всередині циклу.

**Антипатерн:**

```java
// Для кожного Order — окремий SELECT для items
orders.forEach(o -> process(o.getItems()));
```

**Рішення — JOIN FETCH у репозиторії:**

```java
@Query("SELECT o FROM Order o JOIN FETCH o.items WHERE o.status = :status")
List<Order> findWithItemsByStatus(@Param("status") OrderStatus status);
```

**Діагностика:** увімкніть `spring.jpa.show-sql=true` і рахуйте SELECT-и. Якщо N записів = N+1 запитів — є N+1 проблема.

---

### Пагінація — ніколи не використовуй LIMIT у JOIN FETCH

Hibernate повертає всі записи в пам'ять при поєднанні JOIN FETCH та Pageable. Рішення — два запити:

```java
// 1. Отримати ID зі сторінкою
@Query(value = "SELECT o.id FROM Order o WHERE o.status = :status",
       countQuery = "SELECT COUNT(o) FROM Order o WHERE o.status = :status")
Page<Long> findIdsByStatus(@Param("status") OrderStatus status, Pageable pageable);

// 2. Завантажити з JOIN FETCH по ID
@Query("SELECT o FROM Order o JOIN FETCH o.items WHERE o.id IN :ids")
List<Order> findWithItemsByIds(@Param("ids") List<Long> ids);
```

---

### Межі транзакцій

- `@Transactional` — тільки в application layer (сервіси).
- Репозиторії мають вбудовані транзакції на рівні методів — не додавайте зайвих.
- Ніколи не відкривайте транзакцію в контролері — це антипатерн Open Session in View.

---

### FetchType за замовчуванням

- **`@ManyToOne`** — EAGER за замовчуванням. Залишити як є або явно оголосити LAZY.
- **`@OneToMany`** — LAZY за замовчуванням. Залишити LAZY, підвантажувати через JOIN FETCH за потреби.
- **`@ManyToMany`** — LAZY за замовчуванням. Завжди LAZY.

Загальне правило: всі колекції — LAZY. Підвантажуйте явно через JOIN FETCH або EntityGraph.

## Що включати в скіл

- **Антипатерни** — конкретні приклади того, що агент робить без скіла
- **Правильні альтернативи** — код, який треба писати натомість
- **Пояснення "чому"** — коротко, щоб агент розумів інваріант, а не тільки шаблон
- **Таблиці рішень** — коли кілька варіантів і треба обрати правильний

## Коли варто створювати скіл

Скіл виправданий якщо:

- Агент **систематично** робить одну й ту саму помилку в певній темі.
- Тема занадто велика для `CLAUDE.md` (більше 10 рядків правил).
- Знання потрібні лише в конкретних сценаріях, а не завжди.

Типові скіли для Spring Boot проєкту:

- `jpa-patterns.md` — N+1, пагінація, транзакції, fetch strategies
- `kafka-patterns.md` — серіалізація, DLQ, idempotency, consumer groups
- `spring-security.md` — авторизація, JWT, CORS, метод-рівень security
- `api-design.md` — версіювання, коди відповідей, валідація, error body

## Зв'язок з іншими нотатками

- Огляд всіх механізмів знань та вибір між ними: [🛠️ Скіли, плагіни та MCP](Skills_and_MCP.md).
- Що фіксувати в `CLAUDE.md`, а що виносити в скіли: [📄 Написання CLAUDE.md](CLAUDE_md_Writing_Guide.md).
