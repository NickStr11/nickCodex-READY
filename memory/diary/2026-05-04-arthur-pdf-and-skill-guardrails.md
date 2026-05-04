# 2026-05-04-arthur-pdf-and-skill-guardrails

## Что сделано

- Доведён PDF для Артура: `C:\Users\User\Desktop\nickCodex-READY-Arthur-terminal-dossier.pdf`.
- В `huashu-design` закреплены правила A4/PDF вёрстки: render QA, русские переносы, pipeline labels, labeled callouts, контраст на тёмной теме.
- Создан desktop brief для Клода: `C:\Users\User\Desktop\CLAUDE-PDF-DESIGN-BRIEF.md`.
- Проверен `ComposioHQ/awesome-codex-skills`; полезные паттерны перенесены без установки чужой пачки.
- Добавлены guardrails:
  - `skills/core/maintain-context-pack/SKILL.md` — batch/done.list/dry-run для больших миграций.
  - `skills/core/repo-recon/SKILL.md` — triage внешних skill catalogs.
  - `rules/work-style.md` — helper scripts как black box, awesome-lists не ставить пачкой.

## Решения

- `awesome-codex-skills` не импортировать bulk-ом: слишком много vendor/auth/one-off automation.
- Для внешних skill repos сначала вытаскивать reusable workflow pattern, потом решать про отдельный skill.
- Для динамического `aboutme.md` правильный путь: staging layer `personal_observations.md` с explicit confirm, не auto-rewrite профиля.

## Следующий вход

- Новый чат лучше начинать как hypothesis/improvement lane для `nickCodex-READY`.
- Если продолжать улучшение pack: сначала прочитать `AGENTS.md`, `CODEX-USAGE.md`, применить `$daily-session`, потом выбрать один маленький трек.

## Хвосты

- Внедрить `memory/personal_observations.md` + handoff surfacing для unconfirmed личных наблюдений.
- При необходимости отдельно развить writing workflow на базе `content-research-writer` паттерна: outline -> research gaps -> section feedback -> citations.
