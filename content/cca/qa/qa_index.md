[⬅️](../CCA_Foundations.md)

## 📝 TL;DR

Розбір реальних питань іспиту CCA-F: кожна нотатка — одне питання з аналізом усіх варіантів, правильною відповіддю і посиланнями на теоретичні нотатки доменів.

## Патерни у питаннях

### Повторювані правильні відповіді

**Code-level > model-level** — 4 з 10 питань тестують одну ідею: якщо потрібна гарантія, рішення приймає код, а не модель. Хибні варіанти завжди пропонують промпт, few-shot або інструкцію — тобто залишають рішення моделі.

- [Guardrails](d1_deterministic_guardrails.md): compliance-правило ($500 → ескалація) не можна залишати моделі. Хук перехоплює tool call до виконання — модель навіть не отримує шанс "вирішити". Хибні варіанти: emphatic промпт ("NEVER!"), few-shot приклади — все це модельна дискреція.
- [Tool schema](d4_structured_output_tool_schema.md): відповідність JSON-схемі гарантує не інструкція в промпті, а механізм tool use на рівні API. Модель конструює аргументи під схему — не "намагається" вивести JSON. Хибні варіанти: regex парсинг, детальні інструкції у промпті — покладаються на модель.
- [MCP errors](d4_mcp_error_handling.md): тип помилки визначається на рівні протоколу (чи міг інструмент запуститись?), а не модельним рішенням. Хибні варіанти: всі помилки через `isError: true` — скидають рішення на модель.
- [Structured errors](d4_tool_error_design.md): поле `retriable` у відповіді інструменту — детермінований сигнал що усуває потребу моделі "здогадуватись" чи робити retry. Хибні варіанти: few-shot для розпізнавання помилок — знову модельна дискреція.

Сигнал у формулюванні питання: "guaranteed", "cannot be left to model discretion", "reliable", "consistent".

**Класифікуй перед дією** — три питання реалізують один і той самий двофазний патерн: спочатку аналізуй/класифікуй вхідні дані, потім обирай стратегію. Уніформна обробка без класифікації — завжди хибний варіант.

- [Batch strategy](d4_batch_api_strategy.md): класифікація за якістю промптів — спочатку валідуй на 1 000 зразках (real-time), виявляй патерни помилок, лише потім відправляй 50 000 (batch). Хибні варіанти пропускають фазу валідації і одразу batch всього.
- [Routing](d4_batch_vs_realtime_routing.md): класифікація за latency-вимогами — термінові документи (SLA 30 хв) → real-time, стандартні → batch. Хибні варіанти застосовують один API до всіх документів, ігноруючи різницю у вимогах.
- [Context management](d5_context_management_hybrid.md): класифікація за типом інформації — критичні дані (алергії, виміри) → зберігати точно, загальний діалог → резюмувати, останній обмін → verbatim. Хибні варіанти застосовують одну стратегію до всього контексту.

Спільний принцип: перед дією завжди є питання "що це таке?" — і відповідь на нього визначає стратегію.

**Структурний сигнал > парсинг тексту** — `retriable`, `isError`, tool schema. Якщо відповідь пропонує "парсити текст помилки" або "few-shot для розпізнавання" — це дистрактор.

### Повторювані пастки у дистракторах

| Пастка | Як виглядає | Чому хибна |
| --- | --- | --- |
| Prompt замість коду | "Додай інструкцію в промпт", "CAPS і NEVER" | Залишає модельну дискрецію |
| Хибний діагноз | "Перейди на сильнішу модель" | Проблема не в потужності, а в форматі |
| Зайвий pre-check | "Додай інструмент перевірки перед дією" | Overhead на happy path, не вирішує корінь |
| Уніформність | "Відправляй все через один API" | Ігнорує різні вимоги різних типів даних |

## Оцінка якості питань

Питання тестують принципи і практичне мислення, а не зубріння. Дистрактори plausible — промахуються по одному ключовому пункту, що є ознакою якісного дизайну.

**Найсильніше питання** — [Детерміновані guardrails](d1_deterministic_guardrails.md): формулювання "cannot be left to model discretion" елегантно сигналізує правильну відповідь тим хто розуміє різницю між instruction і enforcement.

**Де можна посперечатись:**

- [Few-shot для послідовної екстракції](d3_few_shot_extraction_consistency.md) — temperature=0 теж впливає на послідовність, варіант C не настільки очевидно хибний.
- [MCP error handling](d4_mcp_error_handling.md) — вимагає знання специфіки протоколу більше ніж reasoning; ближче до "зубріння".

## Питання за доменами

### Domain 1 · Agentic AI (22%)

