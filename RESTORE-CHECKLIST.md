# Restore Checklist

Цель: поднять `nickCodex-READY` на новом или рабочем компе из GitHub и проверить, что context pack реально самодостаточный.

Этот файл можно просто дать Codex на другом компе.

## Prompt для нового Codex-чата

```text
Открой RESTORE-CHECKLIST.md и выполни его как чек-лист. Цель: скачать nickCodex-READY с GitHub, проверить bootstrap, validation, Codex usage docs, subagent config и сказать, готов ли repo к работе на этом компе. Ничего не придумывай, действуй по файлу.
```

## 1. Clone

Если repo ещё не скачан:

```powershell
cd D:\code\2026\3
git clone https://github.com/NickStr11/nickCodex-READY.git
cd nickCodex-READY
```

Если путь `D:\code\2026\3` не существует, создай его или выбери другой удобный рабочий путь.

Если repo уже скачан:

```powershell
cd D:\code\2026\3\nickCodex-READY
git pull --ff-only
```

## 2. Bootstrap

```powershell
powershell -ExecutionPolicy Bypass -File scripts/bootstrap-portable.ps1
```

Успех:
- core files найдены
- `git` и `powershell` доступны
- validator проходит
- в next steps упомянуты `AGENTS.md`, `CODEX-USAGE.md`, `DAILY.md`

## 3. Validation

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-context-pack.ps1
```

Ожидаемый результат:

```text
Repo-native skill wrappers are in sync: 22
Validation passed.
```

Потом проверить project starter:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-project-context.ps1 -TargetPath templates\project-starter
```

Ожидаемый результат:

```text
Project validation passed.
```

## 4. Readiness Check

Проверь, что есть файлы:

```powershell
Test-Path AGENTS.md
Test-Path CODEX-USAGE.md
Test-Path rules\subagents.md
Test-Path .codex\config.toml
Test-Path .codex\agents\repo-recon.toml
Test-Path .agents\skills\reflect-session\SKILL.md
Test-Path memory\reflections\processed.log
```

Все должны вернуть `True`.

## 5. Git State

```powershell
git status --short --branch
git log --oneline -3
```

Нормально:
- ветка `main`
- нет неожиданных modified/untracked файлов сразу после clone
- последние коммиты включают restore/context workflow updates

## 6. Codex Session Start

После проверок открыть repo как workspace в Codex и дать prompt:

```text
Подними AGENTS.md и CODEX-USAGE.md. Используй $daily-session, проверь текущий фокус и продолжи работу с этим context pack.
```

Важно: лучше писать именно `$daily-session`, а не просто `daily session`. Так Codex получает прямой skill-trigger и не должен угадывать интент по обычной фразе.

Для большой задачи:

```text
Подними AGENTS.md и CODEX-USAGE.md. Никита разрешает активное использование субагентов по rules/subagents.md. Разбери задачу через подходящие subagents, если она выше порога.
```

## 7. Что не чинить без причины

- Не тащить в git `.env`, secrets и локальные кэши.
- Не коммитить payload из `runtime/`, если он не нужен как осознанный artifact.
- Не редактировать `.agents/skills/*` руками; сначала править `skills/*`, потом запускать `scripts/sync-agent-skills.ps1`.
- Не переписывать `AGENTS.md` целиком, если проблема локальная и решается в `rules/`, `skills/` или `memory/`.

## 8. Итоговый ответ от Codex

После выполнения чек-листа Codex должен коротко ответить:

```text
Restore check: passed/failed.
Repo path: <path>
Git commit: <hash>
Validation: passed/failed
Project starter validation: passed/failed
Missing tools: <list or none>
Problems: <list or none>
Next step: <one concrete action>
```
