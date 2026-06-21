[⬅️](qa_index.md)

## 📝 TL;DR

`.mcp.json` у корені проєкту — єдине правильне місце для командної конфігурації MCP серверів: версіонується через git, клонується автоматично. Персональні credentials — через змінні середовища (`${TOKEN}`), не хардкодом. Особисті сервери — у `~/.claude.json`.

## Original

**Scenario A (Q3):** A platform engineering team wants to share an MCP server for their internal ticketing system across all developers using Claude Code. The server requires an API token unique to each developer. Where should the MCP server be configured, and how should credentials be managed?

**A)** Have each developer add the server to their personal `~/.claude.json` with their API token

**B)** Create a shared `.env` file in the repository with all developer tokens and reference it from `.mcp.json`

**C)** Add the server to `.mcp.json` in the project root with each developer's API token hard-coded in the configuration

**D)** Add the server to `.mcp.json` in the project root using `${TICKETING_API_TOKEN}` environment variable expansion, so each developer sets their own token locally

---

**Scenario B (Q23):** Where should a team-wide MCP server configuration be placed so that it is version-controlled and shared across all developers on the project?

**A)** In environment variables set on each developer's machine

**B)** In the project's `.mcp.json` file, committed to the repository

**C)** In `~/.claude.json` in each developer's home directory

**D)** In the system prompt, as an inline JSON block that defines the server connection

## Питання

**Сценарій A:** Команда платформних інженерів хоче поділитися MCP сервером для внутрішньої ticketing системи між усіма розробниками. Сервер вимагає унікального API токену для кожного. Де налаштувати сервер і як керувати credentials?

**D)** Додати сервер до `.mcp.json` у корені проєкту з `${TICKETING_API_TOKEN}` — кожен розробник встановлює свій токен локально ✓

---

**Сценарій B:** Де розмістити командну конфігурацію MCP сервера щоб вона версіонувалась і шерувалась між розробниками?

**B)** У файлі `.mcp.json` проєкту, закомічений у репозиторій ✓

## Правильна відповідь: D (Q3), B (Q23)

## Аналіз варіантів

### Q3 — правильна відповідь D

`.mcp.json` у корені проєкту версіонується і шерується (Q23 теж підтверджує). Env var expansion `${TICKETING_API_TOKEN}` дозволяє кожному розробнику зберігати свій токен локально (`.env` або змінні ОС) без його присутності у git. Особистий `~/.claude.json` (A) не шерується. Shared `.env` з усіма токенами (B) — security risk і не масштабується. Hard-coded токени (C) — security risk, ламається у кожного іншого розробника.

### Q23 — правильна відповідь B

`.mcp.json` — офіційний файл конфігурації MCP для Claude Code. Зберігається в репо → автоматично доступний після `git clone`. Змінні середовища на машині (A) не версіонуються і не описують конфігурацію сервера. `~/.claude.json` (C) — особистий, не шерується. System prompt (D) — не місце для конфігурації серверів.

## Ключові концепції

### .mcp.json з env var expansion

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

Файл у git — конфігурація сервера. Токен — у локальному `.env` або `export TICKETING_API_TOKEN=...` в shell. Розробник B клонує репо → налаштовує свою змінну → MCP сервер доступний.

### Де зберігати MCP конфігурацію

| Файл | Scope | Шерується? |
| --- | --- | --- |
| `.mcp.json` (project root) | Проєктний | Так (git) |
| `~/.claude.json` | Глобальний | Ні |
| `.mcp.json` (local scope) | Проєктний, ігнорується git | Ні |

### Принцип розділення

Конфігурація сервера (endpoint, команда, параметри) → `.mcp.json` у git.
Credentials (токени, ключі) → змінні середовища локально.
Ніколи не комітити credentials у репо.

## Пов'язані нотатки

- [Скіли, плагіни та MCP](../../Skills_and_MCP.md) — реєстрація через `.mcp.json`
- [Розробка власного MCP-сервера](../../MCP_Server_Development.md) — TypeScript SDK, scopes
- [Domain 4: Tool Design & MCP](../domain_4_mcp_tools.md)
