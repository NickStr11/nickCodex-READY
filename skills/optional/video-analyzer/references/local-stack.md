# Local Stack

## Why this stack

- `yt-dlp` is the first pass for YouTube because subtitles are cheaper and usually cleaner than ASR.
- `ffmpeg` extracts audio and can run the built-in `whisper` filter if a local `whisper.cpp` model is available.
- chapters + metadata are the final fallback when YouTube blocks transcript or audio extraction.
- Google AI API is the default summary backend because it can use `gemini-3-flash-preview` directly with an API key.
- collection mode reuses the same single-video pipeline per item, then builds one cross-video summary over the item outputs.

## Backend order

1. `yt-dlp` subtitles / auto-subs
2. `ffmpeg` whisper with `VIDEO_ANALYZER_WHISPER_MODEL`
3. chapters + metadata fallback
4. final summary generation:
   - default: Google AI API
   - optional: Vertex
5. collection summary generation:
   - summarize each video first
   - then summarize the whole set

## Environment

- Required:
  - `yt-dlp`
  - `ffmpeg`
  - `ffprobe`
  - `python`
- Optional:
  - `VIDEO_ANALYZER_WHISPER_MODEL`
    - path to a `whisper.cpp` ggml model such as `ggml-base.bin` or `ggml-small.bin`
  - `VIDEO_ANALYZER_VAD_MODEL`
    - optional VAD model path for cleaner segmentation
  - `GEMINI_API_KEY` or `VIDEO_ANALYZER_GEMINI_API_KEY`
    - key for Google AI API summary generation
  - `VIDEO_ANALYZER_GOOGLE_MODEL`
    - Google AI summary model, default `gemini-3-flash-preview`
  - `VIDEO_ANALYZER_VERTEX_MODEL`
    - Vertex summary model, default `gemini-2.5-flash`

## Troubleshooting

- If YouTube returns bot-check or `LOGIN_REQUIRED`, do not fake a transcript.
- If `yt-dlp` is blocked but the public watch page still opens, keep the saved watch HTML and extracted chapters; that is still enough for a high-level summary.
- If Google AI API works but transcript extraction fails, the chapters fallback is still useful; the model can still write a clean high-level summary.
- If your machine can expose browser cookies cleanly, retry with `--cookies-browser chrome` or `--cookies-browser edge`.
- If subtitles fail and no whisper model is configured, stay in chapters fallback mode.
- If `ffmpeg whisper` fails, check:
  - model path exists
  - the model is a `whisper.cpp` ggml file
  - audio extraction succeeded
- For channel or playlist URLs, enumeration itself can fail because of YouTube bot-check. In that case say it directly and do not pretend the whole channel was analyzed.
- For local files, the final summary document should still be created even when ASR is unavailable.
- If Vertex model ids fail, prefer Google AI API unless you specifically need Vertex billing or project controls.
