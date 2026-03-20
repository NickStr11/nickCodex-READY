# nickCodex-READY

[![Validate Context Pack](https://github.com/NickStr11/nickCodex-READY/actions/workflows/validate-context-pack.yml/badge.svg)](https://github.com/NickStr11/nickCodex-READY/actions/workflows/validate-context-pack.yml)

Персональная ОС для работы с Codex, Claude Code и другими coding agents.
Это переносимый context pack: один root contract, живая память, reusable skills, runtime-слой и шаблоны для новых repo.

## Entry Points

- `.\resume.ps1` — печатает готовый prompt для входа в текущий проект
- `.\new-project.ps1 <name>` — создаёт новый project-local repo рядом с этим pack
- `.\new-memory-repo.ps1 <name>` — создаёт отдельный git-backed memory repo рядом с этим pack
- `.\doctor.ps1` — проверяет tooling, env и минимальный project-local context
- `powershell -ExecutionPolicy Bypass -File scripts/smoke-codex-subagents.ps1` — проверяет `.codex/` config, custom agents и живой Codex runtime
- `powershell -ExecutionPolicy Bypass -File scripts/sync-project-subagents.ps1` — синхронизирует `.codex/` subagent layer в соседние project-local repo
- `.\setup-openclaw-laptop.ps1` — быстрый bootstrap второго ноута под Codex + OpenClaw
- `.\finalize-openclaw-laptop.ps1` — добивает OpenClaw после логина вторым Codex-аккаунтом
- `powershell -ExecutionPolicy Bypass -File scripts/validate-project-context.ps1 -TargetPath <path>` — валидирует project-local scaffold

## Subagents

- Project-scoped Codex subagents live in `.codex/agents/`.
- `repo_recon` - read-only architecture mapping and first-pass repo understanding
- `security_reviewer` - read-only security and unsafe-default review
- `docs_researcher` - official docs, API checks, version-sensitive verification
- `exa_researcher` - fresh web research, source discovery, current comparisons, implementation examples
- `notebooklm_summarizer` - source-backed summaries for videos, articles, PDFs, and source bundles
- `browser_debugger` - browser reproduction, screenshots, console and network evidence
- `targeted_fixer` - smallest defensible local fix after the failure mode is known
- Global subagent settings live in `.codex/config.toml`.
- Agent-specific MCP wiring lives in the matching `.codex/agents/*.toml` file.
- After changing `.codex/`, run `.\doctor.ps1` or `scripts/smoke-codex-subagents.ps1`.

## Quick Start

```powershell
cd D:\path\to\nickCodex-READY
```

Открой `AGENTS.md`, для daily работы держи рядом `DAILY.md`, для живого статуса смотри `inbox/now.md` и `memory/DEV_CONTEXT.md`.
Для переезда на другой комп используй `PORTABILITY.md`.
Для отдельной долгой памяти используй `MEMORY-REPO-RUNBOOK.md` и `.\new-memory-repo.ps1 claw-memory`.
Для редких OpenClaw-сценариев смотри `runbooks/openclaw/README.md`.

Если менялась структура или документация:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-context-pack.ps1
```

Для вклада в сам repo смотри [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
