---
name: openai-docs-skill
description: Query the OpenAI developer documentation via the OpenAI Docs MCP server using CLI (curl/jq). Use whenever a task involves the OpenAI API (Responses, Chat Completions, Realtime, etc.), OpenAI SDKs, ChatGPT Apps SDK, Codex, MCP integrations, endpoint schemas, parameters, limits, or migrations and you need up-to-date official guidance.
---

# Repo Skill Wrapper

Canonical skill: `skills/optional/openai-docs-skill/SKILL.md`

This wrapper exists so Codex can discover the skill from `.agents/skills`.
Read and follow the canonical skill above before doing the task.
Resolve any relative `scripts/`, `references/`, `assets/`, and `agents/` paths from `skills/optional/openai-docs-skill/`.
Do not edit this wrapper manually. Regenerate it with `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.
