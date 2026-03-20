Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$requiredPaths = @(
    'AGENTS.md',
    'README.md',
    'resume.ps1',
    'persona\voice.md',
    'persona\operator-rules.md',
    'memory\user-profile.md',
    'memory\stable-facts.md',
    'memory\projects.md',
    'memory\relationships.md',
    'memory\CHANGELOG.md',
    'handoff\now.md',
    'handoff\recent-decisions.md',
    'knowledge\imported\{{LEGACY_SOURCE_NAME}}\README.md',
    'runtime\imports\README.md'
)

$errors = [System.Collections.Generic.List[string]]::new()

foreach ($relativePath in $requiredPaths) {
    $fullPath = Join-Path $repoRoot $relativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        $errors.Add("Missing required path: $relativePath")
    }
}

if ($errors.Count -gt 0) {
    Write-Host 'Memory repo validation failed:' -ForegroundColor Red
    $errors | ForEach-Object {
        Write-Host " - $_"
    }
    exit 1
}

Write-Host 'Memory repo validation passed.' -ForegroundColor Green
