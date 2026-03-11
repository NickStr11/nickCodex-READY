# Output Shape

Default folder:

```text
runtime/research/<slug>/
  auth-check.json
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

- `answer.json` exists when `ask` ran.
- `report.json`, `report-download.json`, and `report.md` exist when report generation ran.
- `summary.md` should always exist unless the adapter fails before notebook creation.
