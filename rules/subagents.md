# Subagents

Codex работает hub-and-spoke: основной агент остаётся координатором, субагенты возвращают узкие результаты.

## Главное ограничение

Никита предпочитает активное использование субагентов. Для задач выше порога Codex должен сам решить, нужен ли `repo_recon`, `security_reviewer`, `docs_researcher`, `exa_researcher`, `browser_debugger` или другой узкий агент.

Если runtime требует явного разрешения на delegation/parallel agents, настройки repo не могут это отменить.
Если такого разрешения ещё нет в текущей сессии, спроси коротко один раз:

```text
Задача хорошо делится. Разрешаешь поднять субагентов?
```

После разрешения применяй routing из `.codex/config.toml` и `.codex/agents/*.toml` без дальнейшего ручного микроменеджмента.

## Когда делегировать

- 3+ шага research/recon
- независимые вопросы, которые можно читать параллельно
- review/security/docs/browser evidence
- большие файлы, verbose logs или шумные проверки
- сравнение двух repo, перенос идей или внешний аудит
- задача может выиграть от параллельной проверки гипотез

## Когда не делегировать

- мелкая локальная правка
- задача требует частого back-and-forth с пользователем
- следующий локальный шаг заблокирован результатом агента
- агенту пришлось бы собирать больше контекста, чем стоит сама задача

## Роли

- `repo_recon` — карта repo, entrypoints, hotspots, attack path
- `security_reviewer` — unsafe defaults, secrets, auth, deploy/network risk
- `docs_researcher` — official docs, API/version checks
- `exa_researcher` — fresh web research и implementation examples
- `notebooklm_summarizer` — source-backed summaries
- `browser_debugger` — UI reproduction, screenshots, console/network evidence
- `targeted_fixer` — маленький patch после понятной диагностики

## Правила координатора

- Разделяй scope явно: разные агенты не должны искать одно и то же.
- Проси структурированный вывод и конкретные file refs.
- Не доверяй важным claims слепо; проверь ключевое через прямое чтение/поиск.
- После возврата агентов основной Codex сам собирает решение и отвечает пользователю коротко.
