#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any


DEFAULT_QUESTION = (
    "Write a detailed summary with key ideas, conclusions, risks, and next actions."
)


def slugify(value: str) -> str:
    value = value.strip().lower()
    value = re.sub(r"https?://", "", value)
    value = re.sub(r"[^a-z0-9]+", "-", value)
    value = value.strip("-")
    return value or "notebooklm-research"


def ensure_cli() -> str:
    notebooklm = shutil.which("notebooklm")
    if not notebooklm:
        raise RuntimeError(
            "notebooklm CLI is not available in PATH. Install notebooklm-py[browser] first."
        )
    return notebooklm


def run_cli_completed(args: list[str]) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    env["PYTHONIOENCODING"] = "utf-8"

    return subprocess.run(
        ["notebooklm", *args],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        env=env,
        check=False,
    )


def run_cli(args: list[str], *, expect_json: bool = False) -> Any:
    completed = run_cli_completed(args)

    if completed.returncode != 0:
        raise RuntimeError(
            f"NotebookLM command failed: {' '.join(args)}\n"
            f"stdout:\n{completed.stdout}\n"
            f"stderr:\n{completed.stderr}"
        )

    if expect_json:
        try:
            return json.loads(completed.stdout)
        except json.JSONDecodeError as exc:
            raise RuntimeError(
                f"Expected JSON from notebooklm command: {' '.join(args)}\n{completed.stdout}"
            ) from exc

    return completed.stdout


def parse_json_output(value: str) -> Any | None:
    try:
        return json.loads(value)
    except json.JSONDecodeError:
        return None


def write_json(path: Path, payload: Any) -> None:
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def derive_title(args: argparse.Namespace) -> str:
    if args.title:
        return args.title

    first = args.source[0]
    if re.match(r"^https?://", first):
        return f"NotebookLM: {first}"
    return f"NotebookLM: {Path(first).name}"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create a NotebookLM research bundle and save artifacts locally."
    )
    parser.add_argument(
        "--source",
        action="append",
        required=True,
        help="URL, local path, or inline text source. Repeat for multiple sources.",
    )
    parser.add_argument("--title", help="Notebook title.")
    parser.add_argument("--slug", help="Output folder slug.")
    parser.add_argument("--notebook-id", help="Reuse an existing notebook ID.")
    parser.add_argument(
        "--question",
        default=DEFAULT_QUESTION,
        help="Question for notebooklm ask. Use --skip-ask to disable.",
    )
    parser.add_argument(
        "--skip-ask",
        action="store_true",
        help="Skip notebooklm ask and only prepare sources / report.",
    )
    parser.add_argument(
        "--report-format",
        choices=["briefing-doc", "study-guide", "blog-post", "custom"],
        help="Generate and download a report after ingestion.",
    )
    parser.add_argument(
        "--report-instructions",
        help="Extra instructions for report generation. For custom reports this becomes the description.",
    )
    parser.add_argument(
        "--wait-timeout",
        type=int,
        default=180,
        help="Maximum seconds to wait for each source.",
    )
    parser.add_argument(
        "--auth-heal",
        choices=["interactive", "off"],
        default="interactive",
        help="Whether to try interactive live-auth repair when stored NotebookLM auth is stale.",
    )
    parser.add_argument(
        "--auth-heal-timeout",
        type=int,
        default=240,
        help="Maximum seconds to wait for interactive NotebookLM auth repair.",
    )
    parser.add_argument(
        "--output-root",
        default=str(Path.cwd() / "runtime" / "research"),
        help="Root folder for saved artifacts.",
    )
    return parser.parse_args()


def run_live_auth_probe(output_dir: Path) -> dict[str, Any]:
    completed = run_cli_completed(["list", "--json"])
    parsed = parse_json_output(completed.stdout)
    payload = {
        "command": ["list", "--json"],
        "returncode": completed.returncode,
        "stdout": None if parsed is not None else completed.stdout,
        "stderr": completed.stderr.strip() or None,
        "data": parsed,
    }
    write_json(output_dir / "auth-live-check.json", payload)
    return payload


def run_auth_heal(output_dir: Path, timeout: int) -> dict[str, Any]:
    helper_path = Path(__file__).with_name("ensure_notebooklm_auth.py")
    env = os.environ.copy()
    env["PYTHONIOENCODING"] = "utf-8"
    completed = subprocess.run(
        [sys.executable, str(helper_path), "--json", "--timeout", str(timeout)],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        env=env,
        check=False,
    )
    parsed = parse_json_output(completed.stdout)
    payload = {
        "command": [sys.executable, str(helper_path), "--json", "--timeout", str(timeout)],
        "returncode": completed.returncode,
        "stdout": None if parsed is not None else completed.stdout,
        "stderr": completed.stderr.strip() or None,
        "data": parsed,
    }
    write_json(output_dir / "auth-heal.json", payload)
    return payload


def describe_live_probe_failure(live_probe: dict[str, Any]) -> str:
    parsed = live_probe.get("data")
    if isinstance(parsed, dict) and parsed.get("message"):
        message = parsed["message"]
    else:
        message = live_probe.get("stderr") or live_probe.get("stdout") or "NotebookLM live auth probe failed."
    return (
        "NotebookLM live auth probe failed. "
        "Stored cookies exist, but the live NotebookLM session is still invalid.\n"
        f"{message}"
    )


