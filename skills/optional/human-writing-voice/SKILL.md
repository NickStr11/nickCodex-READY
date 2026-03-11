---
name: human-writing-voice
description: "Rewrite and edit text so it sounds more lived-in, conversational, and less like generic AI prose. Use when the user asks to make writing more human, more alive, less polished, less corporate, less 'LLM', or wants to preserve a specific personal voice, rough edges, profanity, self-dialogue, unfinished thoughts, and example-first reasoning."
---

# Human Writing Voice

## Workflow

1. If the task is voice-sensitive inside this repo, read [../../../writing-style.md](../../../writing-style.md). If the text is deeply personal, also read [../../../aboutme.md](../../../aboutme.md).
2. Preserve the original core thought before touching style.
3. Keep the text conversational:
   situation -> idea -> own take -> ending only if it naturally exists.
4. Prefer concrete anchors over abstract generalities.
5. Keep profanity if it fits the source voice. Do not auto-sanitize.
6. Keep unfinished thoughts unfinished if closure would fake certainty.
7. If the user asked for shorter text, cut hard without flattening the voice.

## Remove AI Tells

- Remove padded intros and outros.
- Remove fake balance like "on the one hand / on the other hand" unless the source really works that way.
- Remove generic moralizing, coaching tone, and motivation-speak.
- Remove polished summary lines that sound smarter than the source.
- Remove repetitive sentence rhythm and overly symmetric paragraph shapes.
- Remove abstract adjectives when a concrete example can carry the point.

## Add Human Signals

- Vary sentence length.
- Let one sharp sentence stand alone when it helps.
- Keep slight roughness if it carries honesty.
- Prefer one real example over three generic claims.
- Use spoken phrasing when it helps the text sound lived, not staged.

## Output Rules

- Default output: just the rewritten text.
- If needed, keep markdown structure but do not overformat.
- If the source is weak or over-AI already, rewrite for truth and rhythm, not just synonym-swapping.

## Reference

- Use [references/rewrite-checklist.md](references/rewrite-checklist.md) as the quick QA pass before finalizing.
