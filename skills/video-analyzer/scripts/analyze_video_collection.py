#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Any
from urllib.parse import parse_qs, urlparse

from prepare_video import (
    default_output_root,
    ensure_dir,
    gcloud_config_get_value,
    google_ai_generate_summary,
    maybe_fix_mojibake,
    run_command,
    slugify,
    vertex_generate_summary,
)


YOUTUBE_HOSTS = {
    "youtube.com",
    "www.youtube.com",
    "m.youtube.com",
    "youtu.be",
}


def is_url(value: str) -> bool:
    parsed = urlparse(value)
    return parsed.scheme in {"http", "https"}


def is_youtube_collection_url(value: str) -> bool:
    parsed = urlparse(value)
    host = parsed.netloc.lower()
    if host not in YOUTUBE_HOSTS:
        return False

    if parsed.path == "/playlist":
        return True
    if parse_qs(parsed.query).get("list"):
        return True
    if parsed.path.startswith(("/channel/", "/user/", "/c/", "/@", "/feed/")):
        return True
    return parsed.path.endswith("/videos")


def collection_slug_from_source(source: str) -> str:
    parsed = urlparse(source)
    if not parsed.scheme:
        return slugify(Path(source).stem)

    if parsed.netloc.lower() == "youtu.be":
        return slugify(parsed.path.strip("/") or "youtube-collection")

    query = parse_qs(parsed.query)
    if query.get("list"):
        return slugify(query["list"][0])

    path = parsed.path.strip("/")
    return slugify(path or parsed.netloc)


def collect_youtube_entries(source: str, cookies_browser: str | None, max_items: int | None) -> tuple[dict[str, Any] | None, list[dict[str, str]], str | None]:
    command = ["yt-dlp", "--flat-playlist", "--dump-single-json", "--no-warnings"]
    if cookies_browser:
        command.extend(["--cookies-from-browser", cookies_browser])
    command.append(source)

    result = run_command(command)
    if result.returncode != 0:
        return None, [], result.stderr.strip() or result.stdout.strip() or "playlist enumeration failed"

    try:
        payload = json.loads(result.stdout)
    except json.JSONDecodeError as error:
        return None, [], str(error)

    entries = payload.get("entries") or []
    items: list[dict[str, str]] = []
    for entry in entries:
        if not isinstance(entry, dict):
            continue
        video_id = entry.get("id") or entry.get("url")
        webpage_url = entry.get("webpage_url")
        if not webpage_url and video_id:
            webpage_url = f"https://www.youtube.com/watch?v={video_id}"
        if not webpage_url:
            continue
        items.append(
            {
                "title": maybe_fix_mojibake(entry.get("title")) or video_id or webpage_url,
                "source": webpage_url,
            }
        )

    if max_items is not None:
        items = items[:max_items]

    metadata = {
        "source": source,
        "title": maybe_fix_mojibake(payload.get("title")),
        "uploader": maybe_fix_mojibake(payload.get("uploader")),
        "entry_count": len(items),
    }
    return metadata, items, None


def run_single_analysis(
    *,
    prep_script: Path,
    source: str,
    item_slug: str,
    output_root: Path,
    args: argparse.Namespace,
) -> tuple[dict[str, Any] | None, str | None]:
    command = [
        sys.executable,
        str(prep_script),
        "--source",
        source,
        "--output-root",
        str(output_root),
        "--slug",
        item_slug,
        "--summarize-backend",
        args.summarize_backend,
        "--google-model",
        args.google_model,
        "--vertex-location",
        args.vertex_location,
        "--vertex-model",
        args.vertex_model,
    ]

    if args.vertex_project:
        command.extend(["--vertex-project", args.vertex_project])
    if args.whisper_model:
        command.extend(["--whisper-model", args.whisper_model])
    if args.vad_model:
        command.extend(["--vad-model", args.vad_model])
    if args.cookies_browser:
        command.extend(["--cookies-browser", args.cookies_browser])
    if args.keep_audio:
        command.append("--keep-audio")

    result = subprocess.run(
        command,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        check=False,
    )
    if result.returncode != 0:
        message = result.stderr.strip() or result.stdout.strip() or f"failed for {source}"
        return None, message

    stdout_lines = [line.strip() for line in result.stdout.splitlines() if line.strip()]
    if not stdout_lines:
        return None, f"no output returned for {source}"
    try:
        payload = json.loads(stdout_lines[-1])
    except json.JSONDecodeError as error:
        return None, f"invalid JSON output for {source}: {error}"
    return payload, None


