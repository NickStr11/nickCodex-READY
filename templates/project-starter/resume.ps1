Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$prompt = @"
Load the project context from $projectRoot.

Read first:
- $projectRoot\AGENTS.md
- $projectRoot\memory\PROJECT_CONTEXT.md
- $projectRoot\inbox\now.md

If you need the latest handoff:
- $projectRoot\memory\DEV_CONTEXT.md

Then briefly say:
1. what the current focus is
2. what the next step is
3. what should be done first
"@

Write-Host ''
Write-Host '=== Resume Prompt ===' -ForegroundColor Cyan
Write-Host $prompt
