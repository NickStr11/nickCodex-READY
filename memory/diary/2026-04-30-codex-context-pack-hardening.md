# 2026-04-30 — Codex context pack hardening

## Что сделано

- Сравнили `nickCodex-READY` с Cortex/Claude setup и перенесли только подходящие идеи: Codex usage guide, subagent playbook, reflection loop, restore checklist.
- Зафиксировали standing preference: Codex должен активнее использовать subagents сам по порогу задачи, если runtime позволяет.
- Добавили `CODEX-USAGE.md`, `rules/subagents.md`, `$reflect-session`, `memory/reflections/`, `RESTORE-CHECKLIST.md`.
- Добавили GitHub restore flow: clone, bootstrap, validation, стартовый prompt для нового Codex-чата.
- Добавили `scripts/sync-profile-from-obsidian.ps1`: Obsidian остаётся каноном профиля, repo хранит portable snapshots, не absolute symlink.
- Удалили локальный тяжёлый runtime хвост `runtime/scratch/chrome-auth-copy/` (~4.67 GB).
- Всё важное закоммичено и запушено в `origin/main`, последний commit: `9406979 feat: add obsidian profile snapshot sync`.

## Решения

- `nickCodex-READY` должен оставаться portable context pack, не Cortex-style monorepo.
- Не делать absolute symlink из repo на `C:\Program Files\Obsidian\...`: это ломает clone на другом компе.
- `~/.claude/aboutme.md` может быть локальным symlink на Obsidian, но repo должен хранить snapshot/copy.
- `runtime/lis_skins_snapshot.json` остаётся локальным untracked payload и не коммитится без отдельного решения.

## Проблемы

- `inbox/now.md` до этого держал Steam Sniper focus; новый актуальный вход теперь смещён к исследованию `nousresearch/hermes-agent`.
- В Codex runtime subagent auto-use может быть ограничен системным правилом: если среда требует явного разрешения, агент должен коротко спросить один раз.

## Остановились на

- Следующий чат: изучить `https://github.com/nousresearch/hermes-agent` как внешний источник идей для Codex/OpenClaw context pack.
- Стартовый prompt уже подготовлен: поднять `AGENTS.md`, `CODEX-USAGE.md`, использовать `$daily-session`, разрешить активных subagents и сначала дать recon/audit report без правок.
