param(
    [string]$SourcePath = 'C:\Program Files\Obsidian\obsVaultPC\GameChanger\AI',
    [switch]$Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$profileFiles = @(
    'aboutme.md',
    'deep-values.md',
    'deep-philosophy.md',
    'writing-style.md'
)

if (-not (Test-Path -LiteralPath $SourcePath)) {
    Write-Host "Profile source not found: $SourcePath" -ForegroundColor Yellow
    Write-Host 'Pass -SourcePath if your Obsidian vault lives elsewhere.'
    exit 2
}

$missing = @()
foreach ($file in $profileFiles) {
    $sourceFile = Join-Path $SourcePath $file
    if (-not (Test-Path -LiteralPath $sourceFile)) {
        $missing += $file
    }
}

if ($missing.Count -gt 0) {
    Write-Host 'Missing profile source files:' -ForegroundColor Red
    $missing | ForEach-Object { Write-Host " - $_" }
    exit 1
}

if ($Check) {
    Write-Host 'Profile source files found.'
    exit 0
}

foreach ($file in $profileFiles) {
    $sourceFile = Join-Path $SourcePath $file
    $targetFile = Join-Path $repoRoot $file
    Copy-Item -LiteralPath $sourceFile -Destination $targetFile -Force
    Write-Host "synced $file"
}

Write-Host ''
Write-Host 'Next: review git diff, then commit intentional profile snapshot changes.'
