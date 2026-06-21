[⬅️](qa_index.md)

## 📝 TL;DR

MCP сервер розміщується у `.mcp.json` з `${TOKEN}` env var expansion: конфігурація у git (шерується), credentials — локально у кожного розробника (не комітяться). Особистий `~/.claude.json` — не для командних серверів.

## Original

**Scenario:** A platform engineering team wants to share an MCP server for their internal ticketing system across all developers using Claude Code. The server requires an API token unique to each developer. Where should the MCP server be configured, and how should credentials be managed?

**A)** Have each developer add the server to their personal `~/.claude.json` with their API token

**B)** Create a shared `.env` file in the repository with all developer tokens and reference it from `.mcp.json`

**C)** Add the server to `.mcp.json` in the project root with each developer's API token hard-coded in the configuration

**D)** Add the server to `.mcp.json` in the project root using `${TICKETING_API_TOKEN}` environment variable expansion, so each developer sets their own token locally

## Питання

Команда платформних інженерів хоче поширити MCP сервер для внутрішньої ticketing системи між усіма розробниками. Сервер вимагає унікального API токену для кожного. Де налаштувати сервер і як керувати credentials?

**A)** Кожен розробник додає сервер до свого `~/.claude.json` зі своїм токеном

**B)** Створити shared `.env` файл у репозиторії з усіма токенами і посилатись на нього з `.mcp.json`

**C)** Додати сервер до `.mcp.json` у корені проєкту з hard-coded токеном кожного розробника

**D)** Додати сервер до `.mcp.json` у корені проєкту з `${TICKETING_API_TOKEN}` env var expansion — кожен розробник встановлює свій токен локально

## Правильна відповідь: D

## Аналіз варіантів

### D — Правильний

`.mcp.json` у корені проєкту версіонується і шерується між командою. `${TICKETING_API_TOKEN}` — env var expansion: Claude Code підставляє значення змінної з оточення розробника при запуску. Кожен налаштовує свій токен локально (`export TICKETING_API_TOKEN=...` або `.env`), у git не потрапляє.

### A — Хибний

`~/.claude.json` — глобальний особистий файл. Не пов'язаний з проєктом, не шерується. Кожен розробник мусить вручну знайти і додати конфігурацію.

### B — Хибний

Shared `.env` з усіма токенами у репо — security risk: усі токени відкриті усім. Не масштабується при зміні токенів.

### C — Хибний

Hard-coded токени у `.mcp.json` — security risk і не працює: токен розробника A не підходить для розробника B. Файл у git → токени у відкритому доступі.

## Ключові концепції

### Env var expansion у .mcp.json

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

Claude Code підставляє `${TICKETING_API_TOKEN}` зі змінних середовища розробника. Сам файл безпечно комітити — він містить лише назву змінної, не значення.

### Принцип розділення

| Що | Де зберігати |
| --- | --- |
| Конфігурація сервера (endpoint, команда) | `.mcp.json` у git |
| Credentials (токени, ключі) | Змінні середовища локально |

Правило: ніколи не комітити credentials у репо.

## Пов'язані нотатки

- [.mcp.json: розміщення конфігурації команди](d4_mcp_json_config.md) — де зберігати командну конфігурацію
- [Скіли, плагіни та MCP](../../Skills_and_MCP.md) — реєстрація через `.mcp.json`
- [Domain 4: Tool Design & MCP](../domain_4_mcp_tools.md)
