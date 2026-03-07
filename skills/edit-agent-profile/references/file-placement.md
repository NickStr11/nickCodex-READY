# File Placement

Use this map when deciding where a new instruction belongs.

## Root contract

- `AGENTS.md`: stable cross-task contract, startup order, priority of instructions, global do/don't rules.

## Operating rules

- `rules/agent-behavior.md`: tone, response format, explicit prohibitions.
- `rules/work-style.md`: execution rhythm, task slicing, context hygiene, collaboration style.
- `rules/code-style.md`: coding conventions, test expectations, and always/ask-first/never boundaries for code changes.

## Personal context

- `aboutme.md`: current facts, active projects, priorities, recent load, biographical context that may age.

## Task-specific depth

- `writing-style.md`: only for text, blog, essays, voice-sensitive rewriting.
- `deep-values.md`: values, anti-values, recurring conflicts, motivational structure.
- `deep-philosophy.md`: authors, concepts, interpretive lenses, philosophical OS.

## Heuristics

- If the instruction should affect almost every future task, it probably belongs in `AGENTS.md`.
- If it is factual and could change in a month, it probably belongs in `aboutme.md`.
- If it only matters for prose, keep it out of the root contract.
- If it is too detailed for frequent loading, keep it in a deep file and reference it from the root contract instead of copying it.

