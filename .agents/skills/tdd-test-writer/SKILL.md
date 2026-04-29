---
name: tdd-test-writer
description: Writes failing tests first for test-driven development and hands off a strict implementation contract that requires agents to make those tests pass without weakening the tests. Use when users ask for test-first workflows, RED/GREEN cycles, or behavior-gating tasks with automated tests.
---

# Repo Skill Wrapper

Canonical skill: `skills/optional/tdd-test-writer/SKILL.md`

This wrapper exists so Codex can discover the skill from `.agents/skills`.
Read and follow the canonical skill above before doing the task.
Resolve any relative `scripts/`, `references/`, `assets/`, and `agents/` paths from `skills/optional/tdd-test-writer/`.
Do not edit this wrapper manually. Regenerate it with `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.
