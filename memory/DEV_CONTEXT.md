# DEV_CONTEXT

## Последнее обновление

- Дата: 2026-03-18

## Текущий статус

- Репо уже оформлено как нормальный portable context pack: `memory/`, `runtime/`, `inbox/`, `CLAUDE.md`, CI, issue templates, PR template, `LICENSE`, `.gitignore`, `.gitattributes`.
- Добавлен отдельный трек под второй ноут: `setup-openclaw-laptop.ps1`, `finalize-openclaw-laptop.ps1`, `OPENCLAW-SECOND-LAPTOP.md`, `FRESH-CODEX-OPENCLAW-PROMPT.md`.
- Под second-laptop flow есть отдельная ветка `codex/openclaw-second-laptop-setup`, чтобы не мешать этот rollout с остальным repo.
- Source of truth для repo/model настроек второго ноута вынесен в `scripts/openclaw-second-laptop.config.psd1`.
- Добавлен `WSL-MIGRATION.md` как короткий fallback-runbook, если native Windows path у OpenClaw начинает разваливаться.
- На новом ноуте уже идёт реальный прогон setup через голый Codex, не только локальная сухая проверка.

## Что выяснилось

- Самый хрупкий кусок не структура pack, а первый запуск на голой Windows-машине: Codex extension/Windows path может быть нестабилен раньше, чем сам repo успевает помочь.
- Для second-laptop flow нужно держать отдельно два слоя:
  - system/bootstrap repo: `nickCodex-READY`
  - будущий GitHub-backed long-term memory repo для Клешни
- GitHub-backed память Клешни пока не встроена в автоматизацию и остаётся следующим отдельным этапом после базового bring-up.

## Ближайший фокус

- Довести до рабочего состояния второй ноут: Codex login -> finalize -> `openclaw gateway status` -> `openclaw dashboard`.
- После базового старта прикрутить Клешне отдельный GitHub-backed memory repo, не смешивая его с системным bootstrap repo.
- Решать вопрос с WSL2 только если native Windows реально не держится, а не заранее.

## Known Issues

- На части Windows-машин Codex extension может падать ещё до того, как setup repo вообще начнёт работать.
- GitHub-backed память Клешни пока не описана как повторяемый runbook: нужен либо старый источник/статья, либо отдельный ресёрч через Exa.
- В worktree уже есть посторонние незакоммиченные изменения не по second-laptop flow; их лучше не мешать в один merge.

## Next Step

- Снять фактический blocker с нового ноута, если он появится.
- После этого оформить второй этап: GitHub-backed long-term memory для Клешни.
