---
name: read-github
description: |
  Read and search GitHub repository documentation via gitmcp.io MCP service.

  **WHEN TO USE:**
  - User provides a GitHub URL
  - User mentions a specific repo in owner/repo format
  - User asks "what does this repo do?", "read the docs for X repo", or similar
  - User wants to search code or docs within a repo
---

# Repo Skill Wrapper

Canonical skill: `skills/optional/read-github/SKILL.md`

This wrapper exists so Codex can discover the skill from `.agents/skills`.
Read and follow the canonical skill above before doing the task.
Resolve any relative `scripts/`, `references/`, `assets/`, and `agents/` paths from `skills/optional/read-github/`.
Do not edit this wrapper manually. Regenerate it with `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.
