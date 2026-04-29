---
name: edit-agent-profile
description: "Translate new user preferences, writing constraints, and working habits into the right profile files without overloading AGENTS.md. Use when Codex needs to update AGENTS.md, rules/*.md, aboutme.md, writing-style.md, deep-values.md, or deep-philosophy.md based on new behavioral guidance or personal context."
---

# Repo Skill Wrapper

Canonical skill: `skills/core/edit-agent-profile/SKILL.md`

This wrapper exists so Codex can discover the skill from `.agents/skills`.
Read and follow the canonical skill above before doing the task.
Resolve any relative `scripts/`, `references/`, `assets/`, and `agents/` paths from `skills/core/edit-agent-profile/`.
Do not edit this wrapper manually. Regenerate it with `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.
