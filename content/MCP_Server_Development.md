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

> **SDK:** найзріліший — TypeScript (`@modelcontextprotocol/sdk`). Для Java/Spring Boot — Spring AI MCP (`spring-ai-starter-mcp-server`). Для Python — FastMCP (`mcp[cli]`).

## Транспорти

| Транспорт | Коли використовувати |
| :--- | :--- |
| **stdio** | Локальний сервер на машині розробника. Claude Code запускає процес сам. Простіше за все. |
| **SSE / HTTP** | Команда розробників або CI. Сервер запущений централізовано, підключається через URL. |

## Мінімальний приклад (Spring AI MCP — Java)

Spring AI 2.0 має повноцінну підтримку MCP-серверів — анотація `@McpTool` аналог `@mcp.tool()` у Python.

`pom.xml`:

```xml
<dependency>
    <groupId>org.springframework.ai</groupId>
    <artifactId>spring-ai-starter-mcp-server</artifactId>
</dependency>
```

`application.properties`:

```properties
spring.ai.mcp.server.stdio=true
```

Файл `DatabaseTool.java`:

```java
@Service
public class DatabaseTool {

    private final JdbcTemplate jdbc;

    public DatabaseTool(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    @McpTool(name = "get_table_columns",
             description = "Returns column names and types. Use before writing migrations or queries.")
    public String getTableColumns(String tableName) {
        var rows = jdbc.queryForList("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_schema = 'public' AND table_name = ?
            ORDER BY ordinal_position LIMIT 100
            """, tableName);
        return rows.toString();
    }
}
```

`.mcp.json` для підключення:

```json
{
  "mcpServers": {
    "project-db": {
      "command": "java",
      "args": ["-jar", "target/mcp-server.jar"],
      "env": {
        "SPRING_DATASOURCE_URL": "jdbc:postgresql://localhost:5432/mydb"
      }
    }
  }
}
```

Для HTTP-транспорту (команда/CI) замість STDIO-стартера використовується `spring-ai-starter-mcp-server-webmvc`.

## Мінімальний приклад (Python FastMCP)

Python-альтернатива з бібліотекою `FastMCP` — менше бойлерплейту. MCP тут лише транспортний шар поверх звичайного Python-коду: сервер може мати повноцінну структуру проєкту, тести, залежності.

Встановлення:

```bash
pip install "mcp[cli]"
```

Файл `server.py`:

```python
import json
import os
import psycopg2
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("project-db")

@mcp.tool()
def get_table_columns(table_name: str) -> str:
    """Returns column names, types and constraints. Use before writing migrations or queries."""
    with psycopg2.connect(os.environ["DATABASE_URL"]) as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT column_name, data_type, is_nullable
                FROM information_schema.columns
                WHERE table_schema = 'public' AND table_name = %s
                ORDER BY ordinal_position LIMIT 100
            """, (table_name,))
            return json.dumps(cur.fetchall(), indent=2)

if __name__ == "__main__":
    mcp.run()
```

`.mcp.json` для підключення:

```json
{
  "mcpServers": {
    "project-db": {
      "command": ".venv/bin/python",
      "args": ["server.py"],
      "env": {
        "DATABASE_URL": "postgresql://readonly_user:pass@localhost:5432/mydb"
      }
    }
  }
}
```

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

> **Відносні шляхи** в `command`/`args` резолвяться від директорії де лежить сам `.mcp.json` файл, не від `cwd`. Важливо для org-level патерну.

> **`.mcp.local.json` не підтримується** — на відміну від `settings.local.json`, аналогічного файлу для MCP немає. Для особистих серверів використовуйте `local` scope через CLI.

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

> **CWD caveat:** шляхи у `command`/`args` резолвяться від директорії `.mcp.json`, але внутрішні відносні шляхи самого сервера (до `.env`, конфігів) резолвяться від `cwd` — директорії де запущено `claude`. Якщо сервер читає файли відносно себе, використовуйте `__dirname` (Node.js), `Path(__file__).parent` (Python) або `Paths.get("")` (Java).

## Tool annotations

MCP дозволяє оголошувати підказки про поведінку tool. FastMCP виставляє консервативні дефолти — всі tools виглядають як потенційно небезпечні:

| Анотація | Default | Що означає |
| :--- | :--- | :--- |
| `readOnlyHint` | `false` | Tool тільки читає, не змінює стан |
| `destructiveHint` | `true` | Tool може незворотньо змінити або видалити дані |
| `idempotentHint` | `false` | Повторний виклик з тими ж аргументами безпечний |
| `openWorldHint` | `true` | Tool взаємодіє з зовнішніми системами (мережа, БД) |

Для read-only tools (читання схеми, запит даних) варто задати явно — Claude Code зможе дозволяти їх без підтвердження:

```python
from mcp.types import ToolAnnotations

@mcp.tool(annotations=ToolAnnotations(readOnlyHint=True, destructiveHint=False))
def get_table_columns(table_name: str) -> str:
    ...
```

Анотації — підказки клієнту, не enforcement на рівні протоколу.

## MCP Inspector

Браузерний UI для дебагу MCP-сервера під час розробки. Входить у `mcp[cli]`:

```bash
.venv/bin/mcp dev server.py
```

Відкрити `http://127.0.0.1:6274`. У UI змінити Command на `.venv/bin/python`, Arguments на `server.py` (дефолтний `uv` може бути не встановлений), натиснути Connect.

Зупинити (Inspector складається з двох частин — Python і Node.js):

```bash
pkill -f "mcp dev server.py"
lsof -ti :6274 | xargs kill
```

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
- Обмежуйте обсяг виводу — `LIMIT 100` у SQL-запитах, пагінація у API. Великий результат витрачає контекстне вікно і коштує дорого.

## Зв'язок з іншими нотатками

- Огляд готових серверів та вибір між MCP/Skills/Rules: [🛠️ Скіли, плагіни та MCP](Skills_and_MCP.md).
- Захист від запису в БД на рівні хуків: [🛡️ Захисні хуки (Guardian)](Guardian_Hooks.md).
