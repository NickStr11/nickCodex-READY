# OpenClaw On A Second Laptop

Коротко: базовый portable repo для нового ноута должен быть `nickCodex-READY`.

`cipher-knowledge` можно держать как legacy memory import, но не как основной
portable bootstrap repo. Там старый монолитный формат памяти и смешаны
инструкции, личность и рабочие скрипты.

## Что реально получится

Самый короткий рабочий путь:

1. Склонировать этот repo на новый ноут.
2. Открыть папку в Codex.
3. Запустить `.\setup-openclaw-laptop.ps1`.
4. Залогиниться вторым ChatGPT/Codex-аккаунтом.
5. Запустить `.\finalize-openclaw-laptop.ps1`.
6. После стабилизации runtime поднять отдельный memory repo по `MEMORY-REPO-RUNBOOK.md`.

## Почему так

Есть две разные задачи:

- подготовить ноут и portable Codex workspace
- поднять OpenClaw и привязать модель/аккаунт

Первое автоматизируется хорошо.
Второе упирается в OAuth, browser callback, возможные admin/reboot шаги и не
должно silently выполняться без твоего участия.

## Быстрый сценарий

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-openclaw-laptop.ps1
```

Этот скрипт:

- проверяет Git
- проверяет Node/npm
- ставит или обновляет Codex CLI
- добавляет OpenAI docs MCP для Codex CLI
- ставит или обновляет OpenClaw через официальный PowerShell installer
- прогоняет local portable bootstrap
- печатает точные next steps

После логина вторым аккаунтом второй скрипт:

- пытается неинтерактивно использовать `~/.codex/auth.json` для OpenClaw
- фиксирует целевую модель из `scripts/openclaw-second-laptop.config.psd1`
- ставит `fastMode` из `scripts/openclaw-second-laptop.config.psd1`
- валидирует конфиг и проверяет gateway status
- после этого не обязан сразу тащить `Hindsight`; repo-backed memory остаётся нормальным основным путём

## Какую модель ставить

Source of truth для repo/model/finalize-настроек:

- `scripts/openclaw-second-laptop.config.psd1`

В `.codex/config.toml` для этого repo включено `cli_auth_credentials_store = "file"`,
чтобы после логина Codex складывал кэш в `~/.codex/auth.json`, который OpenClaw
умеет переиспользовать.

Это лучше, чем начинать с рандомного second-tier провайдера только потому, что
он уже оплачен. Antigravity Ultra можно держать как запасной провайдер или
сравнительный вариант, но не как базовую опору первого portable setup.

## Важная оговорка по Windows

Быстрый путь для первого запуска: native Windows.

Но по текущим официальным OpenClaw docs на Windows всё ещё рекомендован WSL2.
Если native path начнет бесить, следующий шаг не “чинить вечно Windows”, а
перевести OpenClaw в WSL2 и оставить этот repo как верхний workspace.

Короткий runbook уже лежит в `WSL-MIGRATION.md`.

Важно: на текущем втором ноуте `Hindsight` уже выключен из-за native Windows
blocker по `mlx`. Это не мешает работе OpenClaw. Для долгой памяти сейчас
приоритетнее отдельный GitHub-backed memory repo, а не возврат к `Hindsight`
любой ценой.

## Основные источники

- [Codex CLI](https://developers.openai.com/codex/cli/)
- [Codex Authentication](https://developers.openai.com/codex/auth/)
- [OpenClaw Getting Started](https://docs.openclaw.ai/start/getting-started)
- [OpenClaw Install](https://docs.openclaw.ai/install)
- [OpenClaw Windows](https://docs.openclaw.ai/platforms/windows)
- [OpenClaw OpenAI provider](https://docs.openclaw.ai/providers/openai)
