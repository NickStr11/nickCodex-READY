---
name: handoff-session
description: "Close or pause a work session cleanly inside this personal OS. Use when Codex is finishing work, pausing a live track, needs to preserve state for later, write a diary entry in `memory/diary/`, refresh `inbox/now.md`, optionally update transitional `memory/DEV_CONTEXT.md`, or move leftovers into `inbox/backlog.md`."
---

# Handoff Session

## Workflow

1. Read `inbox/now.md`, `memory/PROJECT_CONTEXT.md`, and `memory/DEV_CONTEXT.md` if it still contains transitional hot state.
2. Extract only durable session facts: what changed, what was decided, what is blocked, and where to restart.
3. Write a short dated diary entry in `memory/diary/` using the diary shape from `references/handoff-template.md`.
4. Refresh `inbox/now.md` to show the next entry point, not a finished worklog.
5. If the session was substantial, branched, or exploratory, create a longer dated note in `memory/sessions/` using `references/handoff-template.md`.
6. Update `memory/DEV_CONTEXT.md` only if there is still transitional hot state that has not yet been absorbed by `inbox/now.md`, `memory/diary/`, or `memory/CHANGELOG.md`.
7. Move loose leftovers and side ideas into `inbox/backlog.md`.
8. Keep the handoff terse. Do not dump the whole conversation transcript.

## Output Rules

- `memory/diary/` is the default session-history layer.
- `memory/DEV_CONTEXT.md` is transitional; do not keep growing it as a full worklog.
- `memory/sessions/` is for longer tails, not for every trivial tweak.
- `inbox/now.md` should point forward to the next action.
- If nothing meaningful changed, prefer a light `inbox/now.md` refresh over inventing a diary entry.

## Reference

- Use `references/handoff-template.md` for the diary shape, long session-note shape, and transitional `memory/DEV_CONTEXT.md` checklist.
