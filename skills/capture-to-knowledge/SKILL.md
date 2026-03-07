---
name: capture-to-knowledge
description: "Turn useful outputs, chat insights, and research scraps into the correct long-lived file inside this personal OS. Use when Codex needs to capture reusable knowledge from a conversation, task, import, or artifact and decide whether it belongs in `knowledge/`, `memory/`, `aboutme.md`, writing/deep context files, `rules/`, or `skills/`."
---

# Capture To Knowledge

## Workflow

1. Identify the candidate insight and ask whether it is stable, reusable, and worth keeping.
2. Read the root `AGENTS.md` and the local `AGENTS.md` of the target folder before editing.
3. Route the insight to the narrowest owner using `references/placement.md`.
4. Compress the idea into a durable note or rule. Do not dump raw chat logs into long-lived files.
5. If the source lived in `inbox/backlog.md` or `runtime/`, remove or downscope the original so the same thing is not stored twice.
6. If the insight changes active project state, update `memory/DEV_CONTEXT.md` or `memory/PROJECT_CONTEXT.md` too.

## Guardrails

- Do not put transient status into `aboutme.md`, `rules/`, or deep context files.
- Do not store raw dumps in `knowledge/`.
- Do not create duplicate rules when one canonical owner already exists.
- If the material is not clearly reusable yet, leave it in `runtime/` or `inbox/backlog.md`.

## Reference

- Use `references/placement.md` as the routing table for long-lived knowledge.