| Нотатка | Тема |
| --- | --- |
| [Наступний крок в agentic loop](d1_agentic_loop_next_tool.md) | Як модель вирішує який інструмент викликати далі |
| [Детерміновані guardrails](d1_deterministic_guardrails.md) | Compliance-правила через хуки, а не промпти |
| [Multi-pass code review](d1_multi_pass_review.md) | Focused passes замість single-pass по 14 файлах |
| [Prerequisite gate](d1_prerequisite_gate.md) | Programmatic блокування process_refund до верифікації |
| [Hub-and-spoke оркестрація](d1_hub_spoke_orchestration.md) | Вся комунікація через координатор, субагенти ніколи напряму |
| [Session management](d1_session_management.md) | Нова сесія + summary injection замість забрудненого контексту |
| [PreToolUse hook: людське затвердження](d1_pretooluse_human_approval.md) | Незворотні дії — hook до виконання, не після |
| [PostToolUse hook: нормалізація дат](d1_posttooluse_normalization.md) | Нормалізація різних форматів від backend до ISO 8601 |

### Domain 2 · Claude Code Workflows (20%)

| Нотатка | Тема |
| --- | --- |
| [allowedTools для обмеження файлів](d2_allowed_tools_restriction.md) | Whitelist інструментів і glob-паттерни vs CLAUDE.md правила |
| [--output-format у CI/CD](d2_output_format_flag.md) | JSON stdout для програмного парсингу пайплайном |
| [Ієрархія CLAUDE.md](d2_claude_md_hierarchy.md) | User-level vs project-level: командні конвенції — тільки в репо |
| [Skill context:fork](d2_skill_context_fork.md) | .claude/skills/ + context:fork = shared + ізольований вивід |

### Domain 3 · Prompt Engineering (20%)

| Нотатка | Тема |
| --- | --- |
| [Стратегія batch processing](d4_batch_api_strategy.md) | Batch API vs real-time: cost-efficiency при дедлайні |
| [Few-shot для послідовної екстракції](d3_few_shot_extraction_consistency.md) | Непослідовне поле — few-shot, не зміна моделі |
| [Prompt cache: статичне першим](d3_prompt_cache_static_first.md) | Static before dynamic — незмінний контент на початку |
| [Prompt cache: cache\_control breakpoint](d3_prompt_cache_breakpoint.md) | 12k статичний system prompt + breakpoint = економія для 500 запитів/год |
| [Конкретні приклади vs прозові описи](d3_concrete_examples_severity.md) | Приклади коду для калібрації severity — не prose definitions |

### Domain 4 · Tool Design & MCP (18%)

| Нотатка | Тема |
| --- | --- |
| [Стратегія batch processing](d4_batch_api_strategy.md) | Batch API vs real-time: cost-efficiency при дедлайні |
| [Hybrid routing: Batch vs real-time](d4_batch_vs_realtime_routing.md) | Маршрутизація за latency-вимогами для різних типів документів |
| [Structured output через tool schema](d4_structured_output_tool_schema.md) | Tool use як надійний механізм екстракції структурованих даних |
| [Дизайн помилок інструментів](d4_tool_error_design.md) | Structured errors з `retriable` усувають марні retries агента |
| [MCP error handling](d4_mcp_error_handling.md) | Protocol errors vs tool result `isError: true` — два рівні помилок |
| [Tool description: SQL діалект](d4_tool_description_dialect.md) | Розширений опис з діалектом і прикладами — агент генерує правильний SQL |
| [.mcp.json: розміщення конфігурації команди](d4_mcp_json_config.md) | Project root .mcp.json в git — версіоноване і автоматично доступне |
| [.mcp.json: credentials через env var](d4_mcp_credentials_env_var.md) | `${TOKEN}` expansion — config в git, токен локально |
| [Scoped tool для субагента](d4_scoped_tool_subagent.md) | verify_fact у субагента усуває 85% round trips до координатора |
| [Розбиття інструменту на цільові](d4_tool_splitting.md) | analyze_content → extract_web/parse_doc/analyze_code |
| [Nullable fields у schema](d4_nullable_fields_schema.md) | Required поля тиснуть на fabrication — nullable дозволяє null |

### Domain 5 · Context & Memory (15%)

| Нотатка | Тема |
| --- | --- |
| [Гібридне управління контекстом](d5_context_management_hybrid.md) | Різні стратегії для різних типів інформації при скороченні токенів |
| [Prompt versioning для multi-session](d5_prompt_versioning_sessions.md) | Оновлення промпту не ламає активні розмови — тільки нові |
| [Context degradation: термін і мітигація](d5_context_degradation.md) | Термін + scratchpad та субагенти як профілактика |
| [Context degradation: /compact як втручання](d5_context_compact_intervention.md) | /compact з focus інструкціями для деградованої сесії |
| [Provenance metadata](d5_provenance_metadata.md) | Джерело + часовий період + timestamp — обов'язкова тріада |
| [Калібрація confidence per field type](d5_confidence_calibration.md) | Єдиний поріг не враховує різну кореляцію confidence і accuracy |
