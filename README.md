# nickCodex-READY

[![Validate Context Pack](https://github.com/NickStr11/nickCodex-READY/actions/workflows/validate-context-pack.yml/badge.svg)](https://github.com/NickStr11/nickCodex-READY/actions/workflows/validate-context-pack.yml)

Персональная ОС для работы с Codex, Claude Code и другими coding agents.

Это не приложение и не фреймворк. Это переносимый context pack, в котором уже лежат:
- корневой контракт агента
- живая память проекта
- входящий слой с текущим фокусом
- reusable skills
- холодный knowledge-слой
- runtime-папки для сырья и времянки
- daily golden path для обычной рабочей сессии
- короткий сценарий переезда на другой комп

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
- `DAILY.md` — короткий ежедневный golden path
- `PORTABILITY.md` — что копировать и как быстро поднять среду на другом компе
- `inbox/` — текущий фокус и входящие хвосты
- `skills/` — reusable workflows и imported upgrades
- `knowledge/` — долговечные и переиспользуемые заметки
- `runtime/` — импорты, выгрузки, scratch и временные файлы
- `templates/` — starter-шаблоны для новых project-local repo

## Operational Shell

- `.\resume.ps1` — печатает готовый prompt для входа в текущий проект
- `.\new-project.ps1 <name>` — создаёт новый project-local repo рядом с этим pack
- `.\doctor.ps1` — проверяет tooling, env и минимальный project-local context
- `.\setup-openclaw-laptop.ps1` — быстрый bootstrap второго ноута под Codex + OpenClaw
- `.\finalize-openclaw-laptop.ps1` — добивает OpenClaw после логина вторым Codex-аккаунтом
- `powershell -ExecutionPolicy Bypass -File scripts/validate-project-context.ps1 -TargetPath <path>` — валидирует project-local scaffold

## Почему это уже не просто заметочник

- есть CI, который валидирует структуру и ссылки на каждом `push` и `pull_request`
- есть issue / PR templates под intake новых задач и развитие skills
- есть `repo-recon` для быстрого входа в любой незнакомый репозиторий
- есть `CONTRIBUTING.md`, чтобы operational-слой не расползался в бардак

## Базовый цикл

1. Открыть папку в Codex или Claude Code.
2. Стартовать от `AGENTS.md`.
3. Для обычной сессии держать рядом `DAILY.md`.
4. Для живой работы использовать `inbox/now.md` и `memory/DEV_CONTEXT.md`.
5. Для повседневного цикла использовать skills:
   `daily-session` -> работа -> `capture-to-knowledge` -> `handoff-session`

## Боевые навыки

- `repo-recon` — быстрый вход в новый репо: стек, команды, entrypoints, hotspots
- `read-github` — чтение и поиск по GitHub-репам
- `context7` — свежая внешняя документация
- `tdd-test-writer` — regression-first фиксы и RED-фаза TDD

## Quick Start

```powershell
cd D:\path\to\nickCodex-READY
```

Дальше:
- для человека точка входа здесь, в `README.md`
- для агента точка входа в `AGENTS.md`
- для ежедневной работы без лишней навигации — `DAILY.md`
- для переезда на другой комп — `PORTABILITY.md`
- для нового ноута под OpenClaw — `OPENCLAW-SECOND-LAPTOP.md`
- для готового prompt в свежий Codex — `FRESH-CODEX-OPENCLAW-PROMPT.md`
- для быстрой проверки среды на новом компе — `powershell -ExecutionPolicy Bypass -File scripts/bootstrap-portable.ps1`

Если менялась структура или документация:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-context-pack.ps1
```

Для вклада в сам repo смотри [CONTRIBUTING.md](CONTRIBUTING.md).

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
