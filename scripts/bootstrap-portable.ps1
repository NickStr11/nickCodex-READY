param(
    [switch]$SkipValidation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot

function Test-Tool {
    param(
        [string]$Name,
        [string]$Command,
        [bool]$Required = $false,
        [string]$Reason
    )

    $found = $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
    [pscustomobject]@{
        Name = $Name
        Command = $Command
        Required = $Required
        Found = $found
        Reason = $Reason
    }
}

Write-Host 'nickCodex-READY bootstrap' -ForegroundColor Cyan
Write-Host "Repo root: $repoRoot"
Write-Host ''

$pathsToCheck = @(
    'AGENTS.md',
    'README.md',
    'DAILY.md',
    'PORTABILITY.md',
    'memory/DEV_CONTEXT.md',
    'inbox/now.md',
    'scripts/validate-context-pack.ps1'
)

$missingPaths = @()
foreach ($path in $pathsToCheck) {
    $fullPath = Join-Path $repoRoot $path
    if (-not (Test-Path -LiteralPath $fullPath)) {
        $missingPaths += $path
    }
}

if ($missingPaths.Count -gt 0) {
    Write-Host 'Missing core files:' -ForegroundColor Red
    $missingPaths | ForEach-Object { Write-Host " - $_" }
    exit 1
}

$tools = @(
    (Test-Tool -Name 'git' -Command 'git' -Required $true -Reason 'sync with GitHub and inspect repos'),
    (Test-Tool -Name 'powershell' -Command 'powershell' -Required $true -Reason 'run local bootstrap and validation scripts'),
    (Test-Tool -Name 'rg' -Command 'rg' -Required $false -Reason 'fast file discovery and search'),
    (Test-Tool -Name 'python' -Command 'python' -Required $false -Reason 'many external repos and helper scripts need it'),
    (Test-Tool -Name 'node' -Command 'node' -Required $false -Reason 'frontend and JS/TS repos'),
    (Test-Tool -Name 'npm' -Command 'npm' -Required $false -Reason 'Node package workflows'),
    (Test-Tool -Name 'pnpm' -Command 'pnpm' -Required $false -Reason 'common in modern frontend repos'),
    (Test-Tool -Name 'uv' -Command 'uv' -Required $false -Reason 'fast Python env and dependency workflow'),
    (Test-Tool -Name 'docker' -Command 'docker' -Required $false -Reason 'containers and compose-based repos'),
    (Test-Tool -Name 'gh' -Command 'gh' -Required $false -Reason 'GitHub workflows and repo operations')
)

Write-Host 'Tool check:'
foreach ($tool in $tools) {
    $status = if ($tool.Found) { 'OK' } elseif ($tool.Required) { 'MISSING' } else { 'optional' }
    $color = if ($tool.Found) { 'Green' } elseif ($tool.Required) { 'Red' } else { 'Yellow' }
    Write-Host (" - {0,-10} {1,-8} {2}" -f $tool.Name, $status, $tool.Reason) -ForegroundColor $color
}

$missingRequired = @($tools | Where-Object { -not $_.Found -and $_.Required })
if ($missingRequired.Count -gt 0) {
    Write-Host ''
    Write-Host 'Bootstrap failed: install missing required tools first.' -ForegroundColor Red
    exit 1
}

if (-not $SkipValidation) {
    Write-Host ''
    Write-Host 'Running context-pack validation...' -ForegroundColor Cyan
    & powershell -ExecutionPolicy Bypass -File (Join-Path $repoRoot 'scripts/validate-context-pack.ps1')
}

Write-Host ''
Write-Host 'Next steps:' -ForegroundColor Cyan
Write-Host ' - Open AGENTS.md for agent rules.'
Write-Host ' - Open DAILY.md for the short daily flow.'
Write-Host ' - Use repo-recon on the next unfamiliar repository.'
Write-Host ' - If the target system looks fragile, map contracts before refactoring.'
