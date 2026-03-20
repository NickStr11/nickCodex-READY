# Windows Gotchas

## Encoding

- On Windows, NotebookLM CLI can crash on Unicode console output.
- Always run subprocesses with `PYTHONIOENCODING=utf-8`.
- The adapter script already forces this for child processes.

## Login

- The upstream `notebooklm login` flow needs a manual `ENTER` in the terminal after the browser login. That is easy to miss.
- Prefer the skill helper instead:

```powershell
python skills/notebooklm-research/scripts/ensure_notebooklm_auth.py --json
```

- It reuses the persistent browser profile, opens a browser only if needed, waits for the NotebookLM homepage, and auto-saves `storage_state.json`.
- The helper prefers real installed `Chrome` or `Edge` channels first and strips Playwright's `--no-sandbox` default flag. This avoids Google's "unsafe browser or app" block and the endless-loading sign-in screen that can appear with the embedded Playwright browser flow.

## Expired Auth

`notebooklm auth check --json` only validates the stored cookie file. It can still look green while the live NotebookLM session is already dead.

Always confirm with:

```powershell
notebooklm list --json
```

If `list --json` redirects to Google sign-in, the live session is invalid even when `auth check` says `ok`.

Fix order:

1. run the helper `ensure_notebooklm_auth.py`
2. if a browser window opens, finish the login there
3. wait until the NotebookLM homepage loads
4. rerun the task

## Persistent Browser Profile

- The helper and the upstream CLI both use the persistent profile under `NOTEBOOKLM_HOME/browser_profile` or `~/.notebooklm/browser_profile`.
- This means the helper can often refresh `storage_state.json` without asking you to log in again, as long as the browser profile still has a valid NotebookLM session.
