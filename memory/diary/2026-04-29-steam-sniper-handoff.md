# 2026-04-29-steam-sniper-handoff

## Что сделано

- Разобрали production Steam Sniper и исправили путаницу с устаревшим standalone repo.
- Зафиксировали canonical source: `D:/code/2026/2/cortex/tools/steam-sniper/`.
- Подтверждено, что старый `D:/code/2026/3/steam-sniper/` переименован в `steam-sniper-OLD-do-not-use`.
- Проверили итерации по wear/exterior: extension v1.4, `source_url`, backend fail-loud, namespace separation.
- Проверили тесты в production repo: `uv run pytest -q` -> `116 passed`.
- `CODEX_TASK.md` в production repo обновлён на новый VPS `72.56.37.150`.

## Решения

- Не угадывать wear/exterior по первому или самому дешёвому варианту.
- Если item name ambiguous и нет wear/source URL, backend должен возвращать `400 wear_required`.
- `source_url` надо применять до `_resolve_item_name`, чтобы RU/Steam-search path не успел выбрать случайное качество.
- `StatTrak™`, `Souvenir`, `★` считаются отдельными namespace.

## Следующий вход

- Новый чат должен стартовать из `D:/code/2026/2/cortex/tools/steam-sniper/`.
- Сначала проверить `git status --short -- tools/steam-sniper` в `D:/code/2026/2/cortex`.
- Затем прогнать `uv run pytest -q` в `tools/steam-sniper`.
- Если продолжаем Steam Sniper, не использовать старый standalone repo.

## Хвосты

- В Cortex остались незакоммиченные изменения Steam Sniper.
- Security hardening пока отложен.
- Если нужна точная parity с lis-skins RUB UI, дальше смотреть calibration/rate source.
