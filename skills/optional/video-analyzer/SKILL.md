---
name: video-analyzer
description: "Analyze and summarize one video, multiple videos, or a full YouTube channel/playlist. Use when the user asks things like 'что в этом видео', 'разбери эти видосы', 'сделай summary по каналу', or wants transcript/chapters/action items from a video source. For single videos and small source bundles, prefer NotebookLM first when auth is healthy; if NotebookLM is unavailable or the user needs raw transcript artifacts, fall back to the local extraction pipeline."
---

# Video Analyzer

## Workflow

1. Read the root `AGENTS.md` and the nearest local `AGENTS.md` in the target repo before saving anything.
2. Save into the current repo by default:
   - single video -> `./runtime/research/<video-slug>/`
   - multiple videos or channel/playlist -> `./runtime/research/<collection-slug>/`
3. Route by scope and backend:
   - one video or a small set of sources -> try NotebookLM first; the NotebookLM adapter now self-heals stale auth through the persistent browser profile when possible
   - if NotebookLM auth is broken even after self-heal, the CLI is missing, or the user wants transcript/raw artifacts -> use the local pipeline
   - channel or playlist -> use the local collection pipeline first
4. Choose the script by scope when using the local pipeline:
   - one video or one local file -> `scripts/prepare_video.py`
   - multiple links, channel, or playlist -> `scripts/analyze_video_collection.py`
5. Summarize from the richest artifact actually recovered:
   - NotebookLM answer/report bundle
   - transcript text or subtitle text
   - subtitle files
   - extracted chapters
   - metadata only as last resort
6. Keep raw artifacts and the final summary file together in the same research folder.
7. If the output becomes durable knowledge rather than one-off research, route the meaning later through `capture-to-knowledge`.

## Backend Order

### Preferred route for a single video

1. Run the NotebookLM adapter.
2. It checks stored auth, probes the live session, and attempts interactive self-heal via the persistent browser profile when needed.
3. Only if NotebookLM still cannot establish a live session, fall back to the local pipeline below.