def describe_auth_heal_failure(auth_heal: dict[str, Any]) -> str:
    parsed = auth_heal.get("data")
    if isinstance(parsed, dict) and parsed.get("error"):
        detail = parsed["error"]
    else:
        detail = auth_heal.get("stderr") or auth_heal.get("stdout") or "NotebookLM auth repair failed."
    return "NotebookLM auth repair did not restore a live session.\n" + detail


def build_summary(
    *,
    notebook: dict[str, Any],
    sources_added: list[dict[str, Any]],
    auth_check: dict[str, Any],
    live_probe: dict[str, Any] | None,
    auth_heal: dict[str, Any] | None,
    question: str | None,
    answer_data: dict[str, Any] | None,
    report_data: dict[str, Any] | None,
    report_path: Path | None,
) -> str:
    lines: list[str] = []
    lines.append("# NotebookLM Research Bundle")
    lines.append("")
    lines.append("## Notebook")
    lines.append(f"- title: {notebook.get('title', '-')}")
    lines.append(f"- id: {notebook.get('id', '-')}")
    lines.append("")
    lines.append("## Auth")
    lines.append(f"- status: {auth_check.get('status', 'unknown')}")
    sid_cookie = (
        auth_check.get("checks", {}).get("sid_cookie")
        if isinstance(auth_check.get("checks"), dict)
        else None
    )
    lines.append(f"- sid_cookie: {sid_cookie}")
    lines.append(f"- live_probe: {'ok' if live_probe and live_probe.get('returncode') == 0 else 'not-run'}")
    if auth_heal:
        lines.append(f"- auth_heal: {'ok' if auth_heal.get('returncode') == 0 else 'failed'}")
    lines.append("")
    lines.append("## Sources")
    for item in sources_added:
        source = item.get("source", {})
        wait = item.get("wait", {})
        lines.append(
            f"- {source.get('id', '-')} | {source.get('type', '-')} | {source.get('title', '-') or '-'} | status={wait.get('status', '-')}"
        )
    lines.append("")

    if answer_data:
        lines.append("## Ask")
        lines.append(f"- question: {question}")
        lines.append("")
        lines.append(answer_data.get("answer", "").strip() or "(empty answer)")
        lines.append("")

    if report_data:
        lines.append("## Report")
        lines.append(f"- status: {report_data.get('status', '-')}")
        if report_data.get("task_id"):
            lines.append(f"- artifact id: {report_data.get('task_id')}")
        if report_path:
            lines.append(f"- downloaded: {report_path}")
        lines.append("")

    return "\n".join(lines).strip() + "\n"


def build_failure_summary(
    *,
    title: str,
    sources: list[str],
    auth_check: dict[str, Any],
    live_probe: dict[str, Any] | None,
    auth_heal: dict[str, Any] | None,
    error_message: str,
) -> str:
    lines: list[str] = []
    lines.append("# NotebookLM Research Bundle")
    lines.append("")
    lines.append("## Notebook")
    lines.append(f"- title: {title}")
    lines.append("- id: -")
    lines.append("")
    lines.append("## Auth")
    lines.append(f"- status: {auth_check.get('status', 'unknown')}")
    sid_cookie = (
        auth_check.get("checks", {}).get("sid_cookie")
        if isinstance(auth_check.get("checks"), dict)
        else None
    )
    lines.append(f"- sid_cookie: {sid_cookie}")
    lines.append(f"- live_probe: {'failed' if live_probe else 'not-run'}")
    if auth_heal:
        lines.append(f"- auth_heal: {'failed' if auth_heal.get('returncode') != 0 else 'ok'}")
    lines.append("")
    lines.append("## Sources")
    for source in sources:
        lines.append(f"- {source}")
    lines.append("")
    lines.append("## Failure")
    lines.append(f"- {error_message}")
    lines.append("")
    lines.append("## Next Step")
    lines.append("- Re-run the same task; the adapter will try auth self-heal again unless disabled.")
    lines.append("- If a browser window opens, finish the Google login there and wait for the NotebookLM homepage.")
    lines.append("- The auth-heal helper auto-saves storage_state; no extra ENTER confirmation is needed there.")
    lines.append("- If the live probe still fails after login, inspect auth-live-check.json and auth-heal.json in this bundle.")
    lines.append("")
    return "\n".join(lines).strip() + "\n"


