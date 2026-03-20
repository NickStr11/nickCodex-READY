# Fresh Codex Prompt For The New Laptop

Если на новом ноуте уже установлен Codex и ты хочешь просто дать ему задачу,
можешь почти дословно вставить это:

```text
Склонируй https://github.com/NickStr11/nickCodex-READY.git в удобную папку на этом ноуте, открой repo как workspace, прочитай AGENTS.md, README.md, PORTABILITY.md, runbooks/openclaw/OPENCLAW-SECOND-LAPTOP.md и scripts/openclaw-second-laptop.config.psd1, потом запусти .\setup-openclaw-laptop.ps1.

Если для продолжения нужен мой вход вторым ChatGPT/Codex-аккаунтом, остановись и попроси меня залогиниться через Codex. После моего логина продолжай сам: запусти .\finalize-openclaw-laptop.ps1, попробуй довести OpenClaw до рабочего состояния, потом проверь openclaw gateway status и открой openclaw dashboard.

Цель: подготовить этот ноут под отдельный Codex/OpenClaw аккаунт с моделью из scripts/openclaw-second-laptop.config.psd1. Если native Windows путь начнет ломаться, не закапывайся, а предложи переход OpenClaw в WSL2 по runbooks/openclaw/WSL-MIGRATION.md.
```

## Что этот prompt предполагает

- repo: `nickCodex-READY`
- первый шаг автоматизации: `setup-openclaw-laptop.ps1`
- второй шаг после логина: `finalize-openclaw-laptop.ps1`
- source of truth для модели: `scripts/openclaw-second-laptop.config.psd1`