def load_text_if_exists(path: Path) -> str:
    if not path.exists():
        return ""
    return path.read_text(encoding="utf-8", errors="replace").strip()


def build_collection_prompt(
    *,
    mode: str,
    source: str,
    item_reports: list[dict[str, Any]],
) -> str:
    lines = [
        "You are summarizing a set of videos for a coding and research workflow.",
        "Return markdown only.",
        "Use this exact structure:",
        "# Summary",
        "",
        "## Source",
        "- input: ...",
        f"- mode: {mode}",
        f"- videos analyzed: {len(item_reports)}",
        "",
        "## Short Summary",
        "- 3-6 concise bullets",
        "",
        "## Cross-Video Themes",
        "- 4-8 bullets",
        "",
        "## Notable Videos",
        "- one bullet per especially useful or distinctive item",
        "",
        "## Action Items",
        "- 0-5 bullets, only if clearly implied",
        "",
        "## Notes",
        "- mention missing transcripts, chapters fallback, blockers, or coverage limits",
        "",
        f"Collection source: {source}",
        "",
        "Per-video material:",
    ]

    for report in item_reports:
        lines.extend(
            [
                f"### {report['title']}",
                f"- source: {report['source']}",
                f"- backend: {report['backend']}",
                f"- item_dir: {report['item_dir']}",
                "- summary:",
                report["summary"][:12000] if report["summary"] else "(no summary produced)",
                "",
            ]
        )

    return "\n".join(lines)


def write_collection_summary_stub(
    path: Path,
    *,
    source: str,
    mode: str,
    item_reports: list[dict[str, Any]],
) -> None:
    lines = [
        "# Summary",
        "",
        "## Source",
        f"- input: `{source}`",
        f"- mode: `{mode}`",
        f"- videos analyzed: {len(item_reports)}",
        "",
        "## Short Summary",
        "- [fill]",
        "",
        "## Cross-Video Themes",
        "- [fill]",
        "",
        "## Notable Videos",
    ]
    for report in item_reports:
        lines.append(f"- `{report['title']}` -> `{report['backend']}`")
    lines.extend(
        [
            "",
            "## Action Items",
            "- [fill]",
            "",
            "## Notes",
            "- State clearly if some items were summarized only from chapters/metadata.",
            "",
        ]
    )
    path.write_text("\n".join(lines), encoding="utf-8")


def maybe_generate_collection_summary(
    *,
    output_dir: Path,
    source: str,
    mode: str,
    item_reports: list[dict[str, Any]],
    summarize_backend: str,
    google_model: str,
    vertex_project: str | None,
    vertex_location: str,
    vertex_model: str,
    prep_lines: list[str],
) -> bool:
    if not item_reports:
        prep_lines.append("Collection summary skipped: no successful item analyses.")
        return False

    prompt = build_collection_prompt(
        mode=mode,
        source=source,
        item_reports=item_reports,
    )

    if summarize_backend == "google-ai":
        api_key = os.environ.get("VIDEO_ANALYZER_GEMINI_API_KEY") or os.environ.get("GEMINI_API_KEY")
        if not api_key:
            prep_lines.append("Collection summary skipped: no GEMINI_API_KEY configured.")
            return False
        try:
            summary = google_ai_generate_summary(
                prompt=prompt,
                model=google_model,
                api_key=api_key,
            )
        except Exception as error:  # noqa: BLE001
            prep_lines.append(f"Collection summary failed via Google AI API: {error}")
            return False
        (output_dir / "summary.md").write_text(summary if summary.endswith("\n") else summary + "\n", encoding="utf-8")
        prep_lines.append(f"Generated collection summary with Google AI model `{google_model}`.")
        return True

    if summarize_backend == "vertex":
        if not vertex_project:
            prep_lines.append("Collection summary skipped: no GCP project configured for Vertex.")
            return False
        try:
            summary = vertex_generate_summary(
                prompt=prompt,
                project_id=vertex_project,
                location=vertex_location,
                model=vertex_model,
            )
        except Exception as error:  # noqa: BLE001
            prep_lines.append(f"Collection summary failed via Vertex: {error}")
            return False
        (output_dir / "summary.md").write_text(summary if summary.endswith("\n") else summary + "\n", encoding="utf-8")
        prep_lines.append(f"Generated collection summary with Vertex model `{vertex_model}`.")
        return True

    prep_lines.append("Collection summary backend set to stub.")
    return False


