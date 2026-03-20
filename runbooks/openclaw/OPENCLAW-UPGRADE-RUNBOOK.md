# OpenClaw Upgrade Runbook

Коротко: для второго ноута лучший путь сейчас не "ещё один большой bootstrap", а аккуратный upgrade поверх уже живого OpenClaw.

Рекомендуемый порядок:

1. Сделать отдельный GitHub repo под `claw-memory`.
2. Импортировать туда полезное из `cipher-knowledge` как legacy source.
3. Держать repo-backed memory как основной путь, пока native Windows path у `Hindsight` не станет реально нужен и стабилен.
4. Добавить минимальную наблюдаемость.
5. Только потом думать про multi-agent routing и Telegram forum topics.

## Что уже должно быть готово

- На ноуте уже стоит OpenClaw.
- Telegram DM уже работает.
- Модель уже выбрана и gateway живой.
- `nickCodex-READY` остаётся system/bootstrap repo.

Не смешивать:

- `nickCodex-READY` — система и bootstrap
- `cipher-knowledge` — legacy memory source
- `claw-memory` — новый долгосрочный memory repo

## Как лучше выполнять

Лучший путь: делать по SSH с основного компа.

Почему:

- меньше токенов на ноуте
- меньше дрейфа и фантазий
- проще контролировать git, конфиги и сервисы
- легче откатить точечно, если что-то сломается

Codex на ноуте использовать как fallback:

- если нужен локальный GUI
- если нужен интерактивный login/OAuth
- если SSH временно недоступен

## Фаза 1. Claw Memory Repo

Цель: вынести долгую память из локального runtime в отдельный приватный GitHub repo.

Не собирать это руками каждый раз. В `nickCodex-READY` уже есть:

- starter: `templates/memory-repo-starter/`
- bootstrap script: `.\new-memory-repo.ps1`
- отдельный runbook: `MEMORY-REPO-RUNBOOK.md`

Быстрый старт:

```powershell
.\new-memory-repo.ps1 -RepoName claw-memory -OwnerName Nikita -AgentName "Kleshnya / Cipher V2"
```

Что переносить из `cipher-knowledge`:

- стабильные факты о пользователе
- полезные long-term preferences
- persona / tone / role notes
- долговечные project summaries

Что не переносить:

- старые временные заметки
- мусорные runtime следы
- устаревшие operational артефакты
- всё подряд без фильтрации

## Фаза 2. Hindsight

Предпочтительный plugin в будущем: `Hindsight`.

Почему:

- self-hosted / local-first
- без vendor lock
- auto-inject памяти перед ответом
- подходит под одного юзера и один Telegram DM better, чем SaaS path

Но прямо сейчас есть важная оговорка:

- на текущем native Windows втором ноуте `Hindsight` уже упёрся в blocker по `mlx` и отсутствующим `win_amd64` wheels
- значит сейчас не надо делать вид, что memory plugin вот-вот взлетит на этой машине
- repo-backed memory уже достаточно, чтобы продолжать работу без авто-memory слоя

Пока не делать:

- `Supermemory`, если не нужен cloud speed-run
- `Mem0`, если нет отдельной причины идти именно в mem0-стек
- ещё один круг native Windows фиксов ради `Hindsight`, если без него уже можно работать

## Фаза 3. Observability

Минимум, который нужен:

- лог gateway ошибок
- понятный статус memory plugin
- видимость, какой поиск реально использовался
- базовый след по tool calls и latency

Если нужен следующий уровень:

- `Langfuse`

Но это уже после того, как память поднята и не ломает runtime.

## Фаза 4. Multi-Agent

Не первый шаг.

Делать только если:

- single-agent стабилен
- memory layer уже живой
- Telegram DM уже не плавает

До этого multi-agent только добавит хрупкости.

## Готовый prompt для Codex на ноуте

```text
На этом ноуте уже есть рабочий OpenClaw runtime. Не ломая текущий Telegram/gateway/model setup, нужно аккуратно сделать следующий upgrade-слой.

Контекст:
- system/bootstrap repo: https://github.com/NickStr11/nickCodex-READY
- legacy memory source: https://github.com/NickStr11/cipher-knowledge
- это не одно и то же
- текущий OpenClaw runtime уже живой

Цель:
1. подготовить отдельный GitHub repo под claw-memory
2. импортировать туда только полезную долгосрочную память из cipher-knowledge
3. затем подготовить почву под self-hosted memory plugin, приоритетно Hindsight
4. не трогать без нужды текущие Telegram/gateway/model/auth настройки

Что делать:
1. Проверь текущее состояние OpenClaw workspace, config и memory files.
2. Склонируй cipher-knowledge в отдельную папку как legacy source.
3. Проанализируй, какие файлы из cipher-knowledge подходят для долгосрочной памяти, а какие являются мусором или устаревшим operational слоем.
4. Подготовь структуру нового claw-memory repo:
   - persona/
   - memory/
   - handoff/
   - knowledge/imported/cipher-knowledge/
5. Не копируй всё подряд. Импортируй только стабильные long-term facts, preferences, persona notes и project summaries.
6. Не заменяй текущий OpenClaw workspace старым repo.
7. Не ломай Telegram, gateway, model config или auth.
8. После этого отдельно оцени, готова ли эта машина к подключению Hindsight как self-hosted memory layer.
9. В конце коротко покажи:
   - что импортировал
   - что не трогал
   - нужен ли отдельный новый GitHub repo прямо сейчас
   - что будет следующим шагом для Hindsight

Правила:
- сначала действие, потом короткий статус
- не выдумывай
- не делай destructive changes
- если упёрся в git auth, GitHub repo creation или права, покажи точную причину
```

## Готовый путь для SSH

Если делать не через Codex на ноуте, а напрямую:

1. создать приватный `claw-memory` repo
2. прогнать `.\new-memory-repo.ps1`
3. клонировать `cipher-knowledge`
4. собрать curated import
5. положить repo на ноут
6. затем отдельно решать, нужен ли вообще `Hindsight`

Это предпочтительный путь.

## Источники

- https://github.com/supermemoryai/openclaw-supermemory
- https://hindsight.vectorize.io/blog/2026/03/06/adding-memory-to-openclaw-with-hindsight
- https://github.com/tensakulabs/openclaw-mem0
- https://docs.openclaw.ai/tools/subagents
- https://docs.openclaw.ai/concepts/multi-agent
- https://github.com/openclaw/openclaw/issues/43295
- https://github.com/openclaw/openclaw/issues/31473
- https://github.com/openclaw/openclaw/issues/44240
- https://github.com/openclaw/openclaw/issues/44492
