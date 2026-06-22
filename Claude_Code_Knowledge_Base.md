## 📝 TL;DR

Це центральний вузол бази знань. Тут зібрані всі стандарти: від філософії агентської розробки до конкретних технічних скриптів захисту та конвенцій тестування.

## 🚀 Швидкий старт (Workflow)

Для ефективної роботи з агентом рекомендується дотримуватися такого порядку:

0. **Підготовка:** Пройдіть [чеклист перед задачею](content/Pre_Task_Checklist.md) — CLAUDE.md, git, scope, критерій Done.
1. **Дослідження:** Використовуйте [субагента Explorer](content/Subagents_Architecture.md) для вивчення коду.
2. **Планування:** Складіть план у [Plan Mode](content/Planning_and_Tasks.md).
3. **Реалізація:** Дотримуйтесь [технічних стандартів](content/Spring_Boot_Testing.md) та використовуйте [скіли](content/Skills_and_MCP.md).
4. **Верифікація:** Замкніть [цикл перевірки](content/Agentic_Verification_Loop.md) перед комітом.

---

## 🏗️ Структура бази знань

### 🤖 Методологія Agentry

*Основи взаємодії з AI-агентами та управління процесами.*

- [🤖 Основи агентської розробки](content/Agentry_Basics.md) — Що таке агентність та різниця між API та CLI.
- [🖥️ IDE інтеграції](content/IDE_Integrations.md) — VS Code та JetBrains: inline diff, діагностика, getDiagnostics MCP, коли CLI краще.
- [🧠 Extended Thinking та /think](content/Extended_Thinking.md) — Глибше міркування для складних рішень: коли вмикати і як не переплачувати.
- [📅 Планування та Tasks API](content/Planning_and_Tasks.md) — Як не дати агенту "заблукати" у складних задачах.
- [👥 Архітектура субагентів](content/Subagents_Architecture.md) — Розподіл ролей: Explorer, Runner, Reviewer.
- [🤖 Вбудовані агенти](content/Builtin_Agents.md) — Explore, Plan, general-purpose: коли спрацьовують автоматично та чим відрізняються.
- [🖥️ Headless Mode](content/Headless_Mode.md) — Запуск без REPL: `--print`, ключові прапори, одна задача — один процес, захист від нескінченних циклів.

### 💡 Кращі практики

*Як працювати з агентом ефективно: workflow, помилки, промпти.*

- [🏆 Золотий workflow](content/Golden_Workflow.md) — Наскрізний приклад ефективної сесії: Explore → Plan → Implement → Verify → Commit.
- [🚫 Антипатерни](content/Anti_Patterns.md) — Вісім найпоширеніших помилок при роботі з Claude Code: симптом, причина, виправлення.
- [✍️ Ефективні промпти](content/Effective_Prompting.md) — Шість правил формулювання запитів: scope, constraints, критерій Done, шаблони.
- [☑️ Чеклист перед задачею](content/Pre_Task_Checklist.md) — Шість питань перед стартом агента: CLAUDE.md, git, scope, Done, Flyway, ризики.

### 🔬 Субагенти та оркестрація

*Готові приклади агентів та інструменти для складних сценаріїв.*

- [🔍 Приклад субагента: Explorer](content/Explorer_Subagent_Example.md) — Готовий файл агента з system prompt для Spring Boot проєкту.
- [🧪 Приклад субагента: Test-runner](content/Test_Runner_Subagent_Example.md) — Запуск тестів, аналіз стектрейсів та діагностика без права на зміну коду.
- [⚖️ Приклад субагента: Reviewer](content/Reviewer_Subagent_Example.md) — Перевірка diff перед комітом: архітектура, тести, CLAUDE.md. Вердикт APPROVE/REJECT.
- [⚡ Кастомні Slash-команди](content/Custom_Slash_Commands.md) — Збережені prompt-шаблони для повторюваних задач.
- [📖 Довідник команд](content/Commands_Reference.md) — Всі вбудовані команди і скіли: що робить, коли використовувати, де деталі.
- [⚡ Паралельні субагенти](content/Parallel_Subagents.md) — Одночасний запуск кількох Task-викликів: коли виграє час, коли створює конфлікти.
- [🌿 Worktree Isolation](content/Worktree_Isolation.md) — Ізольований запуск субагента у відгалуженій копії репо: lifecycle, злиття результату, коли варто.
- [🔀 Динамічна оркестрація субагентів](content/Dynamic_Orchestration.md) — Оркестратор вирішує наступний крок за результатом: розгалуження, retry loop, адаптивний паралелізм.
- [⚙️ Claude Code Dynamic Workflows](content/Claude_Code_Dynamic_Workflows.md) — Офіційна фіча (research preview): Claude генерує JS-скрипт і запускає сотні субагентів поза сесією.
- [🔁 Loop Engineering](content/Loop_Engineering.md) — 14-крокова рамка переходу від ручного промптингу до автономних циклів: 4-умовний тест, 5 блоків, failure modes.
- [🖥️ Agent View](content/Agents_View.md) — `claude agents`: dashboard фонових сесій, стани, peek, диспатч, ізоляція через worktrees.

### 🧠 Контекст та Пам'ять

*Як ми навчаємо агента знанням про наш проєкт.*

