#!/usr/bin/env python3
from __future__ import annotations

import argparse
import asyncio
import json
import os
import subprocess
import sys
import time
from contextlib import contextmanager
from pathlib import Path
from typing import Any, Iterator

from notebooklm.paths import get_browser_profile_dir, get_storage_path

PLAYWRIGHT_IGNORE_DEFAULT_ARGS = ["--enable-automation", "--no-sandbox"]


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


def run_powershell(script: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["powershell", "-NoProfile", "-Command", script],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        check=False,
    )


def parse_json_output(value: str) -> Any | None:
    try:
        return json.loads(value)
    except json.JSONDecodeError:
        return None


@contextmanager
def windows_playwright_event_loop() -> Iterator[None]:
    if sys.platform != "win32":
        yield
        return

    original_policy = asyncio.get_event_loop_policy()
    asyncio.set_event_loop_policy(asyncio.DefaultEventLoopPolicy())
    try:
        yield
    finally:
        asyncio.set_event_loop_policy(original_policy)


def is_ready_url(url: str) -> bool:
    return "notebooklm.google.com" in url and "accounts.google.com" not in url


def best_page(context: Any) -> Any:
    for page in reversed(context.pages):
        current_url = page.url or ""
        if "notebooklm.google.com" in current_url or "accounts.google.com" in current_url:
            return page
    return context.pages[-1] if context.pages else context.new_page()


def run_live_probe() -> dict[str, Any]:
    completed = run_cli_completed(["list", "--json"])
    return {
        "returncode": completed.returncode,
        "stdout": completed.stdout,
        "stderr": completed.stderr,
        "data": parse_json_output(completed.stdout),
    }


def find_profile_processes(browser_profile: Path) -> list[dict[str, Any]]:
    if sys.platform != "win32":
        return []

    needle = str(browser_profile).replace("'", "''")
    completed = run_powershell(
        "$needle = [regex]::Escape('"
        + needle
        + "'); "
        + "Get-CimInstance Win32_Process | "
        + "Where-Object { $_.CommandLine -and $_.CommandLine -match $needle } | "
        + "Select-Object Name,ProcessId,CommandLine | ConvertTo-Json -Compress"
    )
    if completed.returncode != 0 or not completed.stdout.strip():
        return []

    parsed = parse_json_output(completed.stdout)
    if parsed is None:
        return []
    if isinstance(parsed, list):
        return parsed
    if isinstance(parsed, dict):
        return [parsed]
    return []


def reap_profile_processes(browser_profile: Path) -> list[int]:
    processes = find_profile_processes(browser_profile)
    if not processes:
        return []

    ids = [int(item["ProcessId"]) for item in processes if item.get("ProcessId")]
    if not ids:
        return []

    joined = ",".join(str(pid) for pid in ids)
    run_powershell(f"Stop-Process -Id {joined} -Force -ErrorAction SilentlyContinue")
    time.sleep(2)
    return ids


def clear_profile_lockfile(browser_profile: Path) -> bool:
    lockfile = browser_profile / "lockfile"
    if not lockfile.exists():
        return False
    try:
        lockfile.unlink()
        return True
    except OSError:
        return False


def installed_browser_channels() -> list[str]:
    candidates: list[tuple[str, list[str]]] = [
        ("chrome", [
            r"C:\Program Files\Google\Chrome\Application\chrome.exe",
            r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        ]),
        ("msedge", [
            r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
            r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
        ]),
    ]

    channels: list[str] = []
    for name, paths in candidates:
        if any(Path(path).exists() for path in paths):
            channels.append(name)
    channels.append("chromium")
    return channels


def launch_context(p: Any, browser_profile: Path) -> tuple[Any, str]:
    last_error: Exception | None = None
    for channel in installed_browser_channels():
        kwargs = {
            "user_data_dir": str(browser_profile),
            "headless": False,
            "args": [
                "--disable-blink-features=AutomationControlled",
                "--password-store=basic",
            ],
            "ignore_default_args": PLAYWRIGHT_IGNORE_DEFAULT_ARGS,
        }
        if channel != "chromium":
            kwargs["channel"] = channel

        try:
            context = p.chromium.launch_persistent_context(**kwargs)
            return context, channel
        except Exception as exc:  # noqa: BLE001
            last_error = exc

    raise RuntimeError(f"Failed to launch a usable browser channel for NotebookLM auth repair: {last_error}")


