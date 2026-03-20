# 2026-03-20 — funding-scanner + FUNDthe

## Что делали

- Подняли рабочий контур вокруг `funding-scanner` как реального operational tool, а не только локального клона.
- Использовали authenticated `tablefundthe.replit.app` как truth source для live/historical checks.
- Подключили приватный чат `FUNDthe` через уже существующую Telethon session в `D:\code\2026\2\cortex\tools\tg-monitor`.
- Смотрели свежие сигналы из чата и сравнивали их с original scanner.

## Что выяснилось

- Для реальных входов локального сканера одного мало: reference scanner и чат с сигналами дают более честную operational картину.
- По `BTC` и `BCH` режимы могут резко меняться внутри дня; особенно `BCH EXTENDED / PACIFICA` реально оживал после почти схлопнувшегося spread.
- `FUNDthe` годится как source of ideas, но без перепроверки через scanner там легко спутать живой сетап, рваную аномалию и просто сопровождение старой позы.

## Инфра

- На VM у `funding-scanner` был продовый сбой: `funding-scanner.timer` оказался `masked`, а systemd unit-файлы стали нулевыми.
- Из-за этого live часть панели умерла, historical осталась жить, UI зависал на `Connecting...`.
- Инцидент починен: unit-файлы восстановлены, timer снова активен, web перезапущен, live snapshot снова живой.
- Отдельно починен баг login page в `web.py` и подкручен тёмный стиль dropdown в `dashboard_page.py`.

## Где продолжать

- Основной проект: `D:\code\2026\3\funding-scanner`
- Сигнальный/чатовый слой: `D:\code\2026\2\cortex\tools\tg-monitor`
- Главное hot-resume по проекту: `D:\code\2026\3\funding-scanner\memory\DEV_CONTEXT.md`
- Ближайший next step: `D:\code\2026\3\funding-scanner\inbox\now.md`
