# Windows Gotchas

## Encoding

- On Windows, NotebookLM CLI can crash on Unicode console output.
- Always run subprocesses with `PYTHONIOENCODING=utf-8`.
- The adapter script already forces this for child processes.

## Login

- Interactive login often does not behave well inside an agent-run terminal.
- Use:

```powershell
powershell -Command "Start-Process cmd -ArgumentList '/k notebooklm login'"
```

- Finish the browser flow manually, then rerun the task.

## Expired Auth

If `notebooklm auth check --json` shows missing cookies like `SID`, the stored browser session expired.

Fix:

1. rerun `notebooklm login`
2. confirm with `notebooklm auth check --json`

## Current Notebook Context

- `notebooklm use <id>` changes the active notebook context in the local CLI state.
- The adapter script always passes `-n <id>` explicitly, so it does not depend on whatever was active before.