def repair_auth(timeout: int) -> dict[str, Any]:
    try:
        from playwright.sync_api import sync_playwright
    except ImportError as exc:  # pragma: no cover
        raise RuntimeError(
            "Playwright is not installed. Install notebooklm[browser] and playwright chromium."
        ) from exc

    storage_path = get_storage_path()
    browser_profile = get_browser_profile_dir()
    storage_path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    browser_profile.mkdir(parents=True, exist_ok=True, mode=0o700)

    result: dict[str, Any] = {
        "storage_path": str(storage_path),
        "browser_profile": str(browser_profile),
        "timeout_seconds": timeout,
        "ignore_default_args": PLAYWRIGHT_IGNORE_DEFAULT_ARGS,
    }
    result["reaped_processes"] = reap_profile_processes(browser_profile)
    result["lockfile_removed"] = clear_profile_lockfile(browser_profile)

    with windows_playwright_event_loop(), sync_playwright() as p:
        context, channel = launch_context(p, browser_profile)
        try:
            result["browser_channel"] = channel
            page = best_page(context)
            page.goto("https://notebooklm.google.com/", wait_until="domcontentloaded")
            time.sleep(2)

            initial_url = best_page(context).url
            result["initial_url"] = initial_url
            result["initial_state"] = "ready" if is_ready_url(initial_url) else "login_required"

            deadline = time.time() + timeout
            while time.time() < deadline:
                active_page = best_page(context)
                current_url = active_page.url
                result["last_url"] = current_url

                if is_ready_url(current_url):
                    time.sleep(2)
                    context.storage_state(path=str(storage_path))
                    try:
                        storage_path.chmod(0o600)
                    except OSError:
                        pass
                    result["status"] = "saved"
                    result["saved_from"] = "existing-profile" if result["initial_state"] == "ready" else "interactive-login"
                    return result

                time.sleep(2)

            result["status"] = "timeout"
            raise RuntimeError(
                "Timed out waiting for NotebookLM homepage during auth repair. "
                "If a browser window opened, finish Google login there and retry."
            )
        finally:
            context.close()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Ensure NotebookLM has a live authenticated session and refresh storage_state.json if needed."
    )
    parser.add_argument("--timeout", type=int, default=240, help="Seconds to wait for interactive login if needed.")
    parser.add_argument("--json", action="store_true", help="Print JSON result.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    live_before = run_live_probe()
    if live_before["returncode"] == 0 and live_before["data"] is not None:
        payload = {
            "status": "ok",
            "action": "noop",
            "live_probe_before": live_before,
            "storage_path": str(get_storage_path()),
            "browser_profile": str(get_browser_profile_dir()),
        }
        if args.json:
            print(json.dumps(payload, ensure_ascii=False))
        else:
            print("NotebookLM live auth already valid.")
        return 0

    try:
        repair = repair_auth(args.timeout)
        live_after = run_live_probe()
        payload = {
            "status": "ok" if live_after["returncode"] == 0 and live_after["data"] is not None else "failed",
            "action": "repaired",
            "repair": repair,
            "live_probe_before": live_before,
            "live_probe_after": live_after,
        }
        if args.json:
            print(json.dumps(payload, ensure_ascii=False))
        else:
            print(json.dumps(payload, ensure_ascii=False, indent=2))
        return 0 if payload["status"] == "ok" else 1
    except Exception as exc:
        payload = {
            "status": "failed",
            "action": "repair-attempted",
            "error": str(exc),
            "live_probe_before": live_before,
            "storage_path": str(get_storage_path()),
            "browser_profile": str(get_browser_profile_dir()),
        }
        if args.json:
            print(json.dumps(payload, ensure_ascii=False))
        else:
            print(json.dumps(payload, ensure_ascii=False, indent=2))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
