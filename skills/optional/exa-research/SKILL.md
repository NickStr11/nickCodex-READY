---
name: exa-research
description: |
  Use Exa MCP as the first step in a research-first routing workflow.

  Use PROACTIVELY when:
  - the user asks to find fresh web information and better sources
  - the task needs current implementation examples or code context from the web
  - you need targeted research before writing code, a skill, or an integration
  - the user explicitly mentions Exa, Exa MCP, or wants a research-first workflow
  - the task likely needs a mix of fresh search, library docs, and GitHub repo reading
---

# Exa Research

Use the configured `exa` MCP server as the first research layer when it is available.
This skill is a router:

1. Exa first for fresh discovery
2. `context7` second for library docs
3. `read-github` second for GitHub repos

Do not treat these as competing tools. Treat them as a pipeline.

Current intended tools:
- `web_search_exa`
- `get_code_context_exa`
- `company_research_exa`
- `crawling_exa`
- `deep_researcher_start`
- `deep_researcher_check`

With the current local setup, Exa is configured globally in `~/.codex/config.toml` as:

`exa-mcp-server` via `npx` with `EXA_API_KEY` in the MCP server env.

## When To Prefer Exa

- Fresh web research for a technical or product question
- Code example search before implementation
- Research for a new skill, integration, adapter, or stack choice
- Better web grounding than generic search
- Company, product, or competitor research
- First-pass source discovery before switching to a deeper specialized skill

## Workflow

1. If Exa MCP tools are available in the current session, use them first for research-heavy tasks.
2. Use `web_search_exa` for:
   - current info
   - docs discovery
   - comparisons
   - finding primary sources
3. Use `get_code_context_exa` for:
   - implementation examples
   - library usage patterns
   - repo or framework context from the web
4. Use `company_research_exa` for:
   - company checks
   - product and market research
   - vendor or service analysis
5. Use `crawling_exa` when a specific page or source needs deeper extraction.
6. Use `deep_researcher_start` and `deep_researcher_check` only when the user wants a broader research pass, not for simple lookup.
7. If Exa returns a library or framework that needs official docs, switch to `$context7`.
8. If Exa surfaces a GitHub repository you need to inspect, switch to `$read-github`.
9. Keep queries narrow and task-shaped. Prefer:
   - stack name
   - exact feature
   - exact provider or API
   - timeframe if freshness matters
10. Summarize findings with links and say whether Exa-only or Exa-plus-followup was used.
11. If Exa MCP is unavailable in the current session, fall back to normal web/doc workflows and say so briefly.

## Query Style

Good:
- `next.js app router auth middleware example`
- `exa mcp codex setup`
- `fastapi sqlite graph visualization react-force-graph`

Bad:
- `how to build apps`
- `javascript examples`
- `graph stuff`

## Routing Rules

- Exa -> `context7`
  Use when search identifies a library or framework and you now need exact current docs.

- Exa -> `read-github`
  Use when search identifies a GitHub repo and you need repo docs or code search.

- Exa only
  Use when the task is mostly source discovery, comparison, market scan, company scan, or quick code-example discovery.

## Important Limits

- Exa being configured in `~/.codex/config.toml` does not guarantee that the current already-open chat sees the new MCP tools.
- After adding or changing the Exa MCP server, prefer a new chat or full Codex restart.
- Do not assume every Exa deployment exposes the same tool set; use only what is actually available in the session.

## Fallback

If Exa is not available:
- use the built-in web workflow
- use `context7` for library docs
- use `read-github` for GitHub repos
- do not pretend Exa ran if it did not
