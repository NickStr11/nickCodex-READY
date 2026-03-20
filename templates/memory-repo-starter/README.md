# {{MEMORY_REPO_NAME}}

Long-term memory repo for `{{AGENT_NAME}}`.

## Start here

- `AGENTS.md`
- `persona/voice.md`
- `persona/operator-rules.md`
- `handoff/now.md`
- `memory/user-profile.md`
- `memory/stable-facts.md`
- `memory/projects.md`

## Validate

```powershell
.\scripts\validate-memory-repo.ps1
```

## Minimum discipline

- stable facts -> `memory/*`
- hot context -> `handoff/now.md`
- significant changes -> `memory/CHANGELOG.md`
- raw imports -> `runtime/imports/`
