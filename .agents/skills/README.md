# Repo-Native Skills

Этот слой нужен только для того, чтобы Codex видел repo-scoped skills по официальному пути `.agents/skills/`.

- Канон остаётся в `skills/`.
- Каждая папка в `.agents/skills/*` — маленький wrapper на канонический skill.
- Wrapper-ы генерируются скриптом `scripts/sync-agent-skills.ps1`.
- Не редактируй `.agents/skills/*` руками: следующая синхронизация их перезапишет.
