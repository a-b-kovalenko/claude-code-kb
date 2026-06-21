[⬅️](qa_index.md)

## 📝 TL;DR

CLAUDE.md має два рівні: глобальний (`~/.claude/CLAUDE.md` — особистий, не шерується) і проєктний (`./CLAUDE.md` — в репо, доступний усій команді). Конвенції команди мають жити в проєктному CLAUDE.md, інакше вони не доступні іншим розробникам.

## Original

**Scenario:** Developer A's Claude Code follows the team's API naming conventions perfectly. Developer B, who joined last week, gets inconsistent naming from Claude Code. Both are working on the same repo, same branch.

**Question:** What is the most likely root cause?

**A)** Developer B needs to install an MCP server to access the naming convention rules

**B)** The conventions are in a .claude/rules/ file that Developer B's editor does not support

**C)** The API naming conventions are stored in Developer A's user-level CLAUDE.md (~/.claude/CLAUDE.md) rather than the project-level configuration

**D)** Developer B has not run /memory to load the configuration files

## Питання

Claude Code розробника A ідеально дотримується командних конвенцій іменування API. Розробник B, який приєднався минулого тижня, отримує непослідовне іменування від Claude Code. Обидва працюють в одному репо, одній гілці. Яка найбільш імовірна першопричина?

**A)** Розробнику B потрібно встановити MCP сервер для доступу до правил іменування

**B)** Конвенції знаходяться у файлі `.claude/rules/`, який не підтримується редактором розробника B

**C)** Конвенції іменування API збережені у user-level CLAUDE.md розробника A (`~/.claude/CLAUDE.md`), а не в конфігурації рівня проєкту

**D)** Розробник B не запустив `/memory` для завантаження конфігураційних файлів

## Правильна відповідь: C

## Аналіз варіантів

### C — Правильний

`~/.claude/CLAUDE.md` — глобальна особиста конфігурація яка НЕ входить в git репозиторій. Розробник A додав конвенції туди, тому вони доступні лише йому. Правильне місце для командних конвенцій — `./CLAUDE.md` або `.claude/rules/` в корені проєкту (шерується через git).

### A — Хибний

MCP сервери надають Claude Code доступ до зовнішніх інструментів і даних. Правила іменування не вимагають MCP — вони живуть в CLAUDE.md.

### B — Хибний

`.claude/rules/` файли читаються Claude Code незалежно від редактора. Підтримка редактора не впливає на те чи Claude Code завантажує ці файли.

### D — Хибний

`/memory` — команда для роботи з auto-memory системою агента. Вона не завантажує конфігурацію проєкту — CLAUDE.md завантажується автоматично при старті сесії.

## Ключові концепції

### Ієрархія CLAUDE.md

| Файл | Область | Шерується? |
| --- | --- | --- |
| `~/.claude/CLAUDE.md` | Глобальна (всі проєкти) | Ні — особистий |
| `./CLAUDE.md` | Проєктна (поточний репо) | Так — через git |
| `.claude/rules/*.md` | Проєктна (модульні правила) | Так — через git |

### Правило для командних конвенцій

Будь-яке правило, якому повинна слідувати вся команда → зберігати в git-tracked файлі: `./CLAUDE.md` або `.claude/rules/`. Особистий `~/.claude/CLAUDE.md` — для індивідуальних уподобань і persona розробника.

### Сигнал у питанні

"Same repo, same branch" + різна поведінка = конфігурація яка не в репо. Перша гіпотеза: user-level vs project-level.

## Пов'язані нотатки

- [Написання CLAUDE.md](../../CLAUDE_md_Writing_Guide.md) — структура, шаблон, де зберігати
- [Ієрархія артефактів проєкту](../../Project_Artifacts_Hierarchy.md) — повна схема: CLAUDE.md, rules, skills
- [Domain 2: Claude Code Workflows](../domain_2_claude_code.md)
