# Skills

Навыки лежат leaf-папками со skill file вроде `core/*/SKILL.md` или `optional/*/SKILL.md`.

Текущая раскладка:

```text
skills/
  core/
    skill-name/
      SKILL.md
      agents/openai.yaml
      references/
      scripts/
      assets/
  optional/
    skill-name/
      SKILL.md
      agents/openai.yaml
      references/
      scripts/
      assets/
```

`core/` — минимальный OS-слой, который держит сам pack в рабочем состоянии.

`optional/` — боевые и внешние навыки. Они reusable, но не обязательны для каждого нового проекта.

Минимум для рабочего skill:
- `core/*/SKILL.md` или `optional/*/SKILL.md`
- `core/*/agents/openai.yaml` или `optional/*/agents/openai.yaml`

## Core

- `maintain-context-pack` — правка и валидация portable context pack
- `edit-agent-profile` — раскладка новых инструкций по правильным profile-файлам
- `daily-session` — старт или рестарт рабочей сессии через `memory/` и `inbox/`
- `handoff-session` — короткий handoff в `memory/` и очистка текущего фокуса
- `close-session` — один вход на конец сессии: handoff, backlog cleanup и capture если надо
- `capture-to-knowledge` — раскладка полезных инсайтов по правильным долгоживущим файлам
- `repo-recon` — быстрый вход в незнакомый репозиторий: стек, команды, entrypoints, hotspots и первый путь атаки

## Optional

- `video-analyzer` — разбор одного видео, пачки видео или канала/плейлиста
- `notebooklm-research` — deep research через Google NotebookLM CLI
- `exa-research` — research-first поиск и code context через Exa MCP
- `planner` — планирование по явному запросу пользователя
- `openclaw-memory-cutover` — cutover OpenClaw с сломанного `Hindsight` на отдельный repo-backed memory flow
- `tdd-test-writer` — RED-фаза TDD и regression-first bugfix workflow
- `read-github` — чтение GitHub-реп через `gitmcp.io`
- `markdown-url` — чтение сайтов через markdown proxy
- `context7` — свежая документация по внешним библиотекам
- `openai-docs-skill` — официальная документация OpenAI через shell-wrapper
- `human-writing-voice` — перепись текста в более живой и менее AI-вылизанный голос
- `frontend-design` — сильный визуальный фронтенд
- `frontend-responsive-ui` — mobile-first и responsive quality bar
- `vercel-react-best-practices` — performance-паттерны для React/Next.js

## Правило против расползания

- В `skills/` остаются только reusable workflows.
- Project-specific навыки не живут тут: им место в project repo или в `runtime/scratch/`.
- Если новый навык не нужен минимум в двух разных задачах, не тащи его в этот слой.

## Намеренно не тащили

- swarm / council / parallel orchestration
- browser-automation внешними CLI
- завязку на отдельный marketplace ради самого marketplace

Если нужен reuse в Claude Code, можно симлинкать leaf-папки skill'ов в `~/.claude/skills/`.
