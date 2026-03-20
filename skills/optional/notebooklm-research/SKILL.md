---
name: notebooklm-research
description: "Use Google NotebookLM through the local notebooklm CLI to create notebooks, add YouTube/URL/PDF/text sources, wait for processing, ask for deep summaries, and optionally generate downloadable reports. Use when the user explicitly wants NotebookLM, wants deeper analysis of a video/article/PDF through NotebookLM, or wants a NotebookLM-backed research bundle saved into the current project's runtime/research."
---

# NotebookLM Research

## Workflow

1. Read the root `AGENTS.md` and the nearest local `AGENTS.md` before saving anything.
2. Save into the current repo by default:
   - single source -> `./runtime/research/<slug>/`
   - multiple sources -> `./runtime/research/<slug>/`
3. Use `scripts/notebooklm_bundle.py` as the main adapter:
   - it checks `notebooklm` CLI availability
   - it checks cookie auth with `notebooklm auth check --json`
   - it verifies the live session with `notebooklm list --json`
   - if the stored auth is stale, it auto-runs `scripts/ensure_notebooklm_auth.py` to refresh the stored auth state from the persistent browser profile
   - the helper prefers real installed `Chrome` or `Edge` channels before falling back to Playwright Chromium, and strips Playwright's `--no-sandbox` default so Google sign-in does not get stuck behind the unsupported-browser warning banner
   - if a browser window opens, finish the login there and wait for the NotebookLM homepage; the helper auto-saves auth and does not require a manual `ENTER` confirmation
   - it creates a notebook or uses an existing one
   - it adds each source, waits for processing, asks a question, and can generate a report
   - it saves the whole bundle locally
4. Keep both raw CLI JSON and the human-readable summary together in the same research folder.
5. If NotebookLM auth is broken or the CLI is missing, say it directly and fall back to another research path instead of faking a result.

## Trigger Phrases

This skill should trigger for requests like:

- `прогони это через NotebookLM`
- `разбери это видео через NotebookLM`
- `закинь эту статью в NotebookLM и дай выводы`
- `сделай research bundle через NotebookLM`
- `собери NotebookLM notebook из этих источников`
- `сделай NotebookLM summary`

## Output Rules

- Default save path is project-local `runtime/research/`; do not write into the shared OS repo unless that repo is the active project.
- Save:
  - manifest.json
  - auth-check.json
  - auth-live-check.json when the live auth probe ran
  - auth-heal.json when auto-repair ran
  - error.json when the adapter failed after creating the output folder
  - notebook.json
  - sources.json
  - answer.json when `ask` ran
  - report.json and report-download.json when report generation ran
  - summary.md
- In the summary file, state clearly:
  - notebook title and id
  - which sources were added
  - whether NotebookLM auth worked
  - whether the live auth probe worked
  - whether auth self-heal ran
  - whether `ask` and/or `generate report` ran
  - where the downloaded report was saved
- If a source fails to process, say so and keep the partial bundle.

## Environment

- Required:
  - `python`
  - `notebooklm` CLI from `notebooklm-py[browser]`
- Required on Windows:
  - `PYTHONIOENCODING=utf-8` for NotebookLM CLI subprocesses
- Required auth:
  - valid NotebookLM storage-state file under `~/.notebooklm/`
  - `notebooklm auth check --json` should return `"status": "ok"` and `"sid_cookie": true`
  - `notebooklm list --json` must also succeed as a live auth probe

Read `references/windows-gotchas.md` when auth or Windows console behavior gets weird.

## Commands

Single source with a deep summary:

```powershell
python skills/notebooklm-research/scripts/notebooklm_bundle.py --source "<url-or-path>" --title "NotebookLM Research" --question "Write a detailed summary with key ideas, conclusions, risks, and next actions."
```

Repair auth without starting a full research bundle:

```powershell
python skills/notebooklm-research/scripts/ensure_notebooklm_auth.py --json
```

Multiple sources with one shared notebook:

```powershell
python skills/notebooklm-research/scripts/notebooklm_bundle.py --source "<url-1>" --source "<url-2>" --title "Cross-source research" --question "Compare the sources, extract the main themes, and give actionable conclusions."
```

Generate a downloadable briefing doc:

```powershell
python skills/notebooklm-research/scripts/notebooklm_bundle.py --source "<url-or-path>" --title "NotebookLM report" --skip-ask --report-format briefing-doc --report-instructions "Focus on practical implications and recommended next steps."
```

Reuse an existing notebook:

```powershell
python skills/notebooklm-research/scripts/notebooklm_bundle.py --notebook-id "<notebook-id>" --source "<url-or-path>" --question "Summarize what changed compared with the previous sources."
```

## Reference

- Use `references/windows-gotchas.md` for login, encoding, and cookie issues on Windows.
- Use `references/output-shape.md` for the expected local artifact layout.