- [🗂️ Ієрархія артефактів проєкту](content/Project_Artifacts_Hierarchy.md) — Повна схема папок: CLAUDE.md, .mcp.json, rules, skills, agents, hooks, commands, settings.json.
- [🧠 Ієрархія пам'яті та синтез](content/Memory_Hierarchy_and_Synthesis.md) — CLAUDE.md та патерн компіляції знань Карпаті.
- [💾 Auto-memory система](content/Auto_Memory_System.md) — Файлова структура, чотири типи пам'яті, формат файлів та що не варто зберігати.
- [🪟 Контекстне вікно та /compact](content/Context_Window_Management.md) — Lost in the Middle, ручне стиснення, PreCompact хук та стратегії керування.
- [🔢 Токени та токенізація](content/Tokens_and_Tokenization.md) — що таке токен, BPE, порівняння англійської та української, практичні наслідки для вартості та контексту.
- [💰 Вибір моделі та оптимізація вартості](content/Model_Selection_and_Cost.md) — Haiku/Sonnet/Opus по задачах, налаштування, стратегії економії, підписка vs API.
- [📄 Написання CLAUDE.md](content/CLAUDE_md_Writing_Guide.md) — Структура, шаблон та правила ефективного контракту з агентом.
- [🛠️ Скіли, плагіни та MCP](content/Skills_and_MCP.md) — Надання агенту експертних знань та доступу до БД; реєстрація серверів через `.mcp.json`.
- [✍️ Розробка власного скіла](content/Skill_Development_Guide.md) — Анатомія скіл-файлу, приклад JPA-скіла та правила написання ефективної експертизи.
- [📦 Плагіни](content/Plugins.md) — Упаковка skills+agents+hooks у директорій для шерингу: standalone vs плагін, маніфест, маркетплейси.
- [🔌 Розробка власного MCP-сервера](content/MCP_Server_Development.md) — TypeScript SDK, реєстрація через `.mcp.json` (скоупи project/local/user), практичні інструменти для Spring Boot.
- [🌐 Code RAG та Knowledge Graph](content/Code_RAG_Knowledge_Graph.md) — Робота з великими монорепозиторіями через семантичний та графовий пошук.

### 🧪 Інженерна якість

*Технічні стандарти та гарантії стабільності коду.*

- [🔄 Верифікаційний цикл](content/Agentic_Verification_Loop.md) — Швидкий зворотний зв'язок як основа якості.
- [🧪 Тестування Spring Boot](content/Spring_Boot_Testing.md) — Testcontainers, AssertJ та робота з Kafka.
- [🌿 Git та PR Workflow](content/Git_PR_Workflow.md) — Чиста git-історія, коміт-конвенції та відкриття PR через агента.

### 🛡️ Інфраструктура та Безпека

*Автоматизовані засоби контролю та захисту.*

- [⚙️ Конфігурація settings.json](content/Settings_JSON_Guide.md) — Дозволи інструментів (allow/deny), змінні середовища та модель за замовчуванням.
- [🔐 Оптимізація дозволів](content/Permissions_Optimization.md) — `/fewer-permission-prompts`, glob-синтаксис, tools у субагентах, workflow мінімізації запитів.
- [🛡️ Захисні хуки (Guardian)](content/Guardian_Hooks.md) — Bash-guard, Flyway-guard та авто-форматування.
- [🔧 Розробка власного хука](content/Hook_Development_Guide.md) — Анатомія хука, stdin JSON, exit-коди, зворотний зв'язок та практичні приклади.
- [📋 MD Lint Hook](content/MD_Lint_Hook.md) — PostToolUse-хук для автоматичної перевірки markdown: конфіг, скрипт та відома поведінка.
- [🛑 Stop Hook](content/Stop_Hook.md) — Хук на завершення відповіді: сповіщення, нагадування, примусове продовження через exit 2.
- [🖥️ Headless Mode](content/Headless_Mode.md) — Запуск без REPL: `--print`, ключові прапори, одна задача — один процес, захист від нескінченних циклів.
- [⚙️ CI/CD інтеграція](content/CI_CD_Integration.md) — GitHub Actions, автентифікація через API key, prompt injection, управління вартістю.
- [📱 Remote Control](content/Remote_Control.md) — Продовження локальної сесії з телефону або браузера: QR-код, push-нотифікації, вимоги до плану.
- [🖥️ Desktop App](content/Desktop_App.md) — Нативний додаток: паралельні сесії з worktree, diff-рев'ю, PR моніторинг, вбудований браузер, Dispatch з телефону.

### 🏁 Старт проєкту

- [☑️ Чеклист старту проєкту](content/Project_Startup_Checklist.md) — Git, CLAUDE.md, Claude Code config, ADR, Antora: що налаштувати перед першим коммітом.
- [📐 ADR — Architecture Decision Records](content/ADR_Guide.md) — Шаблон, статуси, нумерація та інтеграція з Antora.
- [🔍 Аудит існуючого проєкту](content/Project_Audit_Guide.md) — Реконструкція контексту з git-історії та кодової бази: CLAUDE.md, ретроспективні ADR, MCP.
- [🚀 Bootstrap-команда /init-project](content/Project_Bootstrap_Command.md) — Slash-команда з плейсхолдерами: запускаєш у новій папці — отримуєш готовий проєкт.

### 🌐 Claude API

*Механіки API для CCA-F: tool use, prompt caching, batch processing.*

- [🌐 Claude API — Огляд та навігація](content/claude_api/Claude_API.md) — tool use, prompt caching, Batch API для доменів 3 і 4 іспиту CCA-F.

### 🎓 Підготовка до сертифікації CCA-F

*Claude Certified Architect – Foundations: теорія, failure patterns і питання для самоперевірки.*

- [🎓 CCA-F: Огляд та навігація](content/cca/CCA_Foundations.md) — Параметри іспиту, таблиця доменів, посилання на всі нотатки розділу.

---

[📝 CLAUDE.md](CLAUDE.md) — Правила ведення цієї бази знань.
