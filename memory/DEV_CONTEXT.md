# DEV_CONTEXT

## Последнее обновление

- Дата: 2026-03-07

## Текущий статус

- Добавлены `memory/` и `runtime/` как рабочие слои.
- Из корня вынесены сырые youtube-артефакты в `runtime/imports/youtube-raw/`.
- Добавлен `CLAUDE.md` как совместимый алиас без второго источника истины.
- Добавлен `inbox/` как входной слой с `inbox/now.md` и `inbox/backlog.md`.
- Добавлены skills: `daily-session`, `handoff-session`, `capture-to-knowledge`.
- Импортированы внешние skills для docs/research/frontend/TDD из `am-will/codex-skills`.
- Репозиторий оформлен как нормальный git/GitHub-пакет с `LICENSE`, `.gitignore`, `.gitattributes`.
- Добавлены `.github/workflows/validate-context-pack.yml`, issue templates, PR template и `CONTRIBUTING.md`.
- Добавлен skill `repo-recon` для быстрого входа в новый кодбейс.
- Добавлены `PORTABILITY.md` и `DAILY.md` как короткие operational entrypoints.
- Граница `memory/` vs `knowledge/` зафиксирована жёстче в README и AGENTS.
- Валидатор усилен: теперь проверяет публичные слои, alias-файлы и обязательные входные документы.

## Ближайший фокус

- прогнать `repo-recon` на 2-3 реальных репозиториях
- проверить, нужен ли следующий слой в виде `.claude/commands` или automation
- развивать только те workflows, которые реально повторяются
- проверить, насколько `PORTABILITY.md` и `DAILY.md` реально сокращают вход в сессию и переезд на другой комп

## Known Issues

- В пакете пока нет лёгкого operational-слоя уровня команд/автоматизаций.
- `context7` по-прежнему требует `CONTEXT7_API_KEY`.
- `.codex/config.toml` остаётся с консервативными portable-настройками.
