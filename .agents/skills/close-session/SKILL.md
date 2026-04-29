---
name: close-session
description: "Close or pause a work session inside this personal OS with one command. Use when the user says `конец сессии`, `закрой сессию`, `сохрани итог`, `сделай handoff`, or otherwise asks Codex to wrap up work, write a diary entry, update `inbox/now.md`, move leftovers into `inbox/backlog.md`, preserve only transitional hot state in `memory/DEV_CONTEXT.md`, and route stable insights into the right long-lived file."
---

# Repo Skill Wrapper

Canonical skill: `skills/core/close-session/SKILL.md`

This wrapper exists so Codex can discover the skill from `.agents/skills`.
Read and follow the canonical skill above before doing the task.
Resolve any relative `scripts/`, `references/`, `assets/`, and `agents/` paths from `skills/core/close-session/`.
Do not edit this wrapper manually. Regenerate it with `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.
