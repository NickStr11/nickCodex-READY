# AGENTS.md

Это project-local репозиторий `{{PROJECT_NAME}}`.

## Первый запуск

Если этот repo только что создан из `nickCodex-READY`, сначала заполни:
- `memory/PROJECT_CONTEXT.md` — цель, рамка, scope, ограничения
- `inbox/now.md` — один текущий фокус и 1-3 ближайших действия

Не начинай содержательную работу, пока эти файлы не отражают запрос пользователя. Не оставляй `[fill]`, если контекст можно вывести из задачи.

## С чего начинать

Читать в таком порядке:
1. `AGENTS.md`
2. `memory/PROJECT_CONTEXT.md`
3. `inbox/now.md`
4. последнюю запись в `memory/diary/`, если нужен последний handoff
5. `memory/DEV_CONTEXT.md` только если остался переходный hot-resume слой

## Как сохранять результат

- долгоживущая рамка проекта -> `memory/PROJECT_CONTEXT.md`
- текущий фокус -> `inbox/now.md`
- история завершённых сессий -> `memory/diary/`
- повторяющиеся уроки из diary/session -> `memory/reflections/`
- свежие решения, blockers, next step -> сначала `memory/diary/`, а `memory/DEV_CONTEXT.md` только как переходный слой
- отложенные идеи -> `inbox/backlog.md`
- сырой research и времянка -> `runtime/`

## Правила

- не оставляй полезные результаты только в чате
- не дублируй одно и то же в нескольких файлах
- код живёт в самом проекте, а не в файлах памяти
- не превращай `memory/DEV_CONTEXT.md` в бесконечный worklog
- reflection-проходы отмечай в `memory/reflections/processed.log`

## Subagent Routing

- Если в repo есть `.codex/agents/`, используй project-scoped subagents проактивно для read-heavy, review-heavy и browser/debug tasks.
- `repo_recon` — быстрое map/recon по repo, entrypoints и code paths.
- `security_reviewer` — read-only review на unsafe defaults, auth/secrets/network risk.
- `docs_researcher` — свежая документация, API verification, version-specific checks.
- `exa_researcher` — свежий веб-ресёрч, source discovery и implementation examples через Exa или live search.
- `notebooklm_summarizer` — source-backed summary для YouTube, статей, PDF и source bundles через NotebookLM, если он доступен.
- `browser_debugger` — воспроизведение UI багов, console/network evidence, screenshots.
- `targeted_fixer` — маленький локальный fix после того, как причина уже понятна.
- Если задача нормально бьётся на части, поднимай 2-3 узких subagents параллельно.
- Для тривиальных правок одного файла subagents не поднимать.
