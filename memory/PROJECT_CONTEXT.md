# PROJECT_CONTEXT

## Проект

- Название: `nickCodex-READY`
- Тип: переносимый agent context pack / personal OS repo
- Цель: дать Никите рабочую агентную среду, которая быстро поднимается, помогает заходить в новые проекты и не требует каждый раз ручной инициализации

## Что уже есть

- root contract через `AGENTS.md`
- слои `rules/`, `skills/`, `knowledge/`, `memory/`, `inbox/`, `runtime/`
- разделение `skills/core/` и `skills/optional/` вместо одного плоского skill-склада
- личный профиль в `aboutme.md` и глубокие контекстные файлы рядом
- operational shell: `resume.ps1`, `new-project.ps1`, `doctor.ps1`
- project starter layer через `templates/project-starter/`
- structural validation через `scripts/validate-context-pack.ps1` и `scripts/validate-project-context.ps1`
- короткие operational entrypoints `PORTABILITY.md` и `DAILY.md`
- `scripts/bootstrap-portable.ps1` для быстрого старта на новом компе
- боевые skills для repo входа, research, docs, TDD, video analysis и NotebookLM-backed research
- project-scoped subagent layer в `.codex/agents/` для `repo_recon`, `security_reviewer`, `docs_researcher`, `browser_debugger` и `targeted_fixer`, который должен включаться проактивно по типу задачи, а не только по ручной команде пользователя
- safety-map check внутри `repo-recon` для хрупких и интеграционно тяжёлых систем

## Текущий фокус

- держать repo боевым, но не дать ему начать жить как свалка operational-хвостов
- усиливать только те workflows, которые реально повторяются в живой работе
- отделять reusable OS-слой от project-specific и экспериментального мусора

## Ограничения

- это не продуктовый монорепо и не execution-lab уровня `cortex`
- active context должен оставаться маленьким и честным
- skill-слой не должен превращаться в склад одноразовых project-specific заготовок
- runtime должен поглощать времянку, а не root

## Следующие шаги

- закрепить anti-sprawl discipline: чистый корень, синхронная hot memory, строгий reusable bar для `skills/`
- pressure-test `repo-recon`, `notebooklm-research` и `video-analyzer` на боевых задачах
- решать про `progress`/compose/global layer только по реальному симптому, не по теории
- при необходимости добавить automation/commands слой без превращения пака в `cortex`
