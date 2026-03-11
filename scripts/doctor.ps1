param(
    [string]$TargetPath = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Find-CommandPath {
    param([string]$Name)

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        return $null
    }

    return $command.Source
}

$resolvedRoot = (Resolve-Path -LiteralPath $TargetPath).Path

$checks = @(
    @{ Name = 'git'; Required = $true },
    @{ Name = 'python'; Required = $true },
    @{ Name = 'ffmpeg'; Required = $false },
    @{ Name = 'ffprobe'; Required = $false },
    @{ Name = 'yt-dlp'; Required = $false },
    @{ Name = 'gcloud'; Required = $false }
)

$rows = foreach ($check in $checks) {
    $pathValue = Find-CommandPath -Name $check.Name
    [pscustomobject]@{
        Tool     = $check.Name
        Required = if ($check.Required) { 'yes' } else { 'optional' }
        Status   = if ($pathValue) { 'ok' } else { 'missing' }
        Path     = if ($pathValue) { $pathValue } else { '-' }
    }
}

$envRows = @(
    [pscustomobject]@{ Variable = 'GEMINI_API_KEY'; Status = if ($env:GEMINI_API_KEY) { 'set' } else { 'empty' } },
    [pscustomobject]@{ Variable = 'CONTEXT7_API_KEY'; Status = if ($env:CONTEXT7_API_KEY) { 'set' } else { 'empty' } },
    [pscustomobject]@{ Variable = 'OPENAI_API_KEY'; Status = if ($env:OPENAI_API_KEY) { 'set' } else { 'empty' } }
)

$projectPaths = @(
    'AGENTS.md',
    'memory\PROJECT_CONTEXT.md',
    'memory\DEV_CONTEXT.md',
    'inbox\now.md'
)

$projectRows = foreach ($relativePath in $projectPaths) {
    $fullPath = Join-Path $resolvedRoot $relativePath
    [pscustomobject]@{
        Path   = $relativePath
        Status = if (Test-Path -LiteralPath $fullPath) { 'ok' } else { 'missing' }
    }
}

Write-Host ''
Write-Host '=== Tooling ===' -ForegroundColor Cyan
$rows | Format-Table -AutoSize

Write-Host ''
Write-Host '=== Environment ===' -ForegroundColor Cyan
$envRows | Format-Table -AutoSize

Write-Host ''
Write-Host "=== Project Context ($resolvedRoot) ===" -ForegroundColor Cyan
$projectRows | Format-Table -AutoSize
