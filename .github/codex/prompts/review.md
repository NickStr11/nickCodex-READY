Read `AGENTS.md` and `code_review.md` first.

Review the current pull request against its base branch.

Focus on concrete findings only:
- broken references, missing required files, and validator regressions
- duplicated or drifting instructions between `skills/` and `.agents/skills/`
- portability regressions, unsafe CI assumptions, and local-machine coupling
- secrets, payload leakage, or dangerous sandbox / approval changes
- stale or misleading subagent, routing, or review instructions

Output findings first, ordered by severity, with tight file and line references.

If there are no findings, say `No findings.` and then mention any residual risk or testing gap in one short paragraph.

Do not praise the PR. Do not rewrite the diff summary unless it helps explain a finding.
