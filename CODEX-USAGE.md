# Codex Usage

Короткий рабочий режим для Codex-сессий в этом pack.

## Старт сессии

Обычный вход:

```text
Подними инструкции и сделай <задача>.
```

Если нужно восстановить текущий трек:

```text
Используй $daily-session, подними текущий фокус и продолжи <задача>.
```

Codex должен прочитать `AGENTS.md`, базовые правила, `aboutme.md`, а живую память грузить только по необходимости.

## Автопилот проверок

Никита не должен руками помнить служебные команды. Codex сам запускает нужный read-only helper, когда задача подходит:

- если пользователь ссылается на прошлые сессии, diary, handoff, “мы уже делали”, “помнишь”, “найди где” — запустить `scripts/search-session-notes.ps1` с подходящим `-Query`;
- если задача выглядит как повторяющийся симптом/сбой — сначала проверить `knowledge/learned-the-hard-way.md` по ключевым словам;
- если работа касается внешнего repo/research — использовать `runtime/research/RECON-TEMPLATE.md` и сохранить заметку в `runtime/research/`;
- если менялись структура, docs, scripts, context layers или reusable workflow — запустить `scripts/validate-context-pack.ps1`;
- если задача про чистку/качество context pack, skills, broken refs или локальные абсолютные пути — запустить `scripts/scan-context-pack-health.ps1`;
- если менялись `skills/` — сначала `scripts/sync-agent-skills.ps1`, потом `scripts/validate-context-pack.ps1`.

Команды ниже существуют для Codex и CI, не как ручной UX для Никиты.

## Субагенты

Никита даёт standing preference: Codex может сам запускать субагентов на своё усмотрение, если задача достаточно большая, read-heavy, review-heavy, research-heavy или хорошо делится на независимые куски.

То есть по умолчанию не надо ждать, пока пользователь перечислит роли руками. Если scope подходит, Codex выбирает bundle сам и остаётся координатором.

Ограничение среды: если конкретный runtime требует явного разрешения на delegation/parallel agents в текущем сообщении, repo-настройки не могут это перебить. В таком случае Codex должен коротко запросить разрешение один раз, а не молча работать без субагентов.

Надёжные фразы:

```text
Разрешаю субагентов: разбери через repo_recon + security_reviewer + docs_researcher.
```

```text
Разбери с параллельными агентами и потом сам собери итог.
```

```text
Используй subagents, если задача нормально делится.
```

`.codex/config.toml` и `.codex/agents/*.toml` задают routing, роли, prompts и лимиты. Они помогают Codex выбрать правильных агентов, но не отменяют runtime-правило: если среда требует явного разрешения, пользователь должен дать его в сообщении.

## Когда включать субагентов

- большой repo-recon или review
- security/docs/browser evidence
- свежий web/docs research
- независимые куски, которые можно проверить параллельно
- длинные логи или шумный анализ, который не стоит тащить в основной контекст

Не включать:
- мелкая правка одного файла
- задача требует частого диалога с пользователем
- следующий шаг зависит от результата прямо сейчас и быстрее сделать самому

## Внешний repo recon

Для чужого repo или внешнего проекта:

1. Клонировать или выгрузить источник в `runtime/research/<repo-slug>-src/`.
2. Зафиксировать checked commit/version.
3. Проверять claims по source files, не только README.
4. Сохранять короткую заметку по `runtime/research/RECON-TEMPLATE.md`.
5. Делить вывод на `можно внедрить`, `изучить глубже`, `не переносить`.

Root contract не раздувать. Если идея reusable, сначала оставить её в recon/report, потом отдельно решить, куда она принадлежит: `CODEX-USAGE.md`, `rules/`, `skills/`, `memory/`, `knowledge/` или `scripts/`.

Read-only helpers:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/scan-context-pack-health.ps1
powershell -ExecutionPolicy Bypass -File scripts/search-session-notes.ps1 -Query "hermes"
```

## Завершение

Если сессия была содержательной:

```text
Сделай handoff.
```

или:

```text
Конец сессии.
```

Ожидаемый результат: короткая запись в `memory/diary/`, обновлённый `inbox/now.md`, хвосты в `inbox/backlog.md`, без раздувания `memory/DEV_CONTEXT.md`.

## Reflection

Раз в несколько сессий:

```text
Используй $reflect-session: посмотри последние diary/session и вынеси повторяющиеся уроки в правила, memory или skills.
```

Reflection не нужен после каждой мелкой задачи. Это цикл для повторяющихся паттернов, а не для пересказа одной сессии.
