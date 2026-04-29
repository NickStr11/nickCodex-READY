# AGENTS.md

Эта папка — repo-native discovery layer для Codex.

## Правила

- Канонические reusable workflows живут в `skills/`.
- `.agents/skills/*` — сгенерированные wrapper-ы для repo-scoped skill discovery, а не ручной источник истины.
- Если меняешь skill, правь `skills/*`, потом запускай `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.
- Не держи здесь project-specific одноразовые навыки.
- Wrapper-файлы держи короткими и детерминированными.
