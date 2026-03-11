# DEV_CONTEXT

## Последнее обновление

- Дата: 2026-03-11

## Текущий статус

- Репо уже оформлено как нормальный portable context pack: `memory/`, `runtime/`, `inbox/`, `CLAUDE.md`, CI, issue templates, PR template, `LICENSE`, `.gitignore`, `.gitattributes`.
- Добавлены короткие operational entrypoints `PORTABILITY.md` и `DAILY.md`.
- Добавлен `scripts/bootstrap-portable.ps1` для быстрого старта на новой машине.
- Добавлен operational shell:
  - `resume.ps1`
  - `new-project.ps1`
  - `doctor.ps1`
  - `scripts/validate-project-context.ps1`
- Добавлен starter scaffold в `templates/project-starter/`.
- Добавлен `repo-recon` и усилен safety-map шагом для хрупких систем и опасных рефакторингов.
- Добавлен `notebooklm-research` с реальным adapter script и живым smoke test через `notebooklm` CLI.
- Pack validator усилен: теперь проверяет публичные слои, alias-файлы, bootstrap-путь, nested skills и safety-map для `repo-recon`.
- `skills/` разрезан на `core/` и `optional/`, чтобы OS-слой и боевые интеграции не жили вперемешку.

## Что выяснилось

- Структура repo ещё держится, но drift начинается не по схеме, а по дисциплине.
- В корень начинают лезть task-specific артефакты и experiment files, если не чистить их сразу.
- `inbox/now.md` и memory быстро отстают от реального состояния repo, если не синхронизировать их после структурных правок.
- В `skills/` легко начинают появляться project-specific хвосты, если не держать reusable bar жёстко.

## Ближайший фокус

- Держать корень каноническим входом, а не рабочим столом.
- Держать `skills/` только для реально reusable workflows.
- Pressure-test'нуть `repo-recon`, `notebooklm-research` и `video-analyzer` на живых задачах, а не только на smoke test.
- Развивать только те слои, которые реально сокращают ручную рутину.

## Known Issues

- Часть старых markdown-файлов по-прежнему отображается в shell с mojibake из-за кодировки консоли, хотя сами файлы живы.
- Рядом с repo уже накопились test project folders от smoke test, их лучше разобрать отдельно от этого cleanup.

## Next Step

- После cleanup добить реальные боевые прогоны для `repo-recon`, `notebooklm-research` и `video-analyzer`, а потом уже решать, нужен ли следующий слой automation/commands.
