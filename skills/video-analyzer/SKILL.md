---
name: video-analyzer
description: "Analyze and summarize one video, multiple videos, or a full YouTube channel/playlist. Use when the user asks things like 'что в этом видео', 'разбери эти видосы', 'сделай summary по каналу', or wants transcript/chapters/action items from a video source. The skill saves artifacts into the current project's runtime/research by default, prefers subtitles/transcript first, falls back to ffmpeg whisper for local files, then to chapters/metadata, and writes the final summary through Google AI API by default."
---

# Video Analyzer

## Workflow

1. Read the root `AGENTS.md` and the nearest local `AGENTS.md` in the target repo before saving anything.
2. Save into the current repo by default:
   - single video -> `./runtime/research/<video-slug>/`
   - multiple videos or channel/playlist -> `./runtime/research/<collection-slug>/`
3. Choose the script by scope:
   - one video or one local file -> `scripts/prepare_video.py`
   - multiple links, channel, or playlist -> `scripts/analyze_video_collection.py`
4. Summarize from the richest artifact actually recovered:
   - transcript text or subtitle text
   - subtitle files
   - extracted chapters
   - metadata only as last resort
5. Keep raw artifacts and the final summary file together in the same research folder.
6. If the output becomes durable knowledge rather than one-off research, route the meaning later through `capture-to-knowledge`.

## Trigger Phrases

This skill should trigger for requests like:

- `что в этом видео`
- `разбери этот видос`
- `сделай summary по этим видео`
- `вытащи главное из канала`
- `прогони плейлист и дай выводы`
- `сделай конспект по видео`

## Output Rules

- Default save path is project-local `runtime/research/`; do not write into the shared OS repo unless that repo is the active project.
- Keep both raw artifacts and final summary together.
- For collections, create one collection-level summary, one collection metadata file, and per-video item folders under the same research root.
- In the final summary file, use the shape from `references/output-shape.md`.
- State clearly which content backend actually succeeded:
  - subtitles
  - ffmpeg whisper
  - chapters fallback
  - metadata-only fallback
- State clearly which summary backend was used:
  - google-ai
  - vertex
  - stub
- If YouTube blocks transcript/audio extraction, say so and fall back instead of hallucinating.

## Backend Order

1. Try `yt-dlp` subtitles and auto-subs first.
2. If no transcript exists and a local whisper model is configured, transcribe local media with `ffmpeg`'s `whisper` filter.
3. If transcript still fails, extract chapters and metadata and write a high-level summary only.
4. For multiple sources, summarize each item first, then generate one collection-level summary.

## Environment

- Required: `python`, `ffmpeg`, `ffprobe`
- Required for YouTube URLs: `yt-dlp`
- Optional:
  - `GEMINI_API_KEY` or `VIDEO_ANALYZER_GEMINI_API_KEY` -> Google AI API key for final summary generation
  - `VIDEO_ANALYZER_GOOGLE_MODEL` -> Google AI model, default `gemini-3-flash-preview`
  - `VIDEO_ANALYZER_VERTEX_MODEL` -> Vertex summary model if you explicitly use Vertex, default `gemini-2.5-flash`
  - `VIDEO_ANALYZER_WHISPER_MODEL` -> path to a `whisper.cpp` ggml model
  - `VIDEO_ANALYZER_VAD_MODEL` -> optional VAD model for cleaner segmentation

Read `references/local-stack.md` when setting up or troubleshooting the stack.

## Commands

Single video in the current repo:

```powershell
python D:\code\2026\3\nickCodex-READY\skills\video-analyzer\scripts\prepare_video.py --source "<url-or-path>"
```

Multiple videos:

```powershell
python D:\code\2026\3\nickCodex-READY\skills\video-analyzer\scripts\analyze_video_collection.py --source "<url-1>" --source "<url-2>"
```

Channel or playlist:

```powershell
python D:\code\2026\3\nickCodex-READY\skills\video-analyzer\scripts\analyze_video_collection.py --source "<channel-or-playlist-url>" --max-items 10
```

With explicit Google AI model:

```powershell
python D:\code\2026\3\nickCodex-READY\skills\video-analyzer\scripts\prepare_video.py --source "<url-or-path>" --summarize-backend google-ai --google-model "gemini-3-flash-preview"
```

## Reference

- Use `references/local-stack.md` for backend behavior and setup.
- Use `references/output-shape.md` for final folder layout and summary shape.
