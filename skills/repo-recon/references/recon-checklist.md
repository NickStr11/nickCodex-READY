# Recon Checklist

## Minimum pass

1. Top-level map:
   README-файлы, manifests, lockfiles, CI workflows, Dockerfiles, env examples, major app folders.
2. Stack:
   language, framework, package manager, test runner, deployment surface.
3. Commands:
   install, dev, test, lint, build, run.
4. Entrypoints:
   frontend root, server boot, CLI `main`, worker/job runner, migration path, config loader.
5. Hotspots:
   auth, payments, secrets/config, DB, queues, external APIs, generated code, large legacy zones.

## Default output shape

```md
## Stack
- ...

## Commands
- ...

## Entrypoints
- ...

## Hotspots
- ...
```

## Optional capture

Если разбор заметно больше обычного ответа, клади сжатую заметку в:

```text
runtime/research/<repo-slug>/summary.md
```

Туда же можно положить временные ссылки, команды и списки файлов. Если находка стала долгоживущим знанием, смысл потом уходит в `knowledge/` или `memory/`, а не остаётся вечным мусором в `runtime/`.
