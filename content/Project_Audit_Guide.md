[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Перед retrofit існуючого проєкту агент проводить аудит кодової бази та git-історії — і реконструює контекст без запитань до користувача. Результат: наповнений CLAUDE.md, список ретроспективних ADR та рекомендації щодо MCP-серверів.

---

## Що і звідки визначається

### Git-історія

```bash
git log --oneline -20          # конвенція комітів
git log --format="%ae" | sort -u  # унікальні автори → командний чи соло
git branch -a                  # конвенція гілок
git remote -v                  # платформа (GitHub/GitLab), наявність remote
git tag --sort=-creatordate | head -10  # cadence релізів, semantic versioning
```

### Build-файли та залежності

| Файл | Що визначається |
| :--- | :--- |
| `pom.xml` / `build.gradle` | Стек, фреймворки, назва, версія |
| `package.json` | JS/TS стек, скрипти, менеджер пакетів |
| `requirements.txt` / `pyproject.toml` | Python-стек |
| Плагіни (Jacoco, Checkstyle, Spotbugs) | Code quality стандарти |

### Структура проєкту

- Архітектурний стиль: hexagonal (ports & adapters), layered, по фічах чи по шарах
- Наявність `api/` модуля → API-first підхід
- Мультимодульність → межі bounded contexts

### Тести

- Співвідношення unit / integration / e2e → тестова піраміда
- Testcontainers → потрібен Docker, є інтеграційні тести
- Jacoco / Istanbul → coverage gate

### Конфігурації та інфраструктура

- `application.yml` / `application.properties` → БД, брокер, кеш
- `docker-compose.yml` → локальна інфраструктура
- `Dockerfile` / `k8s/` / `helm/` → модель деплою та контейнеризація

### CI/CD

- `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile` → платформа, стадії, environments
- Наявність автотестів та quality gates у pipeline

### Code style

- `.checkstyle.xml`, `.eslintrc`, `.prettierrc`, `spotbugs-exclude.xml` → конвенції форматування
- `sonar-project.properties` → SonarQube інтеграція

### Код

- Auth-механізм: JWT, session, OAuth (за анотаціями та залежностями)
- API стиль: REST, GraphQL, gRPC (за контролерами та залежностями)
- Logging framework та рівні логування

---

## Результат аудиту

### Наповнений CLAUDE.md

Замість заглушок — реальні дані: актуальний стек, команди збірки та тестування, виявлені конвенції комітів і гілок, заборонені операції (наприклад, не модифікувати існуючі Flyway-міграції).

### Ретроспективні ADR

Агент пропонує список архітектурних рішень, що вже були прийняті і можуть бути задокументовані:

- Вибір фреймворку (Spring Boot, FastAPI тощо)
- Стратегія міграцій БД (Flyway / Liquibase)
- Підхід до тестування (Testcontainers, піраміда)
- Event-driven архітектура (Kafka / RabbitMQ)
- Модель деплою (Docker, Kubernetes)

Статус таких ADR — одразу `Accepted` (рішення вже прийнято). Контекст реконструюється з коду, а не з пам'яті учасників.

Детальніше про формат: [Методологія ADR](ADR_Guide.md)

### Рекомендації щодо MCP

На основі виявленої інфраструктури агент пропонує конкретні MCP-сервери для `.mcp.json`: PostgreSQL, GitHub, Playwright тощо.

---

## Порядок аудиту

1. Git-аналіз: автори, коміти, гілки, теги
2. Build-файли: стек, залежності, плагіни
3. Структура директорій та архітектурний стиль
4. Конфіги: інфраструктура, CI/CD, code style
5. Вибірковий аналіз коду: auth, API, logging
6. Підсумок: що знайдено, що буде зроблено — **чекати підтвердження** перед записом файлів

---

## Зв'язок з іншими нотатками

- [☑️ Чеклист старту проєкту](Project_Startup_Checklist.md) — секція "Retrofit" посилається сюди
- [🚀 Bootstrap-команда /init-project](Project_Bootstrap_Command.md) — retrofit-сценарій команди
- [📐 Методологія ADR](ADR_Guide.md) — формат ретроспективних ADR
