# Memory Repo Runbook

Коротко: долгую память Клешни лучше держать не в `nickCodex-READY` и не в
runtime OpenClaw, а в отдельном приватном Git repo.

Не смешивать:

- `nickCodex-READY` — system/bootstrap repo
- `cipher-knowledge` или другой старый repo — legacy source
- `claw-memory` — новый GitHub-backed long-term memory repo

## Когда это нужно

- `Hindsight` выключен или не нужен.
- Хочется нормальную историю изменений через git.
- Нужна отдельная долговечная память без смешивания с bootstrap-репо.
- Нужно, чтобы память была читаемой человеком, а не только плагином.

## Что уже сделано в этом repo

- добавлен starter: `templates/memory-repo-starter/`
- добавлен bootstrap script: `.\new-memory-repo.ps1`
- добавлен validator: `templates/memory-repo-starter/scripts/validate-memory-repo.ps1`

## Быстрый старт

Из корня `nickCodex-READY`:

```powershell
.\new-memory-repo.ps1 -RepoName claw-memory -OwnerName Nikita -AgentName "Kleshnya / Cipher V2"
```

Это создаст рядом новый локальный repo со структурой под long-term memory.

## Рекомендуемый flow после создания

1. Перейти в новый repo.

```powershell
cd ..\claw-memory
```

2. Заполнить минимум:

- `persona/voice.md`
- `persona/operator-rules.md`
- `memory/user-profile.md`
- `memory/stable-facts.md`
- `memory/projects.md`

3. Прогнать проверку:

```powershell
.\scripts\validate-memory-repo.ps1
```

4. Сделать первый локальный коммит:

```powershell
git add .
git commit -m "Initial memory repo scaffold"
```

5. Создать приватный GitHub repo и запушить.

Если `gh` уже авторизован:

```powershell
gh repo create NickStr11/claw-memory --private --source . --remote origin --push
```

Если `gh` не авторизован или не нужен:

- создай приватный repo руками в GitHub
- потом добавь `origin` обычным `git remote add origin ...`
- и сделай `git push -u origin main`

## Что куда писать

- `persona/voice.md` — стиль ответа, тон, что сохранять в речи
- `persona/operator-rules.md` — короткие operational guardrails
- `memory/user-profile.md` — стабильные факты о пользователе и его способе работы
- `memory/stable-facts.md` — долговечные факты и предпочтения с источником/датой
- `memory/projects.md` — активные и важные долгие проекты, не daily task list
- `memory/relationships.md` — люди и связи, только если это реально нужно
- `memory/CHANGELOG.md` — важные изменения по схеме `что / зачем / источник / дата`
- `handoff/now.md` — горячий контекст на ближайшие 1-3 сессии
- `handoff/recent-decisions.md` — свежие решения, которые ещё не разложены окончательно
- `knowledge/imported/cipher-knowledge/` — curated import из legacy repo
- `runtime/imports/` — сырые импорты до разборки

## Что переносить из legacy repo

- стабильные факты о Никите
- полезные long-term preferences
- persona / tone / role notes
- долговечные project summaries

## Что не переносить

- старые временные заметки
- мусорные runtime следы
- устаревшие operational артефакты
- всё подряд без фильтрации

## Дисциплина обновления

После нормальной сессии:

1. сырые логи и куски чата кидай в `runtime/imports/`, если они вообще нужны
2. стабильные факты переноси в `memory/*`
3. свежее горячее состояние клади в `handoff/now.md`
4. значимые сдвиги фиксируй в `memory/CHANGELOG.md`
5. дальше коммит в git, чтобы была история

## Как это связано со вторым ноутом

Текущий приоритет для второго ноута:

- держать OpenClaw живым без `Hindsight`
- вести память через repo-backed схему
- возвращаться к `Hindsight` только если он реально понадобится

То есть сейчас memory repo — это основной путь, а не временный костыль.
