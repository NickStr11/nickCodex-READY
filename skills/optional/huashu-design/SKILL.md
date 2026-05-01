---
name: huashu-design
description: Apply Huashu Design-inspired workflows for high-fidelity HTML-first design work: branded prototypes, editorial pages, slide decks, infographics, motion demos, design variants, and design critique. Use when the user asks for a polished visual artifact, wants "like Huashu/Claude Design", asks for multiple design directions, brand-aware design, anti-AI-slop design, HTML-to-PDF/PPT/video-style output, or expert design review.
---

# Huashu Design

Lightweight personal-use adaptation of `alchaincyf/huashu-design`.

Source: `https://github.com/alchaincyf/huashu-design` checked at
`23f60d9b4304f20851469987c6e2c92242b94a45`.

License note: upstream is Personal Use Only. Do not copy upstream assets,
scripts, demos, audio, or large text into public/commercial work. Use this
skill as a workflow adapter and attribution layer. For full upstream behavior,
install/use upstream directly and respect its license.

## Core Mode

HTML is the production canvas, not the final medium. Match the artifact:

- prototype: think like a product/UX designer
- landing/page: think like a visual/web designer
- slide deck: think like a presentation designer
- infographic: think like an editorial/data designer
- animation: think like a motion designer
- critique: think like an art director

Do not make every output look like a webpage.

## Fact And Asset Verification First

Before designing for a named brand, product, person, venue, or current object:

1. Verify the thing exists and what version/state is current.
2. Ask for existing assets once: logo, screenshots, brand guidelines, product photos, Figma/design system, color/font rules.
3. If assets are not provided and the task needs real brand fidelity, search official sources before designing.
4. Extract from real assets: logo, product/UI imagery, palette, type clues, signature details, forbidden moves.
5. Write a small local `brand-spec` in the working artifact or notes before using colors.

Never guess brand colors or draw fake product silhouettes when a real product/logo/screenshot is required.

## Design Direction Advisor

Use when the request is vague: "make it beautiful", "design this", "not sure what style", no brand/design context.

1. Offer 3 distinct directions from different visual families.
2. For each direction give: name, mood, typography, color behavior, density, motion/interaction idea, risks.
3. Build a quick low-cost demo or first screen for the strongest direction if the user wants action now.
4. After direction is chosen, continue with the normal production flow.

Do not pretend there is one objectively correct style.

## Junior Designer Flow

Default workflow:

1. State assumptions and missing assets briefly.
2. Write a short aesthetic hypothesis before layout: direction, why it fits, and 2-3 planned hierarchy/asymmetry moves.
3. Create a rough but visible first pass early.
4. Prefer 3+ variations over one "final answer" when visual direction is uncertain.
5. Iterate from user feedback.
6. Verify in browser/rendered output before delivery.

For Codex UI/app work, combine with `$frontend-design` and `$frontend-responsive-ui` when responsive implementation matters.

## Anti AI Slop

Avoid generic visual averages unless the brand itself uses them:

- purple AI gradients as default tech style
- emoji-as-icons for serious/product work
- rounded cards with colored left borders as the main design language
- fake SVG/CSS product silhouettes instead of real product imagery
- generic Inter/Roboto/Arial/system display type without a reason
- random metrics, icons, or "dashboard" furniture that do not carry meaning

Positive moves:

- start from existing context: brand, screenshot, product, audience, medium
- use one clear design thesis
- make typography carry identity
- use real assets when recognition matters
- keep a stable palette in CSS variables/spec notes
- make density match the artifact: deck != dashboard != app prototype

## Render QA Gates

For any generated HTML, PDF, deck, infographic, or visual artifact:

1. Render the artifact before delivery. For HTML/PDF, print or screenshot the actual output and inspect it.
2. Save a contact sheet or key screenshots near the runtime output when practical.
3. Check page 1 first: no title overlap, no decorative sticker crossing content, no orphaned visual blocks.
4. If there are 4+ equal cards in a symmetric grid, treat it as a design smell. Rebuild as asymmetric hierarchy, dominant + sidekick, table, timeline, or editorial layout.
5. Audit font stack. Generic fallback stacks such as Arial/Inter/Georgia/Consolas are allowed only with a reason; otherwise choose a more intentional local or loaded type system.
6. Avoid evenly distributed soft accent colors. Prefer one dominant surface and one sharp accent, with secondary colors used sparingly.

## A4 Editorial PDF Pattern

Use for technical briefs, personal setup explainers, infra reports, and PDF handoffs like "explain this setup to Arthur".

- Use print-first A4 HTML and export with browser print, not ad hoc PDF drawing, when layout quality matters.
- Start with a strong cover hierarchy: large H1, short lead, one integrated thesis block, no decorative stamp on top of title.
- For Russian covers, break H1 manually by meaning, not by browser auto-wrap. Prefer semantic lines such as "Как работает" / "мой Codex" / "сетап" over orphaned short words.
- Keep body text readable on screen: normal copy around 14px or larger, table/card text around 12px or larger, footers only can be smaller.
- Prefer warm paper + coal text + one sharp accent. Do not distribute four pastel card colors evenly.
- Use asymmetric information architecture: dominant block + supporting blocks, timeline, table, or dispatch board instead of equal card grids.
- Decorative elements must attach to a content role. If a rail, stamp, band, or badge can be removed without losing meaning, remove it.
- For dense technical content, use tables and timelines for comparison/history, not card walls.
- In Russian body copy, avoid lonely one-letter prepositions/conjunctions at line ends where practical: use nonbreaking spaces for short glue words in prominent text and check rendered output.
- For technical inline labels and confidence badges, use non-wrapping spans so markers like `[verified: gh]` do not split across lines.
- Treat spacing as a system: increase section gaps, grid gaps, and card padding together; do not just enlarge font size.
- After any typography or spacing change, rerender page 1 and the densest pages; larger text and extra air can create new overlaps.

## Artifact-Specific Checks

Prototype:
- Decide overview-board vs clickable flow.
- If clickable, test key paths and console errors.
- Use real screen states, not explanatory marketing text.

Slide deck:
- One slide, one job.
- Do not use webpage cards as slide grammar.
- Export/render and inspect text fit.

Infographic:
- Use editorial hierarchy, data labels, source notes, and print-safe spacing.
- Do not fake data for decoration.

Animation/motion:
- Build a timeline plan before implementation.
- Prefer clear stages, easing, and readable keyframes over random movement.
- Export/check frames or rendered video/GIF when possible.

Critique:
- Score or comment on philosophy fit, hierarchy, craft, function, novelty.
- Return Keep / Fix / Quick Wins.

## Upstream References

If deeper source-specific guidance is needed, inspect the local research clone:
`runtime/research/huashu-design-src/`.

Useful upstream files:
- `SKILL.md` — full workflow and rules
- `references/design-styles.md` — design direction library
- `references/slide-decks.md` — slide deck patterns
- `references/editable-pptx.md` — HTML-to-PPTX approach
- `references/critique-guide.md` — design review
- `references/verification.md` — QA checks
