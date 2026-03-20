# CHANGELOG

Фиксируем только значимые изменения.
Формат записи: что поменяли / зачем / источник / дата.
Новые записи сверху.

## 2026-03-18

### Changed

- Что: `claw-memory` занесён на второй ноут в `C:\Users\nsv11\code\claw-memory` и проверен как нормальный git repo.
  Зачем: закрыть не только GitHub-часть, но и локальное наличие memory repo в рабочем контуре второго ноута.
  Источник/дата: SSH-copy + `git -C C:\Users\nsv11\code\claw-memory {remote -v, rev-parse, status}`, 2026-03-18.

- Что: создан и запушен приватный GitHub repo `NickStr11/claw-memory`.
  Зачем: закрыть внешний кусок по owner/repo/auth/first push и перевести memory flow из плана в реальный Git-backed repo.
  Источник/дата: `gh auth status`, `gh repo create NickStr11/claw-memory --private --source . --remote origin --push`, 2026-03-18.

- Что: добавлен повторяемый flow для отдельного GitHub-backed memory repo Клешни.
  Зачем: перевести долгую память на repo-backed схему без ручной сборки структуры каждый раз.
  Источник/дата: `templates/memory-repo-starter`, `new-memory-repo.ps1`, `MEMORY-REPO-RUNBOOK.md`, 2026-03-18.

- Что: для второго ноутбука `Hindsight` оставлен выключенным, активный memory slot переведён на `memory-core`.
  Зачем: вернуть рабочий OpenClaw runtime без native Windows blocker.
  Источник/дата: SSH-проверка ноута `Main`, `C:\Users\nsv11\.openclaw\openclaw.json`, `C:\Users\nsv11\AppData\Local\Temp\openclaw\openclaw-2026-03-18.log`, 2026-03-18.

- Что: `hindsight-openclaw` убран из `plugins.allow` на втором ноутбуке.
  Зачем: одного `enabled = false` оказалось мало, плагин всё ещё пытался стартовать.
  Источник/дата: SSH-проверка ноута `Main`, restart `OpenClaw Gateway`, свежий хвост `openclaw-2026-03-18.log`, 2026-03-18.

- Что: подтверждён фактический blocker native Windows path для `Hindsight`.
  Зачем: зафиксировать точную причину и не тратить ещё один круг на гадание.
  Источник/дата: лог OpenClaw/Hindsight на ноуте `Main`; `mlx>=0.31.0` без `win_amd64` wheels, 2026-03-18.

### Added

- Что: заведён `memory/CHANGELOG.md` как короткий журнал значимых изменений.
  Зачем: не восстанавливать важные шаги по git-следам и обрывкам контекста.
  Источник/дата: решение в этой сессии, 2026-03-18.
