Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$prompt = @"
Load the long-term memory repo from $repoRoot.

Read first:
- $repoRoot\AGENTS.md
- $repoRoot\persona\voice.md
- $repoRoot\persona\operator-rules.md
- $repoRoot\handoff\now.md
- $repoRoot\memory\user-profile.md
- $repoRoot\memory\stable-facts.md
- $repoRoot\memory\projects.md

If needed:
- $repoRoot\memory\relationships.md
- $repoRoot\handoff\recent-decisions.md
- $repoRoot\memory\CHANGELOG.md

Then briefly say:
1. what stable context matters here
2. what the current handoff says
3. what should be updated after this session
"@

Write-Host ''
Write-Host '=== Resume Prompt ===' -ForegroundColor Cyan
Write-Host $prompt
