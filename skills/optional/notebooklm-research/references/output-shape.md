# Output Shape

Default folder:

```text
runtime/research/<slug>/
  auth-check.json
  auth-live-check.json
  auth-heal.json
  error.json
  manifest.json
  notebook.json
  sources.json
  answer.json
  report.json
  report-download.json
  report.md
  summary.md
```

Not every file is mandatory on every run.

- `auth-live-check.json` exists when the adapter reached the live auth probe.
- `auth-heal.json` exists when the adapter attempted interactive auth repair.
- `error.json` exists when the adapter failed after creating the output folder.
- `answer.json` exists when `ask` ran.
- `report.json`, `report-download.json`, and `report.md` exist when report generation ran.
- `summary.md` should exist on both success and handled failure paths.
