---
name: openclaw-memory-cutover
description: >
  Stabilize an OpenClaw setup by separating the live workspace from durable memory
  and cutting over from broken or unwanted Hindsight to a git-backed memory repo.
  Use when Codex is wiring a second machine, sees Hindsight or plugin startup
  failures, needs to disable native-Windows Hindsight cleanly, create or verify a
  durable memory repo, re-point workspace startup docs to that repo, and confirm
  the final runtime state.
---

# OpenClaw Memory Cutover

Cut over OpenClaw to a stable repo-backed memory layout fast. Treat this as an operational workflow, not as a generic essay about memory systems.

## Workflow

1. Establish the current state.
   - Read the live workspace instructions and current context.
   - Inspect runtime config, logs, and plugin state.
   - Identify three paths explicitly: live workspace, current durable memory path, and the intended durable repo path.

2. Decide whether `Hindsight` stays or goes.
   - If `Hindsight` is healthy and the user explicitly wants it, leave it alone.
   - If native Windows `Hindsight` is failing, blocking work, or requires speculative fixes, stop the loop and move to repo-backed memory.
   - Capture the exact blocker text before changing anything.

3. Stabilize runtime first.
   - Disable `Hindsight` cleanly instead of leaving a half-on state.
   - Remove plugin references that still force startup attempts.
   - Switch the active memory slot to a working fallback such as `memory-core`.
   - Restart the gateway or service if needed.
   - Verify fresh logs no longer show `Hindsight` retry noise.

4. Create or verify the durable memory repo.
   - Keep durable memory in a separate git repo from the live workspace.
   - Create the local repo, add the remote if requested, and push when auth is available.
   - Import only curated durable files: operator profile, stable facts, projects, relationships, handoff state, and decision history.
   - Do not bulk-copy the whole live workspace into durable memory.

5. Rewire the live workspace.
   - Update startup order so the live workspace reads the durable repo first for long-lived context.
   - Mark the live workspace as operational, not canonical durable memory.
   - Keep one source of truth per fact. Do not create parallel state files that drift immediately.

6. Verify the end state.
   - Confirm the gateway is healthy.
   - Confirm the durable repo exists locally.
   - Confirm the live workspace points to the durable repo in its instructions.
   - If a remote exists, confirm `origin`, current commit, and clean `git status`.
   - Write a session note if the cutover was a long or messy track.

## Rules

- Quote exact blocker text when a dependency or platform path is broken.
- Do not store passwords, temporary SSH credentials, or host secrets in notes or repos.
- Do not keep retrying native-Windows `Hindsight` without new upstream evidence.
- Do not switch the OpenClaw workspace itself to the durable memory repo unless the user asks for that architecture change.
- Prefer a working repo-backed path now over a prettier but blocked setup.

## Repo Hints

- If present, use `../../../runbooks/openclaw/OPENCLAW-SECOND-LAPTOP.md` for second-machine operational context.
- If present, use `../../../runbooks/openclaw/OPENCLAW-UPGRADE-RUNBOOK.md` for upgrade and rollback sequencing.
- If present, use `../../../MEMORY-REPO-RUNBOOK.md` for the durable repo layout and import discipline.
- Run `powershell -ExecutionPolicy Bypass -File scripts/validate-context-pack.ps1` from the repo root after changing pack structure or docs.
