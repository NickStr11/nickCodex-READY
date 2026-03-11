#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import parse_qs, urlparse
from urllib.request import Request, urlopen


YOUTUBE_HOSTS = {
    "youtube.com",
    "www.youtube.com",
    "m.youtube.com",
    "youtu.be",
}


def run_command(command: list[str], cwd: Path | None = None) -> subprocess.CompletedProcess[str]:
    executable = resolve_executable(command[0])
    final_command = [executable, *command[1:]]
    return subprocess.run(
        final_command,
        cwd=str(cwd) if cwd else None,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        check=False,
    )


def resolve_executable(name: str) -> str:
    if Path(name).exists():
        return name

    candidates = [name]
    if os.name == "nt":
        if not name.lower().endswith(".exe"):
            candidates.append(f"{name}.exe")
        if not name.lower().endswith(".cmd"):
            candidates.append(f"{name}.cmd")
        if not name.lower().endswith(".bat"):
            candidates.append(f"{name}.bat")

    for candidate in candidates:
        resolved = shutil.which(candidate)
        if resolved:
            return resolved

    return name


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def default_output_root() -> Path:
    return Path.cwd() / "runtime" / "research"


def maybe_fix_mojibake(value: str | None) -> str | None:
    if not value:
        return value
    if not any(marker in value for marker in ("Р", "С", "Ð", "Ñ")):
        return value
    try:
        repaired = value.encode("latin1").decode("utf-8")
    except UnicodeError:
        return value
    if repaired.count("\ufffd") > value.count("\ufffd"):
        return value
    return repaired


def slugify(value: str) -> str:
    lowered = value.lower()
    slug = re.sub(r"[^a-z0-9]+", "-", lowered)
    return slug.strip("-") or "video"


def choose_slug(preferred: str | None, fallback: str) -> str:
    if preferred:
        candidate = slugify(preferred)
        if candidate != "video":
            return candidate
    return slugify(fallback)


def is_url(value: str) -> bool:
    parsed = urlparse(value)
    return parsed.scheme in {"http", "https"}


def is_youtube_url(value: str) -> bool:
    parsed = urlparse(value)
    return parsed.netloc.lower() in YOUTUBE_HOSTS


def youtube_id_from_url(value: str) -> str | None:
    parsed = urlparse(value)
    host = parsed.netloc.lower()
    if host == "youtu.be":
        return parsed.path.strip("/") or None
    if host in {"youtube.com", "www.youtube.com", "m.youtube.com"}:
        if parsed.path == "/watch":
            return parse_qs(parsed.query).get("v", [None])[0]
        if parsed.path.startswith("/shorts/"):
            return parsed.path.split("/", 2)[2]
    return None


def fetch_text(url: str) -> str:
    request = Request(
        url,
        headers={
            "User-Agent": (
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/123.0.0.0 Safari/537.36"
            )
        },
    )
    with urlopen(request, timeout=30) as response:
        return response.read().decode("utf-8", errors="replace")


def fetch_json(url: str) -> dict[str, Any] | None:
    try:
        return json.loads(fetch_text(url))
    except (HTTPError, URLError, TimeoutError, json.JSONDecodeError):
        return None


def parse_youtube_chapters(html: str) -> list[dict[str, str]]:
    pattern = re.compile(
        r'"macroMarkersListItemRenderer":\{"title":\{"simpleText":"(.*?)"\},'
        r'"timeDescription":\{"accessibility":\{"accessibilityData":\{"label":"(.*?)"\}\},"simpleText":"(.*?)"\}',
        re.S,
    )
    chapters: list[dict[str, str]] = []
    for title, label, short in pattern.findall(html):
        cleaned_title = maybe_fix_mojibake(title.encode("utf-8").decode("unicode_escape")) or title
        chapters.append(
            {
                "time": short,
                "label": maybe_fix_mojibake(label) or label,
                "title": cleaned_title,
            }
        )
    return chapters


