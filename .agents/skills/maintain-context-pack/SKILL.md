---
name: maintain-context-pack
description: "Maintain and evolve portable agent context packs built around AGENTS.md, local instructions, and lightweight validation. Use when Codex needs to update root or nested AGENTS files, reconcile README and AGENTS roles, fix broken local references, add validation checks, or restructure a context pack without bloating the root contract."
---

# Repo Skill Wrapper

Canonical skill: `skills/core/maintain-context-pack/SKILL.md`

This wrapper exists so Codex can discover the skill from `.agents/skills`.
Read and follow the canonical skill above before doing the task.
Resolve any relative `scripts/`, `references/`, `assets/`, and `agents/` paths from `skills/core/maintain-context-pack/`.
Do not edit this wrapper manually. Regenerate it with `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.
