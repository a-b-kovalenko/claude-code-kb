[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Власний MCP-сервер — це спосіб дати агенту прямий доступ до вашої інфраструктури: прочитати реальну схему БД, заінспектувати Kafka-топіки, отримати дані з внутрішнього API. Замість того щоб вгадувати стан системи по коду, агент бачить живу реальність. Конфігурація для команди зберігається у `.mcp.json` у корені проєкту та комітиться в Git.

## Коли писати власний сервер?

Готові MCP-сервери (Postgres, GitHub, Kafka) покривають загальні випадки. Власний потрібен коли:

- Є внутрішній REST API або сервіс, якого немає у відкритому маркетплейсі.
- Потрібна бізнес-специфічна логіка: наприклад, "покажи всі Flyway-міграції, що стосуються таблиці X".
- Хочете об'єднати кілька джерел (БД + Kafka + Jira) в один контекстний інструмент.

## Три примітиви MCP

| Примітив | Що це | Приклад |
| :--- | :--- | :--- |
| **Tool** | Функція, яку агент може викликати | `get_table_schema(table_name)` |
| **Resource** | Дані, що агент може прочитати (URI-адресовані) | `db://schema/public` |
| **Prompt** | Готовий шаблон промпту для типових задач | "Explain this table structure" |

Для більшості backend-задач достатньо **Tools**.

## Транспорти

| Транспорт | Коли використовувати |
| :--- | :--- |
| **stdio** | Локальний сервер на машині розробника. Claude Code запускає процес сам. Простіше за все. |
| **SSE / HTTP** | Команда розробників або CI. Сервер запущений централізовано, підключається через URL. |

## Мінімальний приклад (TypeScript SDK)

TypeScript — найзріліший SDK для MCP. Встановлення:

```bash
npm install @modelcontextprotocol/sdk zod
```

Файл `src/index.ts`:

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { Pool } from "pg";

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const server = new McpServer({ name: "project-db", version: "1.0.0" });

server.tool(
  "get_table_columns",
  "Returns column names, types and constraints for a given table. Use before writing migrations or queries.",
  { table_name: z.string().describe("Table name in public schema") },
  async ({ table_name }) => {
    const res = await pool.query(
      `SELECT column_name, data_type, is_nullable, column_default
       FROM information_schema.columns
       WHERE table_schema = 'public' AND table_name = $1
       ORDER BY ordinal_position`,
      [table_name]
    );
    return {
      content: [{ type: "text", text: JSON.stringify(res.rows, null, 2) }],
    };
  }
);

const transport = new StdioServerTransport();
await server.connect(transport);
```

> **Примітка для Java-розробників:** офіційного Java SDK для MCP поки немає. Варіанти: TypeScript-обгортка над JDBC (як вище), або Python SDK (`mcp` пакет), або власний HTTP-сервер що реалізує MCP-протокол вручну.

## Реєстрація в Claude Code

MCP-сервери реєструються в одному з трьох скоупів:

| Скоуп | Де зберігається | Видимість |
| :--- | :--- | :--- |
| `local` *(за замовчуванням)* | `~/.claude.json` під ключем поточного проєкту | Тільки ви, тільки цей проєкт |
| `project` | `.mcp.json` у корені проєкту | Вся команда, комітити в Git |
| `user` | `~/.claude.json` на верхньому рівні | Тільки ви, всі проєкти |

> **Примітка:** `local` і `user` зберігаються в одному файлі `~/.claude.json`, але в різних місцях: `local` вкладений під `projects["/шлях/до/проєкту"]`, тому не зʼявляється в інших проєктах; `user` — на верхньому рівні та доступний скрізь.

### Через CLI (рекомендовано)

```bash
# project scope — потрапляє у .mcp.json у корені проєкту
claude mcp add --scope project --transport stdio project-db -- node dist/index.js

# із змінними середовища
claude mcp add --scope project --transport stdio project-db \
  --env DATABASE_URL=postgresql://readonly_user:pass@localhost:5432/mydb \
  -- node dist/index.js
```

### Або вручну у `.mcp.json` (project scope)

```json
{
  "mcpServers": {
    "project-db": {
      "command": "node",
      "args": ["dist/index.js"],
      "env": {
        "DATABASE_URL": "postgresql://readonly_user:pass@localhost:5432/mydb"
      }
    }
  }
}
```

Після збереження — перезапустіть Claude Code. Інструменти сервера стануть доступні агенту автоматично.

Для HTTP-транспорту замість `command`/`args` використовується:

```json
{
  "mcpServers": {
    "project-db": {
      "type": "http",
      "url": "http://mcp.internal:3000/mcp"
    }
  }
}
```

## Org-level MCP: спільний сервер для кількох проєктів

Нативного "організаційного" скоупу немає, але його можна емулювати через відносні шляхи у `.mcp.json`. Перевірено емпірично.

Структура:

```text
org/
├── mcp_server/          ← спільний MCP-сервер
│   └── dist/index.js
├── project1/
│   └── .mcp.json        ← відносний шлях "../mcp_server/..."
└── project2/
    └── .mcp.json        ← відносний шлях "../mcp_server/..."
```

`.mcp.json` у кожному проєкті:

```json
{
  "mcpServers": {
    "org-db": {
      "command": "node",
      "args": ["../mcp_server/dist/index.js"]
    }
  }
}
```

Кожен проєкт підхоплює один і той самий сервер. Оновлення сервера відразу діє на всі проєкти. Підходить для внутрішніх інструментів команди, де один MCP-сервер обслуговує кілька репозиторіїв.

## Практичний інструментарій для Spring Boot проєкту

Кілька корисних інструментів, які варто реалізувати:

```text
get_table_schema(table)      — схема таблиці: колонки, типи, constraints
get_flyway_history()         — список застосованих міграцій
get_kafka_topics()           — перелік топіків з partition count і retention
get_consumer_group_lag(group) — відставання consumer group по партиціям
get_api_endpoints()          — список REST-ендпоінтів (якщо є OpenAPI spec)
```

## Безпека

- Завжди використовуйте **read-only** облікові записи для підключення до БД і брокерів.
- Не передавайте секрети напряму в `args` — використовуйте `env` або змінні середовища з `.env.local`.
- MCP-сервер запускається з правами вашого користувача — аудитуйте код перед додаванням у проєкт командою.
- Фіксуйте проєктний сервер у Git (`.mcp.json` + вихідний код), щоб кожен розробник мав однакові інструменти.

## Зв'язок з іншими нотатками

- Огляд готових серверів та вибір між MCP/Skills/Rules: [🛠️ Скіли, плагіни та MCP](Skills_and_MCP.md).
- Захист від запису в БД на рівні хуків: [🛡️ Захисні хуки (Guardian)](Guardian_Hooks.md).