def write_json(path: Path, payload: Any) -> None:
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def write_text(path: Path, payload: str) -> None:
    path.write_text(payload, encoding="utf-8")


def gcloud_config_get_value(key: str) -> str | None:
    result = run_command(["gcloud", "config", "get-value", key])
    if result.returncode != 0:
        return None
    value = result.stdout.strip()
    if not value or value == "(unset)":
        return None
    return value


def gcloud_access_token() -> str:
    result = run_command(["gcloud", "auth", "print-access-token"])
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "Failed to get gcloud access token")
    token = result.stdout.strip()
    if not token:
        raise RuntimeError("Empty gcloud access token")
    return token


def gemini_api_key() -> str | None:
    return (
        os.environ.get("VIDEO_ANALYZER_GEMINI_API_KEY")
        or os.environ.get("GEMINI_API_KEY")
    )


def load_optional_json(path: Path | None) -> Any:
    if not path or not path.exists():
        return None
    return json.loads(path.read_text(encoding="utf-8", errors="replace"))


def build_vertex_prompt(
    source: str,
    backend: str,
    metadata: dict[str, Any],
    transcript_text_path: Path | None,
    chapters_path: Path | None,
) -> str:
    transcript_text = ""
    if transcript_text_path and transcript_text_path.exists():
        transcript_text = transcript_text_path.read_text(encoding="utf-8", errors="replace").strip()
        transcript_text = transcript_text[:120000]

    chapters = load_optional_json(chapters_path) or []
    chapter_lines = []
    for chapter in chapters[:40]:
        chapter_lines.append(f"- {chapter.get('time', '?')} {chapter.get('title', '')}")

    oembed = metadata.get("oembed") or {}
    title = oembed.get("title") or metadata.get("video_id") or "Unknown title"
    author = oembed.get("author_name") or "Unknown author"

    parts = [
        "You are summarizing a video for a coding/agent workflow.",
        "Return markdown only.",
        "Use this exact structure:",
        "# Summary",
        "",
        "## Source",
        "- input: ...",
        f"- backend: {backend}",
        "",
        "## Short Summary",
        "- 3-6 bullets, concise and concrete",
        "",
        "## Key Ideas",
        "- 4-8 bullets",
        "",
        "## Action Items",
        "- 0-5 bullets, only if clearly implied by the content",
        "",
        "## Notes",
        "- mention transcript quality or fallback limits",
        "",
        "Be explicit if the summary is based on transcript, subtitles, or chapters fallback only.",
        "",
        f"Video title: {title}",
        f"Author: {author}",
        f"Source URL/path: {source}",
        "",
    ]

    if transcript_text:
        parts.extend(
            [
                "Transcript:",
                transcript_text,
            ]
        )
    elif chapter_lines:
        parts.extend(
            [
                "Chapters:",
                "\n".join(chapter_lines),
            ]
        )
    else:
        parts.extend(
            [
                "Metadata:",
                json.dumps(metadata, ensure_ascii=False, indent=2)[:120000],
            ]
        )

    return "\n".join(parts)


def vertex_generate_summary(
    *,
    prompt: str,
    project_id: str,
    location: str,
    model: str,
) -> str:
    token = gcloud_access_token()
    endpoint = (
        f"https://{location}-aiplatform.googleapis.com/v1/projects/{project_id}/"
        f"locations/{location}/publishers/google/models/{model}:generateContent"
    )
    payload = {
        "contents": [
            {
                "role": "user",
                "parts": [
                    {
                        "text": prompt,
                    }
                ],
            }
        ],
        "generationConfig": {
            "temperature": 0.2,
            "maxOutputTokens": 2048,
        },
    }
    request = Request(
        endpoint,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json; charset=utf-8",
        },
        method="POST",
    )
    with urlopen(request, timeout=120) as response:
        response_payload = json.loads(response.read().decode("utf-8", errors="replace"))

    candidates = response_payload.get("candidates") or []
    if not candidates:
        raise RuntimeError(f"Vertex returned no candidates: {json.dumps(response_payload, ensure_ascii=False)[:1500]}")

    parts = candidates[0].get("content", {}).get("parts", [])
    text_chunks = [part.get("text", "") for part in parts if isinstance(part, dict) and part.get("text")]
    text = "\n".join(text_chunks).strip()
    if not text:
        raise RuntimeError(f"Vertex returned empty text: {json.dumps(response_payload, ensure_ascii=False)[:1500]}")
    return text


