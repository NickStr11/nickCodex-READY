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

## Ближайший фокус

- проверить новую петлю `daily-session -> work -> capture/handoff` на реальной работе
- развивать только те workflows, которые реально повторяются

## Known Issues

- В пакете пока нет лёгкого operational-слоя уровня команд/автоматизаций.
- `.codex/config.toml` остаётся с консервативными portable-настройками.
