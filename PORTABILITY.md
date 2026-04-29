# Portability

Копировать на другой комп нужно прежде всего сам репозиторий `nickCodex-READY`.

## Свежий комп через GitHub

GitHub-источник:

```text
https://github.com/NickStr11/nickCodex-READY
```

На новом или рабочем компе:

```powershell
cd D:\code\2026\3
git clone https://github.com/NickStr11/nickCodex-READY.git
cd nickCodex-READY
powershell -ExecutionPolicy Bypass -File scripts/bootstrap-portable.ps1
```

Если папки `D:\code\2026\3` нет, создай её или выбери любой удобный путь.

После этого открой repo как workspace в Codex и дай короткий стартовый prompt:

```text
Подними AGENTS.md и CODEX-USAGE.md. Используй $daily-session, проверь текущий фокус и продолжи работу с этим context pack.
```

Что восстановится из GitHub:
- root contract `AGENTS.md`
- Codex usage flow `CODEX-USAGE.md`
- `.codex/config.toml` и `.codex/agents/*`
- repo-native skills `.agents/skills/*`
- канонические skills `skills/*`
- rules, memory, inbox, runbooks, templates, validators
- GitHub workflows и review prompt

Что не восстановится автоматически:
- локальный вход в Codex/OpenAI/GitHub CLI
- `.env` и секреты
- payload из `runtime/`
- локальные кэши и машинная времянка

Проверка после clone:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-context-pack.ps1
```

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

Детали и модельный выбор: `runbooks/openclaw/OPENCLAW-SECOND-LAPTOP.md`.
Короткий WSL fallback: `runbooks/openclaw/WSL-MIGRATION.md`.
