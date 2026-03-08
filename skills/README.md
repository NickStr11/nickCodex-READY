# Skills

Навыки лежат папками, не одиночными файлами.

Формат:

```text
skills/
  skill-name/
    SKILL.md
    agents/openai.yaml
    references/
    scripts/
    assets/
```

Минимум для рабочего skill:
- `SKILL.md`
- `agents/openai.yaml`

## Ядро персональной ОС

- `maintain-context-pack` — правка и валидация portable context pack
- `edit-agent-profile` — раскладка новых инструкций по правильным profile-файлам
- `daily-session` — старт или рестарт рабочей сессии через `memory/` и `inbox/`
- `handoff-session` — короткий handoff в `memory/` и очистка текущего фокуса
- `capture-to-knowledge` — раскладка полезных инсайтов по правильным долгоживущим файлам

## Боевой слой

- `repo-recon` — быстрый вход в незнакомый репозиторий: стек, команды, entrypoints, hotspots и первый путь атаки
- `planner` — планирование по явному запросу пользователя
- `tdd-test-writer` — RED-фаза TDD и regression-first bugfix workflow
- `read-github` — чтение GitHub-реп через `gitmcp.io`
- `markdown-url` — чтение сайтов через markdown proxy
- `context7` — свежая документация по внешним библиотекам
  - Нужен `CONTEXT7_API_KEY` в `skills/context7/.env` или в окружении
- `openai-docs-skill` — официальная документация OpenAI через MCP shell-wrapper
  - Нужны `curl` и `jq`

## Фронтенд-апгрейды

- `frontend-design` — сильный визуальный фронтенд
- `frontend-responsive-ui` — mobile-first и responsive quality bar
- `vercel-react-best-practices` — performance-паттерны для React/Next.js

## Намеренно не тащили

- swarm / council / parallel orchestration
- browser-automation внешними CLI
- Gemini-зависимые штуки

## Когда добавлять новый skill

- Не добавлять новый skill под разовый кейс.
- Сначала проверить, что workflow реально повторился хотя бы 2-3 раза.
- Если повторяемости пока нет, лучше оставить это в `memory/`, `knowledge/` или обычной рабочей заметке.

Можно симлинкить папки skill'ов в `~/.claude/skills/`, если нужен reuse в Claude Code.
