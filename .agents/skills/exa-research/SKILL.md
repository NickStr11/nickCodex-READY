---
name: exa-research
description: |
  Use Exa MCP as the first step in a research-first routing workflow.

  Use PROACTIVELY when:
  - the user asks to find fresh web information and better sources
  - the task needs current implementation examples or code context from the web
  - you need targeted research before writing code, a skill, or an integration
  - the user explicitly mentions Exa, Exa MCP, or wants a research-first workflow
  - the task likely needs a mix of fresh search, library docs, and GitHub repo reading
---

# Repo Skill Wrapper

Canonical skill: `skills/optional/exa-research/SKILL.md`

This wrapper exists so Codex can discover the skill from `.agents/skills`.
Read and follow the canonical skill above before doing the task.
Resolve any relative `scripts/`, `references/`, `assets/`, and `agents/` paths from `skills/optional/exa-research/`.
Do not edit this wrapper manually. Regenerate it with `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.
