---
name: handoff-session
description: "Close or pause a work session cleanly inside this personal OS. Use when Codex is finishing work, pausing a live track, needs to preserve state for later, update `memory/DEV_CONTEXT.md`, write a dated note in `memory/sessions/`, reset `inbox/now.md`, or move leftovers into `inbox/backlog.md`."
---

# Handoff Session

## Workflow

1. Read `inbox/now.md` and `memory/DEV_CONTEXT.md`.
2. Extract only durable session facts: what changed, what is blocked, and where to restart.
3. Update `memory/DEV_CONTEXT.md` so another agent can resume without replaying the whole chat.
4. If the session was substantial, branched, or exploratory, create a dated note in `memory/sessions/` using `references/handoff-template.md`.
5. Refresh `inbox/now.md` to show the next entry point, not a finished worklog.
6. Move loose leftovers and side ideas into `inbox/backlog.md`.
7. Keep the handoff terse. Do not dump the whole conversation transcript.

## Output Rules

- `memory/DEV_CONTEXT.md` is the hot resume layer; keep it short.
- `memory/sessions/` is for longer tails, not for every trivial tweak.
- `inbox/now.md` should point forward to the next action.
- If nothing meaningful changed, prefer a light `memory/DEV_CONTEXT.md` update over creating a session note.

## Reference

- Use `references/handoff-template.md` for the session-note shape and the `memory/DEV_CONTEXT.md` update checklist.
