param(
    [string]$TargetRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$templateCodex = Join-Path $repoRoot 'templates\project-starter\.codex'
$templateSmoke = Join-Path $repoRoot 'templates\project-starter\scripts\smoke-codex-subagents.ps1'

if (-not (Test-Path -LiteralPath $templateCodex)) {
    throw "Template .codex folder not found: $templateCodex"
}

if (-not (Test-Path -LiteralPath $templateSmoke)) {
    throw "Template smoke script not found: $templateSmoke"
}

$targets = Get-ChildItem -LiteralPath $TargetRoot -Directory -Force | Where-Object {
    $_.FullName -ne $repoRoot -and
    $_.Name -ne 'claw-memory' -and
    (Test-Path -LiteralPath (Join-Path $_.FullName 'AGENTS.md')) -and
    (
        (Test-Path -LiteralPath (Join-Path $_.FullName 'memory\PROJECT_CONTEXT.md')) -or
        (Test-Path -LiteralPath (Join-Path $_.FullName 'inbox\now.md')) -or
        (Test-Path -LiteralPath (Join-Path $_.FullName 'runtime'))
    )
}

$rows = foreach ($target in $targets) {
    $codexTarget = Join-Path $target.FullName '.codex'
    $scriptsTarget = Join-Path $target.FullName 'scripts'
    if (-not (Test-Path -LiteralPath $codexTarget)) {
        New-Item -ItemType Directory -Path $codexTarget | Out-Null
    }
    if (-not (Test-Path -LiteralPath $scriptsTarget)) {
        New-Item -ItemType Directory -Path $scriptsTarget | Out-Null
    }

    Copy-Item -Path (Join-Path $templateCodex '*') -Destination $codexTarget -Recurse -Force
    Copy-Item -Path $templateSmoke -Destination (Join-Path $scriptsTarget 'smoke-codex-subagents.ps1') -Force

    $nestedCodex = Join-Path $codexTarget '.codex'
    if (Test-Path -LiteralPath $nestedCodex) {
        Copy-Item -Path (Join-Path $nestedCodex '*') -Destination $codexTarget -Recurse -Force
        Remove-Item -LiteralPath $nestedCodex -Recurse -Force
    }

    [pscustomobject]@{
        Repo     = $target.Name
        HasCodex = Test-Path -LiteralPath (Join-Path $codexTarget 'config.toml')
        HasSmoke = Test-Path -LiteralPath (Join-Path $target.FullName 'scripts\smoke-codex-subagents.ps1')
    }
}

Write-Host ''
Write-Host "=== Synced Project Subagents ($TargetRoot) ===" -ForegroundColor Cyan
$rows | Sort-Object Repo | Format-Table -AutoSize
