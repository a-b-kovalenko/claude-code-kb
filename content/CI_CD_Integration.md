[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Два підходи до GitHub інтеграції: **офіційний GitHub App** (`claude-code-action@v1` + `@claude` mentions) і **ручний headless** (`claude --print`). Обидва потребують `ANTHROPIC_API_KEY` — підписка Pro/Max у CI не працює. Для enterprise — Bedrock або Vertex AI замість прямого API key.

## 🔐 Автентифікація в CI

**Підписка Pro/Max у CI не працює** — вона прив'язана до браузерної сесії. Для CI потрібен один із трьох варіантів:

| Варіант | Що потрібно | Коли |
| :--- | :--- | :--- |
| Anthropic API | `ANTHROPIC_API_KEY` → GitHub Secret | Стандартний вибір |
| Amazon Bedrock | OIDC + IAM role (`AWS_ROLE_TO_ASSUME`) | Enterprise, AWS-інфраструктура |
| Google Vertex AI | Workload Identity (`GCP_WORKLOAD_IDENTITY_PROVIDER` + `GCP_SERVICE_ACCOUNT`) | Enterprise, GCP-інфраструктура |

Додати `ANTHROPIC_API_KEY` до **Settings → Secrets and variables → Actions**. Для Bedrock і Vertex — OIDC без статичних ключів; вони також потребують власного кастомного GitHub App (офіційний Anthropic App для них не підходить).

Див. [Вибір моделі та оптимізація вартості](Model_Selection_and_Cost.md) — порівняння вартості моделей.

## 🔌 Провайдери та API

Claude Code використовує **Anthropic API format** — endpoint `/v1/messages` із власною структурою запиту. Це **не** OpenAI-сумісний API (`/v1/chat/completions`), тому вказати довільний OpenAI-сумісний провайдер не вийде.

Підтримувані бекенди для `claude --print`:

| Бекенд | Аутентифікація |
| :--- | :--- |
| Anthropic API (за замовчуванням) | `ANTHROPIC_API_KEY` |
| Amazon Bedrock | OIDC + IAM role (`AWS_ROLE_TO_ASSUME`) — без статичних ключів |
| Google Vertex AI | Workload Identity Federation (`GCP_WORKLOAD_IDENTITY_PROVIDER`) |

Змінна `ANTHROPIC_BASE_URL` дозволяє перенаправити виклики на кастомний endpoint, але він також має відповідати **Anthropic API format**, а не OpenAI.

Для OpenAI-сумісних провайдерів (GitHub Models, Ollama, Groq тощо) — використовуй `curl` або OpenAI SDK напряму, як показано в прикладах нижче.

## 🐙 Офіційна GitHub App інтеграція

Найпростіший шлях — офіційний `claude-code-action@v1`. Не потребує ручного встановлення Claude Code, підтримує `@claude` mentions і автоматично визначає режим роботи.

### Швидке налаштування

```bash
/install-github-app
```

Команда встановлює Anthropic GitHub App і проводить через додавання `ANTHROPIC_API_KEY` як секрету. **Тільки для прямого Anthropic API** — для Bedrock/Vertex потрібне ручне налаштування.

Права, які запитує app: Contents, Issues, Pull requests — Read & Write.

### @claude mentions у PR і issues

```yaml
name: Claude Code
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]

jobs:
  claude:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      issues: write
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

Після налаштування достатньо написати в коментарі до PR:

```text
@claude implement this feature based on the issue description
@claude review this for security issues
@claude fix the failing test in OrderServiceTest
```

### Автоматичний PR review (без trigger)

```yaml
name: Code Review
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: "/code-review"
```

### Параметри claude-code-action@v1

| Параметр | Опис |
| :--- | :--- |
| `anthropic_api_key` | API key (обов'язково для прямого API) |
| `prompt` | Інструкція або назва скіла (`/code-review`) |
| `claude_args` | CLI-аргументи: `--max-turns 5 --model claude-sonnet-4-6` |
| `trigger_phrase` | Кастомний тригер (default: `@claude`) |
| `use_bedrock` | `"true"` для Amazon Bedrock |
| `use_vertex` | `"true"` для Google Vertex AI |

## 🐙 GitHub Actions: ручні приклади (headless)

### Автоматичний PR review

Запускається при відкритті або оновленні PR; публікує коментар з результатом.

```yaml
name: Claude PR Review
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Install Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Run review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          git diff origin/${{ github.base_ref }}...HEAD > /tmp/diff.txt
          claude --print "$(cat /tmp/diff.txt)

          Review this diff. Find bugs, SOLID violations, and security issues.
          Output a concise markdown summary with severity labels." \
            --output-format json \
            --max-turns 3 \
            --model claude-haiku-4-5-20251001 \
            | jq -r '.result' > /tmp/review.md

          gh pr comment ${{ github.event.pull_request.number }} \
            --body "$(cat /tmp/review.md)"
```

### Security scan при push у main

```yaml
name: Claude Security Scan
on:
  push:
    branches: [main]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Security scan
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          claude --print \
            "Scan src/ for OWASP Top 10 vulnerabilities.
             List each finding with file path and severity.
             Return non-zero exit if any CRITICAL found." \
            --output-format json \
            --max-turns 5 \
            --allowedTools Read,Grep
```

### Pipe stdin замість аргументу

Для довгих промптів зручніше передавати через stdin:

```bash
cat << 'EOF' | claude --print --output-format json --max-turns 3
Review the following Java class for thread-safety issues:

$(cat src/main/java/com/example/MyService.java)
EOF
```

Наведений патерн — передати промпт через CLI і отримати текстовий вивід — не прив'язаний до Claude Code. `claude --print` можна замінити будь-яким іншим CLI (наприклад, `ollama run llama3`), зберігши ту саму структуру пайплайну. Відмінність: немає `--output-format json` з полем `cost_usd`, немає захисту `--max-turns` і немає tool use (`Read`, `Grep`).

### GitHub Models: вбудовані моделі

[GitHub Models](https://github.com/marketplace/models) — маркетплейс моделей (GPT-4o, Llama, Mistral тощо) з OpenAI-сумісним API. Ключова перевага для CI: аутентифікація через `${{ secrets.GITHUB_TOKEN }}`, який вже є в кожному Actions workflow — жодного додаткового секрету не потрібно.

```yaml
- name: Review with GitHub Models
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    git diff origin/${{ github.base_ref }}...HEAD > /tmp/diff.txt
    curl -s https://models.inference.ai.azure.com/chat/completions \
      -H "Authorization: Bearer $GH_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{
        \"model\": \"gpt-4o-mini\",
        \"messages\": [{
          \"role\": \"user\",
          \"content\": \"Review this diff for bugs and security issues:\n$(cat /tmp/diff.txt)\"
        }]
      }" | jq -r '.choices[0].message.content'
