---
name: daily-session
description: "Start or resume a focused work session inside this personal OS. Use when Codex begins work for the day, resumes after context loss, needs to choose one active track, triages `inbox/backlog.md`, or refreshes `inbox/now.md` from `memory/PROJECT_CONTEXT.md`, recent diary entries, and any remaining transitional `memory/DEV_CONTEXT.md`."
---

# Daily Session

## Workflow

1. Read `AGENTS.md`, then `memory/PROJECT_CONTEXT.md`, `inbox/now.md`, and `inbox/backlog.md`.
2. Read the most recent entry in `memory/diary/` if it exists.
3. Read `memory/DEV_CONTEXT.md` only if the current track still depends on transitional hot-resume notes that are not yet captured in `inbox/now.md` or the latest diary entry.
4. If the live task points to a specific subtree, read the nearest local `AGENTS.md` there before editing.
5. Pick exactly one active track. If several candidates compete, choose by immediacy, leverage, and user pull.
6. Rewrite the chosen track into a small session scope: one focus line and 1-3 concrete next actions.
7. Update `inbox/now.md` so it matches reality right now, not a wishlist.
8. Leave non-current items in `inbox/backlog.md` or move them into `memory/` or `knowledge/` if they became durable context.
9. Start doing the work. Do not write a long plan unless the user explicitly asks for one.

## Output Rules

- Keep `inbox/now.md` readable in under a minute.
- Keep one active focus only.
- Prefer verbs and concrete next actions over vague goals.
- If the user's latest request already defines the focus, align `inbox/now.md` to it instead of inventing a parallel track.

## Reference

- Use `references/session-flow.md` for the `inbox/now.md` shape and backlog triage rules.
