---
name: notebooklm-research
description: "Use Google NotebookLM through the local notebooklm CLI to create notebooks, add YouTube/URL/PDF/text sources, wait for processing, ask for deep summaries, and optionally generate downloadable reports. Use when the user explicitly wants NotebookLM, wants deeper analysis of a video/article/PDF through NotebookLM, or wants a NotebookLM-backed research bundle saved into the current project's runtime/research."
---

# Repo Skill Wrapper

Canonical skill: `skills/optional/notebooklm-research/SKILL.md`

This wrapper exists so Codex can discover the skill from `.agents/skills`.
Read and follow the canonical skill above before doing the task.
Resolve any relative `scripts/`, `references/`, `assets/`, and `agents/` paths from `skills/optional/notebooklm-research/`.
Do not edit this wrapper manually. Regenerate it with `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.
