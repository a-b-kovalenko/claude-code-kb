[⬅️](qa_index.md)

## 📝 TL;DR

`.mcp.json` у корені проєкту — єдине правильне місце для командної конфігурації MCP серверів: версіонується через git і автоматично доступний після `git clone`. Особисті сервери — у `~/.claude.json`.

## Original

**Question:** Where should a team-wide MCP server configuration be placed so that it is version-controlled and shared across all developers on the project?

**A)** In environment variables set on each developer's machine

**B)** In the project's `.mcp.json` file, committed to the repository

**C)** In `~/.claude.json` in each developer's home directory

**D)** In the system prompt, as an inline JSON block that defines the server connection

## Питання

Де розмістити командну конфігурацію MCP сервера щоб вона версіонувалась і шерувалась між усіма розробниками проєкту?

**A)** У змінних середовища на машині кожного розробника

**B)** У файлі `.mcp.json` проєкту, закомічений у репозиторій

**C)** У `~/.claude.json` у домашньому каталозі кожного розробника

**D)** У system prompt, як inline JSON блок що визначає підключення до сервера

## Правильна відповідь: B

## Аналіз варіантів

### B — Правильний

`.mcp.json` — офіційний файл конфігурації MCP для Claude Code. Зберігається в репо → автоматично доступний після `git clone`. Уся команда отримує однакову конфігурацію без ручного налаштування.

### A — Хибний

Змінні середовища на машині зберігають credentials, але не описують конфігурацію сервера. Не версіонуються, не шеруються.

### C — Хибний

`~/.claude.json` — глобальний особистий файл. Не пов'язаний з репозиторієм, не версіонується, у кожного розробника свій.

### D — Хибний

System prompt — для інструкцій моделі, не для конфігурації інфраструктури. MCP сервер — окрема служба, не частина промпту.

## Ключові концепції

### Де зберігати MCP конфігурацію

| Файл | Scope | Версіонується? | Шерується? |
| --- | --- | --- | --- |
| `.mcp.json` (project root) | Проєктний | Так (git) | Так |
| `~/.claude.json` | Глобальний | Ні | Ні |
| `.mcp.json` (local scope) | Проєктний | Ні (gitignore) | Ні |

### Структура .mcp.json

```json
{
  "mcpServers": {
    "ticketing": {
      "command": "node",
      "args": ["./mcp-servers/ticketing/index.js"],
      "env": {
        "TICKETING_API_TOKEN": "${TICKETING_API_TOKEN}"
      }
    }
  }
}
```

Конфігурація сервера (команда, аргументи) — у git. Credentials — через env var (детальніше: [.mcp.json: credentials через env var](d4_mcp_credentials_env_var.md)).

## Пов'язані нотатки

- [.mcp.json: credentials через env var](d4_mcp_credentials_env_var.md) — `${TOKEN}` expansion для персональних токенів
- [Скіли, плагіни та MCP](../../Skills_and_MCP.md) — реєстрація через `.mcp.json`
- [Розробка власного MCP-сервера](../../MCP_Server_Development.md) — TypeScript SDK, scopes
- [Domain 4: Tool Design & MCP](../domain_4_mcp_tools.md)
