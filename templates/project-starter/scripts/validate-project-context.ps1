Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$requiredPaths = @(
    'AGENTS.md',
    'README.md',
    '.codex\config.toml',
    '.codex\agents\AGENTS.md',
    '.codex\agents\repo-recon.toml',
    '.codex\agents\security-reviewer.toml',
    '.codex\agents\docs-researcher.toml',
    '.codex\agents\exa-researcher.toml',
    '.codex\agents\notebooklm-summarizer.toml',
    '.codex\agents\browser-debugger.toml',
    '.codex\agents\targeted-fixer.toml',
    'resume.ps1',
    'memory\PROJECT_CONTEXT.md',
    'memory\DEV_CONTEXT.md',
    'memory\diary\README.md',
    'inbox\now.md',
    'inbox\backlog.md',
    'runtime\research\README.md',
    'runtime\outputs\README.md',
    'runtime\scratch\README.md',
    'scripts\smoke-codex-subagents.ps1'
)

$errors = [System.Collections.Generic.List[string]]::new()

foreach ($relativePath in $requiredPaths) {
    $fullPath = Join-Path $projectRoot $relativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        $errors.Add("Missing required path: $relativePath")
    }
}

if ($errors.Count -gt 0) {
    Write-Host 'Project validation failed:' -ForegroundColor Red
    $errors | ForEach-Object {
        Write-Host " - $_"
    }
    exit 1
}

Write-Host 'Project validation passed.' -ForegroundColor Green
