# Research Verification

Применять, когда агент пишет про внешний мир: GitHub repo, версии, stars,
релизы, API, цены, законы, текущие факты, сравнения инструментов или любые
числа.

## Confidence Markers

- `[✅ verified: <tool/source>]` — проверено инструментом или прямым чтением source file.
- `[⚠️ unverified]` — взято из README, чужого отчёта или обзорного текста и не проверено.
- `[🟡 inferred]` — вывод из контекста, а не прямой факт.

## Правила

- Любое число проверять через `gh api`, `git`, `curl`, официальный источник или прямое чтение файла.
- Для внешних repo фиксировать checked commit/version.
- Claims про архитектуру подтверждать source refs, не только README.
- Не делать сравнительные таблицы, если каждая важная ячейка не помечена marker’ом или source.
- Если не успел проверить, так и писать: `[⚠️ unverified]`, без уверенного тона.
- Инференсы отделять от фактов: `[🟡 inferred]`.

## Мини-пример

```text
Repo has CLI entrypoints in `pyproject.toml`. [✅ verified: direct file read]
Project has ~126k GitHub stars. [✅ verified: gh api]
The memory layer is likely optimized for user modeling. [🟡 inferred]
README says it supports plugins. [⚠️ unverified]
```