```

GitHub Models має безкоштовний tier для публічних репозиторіїв і обмеження rate limit для приватних. Для вибору моделі: легкі задачі (quick review) → `gpt-4o-mini`; складніший аналіз → `gpt-4o` або `Meta-Llama-3.1-70B-Instruct`.

## ⚠️ Безпека та ризики

**Prompt injection** — головний ризик у CI. Якщо агент читає PR-опис, коміт-повідомлення або будь-який файл від зовнішніх контрибюторів, зловмисник може вставити туди інструкцію для агента.

Мінімізація:

- `--allowedTools Read,Grep` — заборонити `Bash`, `Edit`, `Write` в review-задачах
- Не передавати PR body напряму в промпт; читати лише diff через `git diff`
- Додати `concurrency` у workflow щоб обмежити паралельні запуски:

```yaml
concurrency:
  group: claude-review-${{ github.ref }}
  cancel-in-progress: true
```

**Secrets leakage** — якщо агент читає `.env`, `*.pem` або логи з паролями і виводить їх у `result` (який потрапляє в коментар PR), секрети стають публічними. Захист: `deny`-правила в `settings.json` разом з `--allowedTools`:

```json
{
  "permissions": {
    "deny": ["Read(**/.env)", "Read(**/*.pem)", "Read(**/credentials.xml)"]
  }
}
```

**Rate limits** — кілька одночасних PR можуть вичерпати квоту. GitHub `concurrency` або `max-parallel` допоможуть.

Див. [Оптимізація дозволів](Permissions_Optimization.md) та [Захисні хуки (Guardian)](Guardian_Hooks.md).

## 💰 Управління вартістю

- Haiku (`claude-haiku-4-5-20251001`) для рутинних перевірок — у рази дешевший за Sonnet
- `--max-turns 3–5` запобігає дорогим агентським циклам
- `--output-format json` → поле `cost_usd` у відповіді — логуйте для аудиту:

```bash
result=$(claude --print "..." --output-format json)
cost=$(echo "$result" | jq -r '.cost_usd')
echo "Review cost: $cost USD"
```

- Для великих репозиторіїв: передавати лише diff, а не весь `src/`

Детально — [Вибір моделі та оптимізація вартості](Model_Selection_and_Cost.md).

## 🏭 Production Hardening

### Фіксування версії

`npm install -g @anthropic-ai/claude-code` завжди ставить останню версію — антипатерн у CI. Нова версія може змінити формат виводу або поведінку і непомітно зламати пайплайн. Фіксуй версію та оновлюй свідомо після тестування:

```bash
npm install -g @anthropic-ai/claude-code@1.0.3
```

### Exit codes

| Код | Значення |
| :--- | :--- |
| `0` | Успіх |
| `1` | Загальна помилка агента (rate limit, API недоступний тощо) |
| `2` | Невалідний ввід (неправильні прапори або промпт) |

Перевіряй exit code явно для стійких bash-скриптів:

```bash
if ! claude --print "..." --output-format json > /tmp/result.json; then
  echo "Claude failed with exit $?"
  exit 1
