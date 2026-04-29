---
name: openclaw-memory-cutover
description: >
  Stabilize an OpenClaw setup by separating the live workspace from durable memory
  and cutting over from broken or unwanted Hindsight to a git-backed memory repo.
  Use when Codex is wiring a second machine, sees Hindsight or plugin startup
  failures, needs to disable native-Windows Hindsight cleanly, create or verify a
  durable memory repo, re-point workspace startup docs to that repo, and confirm
  the final runtime state.
---

# Repo Skill Wrapper

Canonical skill: `skills/optional/openclaw-memory-cutover/SKILL.md`

This wrapper exists so Codex can discover the skill from `.agents/skills`.
Read and follow the canonical skill above before doing the task.
Resolve any relative `scripts/`, `references/`, `assets/`, and `agents/` paths from `skills/optional/openclaw-memory-cutover/`.
Do not edit this wrapper manually. Regenerate it with `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.
