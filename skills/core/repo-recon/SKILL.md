---
name: repo-recon
description: "Rapidly map an unfamiliar repository, identify the stack, commands, entrypoints, and hotspots, then choose the thinnest attack path. Use when a user gives a local path, GitHub repo, or asks to study, compare, onboard into, review, or start working inside unknown code."
---

# Repo Recon

## Trigger

Use this skill when:
- the user gives a repo path or GitHub URL
- the codebase is unfamiliar and needs a fast map
- the user asks "что тут вообще происходит", "с чего начать", "разбери структуру", "сравни с X"
- a review or bugfix needs a quick architectural entrypoint before touching code

## Workflow

1. Read the root `AGENTS.md` of the current context pack, then the nearest `AGENTS.md` inside the target repo or subtree.
2. Inventory only the files that shape execution and architecture:
   README-файлы, manifests, lockfiles, env examples, Dockerfiles, compose files, CI workflows, top-level app/test folders.
3. Detect the stack and package manager from common manifest files such as package.json, pyproject.toml, go.mod, Cargo.toml, .csproj, pom.xml, build.gradle, requirements.txt.
4. Extract the most likely commands for install, dev, test, lint, build, and start from manifests or docs.
5. Find entrypoints:
   app boot, API/server bootstrap, frontend root, CLI `main`, test harness, workers, migrations, config loader.
6. Build a heat map of risky or high-leverage zones:
   auth, payments, env/config, DB schema, jobs/queues, integrations, generated code, legacy glue.
7. If the system looks integration-heavy, stateful, file-driven, or dangerous to refactor blindly, map contracts before proposing changes:
   who calls the API, who reads or writes shared files, what machines or services depend on paths, env vars, formats, queues, webhooks, or DB tables.
8. Tie the user request to the thinnest slice that matters now and start there instead of reading the whole repo.
9. If the recon is substantial, leave a compressed note in `runtime/research/` using `references/recon-checklist.md` as the shape.
10. For external skill/template repos, do not recommend installing a large bundle by default.
    First separate reusable workflow patterns from vendor-specific automation, auth
    assumptions, and one-off task wrappers.

## Output Rules

- Return four compact blocks: stack, commands, entrypoints, hotspots.
- If blind refactoring looks risky, add a fifth compact block: contracts.
- Be explicit about unknowns and assumptions.
- Prefer direct file refs and concrete commands over architecture poetry.
- Do not over-scan the whole repo if the user already pointed at one feature or bug.
- If the target is a GitHub repo, combine with `read-github` when it saves time.
- If fresh library docs matter, combine with `context7`.
- If the user asked for a review, keep review findings first after the recon pass.
- For skill catalogs, classify findings as: install now, adapt pattern only,
  study deeper, or reject as context/vendor sprawl.

## Reference

- Use `references/recon-checklist.md` as the default checklist and note shape.
- Use `references/safety-map-checklist.md` when the repo has risky external couplings or refactor could break hidden consumers.
