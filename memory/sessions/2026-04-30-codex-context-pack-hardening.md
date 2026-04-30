# Session Note

Дата: 2026-04-30

## Что сделано

- Провели большой hardening `nickCodex-READY` после сравнения с Cortex/Claude setup.
- Добавлен Codex-specific operational слой:
  - `CODEX-USAGE.md`
  - `rules/subagents.md`
  - standing preference на активное использование subagents
  - обновления в `.codex/config.toml` и `templates/project-starter/.codex/config.toml`
- Добавлен reflection loop:
  - `skills/core/reflect-session/`
  - generated wrapper `.agents/skills/reflect-session/`
  - `memory/reflections/README.md`
  - `memory/reflections/processed.log`
  - starter equivalents в `templates/project-starter/`
- Добавлен restore/portability слой:
  - `RESTORE-CHECKLIST.md`
  - GitHub clone flow в `README.md` и `PORTABILITY.md`
  - `bootstrap-portable.ps1` проверяет `CODEX-USAGE.md`
- Добавлен profile snapshot sync:
  - `scripts/sync-profile-from-obsidian.ps1`
  - docs в `README.md`, `PORTABILITY.md`, `CONTRIBUTING.md`
  - validator проверяет наличие и базовую полноту sync-скрипта
- Удалён локальный `runtime/scratch/chrome-auth-copy/` (~4.67 GB).

## Коммиты и GitHub

- `0595126 feat: strengthen codex context workflows`
- `fcdc755 docs: document github restore flow`
- `ff1d47b docs: add restore checklist`
- `9406979 feat: add obsidian profile snapshot sync`

Все эти коммиты запушены в `origin/main`.

## Проверки

Проходили:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-context-pack.ps1
powershell -ExecutionPolicy Bypass -File scripts/validate-project-context.ps1 -TargetPath templates\project-starter
powershell -ExecutionPolicy Bypass -File scripts/sync-profile-from-obsidian.ps1 -Check
```

## Важные решения

- GitHub `NickStr11/nickCodex-READY` — переносимый источник для восстановления на рабочем компе.
- Вне repo не надо тащить `C:\Users\User\.codex` как source of truth; это локальная среда, auth/cache/plugins.
- Obsidian `GameChanger\AI\` — канон личного профиля, repo хранит portable snapshots.
- Absolute symlink-и из repo на локальный Obsidian path запрещены для portability.
- Claude/Cortex и Codex pack не должны расходиться незаметно: profile sync должен быть явной командой и diff-review.

## Текущий локальный хвост

- `runtime/lis_skins_snapshot.json` остаётся untracked runtime payload. Не коммитить без отдельного решения.

## Следующий вход

- Новый чат должен стартовать с:

```text
Подними AGENTS.md и CODEX-USAGE.md. Используй $daily-session.
Задача: изучить https://github.com/nousresearch/hermes-agent как внешний источник идей для nickCodex-READY/OpenClaw flow.
Никита разрешает активное использование subagents по rules/subagents.md. Сначала дай recon/audit report без правок.
```

## Parked

- Steam Sniper production track остаётся отдельным хвостом; последний handoff: `memory/diary/2026-04-29-steam-sniper-handoff.md` и `memory/sessions/2026-04-29-steam-sniper-session.md`.
