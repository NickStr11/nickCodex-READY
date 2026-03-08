---
name: close-session
description: "Close or pause a work session inside this personal OS with one command. Use when the user says `конец сессии`, `закрой сессию`, `сохрани итог`, `сделай handoff`, or otherwise asks Codex to wrap up work, update `inbox/now.md`, move leftovers into `inbox/backlog.md`, preserve durable state in `memory/DEV_CONTEXT.md`, and route stable insights into the right long-lived file."
---

# Close Session

## Workflow

1. Read `inbox/now.md`, `inbox/backlog.md`, and `memory/DEV_CONTEXT.md`.
2. Extract only durable facts from the session: what changed, what is blocked, and where to restart.
3. Update `memory/DEV_CONTEXT.md` so another agent can resume without replaying the whole chat.
4. Refresh `inbox/now.md` so it points to the next entry point, not to a finished worklog.
5. Move loose leftovers, side ideas, and non-current threads into `inbox/backlog.md`.
6. If the session produced stable reusable knowledge, route it to the narrowest owner in `memory/`, `knowledge/`, `rules/`, or `skills/`. Read the local `AGENTS.md` of the target folder before editing there.
7. Create a dated note in `memory/sessions/` only if the session was substantial, branched, or exploratory. Skip it for trivial work.

## Guardrails

- Do not dump the raw chat transcript into project files.
- Do not write duplicate state to `inbox/`, `memory/`, and `knowledge/` at the same time.
- Keep `inbox/now.md` short and forward-looking.
- Keep `memory/DEV_CONTEXT.md` as the hot resume layer, not as a full diary.
- If nothing meaningful changed, do a light update instead of inventing a summary.

## Output Rules

- Prefer one clean handoff over several mini-updates during the same wrap-up.
- Preserve decisions, blockers, and restart points first.
- Capture reusable knowledge only when it is stable enough to matter later.
- If the user only says `конец сессии`, assume they want the full wrap-up flow above without extra questions.

## Scope

Use this skill as the one-command wrapper around the existing session hygiene of this repo.
It replaces the need to remember separate prompts for handoff, backlog cleanup, and knowledge capture.
