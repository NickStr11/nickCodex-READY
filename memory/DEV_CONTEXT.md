# DEV_CONTEXT

> Deprecated as the main session-history layer.
> New session history should go to `memory/diary/`.
> Keep this file only as a small transitional hot-resume layer until the diary flow proves itself in real use.

## Последнее обновление

- Дата: 2026-03-18
- Last verified from: локальный repo state, SSH-сессия на ноут `Main`, remote OpenClaw config/logs

## Текущая правда

- Репо уже оформлено как portable context pack: `memory/`, `runtime/`, `inbox/`, `CLAUDE.md`, CI, issue templates, PR template, `LICENSE`, `.gitignore`, `.gitattributes`.
- В project config включён multi-agent режим: `.codex/config.toml` держит `[agents]` с `max_threads = 6`, `max_depth = 1`, `job_max_runtime_seconds = 1800`.
- В `.codex/agents/` есть project-scoped subagents: `repo_recon`, `security_reviewer`, `docs_researcher`, `browser_debugger`, `targeted_fixer`.
- Для второго ноута выделен отдельный rollout: `setup-openclaw-laptop.ps1`, `finalize-openclaw-laptop.ps1`, `runbooks/openclaw/OPENCLAW-SECOND-LAPTOP.md`, `runbooks/openclaw/FRESH-CODEX-OPENCLAW-PROMPT.md`.
- Для repo-backed long-term memory добавлен отдельный starter и bootstrap: `templates/memory-repo-starter/`, `new-memory-repo.ps1`, `MEMORY-REPO-RUNBOOK.md`.
- Реальный приватный GitHub repo под память уже создан: `https://github.com/NickStr11/claw-memory` с первым `main`.
- Репо `claw-memory` уже лежит и на втором ноуте: `C:\Users\nsv11\code\claw-memory`, `origin` настроен, `git status` чистый.
- Под second-laptop flow есть отдельная ветка `codex/openclaw-second-laptop-setup`, чтобы не мешать rollout с остальным repo.
- Source of truth для repo/model настроек второго ноута вынесен в `scripts/openclaw-second-laptop.config.psd1`.
- На втором ноуте OpenClaw gateway сейчас жив без `Hindsight`; рабочая память пока ведётся через repo-файлы и git, а не через auto-memory plugin.

## Память без Hindsight

- `inbox/now.md` — один активный трек, 2-4 ближайших действия, parked.
- `memory/DEV_CONTEXT.md` — текущая правда: что работает, что сломано, какие решения уже приняты, что проверено и откуда факт.
- `memory/PROJECT_CONTEXT.md` — стабильная рамка repo: цель, ограничения, архитектурные границы.
- `memory/CHANGELOG.md` — короткая история значимых изменений с `что / зачем / источник / дата`.
- `runtime/` — сырые логи, дампы, выгрузки и временные артефакты; не держать это в active memory.

## Свежие решения

- Что: `Hindsight` на втором ноуте оставлен выключенным.
  Зачем: native Windows path упирается в несовместимость зависимостей и не даёт стабильный runtime.
  Источник/дата: SSH-проверка ноута `Main`, OpenClaw/Hindsight logs, 2026-03-18.

- Что: memory slot на втором ноуте переключён на `memory-core`, а `hindsight-openclaw` убран из `plugins.allow`.
  Зачем: одного `enabled = false` не хватало, плагин всё ещё пытался стартовать.
  Источник/дата: remote `C:\Users\nsv11\.openclaw\openclaw.json`, restart `OpenClaw Gateway`, 2026-03-18.

- Что: отдельный GitHub-backed memory repo для Клешни остаётся следующим этапом после базового bring-up.
  Зачем: долгую память лучше вынести в отдельный repo, не смешивая её с системным bootstrap pack.
  Источник/дата: текущий second-laptop track, `MEMORY-REPO-RUNBOOK.md`, 2026-03-18.

- Что: для отдельного memory repo уже оформлен повторяемый scaffold и validator.
  Зачем: чтобы следующий шаг был командой, а не новой импровизацией по структуре.
  Источник/дата: `templates/memory-repo-starter/`, `scripts/new-memory-repo.ps1`, 2026-03-18.

- Что: приватный `NickStr11/claw-memory` уже создан и получил первый commit/push.
  Зачем: закрыть внешний setup-кусок и перевести long-term memory в реальный Git-backed repo.
  Источник/дата: `gh auth status`, local git commit `76b937b`, `gh repo create ... --push`, 2026-03-18.

- Что: `claw-memory` уже доставлен на второй ноут и проверен как чистый git repo на commit `7138137`.
  Зачем: чтобы repo-backed memory была не только в GitHub и на основном компе, но и в реальном рабочем контуре второго ноута.
  Источник/дата: SSH-copy + remote `git -C C:\Users\nsv11\code\claw-memory {remote -v, rev-parse, status}`, 2026-03-18.

## Что выяснилось

- Самый хрупкий кусок не структура pack, а первый запуск на голой Windows-машине: Codex extension/Windows path может быть нестабилен раньше, чем сам repo успеет помочь.
- Subagents в Codex уже можно оформлять не как абстрактный playbook, а как реальные TOML-агенты в `.codex/agents/`; это закрывает часть разрыва между pack-документацией и живой механикой.
- Для second-laptop flow нужно держать отдельно два слоя:
  - system/bootstrap repo: `nickCodex-READY`
  - будущий GitHub-backed long-term memory repo для Клешни

## Known Issues

- На части Windows-машин Codex extension может падать ещё до того, как setup repo вообще начнёт работать.
- Native Windows path для `Hindsight` на втором ноуте сейчас заблокирован зависимостью `mlx`: нет подходящих `win_amd64` wheels.
- В worktree уже есть посторонние незакоммиченные изменения не по second-laptop flow; их лучше не мешать в один merge.

## Ближайший фокус

- Держать второй ноут в рабочем состоянии с OpenClaw без `Hindsight`, не тратить ещё круг на native Windows patching.
- После базового старта использовать уже занесённый `claw-memory` на втором ноуте и продолжить curated import.
- Решать вопрос с WSL2 только если `Hindsight` снова станет обязательным требованием, а не заранее.

## Next Step

- Зафиксировать путь `C:\Users\nsv11\code\claw-memory` в рабочем контуре второго ноута и продолжить curated import из `cipher-knowledge`.
- После нового чата или рестарта Codex pressure-test'нуть новых subagents на реальном `repo_recon`, `security review` и docs-driven задаче.
- Проверить, что авто-роутинг реально срабатывает без ручной фразы пользователя, а не остаётся только в конфиге и документации.
