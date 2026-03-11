# Output Shape

## Single video

Save final results in:

```text
runtime/research/<video-slug>/
  metadata.json
  prep-report.md
  subtitles*.vtt        # if available
  transcript.json       # if ffmpeg whisper succeeded
  transcript.txt        # normalized plain text
  chapters.json         # if available
  source.html           # useful for YouTube fallback debugging
  summary.md
```

## Multiple videos / channel / playlist

Save final results in:

```text
runtime/research/<collection-slug>/
  collection.json
  prep-report.md
  summary.md
  items/
    <video-slug>/
      metadata.json
      prep-report.md
      subtitles*.vtt
      transcript.json
      transcript.txt
      chapters.json
      source.html
      summary.md
```

## summary.md

```md
# Summary

## Source
- input: ...
- backend or mode: ...

## Short Summary
- 3-6 lines max

## Key Ideas / Cross-Video Themes
- ...

## Action Items
- ...

## Notes
- mention transcript quality, fallback mode, blockers, coverage limits
```

## Quality bar

- If the summary came from transcript/subtitles, say so.
- If the summary came only from chapters/metadata, say that explicitly.
- For collections, say how many videos were actually processed and which ones failed.
- Do not pretend a high-fidelity transcript exists when the pipeline only recovered chapters or metadata.
