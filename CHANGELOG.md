# Changelog

Сесійний журнал змін бази знань. Один запис на сесію роботи.

---

## 2026-06-25

### Додано

- **[MCP — огляд та визначення](content/MCP_Overview.md)** — нова нотатка: що таке MCP, три примітиви, три учасники, місце в Claude Code; точка входу в MCP-кластер
- **[MCP vs Tool Use](content/MCP_vs_Tool_Use.md)** — принципова різниця, ListToolsRequest/CallToolRequest, sequence diagram від Anthropic
- **[Claude Code SDK](content/Claude_Code_SDK.md)** — програмний інтерфейс (CLI/TS/Python), дозволи, формат виводу; розширено кутом зору архітектора команди
- **[REPL-шорткати](content/REPL_Shortcuts.md)** — префікси `#`, `@`, `!` та клавіші Escape, Double Escape, Shift+Tab, Ctrl+V з практичними сценаріями
- **[Playwright MCP](content/Playwright_MCP.md)** — браузерна автоматизація: встановлення, дозволи, сценарії для Java команди, trade-offs

### Оновлено

- **[MCP — огляд та визначення](content/MCP_Overview.md)** — додано протокольну механіку: ListToolsRequest/ListToolsResult, CallToolRequest/CallToolResult, sequence diagram від Anthropic
- **[MCP vs Tool Use](content/MCP_vs_Tool_Use.md)** — рефакторинг: порівняльна таблиця першою, протокольні деталі перенесено в Overview; нотатка зосереджена на порівнянні
- **[Довідник команд](content/Commands_Reference.md)** — додано `/rewind` (повернення до стану до останнього `/clear`)
- **[Agent View](content/Agents_View.md)** — додано зупинку агента в таблицю керування; примітка що зупинка через tasks panel тепер постійна
- **[Написання CLAUDE.md](content/CLAUDE_md_Writing_Guide.md)** — додано розділ про три рівні (`~/.claude/CLAUDE.md`, `CLAUDE.md`, `CLAUDE.local.md`)
- **[CI/CD інтеграція](content/CI_CD_Integration.md)** — офіційна GitHub App інтеграція (`/install-github-app`, `claude-code-action@v1`, `@claude` mentions), оновлено автентифікацію (Bedrock → OIDC, Vertex → Workload Identity)
- **[Розробка власного хука](content/Hook_Development_Guide.md)** — додано security best practices: validate inputs, quote variables, block path traversal, absolute paths, skip sensitive files
- **[Захисні хуки (Guardian)](content/Guardian_Hooks.md)** — додано перевірку path traversal у `flyway-guard.sh`
- **[scripts/flyway-guard.sh](content/scripts/flyway-guard.sh)** — те саме у реальному скрипті
- **README.md** — актуальна кількість нотаток (113), оновлена таблиця розділів і структура папок
- **[Claude_Code_Knowledge_Base.md](Claude_Code_Knowledge_Base.md)** — нова секція `🔌 Розширення та інтеграції`; MCP, CI/CD, Playwright, Remote Control, Desktop App перенесено туди; прибрано дублікат Headless Mode
- **[Скіли, плагіни та MCP](content/Skills_and_MCP.md)** — таблиця скоупів: `local` переміщено першим як дефолтний
- **[Розробка власного MCP-сервера](content/MCP_Server_Development.md)** — таблиця скоупів оновлена; додано секцію "Org-level MCP" (спільний сервер через відносні шляхи, перевірено емпірично)
- **[Довідник команд](content/Commands_Reference.md)** — додано `/rewind`
- **[Agent View](content/Agents_View.md)** — зупинка агента через tasks panel тепер постійна