fi
```

### Корпоративний проксі

Claude Code (Node.js) підтримує стандартні змінні оточення для проксі — актуально для self-hosted runners за корпоративним firewall:

```yaml
env:
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
  HTTPS_PROXY: ${{ secrets.CORPORATE_PROXY_URL }}
```

### Великі дифи: chunking-стратегія

У Java-монолітах `git diff` може бути на тисячі рядків — агент вичерпає ліміт контексту або "загубиться". Стратегія: спочатку отримати список файлів, потім аналізувати по черзі:

```bash
git diff --name-only origin/$BASE_REF...HEAD | while read -r file; do
  echo "=== $file ===" >> /tmp/review.md
  git diff origin/$BASE_REF...HEAD -- "$file" | \
    claude --print "Review this diff for bugs and security issues:" \
      --output-format json --max-turns 2 \
    | jq -r '.result' >> /tmp/review.md
done
```

Це також дозволяє пропустити файли поза scope (наприклад, `.xml`, міграції) або зупинитись при першому критичному знахідку.

## 🔗 Зв'язок з іншими нотатками

- [Headless-режим](Headless_Mode.md) — що таке headless-режим, прапори, одна задача — один процес
- [Git та PR Workflow](Git_PR_Workflow.md) — PR-конвенції та commit-стандарти, які перевіряє review
- [Захисні хуки (Guardian)](Guardian_Hooks.md) — захисні хуки для локального середовища
- [Оптимізація дозволів](Permissions_Optimization.md) — `--allowedTools`, glob-синтаксис дозволів
- [Вибір моделі та оптимізація вартості](Model_Selection_and_Cost.md) — вибір моделі та бюджетні стратегії
- [Динамічні воркфлоу Claude Code](Claude_Code_Dynamic_Workflows.md) — складніший рівень: генерація JS-скрипта і запуск сотень субагентів поза сесією
