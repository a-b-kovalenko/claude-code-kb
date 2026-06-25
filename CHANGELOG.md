# Changelog

Сесійний журнал змін бази знань. Один запис на сесію роботи.

---

## 2026-06-25

### Додано

- **[Claude Code SDK](content/Claude_Code_SDK.md)** — програмний інтерфейс (CLI/TS/Python), дозволи, формат виводу; розширено кутом зору архітектора команди
- **[REPL-шорткати](content/REPL_Shortcuts.md)** — префікси `#`, `@`, `!` та клавіші Escape, Double Escape, Shift+Tab, Ctrl+V з практичними сценаріями
- **[Playwright MCP](content/Playwright_MCP.md)** — браузерна автоматизація: встановлення, дозволи, сценарії для Java команди, trade-offs

### Оновлено

- **[Написання CLAUDE.md](content/CLAUDE_md_Writing_Guide.md)** — додано розділ про три рівні (`~/.claude/CLAUDE.md`, `CLAUDE.md`, `CLAUDE.local.md`)
- **[CI/CD інтеграція](content/CI_CD_Integration.md)** — офіційна GitHub App інтеграція (`/install-github-app`, `claude-code-action@v1`, `@claude` mentions), оновлено автентифікацію (Bedrock → OIDC, Vertex → Workload Identity)
- **[Розробка власного хука](content/Hook_Development_Guide.md)** — додано security best practices: validate inputs, quote variables, block path traversal, absolute paths, skip sensitive files
- **[Захисні хуки (Guardian)](content/Guardian_Hooks.md)** — додано перевірку path traversal у `flyway-guard.sh`
- **[scripts/flyway-guard.sh](content/scripts/flyway-guard.sh)** — те саме у реальному скрипті
- **README.md** — актуальна кількість нотаток (113), оновлена таблиця розділів і структура папок
