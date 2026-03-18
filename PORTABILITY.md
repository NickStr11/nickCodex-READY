# Portability

Копировать на другой комп нужно прежде всего сам репозиторий `nickCodex-READY`.

Что переносить:
- весь репозиторий целиком
- при необходимости локальные `.env` только для тех skills, которым реально нужны ключи

Что не считать источником истины:
- `C:\Users\...\ .codex`
- локальные кэши, temp и машинный мусор
- payload из `runtime/`, если он не нужен дальше

Быстрый подъём:
1. Склонировать или скопировать репозиторий.
2. Открыть папку как workspace в Codex или Claude Code.
3. Стартовать от `README.md` для человека и от `AGENTS.md` для агента.
4. Для обычной сессии держать рядом `DAILY.md`.
5. Прогнать `powershell -ExecutionPolicy Bypass -File scripts/bootstrap-portable.ps1`.
6. Если менялась структура или документация, отдельно прогнать `powershell -ExecutionPolicy Bypass -File scripts/validate-context-pack.ps1`.

Правило простое: долговечный контекст хранить внутри репозитория, а не в локальных папках пользователя.

## Новый ноут под OpenClaw

Если цель — скачать репо на другой ноут, открыть в Codex и быстро довести машину
до рабочего состояния под OpenClaw:

1. Склонировать репо.
2. Открыть его в Codex.
3. Запустить `powershell -ExecutionPolicy Bypass -File .\setup-openclaw-laptop.ps1`.
4. Дальше руками пройти только auth/onboarding шаги:
   - вход вторым ChatGPT/Codex-аккаунтом
   - `powershell -ExecutionPolicy Bypass -File .\finalize-openclaw-laptop.ps1`

Детали и модельный выбор: `OPENCLAW-SECOND-LAPTOP.md`.
Короткий WSL fallback: `WSL-MIGRATION.md`.
