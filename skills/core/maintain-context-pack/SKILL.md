---
name: maintain-context-pack
description: "Maintain and evolve portable agent context packs built around AGENTS.md, local instructions, and lightweight validation. Use when Codex needs to update root or nested AGENTS files, reconcile README and AGENTS roles, fix broken local references, add validation checks, or restructure a context pack without bloating the root contract."
---

# Maintain Context Pack

## Workflow

1. Read the root `AGENTS.md` and the nearest local `AGENTS.md` for the folders you will touch.
2. Keep `README.md` human-facing and `AGENTS.md` agent-facing.
3. Keep the root contract short: overview, precedence, startup docs, editing rules, and validation.
4. Push folder-specific instructions into local `AGENTS.md` files instead of expanding the root file.
5. Remove duplicate sources of truth. If an old file name must survive, turn it into a thin alias that points back to the canonical file.
6. Update file references immediately after renames or moves.
7. Run repo validation before finishing.

## Editing Rules

- Prefer structural clarity over more prose.
- Add a local `AGENTS.md` only when a subtree has rules that differ from the root.
- Keep deep context files out of the hot path unless the task truly needs them.
- If a document is for humans, keep agent-only workflow instructions out of it.

## Repo-Specific Check

Run this command after structural or documentation changes:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-context-pack.ps1
```

If validation fails on references, fix the paths first and only then continue.

