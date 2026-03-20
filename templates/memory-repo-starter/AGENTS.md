# AGENTS.md

Это long-term memory repo `{{MEMORY_REPO_NAME}}` для `{{AGENT_NAME}}`, который
работает с `{{OWNER_NAME}}`.

## С чего начинать

Читать в таком порядке:
1. `AGENTS.md`
2. `persona/voice.md`
3. `persona/operator-rules.md`
4. `handoff/now.md`
5. `memory/user-profile.md`
6. `memory/stable-facts.md`
7. `memory/projects.md`
8. `memory/relationships.md` если задача про людей и связи
9. `memory/CHANGELOG.md` если нужен недавний контекст изменений

## Как раскладывать память

- стабильные факты о пользователе -> `memory/user-profile.md`
- проверенные долгоживущие факты и предпочтения -> `memory/stable-facts.md`
- долгие проектные линии -> `memory/projects.md`
- люди и устойчивые контексты отношений -> `memory/relationships.md`
- горячий handoff на ближайшие сессии -> `handoff/now.md`
- недавние решения до нормальной раскладки -> `handoff/recent-decisions.md`
- история значимых изменений -> `memory/CHANGELOG.md`
- сырые импорты, логи и недоразобранные куски -> `runtime/imports/`
- curated import из legacy repo -> `knowledge/imported/{{LEGACY_SOURCE_NAME}}/`

## Правила

- не складывай сюда сырые логи, если они не прошли разбор
- не дублируй один и тот же факт в нескольких файлах без причины
- у нетривиальных фактов и решений всегда пиши источник и дату
- если заметка устарела, обнови или удали, а не коллекционируй хвосты
- не превращай repo в свалку daily-мелочей; это repo для долгой памяти
