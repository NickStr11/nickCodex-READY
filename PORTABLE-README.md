# Portable AI Context Pack

Коротко: это переносимый personal context pack под coding agents.

В пакете:
- `AGENTS.md` — канонический root contract
- `CLAUDE.md` — совместимый вход для Claude Code
- `README.md` — human quick start
- `DAILY.md` — короткий daily flow
- `PORTABILITY.md` — сценарий переезда на другой комп
- `memory/` — живая память проекта
- `inbox/` — текущий фокус
- `runtime/` — сырые рабочие артефакты
- локальные `AGENTS.md` в рабочих подпапках

Быстрый старт:
1. Положить папку туда, где агент может её читать.
2. Открыть папку как workspace.
3. Для агента загружать сначала `AGENTS.md`.
4. Для ежедневной работы держать рядом `DAILY.md`.
5. После структурных правок гонять `scripts/validate-context-pack.ps1`.
6. Для нового ноута с OpenClaw использовать `setup-openclaw-laptop.ps1`.
