# Changelog

Сесійний журнал змін бази знань. Один запис на сесію роботи.

---

## 2026-06-26

### Оновлено

**MCP-кластер (рефакторинг та розширення):**

- **[MCP — огляд та визначення](content/MCP_Overview.md)** — нова нотатка: визначення, три примітиви, три учасники; протокольна механіка (ListTools/CallTools, sequence diagram); session lifecycle caveat; stdio security note
- **[MCP vs Tool Use](content/MCP_vs_Tool_Use.md)** — нова нотатка порівняння; виправлено флоу (Claude Code як посередник, `query` без префіксу); security boundary; розширення Claude Code — тільки MCP; Java-аналогія → Feign/HttpURLConnection
- **[Розробка власного MCP-сервера](content/MCP_Server_Development.md)** — Spring AI MCP для Java (`@McpTool`); Python FastMCP (виправлено connection leak, LIMIT 100); org-level MCP патерн; tool annotations; MCP Inspector; скоупи (`local` як дефолт)
- **[Claude_Code_Knowledge_Base.md](Claude_Code_Knowledge_Base.md)** — нова секція `🔌 Розширення та інтеграції`; MCP, CI/CD, Playwright, Remote Control, Desktop App перенесено туди

**Нові нотатки:**

- **[Claude Code SDK](content/Claude_Code_SDK.md)** — програмний інтерфейс (CLI/TS/Python); кут зору архітектора команди
- **[REPL-шорткати](content/REPL_Shortcuts.md)** — префікси `#`, `@`, `!` та клавіші Escape, Double Escape, Shift+Tab, Ctrl+V
- **[Playwright MCP](content/Playwright_MCP.md)** — браузерна автоматизація, сценарії для Java команди

**Інші оновлення:**

- **[CI/CD інтеграція](content/CI_CD_Integration.md)** — GitHub App (`/install-github-app`, `claude-code-action@v1`, `@claude`), OIDC автентифікація
- **[Розробка власного хука](content/Hook_Development_Guide.md)** — security best practices (path traversal, quote variables, absolute paths)
- **[Написання CLAUDE.md](content/CLAUDE_md_Writing_Guide.md)** — три рівні CLAUDE.md
- **[Довідник команд](content/Commands_Reference.md)** — `/rewind`
- **[Agent View](content/Agents_View.md)** — зупинка агента через tasks panel тепер постійна

---
