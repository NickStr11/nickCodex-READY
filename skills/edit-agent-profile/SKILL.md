---
name: edit-agent-profile
description: "Translate new user preferences, writing constraints, and working habits into the right profile files without overloading AGENTS.md. Use when Codex needs to update AGENTS.md, rules/*.md, aboutme.md, writing-style.md, deep-values.md, or deep-philosophy.md based on new behavioral guidance or personal context."
---

# Edit Agent Profile

## Workflow

1. Read the root `AGENTS.md` and `references/file-placement.md`.
2. Separate stable operating instructions from factual personal context.
3. Put each change in the narrowest file that can own it.
4. Edit the canonical file once instead of repeating the same instruction across multiple documents.
5. Keep the root contract lean. If a detail only matters for writing, values, or deep context, move it out of `AGENTS.md`.
6. Run repo validation after editing references or structure.

## Placement Rules

- Put cross-task operating instructions in `AGENTS.md`.
- Put terse behavioral rules in `rules/agent-behavior.md` or `rules/work-style.md`.
- Put code quality and code-shape rules in `rules/code-style.md`.
- Put current life and project facts in `aboutme.md`.
- Put text voice constraints in `writing-style.md`.
- Put deeper motivations, anti-values, and conflict patterns in `deep-values.md`.
- Put philosophical lenses and interpretation frames in `deep-philosophy.md`.

## Guardrails

- Do not turn transient facts into hard rules.
- Do not bloat the root contract with details that only matter in rare tasks.
- If a preference already exists, refine it in place instead of adding a second version.
- Preserve the user's actual tone; do not sand it down into neutral corporate text.


