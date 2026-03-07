# Nikita Codex Ready

Переносимый context pack для Codex и других coding agents.

`README.md` — quick start для человека.
`AGENTS.md` — канонический контракт для агента.

Что делать на другом компьютере:
1. Распаковать архив в любую папку.
2. Открыть эту папку как рабочую директорию в Codex.
3. Работать от корневого `AGENTS.md`.

Внутри уже есть:
- `AGENTS.md` — основной рабочий профиль
- `AGENTS-HARD.md` — совместимый алиас на старое имя файла
- `CLAUDE.md` — совместимый алиас для Claude Code
- локальные `AGENTS.md` в `rules/`, `skills/`, `knowledge/`, `memory/`, `runtime/`, `inbox/`
- `memory/` — живая память проекта
- `inbox/` — текущий фокус и необработанные входящие
- `runtime/` — рабочие импорты, выгрузки и scratch
- `.codex/config.toml` — базовый project config для Codex
- `aboutme.md`, `deep-values.md`, `deep-philosophy.md`, `writing-style.md`
- `skills/` и `knowledge/`

Ничего устанавливать не нужно.

Проверка после структурных правок:
- `powershell -ExecutionPolicy Bypass -File scripts/validate-context-pack.ps1`