def main() -> int:
    args = parse_args()
    ensure_cli()

    output_root = Path(args.output_root).resolve()
    title = derive_title(args)
    slug = args.slug or slugify(title)
    output_dir = output_root / slug
    output_dir.mkdir(parents=True, exist_ok=True)

    auth_check = run_cli(["auth", "check", "--json"], expect_json=True)
    write_json(output_dir / "auth-check.json", auth_check)

    live_probe: dict[str, Any] | None = None
    auth_heal: dict[str, Any] | None = None

    try:
        if auth_check.get("status") != "ok":
            raise RuntimeError("NotebookLM auth check failed.")

        live_probe = run_live_auth_probe(output_dir)
        if live_probe.get("returncode") != 0:
            if args.auth_heal == "interactive":
                auth_heal = run_auth_heal(output_dir, args.auth_heal_timeout)
                live_probe = run_live_auth_probe(output_dir)

            if live_probe.get("returncode") != 0:
                message = describe_live_probe_failure(live_probe)
                if auth_heal is not None and auth_heal.get("returncode") != 0:
                    message = f"{message}\n\n{describe_auth_heal_failure(auth_heal)}"
                raise RuntimeError(message)

        if live_probe.get("data") is None:
            raise RuntimeError("NotebookLM live auth probe returned non-JSON output for `notebooklm list --json`.")

        notebook_payload: dict[str, Any]
        notebook: dict[str, Any]
        if args.notebook_id:
            notebook = {"id": args.notebook_id, "title": title}
            notebook_payload = {"notebook": notebook, "created": False}
        else:
            notebook_payload = run_cli(["create", title, "--json"], expect_json=True)
            notebook = notebook_payload["notebook"]

        write_json(output_dir / "notebook.json", notebook_payload)

        notebook_id = notebook["id"]
        run_cli(["use", notebook_id])

        sources_added: list[dict[str, Any]] = []
        source_ids: list[str] = []
        for source_value in args.source:
            added = run_cli(
                ["source", "add", "-n", notebook_id, source_value, "--json"],
                expect_json=True,
            )
            source_id = added["source"]["id"]
            waited = run_cli(
                [
                    "source",
                    "wait",
                    "-n",
                    notebook_id,
                    source_id,
                    "--timeout",
                    str(args.wait_timeout),
                    "--json",
                ],
                expect_json=True,
            )
            sources_added.append({"input": source_value, "source": added["source"], "wait": waited})
            source_ids.append(source_id)

        write_json(output_dir / "sources.json", sources_added)

        answer_data: dict[str, Any] | None = None
        if not args.skip_ask and args.question:
            ask_args = ["ask", "-n", notebook_id]
            for source_id in source_ids:
                ask_args.extend(["-s", source_id])
            ask_args.extend([args.question, "--json"])
            answer_data = run_cli(ask_args, expect_json=True)
            write_json(output_dir / "answer.json", answer_data)

        report_data: dict[str, Any] | None = None
        report_path: Path | None = None
        if args.report_format:
            report_args = [
                "generate",
                "report",
                "-n",
                notebook_id,
                "--format",
                args.report_format,
                "--wait",
                "--json",
            ]
            for source_id in source_ids:
                report_args.extend(["-s", source_id])

            if args.report_instructions:
                if args.report_format == "custom":
                    report_args.append(args.report_instructions)
                else:
                    report_args.extend(["--append", args.report_instructions])

            report_data = run_cli(report_args, expect_json=True)
            write_json(output_dir / "report.json", report_data)

            task_id = report_data.get("task_id")
            if task_id:
                report_path = output_dir / "report.md"
                run_cli(
                    [
                        "download",
                        "report",
                        str(report_path),
                        "-n",
                        notebook_id,
                        "-a",
                        task_id,
                        "--force",
                    ]
                )
                write_json(
                    output_dir / "report-download.json",
                    {
                        "artifact_id": task_id,
                        "output_path": str(report_path),
                        "status": "downloaded" if report_path.exists() else "missing-after-download",
                    },
                )

        manifest = {
            "title": title,
            "slug": slug,
            "output_dir": str(output_dir),
            "notebook_id": notebook_id,
            "sources": args.source,
            "source_ids": source_ids,
            "question": None if args.skip_ask else args.question,
            "report_format": args.report_format,
            "report_instructions": args.report_instructions,
            "report_path": str(report_path) if report_path else None,
        }
        write_json(output_dir / "manifest.json", manifest)

        summary_text = build_summary(
            notebook=notebook,
            sources_added=sources_added,
            auth_check=auth_check,
            live_probe=live_probe,
            auth_heal=auth_heal,
            question=None if args.skip_ask else args.question,
            answer_data=answer_data,
            report_data=report_data,
            report_path=report_path,
        )
        (output_dir / "summary.md").write_text(summary_text, encoding="utf-8")

        print(
            json.dumps(
                {
                    "output_dir": str(output_dir),
                    "notebook_id": notebook_id,
                    "source_count": len(source_ids),
                    "answer_saved": answer_data is not None,
                    "report_saved": report_path is not None,
                },
                ensure_ascii=False,
            )
        )
        return 0
    except Exception as exc:
        write_json(
            output_dir / "error.json",
            {
                "title": title,
                "sources": args.source,
                "error": str(exc),
            },
        )
        (output_dir / "summary.md").write_text(
            build_failure_summary(
                title=title,
                sources=args.source,
                auth_check=auth_check,
                live_probe=live_probe,
                auth_heal=auth_heal,
                error_message=str(exc),
            ),
            encoding="utf-8",
        )
        raise


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # pragma: no cover
        print(str(exc), file=sys.stderr)
        raise SystemExit(1)
