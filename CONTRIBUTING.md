# Contributing

## Перед стартом

1. Прочитай [AGENTS.md](AGENTS.md).
2. Если работаешь внутри `rules/`, `skills/`, `knowledge/`, `memory/`, `runtime/` или `inbox/`, открой ближайший локальный `AGENTS.md`.
3. Не плодить второй источник истины. Если правило уже живёт в одном месте, усиливай его там.

## Что считается нормальной правкой

- Маленькая и понятная правка под одну цель.
- Короткие, сканируемые документы вместо простыней.
- Новый skill только если workflow реально повторился хотя бы 2-3 раза.
- Для каждого нового канонического skill обязательны `skills/core/*/SKILL.md` или `skills/optional/*/SKILL.md`, плюс рядом `agents/openai.yaml`.
- Repo-native wrapper в `.agents/skills/*` руками не редактируется: он генерируется из `skills/` через `scripts/sync-agent-skills.ps1`.
- Новым skill не давай слишком общее имя, если оно легко столкнётся с user/system skills в Codex.

## Границы слоёв

- `memory/` — активный и временный слой: текущий статус, рабочие решения, handoff и живые ограничения.
- `knowledge/` — долговечный и переиспользуемый слой: дайджесты, ресёрч, устойчивые заметки и выводы.
- Если заметка нужна только для текущего трека, не тащи её в `knowledge/`.
- Если материал можно использовать повторно через недели и месяцы, не держи его только в `memory/`.

## Что не должно попадать в git

- Секреты и `.env`.
- Payload из `runtime/`.
- Локальная времянка и машинный мусор.
- Абсолютные symlink-и на локальные vault-пути вроде `C:\Program Files\Obsidian\...`; для portability держи snapshot-файлы.

`.gitignore` уже настроен под это, но не надейся на него вслепую.

## Локальная проверка

После структурных и документных правок запускай:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-context-pack.ps1
```

Если менял что-то в `skills/`, сначала синхронизируй repo-native wrappers:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1
powershell -ExecutionPolicy Bypass -File scripts/validate-context-pack.ps1
```

GitHub Actions в [`.github/workflows/validate-context-pack.yml`](.github/workflows/validate-context-pack.yml) гоняет ту же проверку на `push` и `pull_request`.
PR review через [`.github/workflows/codex-review.yml`](.github/workflows/codex-review.yml) работает только если в репозитории настроен secret `OPENAI_API_KEY`.

Если менял профиль в Obsidian-каноне, обнови repo snapshot:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/sync-profile-from-obsidian.ps1
git diff -- aboutme.md deep-values.md deep-philosophy.md writing-style.md
```

## Pull Request bar

- Один PR = одна внятная цель.
- Если переносишь или переименовываешь файлы, сразу почини ссылки.
- Если меняешь operational-слой в `.github/`, держи его без привязки к локальной машине.
- Если меняешь `code_review.md` или `.github/codex/prompts/review.md`, проверь, что review workflow и README всё ещё согласованы.
- Если правка меняет живой статус repo, обнови `memory/DEV_CONTEXT.md`.
