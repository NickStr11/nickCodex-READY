# nickCodex-READY

Персональная ОС для работы с Codex, Claude Code и другими coding agents.

Это не приложение и не фреймворк. Это переносимый context pack, в котором уже лежат:
- корневой контракт агента
- живая память проекта
- входящий слой с текущим фокусом
- reusable skills
- холодный knowledge-слой
- runtime-папки для сырья и времянки

## Зачем это

Пакет нужен, чтобы:
- быстро поднимать рабочую агентную среду без долгой инициализации
- держать личный и проектный контекст маленьким и разложенным по слоям
- не смешивать жёсткие правила, личный профиль, текущий статус и мусорные артефакты

## Что внутри

- `AGENTS.md` — канонический root contract для агента
- `CLAUDE.md` — совместимый вход для Claude Code
- `rules/` — рабочие правила поведения и качества
- `memory/` — живая память проекта
- `inbox/` — текущий фокус и входящие хвосты
- `skills/` — reusable workflows и imported upgrades
- `knowledge/` — холодный ресёрч-контекст
- `runtime/` — импорты, выгрузки, scratch и временные файлы

## Базовый цикл

1. Открыть папку в Codex или Claude Code.
2. Стартовать от `AGENTS.md`.
3. Для живой работы использовать `inbox/now.md` и `memory/DEV_CONTEXT.md`.
4. Для повседневного цикла использовать skills:
   `daily-session` -> работа -> `capture-to-knowledge` -> `handoff-session`

## Quick Start

```powershell
cd D:\path\to\nickCodex-READY
```

Дальше:
- для человека точка входа здесь, в `README.md`
- для агента точка входа в `AGENTS.md`

Если менялась структура или документация:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-context-pack.ps1
```

## Git Notes

В репо уже настроено:
- `.gitignore` для секретов и runtime-мусора
- `.gitattributes` для нормализации текста

В git не должны уходить:
- `skills/**/.env`
- payload из `runtime/`
- локальная времянка

## License

[MIT](LICENSE)
