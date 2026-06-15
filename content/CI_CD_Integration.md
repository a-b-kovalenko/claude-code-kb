[⬅️](../Claude_Code_Knowledge_Base.md)

## 📝 TL;DR

Claude Code запускається в CI через headless-режим (`--print`) — детально про нього в [Headless Mode](Headless_Mode.md). Для CI специфічно: автентифікація через `ANTHROPIC_API_KEY` (підписка не підходить), обмеження `--allowedTools` проти prompt injection, і `concurrency` у GitHub Actions проти rate limits.

## 🔐 Автентифікація в CI

Підписка Max або Pro прив'язана до браузерної сесії — у CI вона не працює. Потрібен [API key](https://console.anthropic.com/):

```yaml
env:
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

Додати `ANTHROPIC_API_KEY` до **Settings → Secrets and variables → Actions** у репозиторії (GitHub) або до credentials у Jenkins.

Див. [Вибір моделі та оптимізація вартості](Model_Selection_and_Cost.md) — там порівняння вартості моделей.

## 🐙 GitHub Actions: приклади

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

**Rate limits** — кілька одночасних PR можуть вичерпати квоту. GitHub `concurrency` або `max-parallel` допоможуть.

Див. [Permissions Optimization](Permissions_Optimization.md) та [Guardian Hooks](Guardian_Hooks.md).

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

Детально — [Model Selection and Cost](Model_Selection_and_Cost.md).

## 🔗 Зв'язок з іншими нотатками

- [Headless Mode](Headless_Mode.md) — що таке headless-режим, прапори, одна задача — один процес
- [Git PR Workflow](Git_PR_Workflow.md) — PR-конвенції та commit-стандарти, які перевіряє review
- [Guardian Hooks](Guardian_Hooks.md) — захисні хуки для локального середовища
- [Permissions Optimization](Permissions_Optimization.md) — `--allowedTools`, glob-синтаксис дозволів
- [Model Selection and Cost](Model_Selection_and_Cost.md) — вибір моделі та бюджетні стратегії
- [Claude Code Dynamic Workflows](Claude_Code_Dynamic_Workflows.md) — складніший рівень: генерація JS-скрипта і запуск сотень субагентів поза сесією