def main() -> int:
    parser = argparse.ArgumentParser(description="Analyze one or more videos, playlists, or channels and build a collection summary.")
    parser.add_argument("--source", dest="sources", action="append", required=True, help="Video URL, playlist/channel URL, or local file path. Repeat for multiple sources.")
    parser.add_argument("--output-root", help="Root folder for runtime/research output. Defaults to ./runtime/research in the current repo")
    parser.add_argument("--slug", help="Optional explicit collection slug")
    parser.add_argument("--max-items", type=int, help="Optional cap for items collected from a channel or playlist")
    parser.add_argument("--cookies-browser", choices=["chrome", "edge"], help="Optional browser cookies for yt-dlp")
    parser.add_argument("--keep-audio", action="store_true", help="Keep extracted audio.wav for local files")
    parser.add_argument("--whisper-model", help="Path to whisper.cpp ggml model")
    parser.add_argument("--vad-model", help="Optional path to VAD model for ffmpeg whisper")
    parser.add_argument("--summarize-backend", choices=["stub", "vertex", "google-ai"], default=os.environ.get("VIDEO_ANALYZER_SUMMARIZE_BACKEND", "google-ai"))
    parser.add_argument("--vertex-project", help="GCP project id for Vertex summary")
    parser.add_argument("--vertex-location", default=os.environ.get("VIDEO_ANALYZER_VERTEX_LOCATION", "us-central1"))
    parser.add_argument("--vertex-model", default=os.environ.get("VIDEO_ANALYZER_VERTEX_MODEL", "gemini-2.5-flash"))
    parser.add_argument("--google-model", default=os.environ.get("VIDEO_ANALYZER_GOOGLE_MODEL", "gemini-3-flash-preview"))
    args = parser.parse_args()

    output_root = Path(args.output_root or str(default_output_root())).expanduser().resolve()
    ensure_dir(output_root)

    prep_lines: list[str] = []
    prep_script = Path(__file__).with_name("prepare_video.py")
    vertex_project = args.vertex_project or os.environ.get("VIDEO_ANALYZER_VERTEX_PROJECT") or gcloud_config_get_value("project")

    expanded_items: list[dict[str, str]] = []
    collection_mode = "multi-video"
    collection_sources = list(args.sources)

    for raw_source in collection_sources:
        source = raw_source.strip()
        if is_url(source) and is_youtube_collection_url(source):
            metadata, items, error = collect_youtube_entries(source, args.cookies_browser, args.max_items)
            if error:
                prep_lines.append(f"Failed to enumerate `{source}`: {error}")
                continue
            prep_lines.append(
                f"Enumerated {len(items)} video(s) from collection `{maybe_fix_mojibake(metadata.get('title')) or source}`."
            )
            expanded_items.extend(items)
            collection_mode = "channel-or-playlist"
            continue

        expanded_items.append({"title": source, "source": source})

    collection_slug = slugify(args.slug) if args.slug else collection_slug_from_source(collection_sources[0])
    output_dir = output_root / collection_slug
    items_root = output_dir / "items"
    ensure_dir(items_root)

    if not expanded_items:
        collection_metadata = {
            "sources": collection_sources,
            "collection_mode": collection_mode,
            "resolved_items": [],
            "processed_items": [],
            "failures": [{"source": source, "error": "collection enumeration failed"} for source in collection_sources],
        }
        (output_dir / "collection.json").write_text(
            json.dumps(collection_metadata, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )
        write_collection_summary_stub(
            output_dir / "summary.md",
            source=", ".join(collection_sources),
            mode=collection_mode,
            item_reports=[],
        )
        report_lines = prep_lines + ["Processed items: 0", f"Failures: {len(collection_sources)}"]
        prep_report = "# Preparation Report\n\n" + "\n".join(f"- {line}" for line in report_lines) + "\n"
        (output_dir / "prep-report.md").write_text(prep_report, encoding="utf-8")
        print(
            json.dumps(
                {
                    "output_dir": str(output_dir),
                    "collection_mode": collection_mode,
                    "processed_items": 0,
                    "failures": len(collection_sources),
                },
                ensure_ascii=False,
            )
        )
        return 0

    item_reports: list[dict[str, Any]] = []
    failures: list[dict[str, str]] = []
    for index, item in enumerate(expanded_items, start=1):
        title_seed = item["title"] if item["title"] != item["source"] else collection_slug_from_source(item["source"])
        item_slug = f"{index:02d}-{slugify(title_seed)}"
        payload, error = run_single_analysis(
            prep_script=prep_script,
            source=item["source"],
            item_slug=item_slug,
            output_root=items_root,
            args=args,
        )
        if error:
            failures.append({"source": item["source"], "error": error})
            prep_lines.append(f"Failed `{item['source']}`: {error}")
            continue

        item_dir = Path(payload["output_dir"])
        summary_text = load_text_if_exists(item_dir / "summary.md")
        metadata = json.loads((item_dir / "metadata.json").read_text(encoding="utf-8", errors="replace"))
        title = (
            maybe_fix_mojibake((metadata.get("oembed") or {}).get("title"))
            or maybe_fix_mojibake((metadata.get("yt_dlp") or {}).get("title"))
            or item["title"]
        )
        item_reports.append(
            {
                "title": title,
                "source": item["source"],
                "backend": payload.get("backend", "unknown"),
                "item_dir": str(item_dir),
                "summary": summary_text,
            }
        )

    collection_metadata = {
        "sources": collection_sources,
        "collection_mode": collection_mode,
        "resolved_items": expanded_items,
        "processed_items": item_reports,
        "failures": failures,
    }
    ensure_dir(output_dir)
    (output_dir / "collection.json").write_text(
        json.dumps(collection_metadata, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    generated = maybe_generate_collection_summary(
        output_dir=output_dir,
        source=", ".join(collection_sources),
        mode=collection_mode,
        item_reports=item_reports,
        summarize_backend=args.summarize_backend,
        google_model=args.google_model,
        vertex_project=vertex_project,
        vertex_location=args.vertex_location,
        vertex_model=args.vertex_model,
        prep_lines=prep_lines,
    )
    if not generated:
        write_collection_summary_stub(
            output_dir / "summary.md",
            source=", ".join(collection_sources),
            mode=collection_mode,
            item_reports=item_reports,
        )

    report_lines = prep_lines + [f"Processed items: {len(item_reports)}", f"Failures: {len(failures)}"]
    prep_report = "# Preparation Report\n\n" + "\n".join(f"- {line}" for line in report_lines) + "\n"
    (output_dir / "prep-report.md").write_text(prep_report, encoding="utf-8")

    print(
        json.dumps(
            {
                "output_dir": str(output_dir),
                "collection_mode": collection_mode,
                "processed_items": len(item_reports),
                "failures": len(failures),
            },
            ensure_ascii=False,
        )
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
