---
name: context7
description: |
  Fetch up-to-date library documentation via Context7 API. Use PROACTIVELY when:
  (1) Working with ANY external library (React, Next.js, Supabase, etc.)
  (2) User asks about library APIs, patterns, or best practices
  (3) Implementing features that rely on third-party packages
  (4) Debugging library-specific issues
  (5) Need current documentation beyond training data cutoff
  (6) AND MOST IMPORTANTLY, when you are installing dependencies, libraries, or frameworks you should ALWAYS check the docs to see what the latest versions are. Do not rely on outdated knowledge.
  Always prefer this over guessing library APIs or using outdated knowledge.
---

# Repo Skill Wrapper

Canonical skill: `skills/optional/context7/SKILL.md`

This wrapper exists so Codex can discover the skill from `.agents/skills`.
Read and follow the canonical skill above before doing the task.
Resolve any relative `scripts/`, `references/`, `assets/`, and `agents/` paths from `skills/optional/context7/`.
Do not edit this wrapper manually. Regenerate it with `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.
