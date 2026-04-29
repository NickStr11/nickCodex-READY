# 2026-03-22 — kwork retrospective memory

## Что произошло

- трек `kwork` сознательно остановлен как live automation и переведён в архивный срез
- из локального проекта убраны scheduler/task layer, Telegram operational contour, runtime secrets, session artifacts и generated live outputs
- локальный repo теперь входит через retrospective, а не через запуск автопилота

## Что важно запомнить

- главный reusable кусок не full auto-send, а `collector -> discovery passes -> scoring/state -> inbox/dialog visibility`
- первый человеческий контакт на маркетплейсе ломается раньше на voice/tone, чем на transport
- длинные AI-похожие ответы вредят сильнее, чем отсутствие автоматизации
- Telegram как alert sink легко превращается в шум, если из него не принимаются реальные решения
- KPI для таких треков надо считать как `reply -> dialog -> close`, а не как число отправок

## Где лежит основной срез

- проект: `D:\code\2026\3\kwork`
- главное summary: `D:\code\2026\3\kwork\memory\RETROSPECTIVE-2026-03-22.md`
- project status: `D:\code\2026\3\kwork\memory\PROJECT_CONTEXT.md`

## Если к этому возвращаться

- не оживлять старый runtime
- брать только reusable идеи и пересобирать operational слой с нуля
