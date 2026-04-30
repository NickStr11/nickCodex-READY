# NOW

Обновлено: 2026-04-30

## Current Focus

- Изучить `https://github.com/nousresearch/hermes-agent` как внешний источник идей для `nickCodex-READY` и OpenClaw/Codex flow.
- Цель: понять, какие agent/memory/tooling/workflow механики можно перенести без раздувания portable context pack.

## Next Entry

- Стартовать новый чат с `AGENTS.md`, `CODEX-USAGE.md` и `$daily-session`.
- Разрешить активное использование subagents по `rules/subagents.md`.
- Сначала дать recon/audit report по `hermes-agent`, без правок в `nickCodex-READY`.
- Сравнить findings с текущими слоями: `AGENTS.md`, `CODEX-USAGE.md`, `.codex/agents`, `skills/`, `memory/`, `inbox/`, `runtime/`, `PORTABILITY.md`.

## Current Facts

- `nickCodex-READY` hardening запушен в GitHub до `9406979 feat: add obsidian profile snapshot sync`.
- Добавлены `CODEX-USAGE.md`, `rules/subagents.md`, `RESTORE-CHECKLIST.md`, `$reflect-session`, `memory/reflections/`, Obsidian profile snapshot sync.
- `chrome-auth-copy` удалён из `runtime/scratch/`.
- `runtime/lis_skins_snapshot.json` остаётся локальным untracked runtime payload.
- Obsidian `GameChanger\AI\` — канон профиля; repo хранит portable snapshots, не symlink.

## Parked

- Steam Sniper production track в Cortex monorepo: см. `memory/diary/2026-04-29-steam-sniper-handoff.md`.
- Правильный Steam Sniper путь: `D:/code/2026/2/cortex/tools/steam-sniper/`; старый standalone deprecated.
- Security hardening отложен до публичного релиза: token exposure, no API auth, CORS, HTTP без TLS, root services.
- Точный 1:1 RUB rate с lis-skins зависит от calibration/rate source; архитектурно RUB snapshots уже считаются first-class data.
