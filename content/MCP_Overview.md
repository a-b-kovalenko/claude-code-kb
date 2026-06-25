[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

MCP (Model Context Protocol) — відкритий протокол від Anthropic, що стандартизує як зовнішні системи надають інструменти AI-клієнтам. Замість того щоб Claude вгадував стан вашої інфраструктури по коду, MCP дає йому прямий доступ до реальних даних: схем БД, Kafka-топіків, GitHub Issues.

## Що таке MCP

MCP вирішує одну проблему: Claude знає лише те, що є в контексті. Без MCP агент читає код і робить припущення про схему БД чи формат повідомлень. З MCP — запитує живу систему напряму.

Протокол визначає стандартний спосіб:

- оголосити що вміє зовнішня система (три примітиви)
- підключити її до будь-якого MCP-сумісного клієнта
- викликати інструменти з гарантованим контрактом

MCP — не продукт Anthropic, а відкритий стандарт. Його підтримують Claude Code, Cursor, Cline та інші AI-клієнти.

## Три примітиви

| Примітив | Що це | Приклад |
| :--- | :--- | :--- |
| **Tool** | Функція, яку агент може викликати | `get_table_schema(table_name)` |
| **Resource** | Дані, що агент може прочитати (URI-адресовані) | `db://schema/public` |
| **Prompt** | Готовий шаблон для типових задач | "Explain this table structure" |

Для більшості backend-задач достатньо **Tools**.

## Три учасники

| Учасник        | Роль                                                                                |
| :------------- | :---------------------------------------------------------------------------------- |
| **Host**       | Середовище, що запускає AI-клієнт (наприклад, Claude Code, IDE)                     |
| **MCP Client** | Компонент всередині Host, що підключається до серверів і передає інструменти моделі |
| **MCP Server** | Окремий процес із набором інструментів (Postgres, GitHub, ваш власний)              |

У контексті Claude Code: Host і MCP Client — це сам Claude Code; MCP Server — зовнішній процес, який ви реєструєте.

## MCP у Claude Code

Claude Code має два шари інструментів:

- **Вбудовані** (`Read`, `Edit`, `Bash`, `WebSearch` тощо) — реалізовані як tool use всередині самого Claude Code.
- **Зовнішні** — підключаються через MCP-сервери: PostgreSQL, GitHub, Playwright або ваш власний сервер для внутрішніх систем.

Реєстрація — у `.mcp.json` у корені проєкту (для всієї команди) або в `~/.claude.json` (особисті).

## Протокол: як MCP працює під капотом

При підключенні між MCP Client і MCP Server відбуваються два типи запитів.

### Discovery: ListToolsRequest / ListToolsResult

При старті сесії Claude Code надсилає `ListToolsRequest`. Сервер відповідає `ListToolsResult` з масивом інструментів і JSON-схемами:

```json
{
  "tools": [
    {
      "name": "query",
      "description": "Run a SQL query against the database",
      "inputSchema": {
        "type": "object",
        "properties": {
          "sql": { "type": "string" }
        },
        "required": ["sql"]
      }
    }
  ]
}
```

Discovery відбувається один раз при старті сесії — не при кожному виклику.

### Execution: CallToolRequest / CallToolResult

Коли Claude вирішує використати інструмент, надсилається `CallToolRequest`:

```json
{
  "name": "query",
  "arguments": {
    "sql": "SELECT * FROM orders WHERE status = 'pending'"
  }
}
```

Сервер виконує дію і повертає `CallToolResult`:

```json
{
  "content": [
    {
      "type": "text",
      "text": "3 rows returned:\n| id | customer | amount |\n..."
    }
  ],
  "isError": false
}
```

`content` може бути кількох типів:

| Тип | Коли використовується |
| :--- | :--- |
| `text` | Текстовий результат (SQL-рядки, логи) |
| `image` | Base64-зображення (Playwright скріншот) |
| `resource` | Вбудований ресурс (файл, URL) |

`isError: true` — інструмент виконався, але повернув помилку. Відрізняється від протокольної помилки з'єднання.

### Повний цикл

```text
Старт сесії:  ListToolsRequest  →  ListToolsResult   (discovery)
Виклик:       CallToolRequest   →  CallToolResult    (execution)
```

### Sequence diagram (Anthropic)

![MCP flow sequence](assets/mcp_flow_sequence.png)

Шість учасників на прикладі "які у мене репозиторії?":

| Крок | Від | До | Повідомлення |
| :--- | :--- | :--- | :--- |
| 1 | User | Our Server | Запит користувача |
| 2 | Our Server (MCP Client) | MCP Server | `ListToolsRequest` |
| 3 | MCP Server | Our Server | `ListToolsResult` — схеми інструментів |
| 4 | Our Server | Claude | `Query + Tools` — запит з переліком інструментів |
| 5 | Claude | Our Server | `ToolUse` — рішення викликати GitHub-інструмент |
| 6 | Our Server | MCP Server | `CallToolRequest` |
| 7 | MCP Server | GitHub | Реальний HTTP-запит до API |
| 8 | MCP Server | Our Server | `CallToolResult` — дані репозиторіїв |
| 9 | Our Server | Claude | `toolResult` — результат передається моделі |
| 10 | Claude | User | Фінальна відповідь "Your repositories are..." |

**Ключове:** Claude ніколи не звертається до GitHub напряму. Він повертає `ToolUse` блок — рішення що викликати. Реальний запит робить MCP-сервер.

## Навігація по MCP-кластеру

- Принципова різниця MCP і tool use: [⚖️ MCP vs Tool Use](MCP_vs_Tool_Use.md)
- Написати власний сервер: [🔌 Розробка власного MCP-сервера](MCP_Server_Development.md)
- Браузерна автоматизація: [🎭 Playwright MCP](Playwright_MCP.md)
- Скіли, плагіни та вибір між MCP/Skills/Rules: [🛠️ Скіли, плагіни та MCP](Skills_and_MCP.md)