def google_ai_generate_summary(
    *,
    prompt: str,
    model: str,
    api_key: str,
) -> str:
    endpoint = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"
    payload = {
        "contents": [
            {
                "role": "user",
                "parts": [
                    {
                        "text": prompt,
                    }
                ],
            }
        ],
        "generationConfig": {
            "temperature": 0.2,
            "maxOutputTokens": 2048,
        },
    }
    request = Request(
        endpoint,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Content-Type": "application/json; charset=utf-8",
        },
        method="POST",
    )
    with urlopen(request, timeout=120) as response:
        response_payload = json.loads(response.read().decode("utf-8", errors="replace"))

    candidates = response_payload.get("candidates") or []
    if not candidates:
        raise RuntimeError(f"Google AI API returned no candidates: {json.dumps(response_payload, ensure_ascii=False)[:1500]}")

    parts = candidates[0].get("content", {}).get("parts", [])
    text_chunks = [part.get("text", "") for part in parts if isinstance(part, dict) and part.get("text")]
    text = "\n".join(text_chunks).strip()
    if not text:
        raise RuntimeError(f"Google AI API returned empty text: {json.dumps(response_payload, ensure_ascii=False)[:1500]}")
    return text


def normalize_vtt_to_text(vtt_path: Path, destination: Path) -> None:
    lines = vtt_path.read_text(encoding="utf-8", errors="replace").splitlines()
    chunks: list[str] = []
    for line in lines:
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.upper().startswith("WEBVTT"):
            continue
        if "-->" in stripped:
            continue
        if stripped.startswith(("NOTE", "Kind:", "Language:")):
            continue
        chunks.append(stripped)
    write_text(destination, "\n".join(chunks))


def normalize_srt_to_text(srt_path: Path, destination: Path) -> None:
    lines = srt_path.read_text(encoding="utf-8", errors="replace").splitlines()
    chunks: list[str] = []
    for line in lines:
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.isdigit():
            continue
        if "-->" in stripped:
            continue
        chunks.append(stripped)
    write_text(destination, "\n".join(chunks))


def probe_local_file(source: Path) -> dict[str, Any]:
    command = [
        "ffprobe",
        "-v",
        "error",
        "-show_entries",
        "format=duration,size,bit_rate:stream=index,codec_type,codec_name,width,height,sample_rate,channels",
        "-of",
        "json",
        str(source),
    ]
    result = run_command(command)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "ffprobe failed")
    return json.loads(result.stdout)


def extract_audio(source: Path, destination: Path) -> subprocess.CompletedProcess[str]:
    command = [
        "ffmpeg",
        "-y",
        "-i",
        str(source),
        "-vn",
        "-ac",
        "1",
        "-ar",
        "16000",
        "-c:a",
        "pcm_s16le",
        str(destination),
    ]
    return run_command(command)


def transcribe_with_ffmpeg_whisper(
    audio_path: Path,
    transcript_path: Path,
    model_path: Path,
    language: str,
    vad_model: Path | None,
) -> subprocess.CompletedProcess[str]:
    filter_parts = [
        "whisper",
        f"model={model_path.as_posix()}",
        f"language={language}",
        f"destination={transcript_path.as_posix()}",
        "format=json",
    ]
    if vad_model:
        filter_parts.append(f"vad_model={vad_model.as_posix()}")

    command = [
        "ffmpeg",
        "-y",
        "-i",
        str(audio_path),
        "-af",
        ":".join(filter_parts),
        "-f",
        "null",
        "-",
    ]
    return run_command(command)


