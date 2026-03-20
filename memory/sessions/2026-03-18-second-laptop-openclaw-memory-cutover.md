# 2026-03-18: second laptop OpenClaw memory cutover

## Goal

Bring the second Windows laptop into a usable OpenClaw state without wasting more time on broken native-Windows `Hindsight`.

## What Happened

1. Recovered prior context from the neighboring Codex thread to avoid replaying the whole day from memory.
2. Connected to the laptop over SSH and verified the real blocker instead of guessing.
3. Confirmed the native Windows path for `Hindsight` was blocked because `mlx>=0.31.0` did not have `win_amd64` wheels.
4. Disabled `Hindsight`, removed `hindsight-openclaw` from the allowed plugin list, switched the active memory slot to `memory-core`, and restarted `OpenClaw Gateway`.
5. Verified the fresh log tail no longer showed `Hindsight` startup attempts and the gateway was healthy again.
6. Built a separate git-backed durable memory repo `claw-memory`, created the private remote `NickStr11/claw-memory`, and pushed `main`.
7. Synced `claw-memory` onto the laptop at `C:\Users\nsv11\code\claw-memory`.
8. Rewired the live workspace `C:\Users\nsv11\code\cipher-knowledge` so its startup order and memory docs pointed to `claw-memory` as the default durable memory source.

## Decisions

- Do not keep fighting `Hindsight` on native Windows without new upstream support or a different runtime path like WSL/Linux/macOS.
- Keep `cipher-knowledge` as the live workspace and `claw-memory` as the durable memory repo.
- Prefer curated import into `claw-memory` over bulk-copying the whole workspace and dragging legacy noise forward.

## Final State

- Live workspace: `C:\Users\nsv11\code\cipher-knowledge`
- Durable memory repo: `C:\Users\nsv11\code\claw-memory`
- Remote: `NickStr11/claw-memory`
- Default durable memory path: repo-backed memory
- `Hindsight`: disabled and not default
- OpenClaw workspace: still points at `cipher-knowledge`; not switched to `claw-memory`

## What Was Created

- Memory repo bootstrap and runbook inside `nickCodex-READY`
- Private GitHub repo `NickStr11/claw-memory`
- First curated import for operator profile, workspace track, and handoff state
- Explicit startup links from the live workspace to the durable memory repo

## Next Entry Point

- Work can continue immediately; setup is no longer the blocker.
- Keep appending curated durable facts into `claw-memory` during normal work.
- Revisit `Hindsight` only if there is a concrete reason and a runtime path that is not native Windows.
