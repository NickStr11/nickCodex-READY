---
name: reflect-session
description: "Synthesize recent diary and session notes into durable rules, memory updates, or backlog cleanup without bloating the root contract. Use when the user asks to reflect, extract lessons, update behavior from recent sessions, or turn repeated workflow failures into stable project guidance."
---

# Reflect Session

## Workflow

1. Read `AGENTS.md`, `memory/AGENTS.md`, and `rules/AGENTS.md`.
2. Read recent unprocessed files from `memory/diary/` and `memory/sessions/`.
3. Read `memory/reflections/processed.log` if it exists; skip entries already listed there.
4. Look for patterns, not one-off noise:
   - repeated user preferences
   - repeated tool or workflow failures
   - decisions that worked and should become normal practice
   - existing rules that were violated and need sharper wording
   - stale hot-state that should move out of `memory/DEV_CONTEXT.md`
5. Write a short dated note in `memory/reflections/` summarizing what was found and what changed.
6. Update the narrowest canonical owner:
   - behavior or tone -> `rules/agent-behavior.md`
   - workflow tempo or context discipline -> `rules/work-style.md`
   - code and verification discipline -> `rules/code-style.md`
   - durable project status -> `memory/PROJECT_CONTEXT.md`
   - current focus -> `inbox/now.md`
   - reusable workflow -> `skills/`
   - reusable research -> `knowledge/`
7. Append processed diary/session filenames to `memory/reflections/processed.log`.
8. Run validation. If `skills/` changed, run `scripts/sync-agent-skills.ps1` first.

## Guardrails

- Do not promote a single anecdote into a hard rule unless the user explicitly asks.
- Keep root `AGENTS.md` small; push folder-specific guidance to the local `AGENTS.md` or the narrow rule file.
- Do not duplicate the same rule across `AGENTS.md`, `rules/`, `skills/`, and `README.md`.
- If a lesson is still uncertain, leave it in the reflection note or `inbox/backlog.md` instead of hard-coding it.

## Output Rules

- Start with what changed, not with a long analysis.
- List skipped ideas if they looked tempting but were too Cortex-specific or too one-off.
- Be explicit about which diary/session files were processed.
- If no durable pattern exists, say so and only update `processed.log` if the user asked for a full reflection pass.
