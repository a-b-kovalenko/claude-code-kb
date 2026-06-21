[⬅️](CCA_Foundations.md)

## 📝 TL;DR

8-тижневий план підготовки до CCA-F з урахуванням наявного досвіду: активна практика Claude Code і MCP скорочує час підготовки. Фокус — agentic architecture, prompt engineering, context reliability.

## Оцінка стартового рівня

| Домен | Рівень | Пріоритет |
| --- | --- | --- |
| Agentic Architecture (27%) | Середній — теорія є, production gaps | Найвищий |
| Claude Code Workflows (20%) | Високий — активна практика | Повторення |
| Prompt Engineering (20%) | Середній | Високий |
| Tool Design & MCP (18%) | Середній — є досвід MCP | Поглиблення |
| Context & Reliability (15%) | Низький — failure patterns не опрацьовані | Високий |

## Часова шкала

**Тижні 1–2** — Anthropic Academy: API + MCP курси (≈10 год)
Мета: закрити теоретичні gaps по Domain 3, 4, 5

**Тижні 3–4** — Hands-on проєкти:

- Multi-agent orchestration (Domain 1)
- MCP server з custom tools + validation retry (Domain 4)

Фіксувати помилки → нотатки у цьому розділі vault

**Тижні 5–6** — Agent Skills курс + [Anthropic Cookbook](https://github.com/anthropics/anthropic-cookbook) (agentic розділи)
Фокус: production failure patterns для всіх 5 доменів

**Тиждень 7** — [Практичні тести](https://certificationpractice.com/practice-exams/anthropic-claude-certified-architect-foundations)
Повторення слабких зон за результатами

**Тиждень 8** — Фінальний review → реєстрація → іспит

## Офіційні ресурси (безкоштовно)

Курси на [anthropic.skilljar.com](https://anthropic.skilljar.com):

- ~~Claude 101~~ — можна пропустити
- **Building Applications with the Claude API** (≈8 год) — обов'язково
- **Introduction to Model Context Protocol** — обов'язково
- **Agent Skills** — обов'язково
- Claude Code in Action — повторення

[Anthropic Cookbook](https://github.com/anthropics/anthropic-cookbook) — покриває ~90% матеріалу іспиту.

## Реєстрація на іспит

1. Приєднатися до [Claude Partner Network](https://www.anthropic.com/claude-partner-network)
2. Зареєструватися на Anthropic Academy (Skilljar) — окремий акаунт
3. Завершити необхідні курси — розблоковується доступ до іспиту
4. Скласти прокторований тест онлайн

## Чеклист готовності

- [ ] Можна пояснити 3 production failure patterns для кожного домену
- [ ] Знаєш різницю: hooks vs. prompts, plan mode vs. direct execution
- [ ] Можеш описати hub-and-spoke multi-agent схему з session resumption
- [ ] Розумієш JSON schema: nullable vs. required — типові помилки
- [ ] Практичні тести: стабільно ≥75%