def extract_text_from_whisper_json(source: Path, destination: Path) -> None:
    payload = json.loads(source.read_text(encoding="utf-8", errors="replace"))
    text = payload.get("text", "").strip()
    if not text and isinstance(payload.get("segments"), list):
        text = "\n".join(segment.get("text", "").strip() for segment in payload["segments"]).strip()
    write_text(destination, text)


def collect_yt_dlp_metadata(source: str, output_dir: Path, cookies_browser: str | None) -> tuple[dict[str, Any] | None, str | None]:
    command = ["yt-dlp", "--dump-single-json", "--no-warnings"]
    if cookies_browser:
        command.extend(["--cookies-from-browser", cookies_browser])
    command.append(source)
    result = run_command(command)
    if result.returncode != 0:
        return None, result.stderr.strip() or result.stdout.strip()
    try:
        payload = json.loads(result.stdout)
    except json.JSONDecodeError as error:
        return None, str(error)

    write_json(output_dir / "yt-dlp-metadata.json", payload)
    return payload, None


def collect_subtitles(source: str, output_dir: Path, cookies_browser: str | None) -> tuple[list[Path], str | None]:
    output_template = output_dir / "%(id)s.%(ext)s"
    command = [
        "yt-dlp",
        "--skip-download",
        "--write-subs",
        "--write-auto-subs",
        "--sub-langs",
        "ru.*,en.*",
        "--convert-subs",
        "vtt",
        "-o",
        str(output_template),
    ]
    if cookies_browser:
        command.extend(["--cookies-from-browser", cookies_browser])
    command.append(source)

    result = run_command(command)
    subtitle_files = sorted(output_dir.glob("*.vtt")) + sorted(output_dir.glob("*.srt"))
    if subtitle_files:
        return subtitle_files, None
    error = result.stderr.strip() or result.stdout.strip() or "subtitle extraction failed"
    return [], error


def write_prep_report(path: Path, lines: list[str]) -> None:
    body = "# Preparation Report\n\n" + "\n".join(f"- {line}" for line in lines) + "\n"
    write_text(path, body)


def build_summary_stub(path: Path, source: str, backend: str, transcript_path: Path | None, chapters_path: Path | None) -> None:
    transcript_line = f"`{transcript_path.name}`" if transcript_path else "нет"
    chapters_line = f"`{chapters_path.name}`" if chapters_path else "нет"
    content = f"""# Summary

## Source

- input: `{source}`
- backend: `{backend}`
- transcript artifact: {transcript_line}
- chapters artifact: {chapters_line}

## Short Summary

- [fill]

## Key Ideas

- [fill]

## Action Items

- [fill]

## Notes

- State clearly if this summary was based on a full transcript, subtitles, or chapters fallback.
"""
    write_text(path, content)


def maybe_generate_vertex_summary(
    *,
    output_dir: Path,
    source: str,
    backend: str,
    metadata: dict[str, Any],
    transcript_text_path: Path | None,
    chapters_path: Path | None,
    project_id: str | None,
    location: str,
    model: str,
    prep_lines: list[str],
) -> bool:
    if not project_id:
        prep_lines.append("Vertex summary skipped: no GCP project configured.")
        return False

    prompt = build_vertex_prompt(
        source=source,
        backend=backend,
        metadata=metadata,
        transcript_text_path=transcript_text_path,
        chapters_path=chapters_path,
    )
    try:
        summary = vertex_generate_summary(
            prompt=prompt,
            project_id=project_id,
            location=location,
            model=model,
        )
    except Exception as error:  # noqa: BLE001
        prep_lines.append(f"Vertex summary failed: {error}")
        return False

    write_text(output_dir / "summary.md", summary if summary.endswith("\n") else summary + "\n")
    prep_lines.append(f"Generated summary with Vertex model `{model}`.")
    return True


