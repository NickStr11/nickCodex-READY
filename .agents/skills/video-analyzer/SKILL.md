---
name: video-analyzer
description: "Analyze and summarize one video, multiple videos, or a full YouTube channel/playlist. Use when the user asks things like 'что в этом видео', 'разбери эти видосы', 'сделай summary по каналу', or wants transcript/chapters/action items from a video source. For single videos and small source bundles, prefer NotebookLM first when auth is healthy; if NotebookLM is unavailable or the user needs raw transcript artifacts, fall back to the local extraction pipeline."
---

# Repo Skill Wrapper

Canonical skill: `skills/optional/video-analyzer/SKILL.md`

This wrapper exists so Codex can discover the skill from `.agents/skills`.
Read and follow the canonical skill above before doing the task.
Resolve any relative `scripts/`, `references/`, `assets/`, and `agents/` paths from `skills/optional/video-analyzer/`.
Do not edit this wrapper manually. Regenerate it with `powershell -ExecutionPolicy Bypass -File scripts/sync-agent-skills.ps1`.
