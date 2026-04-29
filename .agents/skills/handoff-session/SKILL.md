---
name: handoff-session
description: "Close or pause a work session cleanly inside this personal OS. Use when Codex is finishing work, pausing a live track, needs to preserve state for later, write a diary entry in `memory/diary/`, refresh `inbox/now.md`, optionally update transitional `memory/DEV_CONTEXT.md`, or move leftovers into `inbox/backlog.md`."
---

# Repo Skill Wrapper

Canonical skill: `skills/core/handoff-session/SKILL.md`

This wrapper exists so Codex can discover the skill from `.agents/skills`.
Read and follow the canonical skill above before doing the task.
Resolve any relative `scripts/`, `references/`, `assets/`, and `agents/` paths from `skills/core/handoff-session/`.
Do not edit this wrapper manually. Regenerate it with `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.
