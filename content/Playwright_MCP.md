[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Playwright MCP — сервер, що дає Claude Code доступ до браузера: навігація, кліки, скріншоти, перевірка DOM. Закриває петлю "зміна → компіляція → перевірка в браузері" без ручного втручання. Актуальний для команд з web UI; для pure backend — зайвий overhead.

## Встановлення

```bash
claude mcp add playwright npx @playwright/mcp@latest
```

Сервер запускається локально при старті Claude Code. Перевірити що підключився:

```bash
claude mcp list
```

## Дозволи

При першому виклику кожного інструменту Claude запитує підтвердження. Щоб автоматично дозволити всі Playwright-інструменти, додайте в `.claude/settings.local.json`:

```json
{
  "allowedTools": ["MCP__playwright"]
}
```

Префікс `MCP__<servername>` охоплює всі інструменти сервера одразу. `.local.json` — особистий файл, не комітиться; для командної автоматизації в CI налаштовуйте через `settings.json` або змінні середовища.

> **У GitHub Actions shortcut не працює.** `MCP__playwright` як префікс діє лише в локальному `settings.json`. У CI кожен інструмент треба перелічити явно через `--allowedTools`:
>
> ```yaml
> claude_args: "--allowedTools MCP__playwright__navigate,MCP__playwright__screenshot,MCP__playwright__click"
> ```

## Що вміє

| Інструмент | Що робить |
| :--- | :--- |
| `navigate` | Відкрити URL |
| `screenshot` | Зробити скріншот поточної сторінки |
| `click` | Клікнути елемент |
| `fill` | Ввести текст у поле |
| `evaluate` | Виконати JS у контексті сторінки |
| `wait_for` | Почекати на елемент або стан |

## Сценарії для Java команди

### Верифікація UI після змін бекенду

Spring Boot повертає нові поля в JSON — Claude змінює контролер, потім через Playwright перевіряє що фронтенд коректно їх відображає:

```text
1. Запусти ./mvnw spring-boot:run
2. Відкрий localhost:8080/orders
3. Зроби скріншот — переконайся що нове поле "deliveryDate" видно в таблиці
```

### Перевірка Swagger UI

Після додавання нового endpoint Claude може відкрити `localhost:8080/swagger-ui.html`, знайти новий endpoint і переконатись що документація відображається коректно.

### Автоматизований PR review з UI-перевіркою

У GitHub Actions: Claude отримує PR, запускає dev-сервер, через Playwright перевіряє UI, залишає коментар зі скріншотом. Замикає цикл рев'ю без ручного запуску.

```yaml
- name: Start app
  run: ./mvnw spring-boot:run &
- name: Claude UI review
  run: claude -p "Open localhost:8080, take a screenshot of the main page,
       verify no visual regressions compared to the PR description"
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

## Trade-offs

| Плюс | Мінус |
| :--- | :--- |
| Закриває UI-петлю автоматично | Ще одна залежність в командній інфраструктурі |
| Скріншоти як доказ у PR-рев'ю | Headless браузер у CI потребує налаштування |
| Без ручного запуску і перевірки | Для pure API backend — зайвий overhead |
| Працює з будь-яким web UI | Playwright інструменти споживають токени |

Оптимальна стратегія: локально — дозволяти по запиту (`settings.local.json`), у CI — вмикати тільки для PR що зачіпають UI-шар.

## Зв'язок з іншими нотатками

- Загальна реєстрація MCP-серверів: [🛠️ Скіли, плагіни та MCP](Skills_and_MCP.md).
- Playwright у GitHub Actions pipeline: [⚙️ CI/CD інтеграція](CI_CD_Integration.md).
- Дозволи інструментів і `allowedTools`: [⚙️ Конфігурація settings.json](Settings_JSON_Guide.md).
