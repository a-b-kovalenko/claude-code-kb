[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Плагін — це директорій зі skills, agents, hooks та MCP упакованих разом для шерингу між проєктами або командою. Standalone `.claude/skills/` достатньо для особистих задач; плагін потрібен коли треба версіонувати і ділитися.

## Плагін vs Standalone

| | Standalone (`.claude/skills/`) | Плагін |
| :--- | :--- | :--- |
| Назва скіла | `/hello` | `/plugin-name:hello` |
| Сфера | Один проєкт або `~/.claude/` | Будь-який проєкт, маркетплейс |
| Шеринг | Руками копіювати | `/plugin install` |
| Версіонування | Немає | `version` у маніфесті |
| Неймспейс | Без префіксу | `plugin-name:` |

**Коли залишатися на standalone:**

- Особисті workflows для одного проєкту
- Короткі імена без префіксу (`/deploy`, `/hello`)
- Швидкі експерименти перед упакуванням

**Коли переходити на плагін:**

- Треба ті самі skills/agents у кількох проєктах
- Ділитися з командою або спільнотою
- Потрібне версіонування та оновлення

## Структура плагіна

```text
my-plugin/
├── .claude-plugin/
│   └── plugin.json          ← маніфест (опціонально)
├── skills/
│   └── hello/
│       └── SKILL.md
├── agents/
│   └── reviewer.md
├── hooks/
│   └── hooks.json
├── monitors/
│   └── monitors.json        ← фонові спостерігачі (логи, файли)
├── bin/                     ← виконувані файли в PATH
├── .mcp.json
├── .lsp.json                ← LSP-сервери для мовної підтримки
└── settings.json            ← налаштування за замовчуванням
```

Мінімальний варіант — `SKILL.md` прямо в корені директорія (один скіл без `skills/`).

## Маніфест plugin.json

```json
{
  "name": "my-plugin",
  "description": "Що робить плагін",
  "version": "1.0.0",
  "author": { "name": "Your Name" }
}
```

`name` стає префіксом для скілів: `/my-plugin:hello`. Без `version` — за версію береться git commit SHA.

## Встановлення та тестування

```bash
# Локальне тестування під час розробки
claude --plugin-dir ./my-plugin

# Перезавантажити плагін без рестарту
/reload-plugins

# Завантажити zip-архів (v2.1.128+)
claude --plugin-dir ./my-plugin.zip
```

Плагіни з маркетплейсу встановлюються через `/plugin install`. Встановлені плагіни зберігаються у `~/.claude/plugins/`.

## Плагін у skills-директорії

Найзручніший варіант для персонального плагіну — `claude plugin init` додає маніфест прямо в `~/.claude/skills/`:

```bash
claude plugin init my-tool
# створює ~/.claude/skills/my-tool/ з plugin.json і SKILL.md
```

Завантажується автоматично без встановлення через маркетплейс.

## Маркетплейси

Два офіційні:

- **`claude-plugins-official`** — від Anthropic, реєструється автоматично при першому запуску.
- **`claude-community`** — спільнотні плагіни після ревʼю. Додати: `/plugin marketplace add anthropics/claude-plugins-community`.

Для командного шерингу без публічного маркетплейсу — приватний git-репозиторій як маркетплейс.

## Зв'язок з іншими нотатками

- Анатомія скіл-файлу: [✍️ Розробка власного скіла](Skill_Development_Guide.md)
- Де живуть плагіни в структурі проєкту: [🗂️ Ієрархія артефактів](Project_Artifacts_Hierarchy.md)
- Все про MCP-сервери: [🔌 Розробка MCP-сервера](MCP_Server_Development.md)
