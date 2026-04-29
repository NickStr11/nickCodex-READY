---
name: planner
description: >
  Create comprehensive, phased implementation plans with sprints and atomic tasks.
  Use when user says: "make a plan", "create a plan", "plan this out", "plan the implementation",
  "help me plan", "design a plan", "draft a plan", "write a plan", "outline the steps",
  "break this down into tasks", "what's the plan for", or any similar planning request.
  Also triggers on explicit "/planner" or "/plan" commands.
---

# Repo Skill Wrapper

Canonical skill: `skills/optional/planner/SKILL.md`

This wrapper exists so Codex can discover the skill from `.agents/skills`.
Read and follow the canonical skill above before doing the task.
Resolve any relative `scripts/`, `references/`, `assets/`, and `agents/` paths from `skills/optional/planner/`.
Do not edit this wrapper manually. Regenerate it with `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.