def maybe_generate_google_ai_summary(
    *,
    output_dir: Path,
    source: str,
    backend: str,
    metadata: dict[str, Any],
    transcript_text_path: Path | None,
    chapters_path: Path | None,
    model: str,
    prep_lines: list[str],
) -> bool:
    api_key = gemini_api_key()
    if not api_key:
        prep_lines.append("Google AI summary skipped: no GEMINI_API_KEY configured.")
        return False

    prompt = build_vertex_prompt(
        source=source,
        backend=backend,
        metadata=metadata,
        transcript_text_path=transcript_text_path,
        chapters_path=chapters_path,
    )
    try:
        summary = google_ai_generate_summary(
            prompt=prompt,
            model=model,
            api_key=api_key,
        )
    except Exception as error:  # noqa: BLE001
        prep_lines.append(f"Google AI summary failed: {error}")
        return False

    write_text(output_dir / "summary.md", summary if summary.endswith("\n") else summary + "\n")
    prep_lines.append(f"Generated summary with Google AI model `{model}`.")
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description="Prepare video artifacts for local-first analysis.")
    parser.add_argument("--source", required=True, help="Video URL or local file path")
    parser.add_argument(
        "--output-root",
        help="Root folder for runtime/research output. Defaults to ./runtime/research in the current repo",
    )
    parser.add_argument("--slug", help="Optional explicit output slug")
    parser.add_argument("--language", default="auto", help="Transcription language for ffmpeg whisper")
    parser.add_argument("--whisper-model", help="Path to whisper.cpp ggml model")
    parser.add_argument("--vad-model", help="Optional path to VAD model for ffmpeg whisper")
    parser.add_argument("--cookies-browser", choices=["chrome", "edge"], help="Optional browser cookies for yt-dlp")
    parser.add_argument("--keep-audio", action="store_true", help="Keep extracted audio.wav")
    parser.add_argument("--summarize-backend", choices=["stub", "vertex", "google-ai"], default=os.environ.get("VIDEO_ANALYZER_SUMMARIZE_BACKEND", "google-ai"))
    parser.add_argument("--vertex-project", help="GCP project id for Vertex summary")
    parser.add_argument("--vertex-location", default=os.environ.get("VIDEO_ANALYZER_VERTEX_LOCATION", "us-central1"))
    parser.add_argument("--vertex-model", default=os.environ.get("VIDEO_ANALYZER_VERTEX_MODEL", "gemini-2.5-flash"))
    parser.add_argument("--google-model", default=os.environ.get("VIDEO_ANALYZER_GOOGLE_MODEL", "gemini-3-flash-preview"))
    args = parser.parse_args()

    source = args.source.strip()
    output_root_value = args.output_root or str(default_output_root())
    output_root = Path(output_root_value).expanduser().resolve()
    ensure_dir(output_root)

    prep_lines: list[str] = []
    metadata: dict[str, Any] = {"source": source}
    transcript_text_path: Path | None = None
    chapters_path: Path | None = None
    backend = "chapters-meta-fallback"
    vertex_project = args.vertex_project or os.environ.get("VIDEO_ANALYZER_VERTEX_PROJECT") or gcloud_config_get_value("project")

    explicit_slug = slugify(args.slug) if args.slug else None
    source_path = Path(source).expanduser() if not is_url(source) else None

    if source_path and not source_path.exists():
        raise FileNotFoundError(f"Source file not found: {source_path}")

    if is_url(source) and is_youtube_url(source):
        video_id = youtube_id_from_url(source)
        oembed = fetch_json(f"https://www.youtube.com/oembed?url={source}&format=json")
        if oembed:
            if isinstance(oembed.get("title"), str):
                oembed["title"] = maybe_fix_mojibake(oembed["title"])
            if isinstance(oembed.get("author_name"), str):
                oembed["author_name"] = maybe_fix_mojibake(oembed["author_name"])
            metadata["oembed"] = oembed
            prep_lines.append("Fetched oEmbed metadata from YouTube.")
        else:
            prep_lines.append("Failed to fetch oEmbed metadata.")

        page_html = ""
        try:
            page_html = fetch_text(source)
            write_text((output_root / "_tmp_source.html"), page_html)
            prep_lines.append("Fetched watch page HTML.")
        except (HTTPError, URLError, TimeoutError) as error:
            prep_lines.append(f"Failed to fetch watch page HTML: {error}")

        title = None
        if oembed:
            title = oembed.get("title")
        if not title and video_id:
            title = video_id
        output_slug = explicit_slug or choose_slug(title, video_id or "youtube-video")
        output_dir = output_root / output_slug
        ensure_dir(output_dir)

        temp_html = output_root / "_tmp_source.html"
        if temp_html.exists():
            temp_html.replace(output_dir / "source.html")

        if video_id:
            metadata["video_id"] = video_id

        yt_dlp_metadata, yt_dlp_error = collect_yt_dlp_metadata(source, output_dir, args.cookies_browser)
        if yt_dlp_metadata:
            metadata["yt_dlp"] = {
                "title": maybe_fix_mojibake(yt_dlp_metadata.get("title")),
                "uploader": maybe_fix_mojibake(yt_dlp_metadata.get("uploader")),
                "duration": yt_dlp_metadata.get("duration"),
                "upload_date": yt_dlp_metadata.get("upload_date"),
            }
            prep_lines.append("Collected yt-dlp metadata.")
        elif yt_dlp_error:
            metadata["yt_dlp_error"] = yt_dlp_error
            prep_lines.append(f"yt-dlp metadata failed: {yt_dlp_error}")

        subtitle_files, subtitle_error = collect_subtitles(source, output_dir, args.cookies_browser)
        if subtitle_files:
            subtitle_names = [path.name for path in subtitle_files]
            metadata["subtitle_files"] = subtitle_names
            prep_lines.append(f"Collected subtitles: {', '.join(subtitle_names)}")
            preferred_subtitle = subtitle_files[0]
            if preferred_subtitle.suffix.lower() == ".vtt":
                transcript_text_path = output_dir / "transcript.txt"
                normalize_vtt_to_text(preferred_subtitle, transcript_text_path)
            else:
                transcript_text_path = output_dir / "transcript.txt"
                normalize_srt_to_text(preferred_subtitle, transcript_text_path)
            backend = "subtitles"
        elif subtitle_error:
            metadata["subtitle_error"] = subtitle_error
            prep_lines.append(f"Subtitle extraction failed: {subtitle_error}")

        if page_html:
            chapters = parse_youtube_chapters(page_html)
            if chapters:
                chapters_path = output_dir / "chapters.json"
                write_json(chapters_path, chapters)
                prep_lines.append(f"Extracted {len(chapters)} chapters from watch page HTML.")
                metadata["chapter_count"] = len(chapters)
            else:
                prep_lines.append("No chapters found in watch page HTML.")

        write_json(output_dir / "metadata.json", metadata)
        if transcript_text_path is None and chapters_path is None:
            prep_lines.append("No transcript or chapters available. Summary will be metadata-only.")
        generated = False
        if args.summarize_backend == "google-ai":
            generated = maybe_generate_google_ai_summary(
                output_dir=output_dir,
                source=source,
                backend=backend,
                metadata=metadata,
                transcript_text_path=transcript_text_path,
                chapters_path=chapters_path,
                model=args.google_model,
                prep_lines=prep_lines,
            )
        elif args.summarize_backend == "vertex":
            generated = maybe_generate_vertex_summary(
                output_dir=output_dir,
                source=source,
                backend=backend,
                metadata=metadata,
                transcript_text_path=transcript_text_path,
                chapters_path=chapters_path,
                project_id=vertex_project,
                location=args.vertex_location,
                model=args.vertex_model,
                prep_lines=prep_lines,
            )
        if not generated:
            build_summary_stub(output_dir / "summary.md", source, backend, transcript_text_path, chapters_path)
        write_prep_report(output_dir / "prep-report.md", prep_lines)
        print(json.dumps({"output_dir": str(output_dir), "backend": backend}, ensure_ascii=False))
        return 0

    output_slug = explicit_slug or choose_slug(source_path.stem if source_path else None, "video")
    output_dir = output_root / output_slug
    ensure_dir(output_dir)

    if source_path:
        metadata["source_file"] = str(source_path.resolve())
        metadata["probe"] = probe_local_file(source_path)
        prep_lines.append("Probed local media file with ffprobe.")

        audio_path = output_dir / "audio.wav"
        extract_result = extract_audio(source_path, audio_path)
        if extract_result.returncode != 0:
            raise RuntimeError(extract_result.stderr.strip() or "ffmpeg audio extraction failed")
        prep_lines.append("Extracted mono 16k WAV audio.")

        whisper_model_value = args.whisper_model or os.environ.get("VIDEO_ANALYZER_WHISPER_MODEL")
        vad_model_value = args.vad_model or os.environ.get("VIDEO_ANALYZER_VAD_MODEL")

        whisper_model = Path(whisper_model_value).expanduser().resolve() if whisper_model_value else None
        vad_model = Path(vad_model_value).expanduser().resolve() if vad_model_value else None

        if whisper_model and whisper_model.exists():
            transcript_json_path = output_dir / "transcript.json"
            transcribe_result = transcribe_with_ffmpeg_whisper(
                audio_path=audio_path,
                transcript_path=transcript_json_path,
                model_path=whisper_model,
                language=args.language,
                vad_model=vad_model if vad_model and vad_model.exists() else None,
            )
            if transcribe_result.returncode == 0 and transcript_json_path.exists():
                transcript_text_path = output_dir / "transcript.txt"
                extract_text_from_whisper_json(transcript_json_path, transcript_text_path)
                backend = "ffmpeg-whisper"
                prep_lines.append("Transcribed audio with ffmpeg whisper filter.")
            else:
                metadata["whisper_error"] = transcribe_result.stderr.strip() or transcribe_result.stdout.strip()
                prep_lines.append(f"ffmpeg whisper failed: {metadata['whisper_error']}")
        else:
            prep_lines.append("No local whisper model configured; skipped ASR.")
            metadata["whisper_model_missing"] = True

        if not args.keep_audio and audio_path.exists():
            audio_path.unlink()
            prep_lines.append("Removed temporary audio.wav.")

    write_json(output_dir / "metadata.json", metadata)
    generated = False
    if args.summarize_backend == "google-ai":
        generated = maybe_generate_google_ai_summary(
            output_dir=output_dir,
            source=source,
            backend=backend,
            metadata=metadata,
            transcript_text_path=transcript_text_path,
            chapters_path=chapters_path,
            model=args.google_model,
            prep_lines=prep_lines,
        )
    elif args.summarize_backend == "vertex":
        generated = maybe_generate_vertex_summary(
            output_dir=output_dir,
            source=source,
            backend=backend,
            metadata=metadata,
            transcript_text_path=transcript_text_path,
            chapters_path=chapters_path,
            project_id=vertex_project,
            location=args.vertex_location,
            model=args.vertex_model,
            prep_lines=prep_lines,
        )
    if not generated:
        build_summary_stub(output_dir / "summary.md", source, backend, transcript_text_path, chapters_path)
    write_prep_report(output_dir / "prep-report.md", prep_lines)
    print(json.dumps({"output_dir": str(output_dir), "backend": backend}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
