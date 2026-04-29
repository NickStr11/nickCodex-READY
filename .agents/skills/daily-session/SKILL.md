---
name: daily-session
description: "Start or resume a focused work session inside this personal OS. Use when Codex begins work for the day, resumes after context loss, needs to choose one active track, triages `inbox/backlog.md`, or refreshes `inbox/now.md` from `memory/PROJECT_CONTEXT.md`, recent diary entries, and any remaining transitional `memory/DEV_CONTEXT.md`."
---

# Repo Skill Wrapper

Canonical skill: `skills/core/daily-session/SKILL.md`

This wrapper exists so Codex can discover the skill from `.agents/skills`.
Read and follow the canonical skill above before doing the task.
Resolve any relative `scripts/`, `references/`, `assets/`, and `agents/` paths from `skills/core/daily-session/`.
Do not edit this wrapper manually. Regenerate it with `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.
