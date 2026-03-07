# Contributing

## Перед стартом

1. Прочитай [AGENTS.md](AGENTS.md).
2. Если работаешь внутри `rules/`, `skills/`, `knowledge/`, `memory/`, `runtime/` или `inbox/`, открой ближайший локальный `AGENTS.md`.
3. Не плодить второй источник истины. Если правило уже живёт в одном месте, усиливай его там.

## Что считается нормальной правкой

- Маленькая и понятная правка под одну цель.
- Короткие, сканируемые документы вместо простыней.
- Новый skill только если это реально повторяемый workflow.
- Для каждого нового skill обязательны `skills/*/SKILL.md` и `skills/*/agents/openai.yaml`.

## Что не должно попадать в git

- Секреты и `.env`.
- Payload из `runtime/`.
- Локальная времянка и машинный мусор.

`.gitignore` уже настроен под это, но не надейся на него вслепую.

## Локальная проверка

После структурных и документных правок запускай:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-context-pack.ps1
```

GitHub Actions в [`.github/workflows/validate-context-pack.yml`](.github/workflows/validate-context-pack.yml) гоняет ту же проверку на `push` и `pull_request`.

## Pull Request bar

- Один PR = одна внятная цель.
- Если переносишь или переименовываешь файлы, сразу почини ссылки.
- Если меняешь operational-слой в `.github/`, держи его без привязки к локальной машине.
- Если правка меняет живой статус репо, обнови `memory/DEV_CONTEXT.md`.
