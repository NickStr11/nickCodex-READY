---
name: repo-recon
description: "Rapidly map an unfamiliar repository, identify the stack, commands, entrypoints, and hotspots, then choose the thinnest attack path. Use when a user gives a local path, GitHub repo, or asks to study, compare, onboard into, review, or start working inside unknown code."
---

# Repo Skill Wrapper

Canonical skill: `skills/core/repo-recon/SKILL.md`

This wrapper exists so Codex can discover the skill from `.agents/skills`.
Read and follow the canonical skill above before doing the task.
Resolve any relative `scripts/`, `references/`, `assets/`, and `agents/` paths from `skills/core/repo-recon/`.
Do not edit this wrapper manually. Regenerate it with `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.
