---
name: capture-to-knowledge
description: "Turn useful outputs, chat insights, and research scraps into the correct long-lived file inside this personal OS. Use when Codex needs to capture reusable knowledge from a conversation, task, import, or artifact and decide whether it belongs in `knowledge/`, `memory/`, `aboutme.md`, writing/deep context files, `rules/`, or `skills/`."
---

# Repo Skill Wrapper

Canonical skill: `skills/core/capture-to-knowledge/SKILL.md`

This wrapper exists so Codex can discover the skill from `.agents/skills`.
Read and follow the canonical skill above before doing the task.
Resolve any relative `scripts/`, `references/`, `assets/`, and `agents/` paths from `skills/core/capture-to-knowledge/`.
Do not edit this wrapper manually. Regenerate it with `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.
