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

function Get-FileStatus {
    param([string]$Root, [string]$RelativePath)

    $fullPath = Join-Path $Root $RelativePath
    if (Test-Path -LiteralPath $fullPath) {
        return 'ok'
    }

    return 'missing'
}

function Test-CodexCommand {
    $pathValue = Find-CommandPath -Name 'codex'
    if (-not $pathValue) {
        return [pscustomobject]@{
            Check  = 'codex executable'
            Status = 'missing'
            Detail = 'codex not found in PATH'
            Path   = '-'
        }
    }

    try {
        $output = (& $pathValue --version 2>&1 | Out-String).Trim()
        $exitCode = $LASTEXITCODE
        if ($exitCode -eq 0) {
            return [pscustomobject]@{
                Check  = 'codex executable'
                Status = 'ok'
                Detail = if ([string]::IsNullOrWhiteSpace($output)) { 'version probe passed' } else { $output }
                Path   = $pathValue
            }
        }

        if ($pathValue -like '*WindowsApps*' -and $output -match 'Access is denied') {
            return [pscustomobject]@{
                Check  = 'codex executable'
                Status = 'shell-blocked'
                Detail = 'WindowsApps package stub is not directly executable from shell; verify live spawn inside the Codex app.'
                Path   = $pathValue
            }
        }

        return [pscustomobject]@{
            Check  = 'codex executable'
            Status = 'blocked'
            Detail = if ([string]::IsNullOrWhiteSpace($output)) { "codex exited with code $exitCode" } else { $output }
            Path   = $pathValue
        }
    }
    catch {
        if ($pathValue -like '*WindowsApps*' -and $_.Exception.Message -match 'Access is denied') {
            return [pscustomobject]@{
                Check  = 'codex executable'
                Status = 'shell-blocked'
                Detail = 'WindowsApps package stub is not directly executable from shell; verify live spawn inside the Codex app.'
                Path   = $pathValue
            }
        }

        return [pscustomobject]@{
            Check  = 'codex executable'
            Status = 'blocked'
            Detail = $_.Exception.Message
            Path   = $pathValue
        }
    }
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

$codexRow = Test-CodexCommand
$codexConfigPath = Join-Path $resolvedRoot '.codex\config.toml'
$docsResearcherPath = Join-Path $resolvedRoot '.codex\agents\docs-researcher.toml'
$agentFiles = @(
    '.codex\agents\repo-recon.toml',
    '.codex\agents\security-reviewer.toml',
    '.codex\agents\docs-researcher.toml',
    '.codex\agents\exa-researcher.toml',
    '.codex\agents\notebooklm-summarizer.toml',
    '.codex\agents\browser-debugger.toml',
    '.codex\agents\targeted-fixer.toml'
)

$codexConfig = if (Test-Path -LiteralPath $codexConfigPath) {
    Get-Content -LiteralPath $codexConfigPath -Raw -Encoding utf8
} else {
    $null
}

$docsResearcherConfig = if (Test-Path -LiteralPath $docsResearcherPath) {
    Get-Content -LiteralPath $docsResearcherPath -Raw -Encoding utf8
} else {
    $null
}

$agentFilesPresent = ($agentFiles | Where-Object {
    Test-Path -LiteralPath (Join-Path $resolvedRoot $_)
}).Count

$subagentRows = @(
    [pscustomobject]@{
        Check  = '.codex/config.toml'
        Status = Get-FileStatus -Root $resolvedRoot -RelativePath '.codex\config.toml'
        Detail = 'project-scoped Codex config'
    },
    [pscustomobject]@{
        Check  = 'multi_agent'
        Status = if ($codexConfig -and $codexConfig -match '(?s)\[features\].*?multi_agent\s*=\s*true') { 'ok' } else { 'missing' }
        Detail = 'features.multi_agent = true'
    },
    [pscustomobject]@{
        Check  = 'custom agents'
        Status = if ($agentFilesPresent -eq $agentFiles.Count) { 'ok' } else { 'missing' }
        Detail = "$agentFilesPresent/$($agentFiles.Count) expected agent files"
    },
    [pscustomobject]@{
        Check  = 'docs MCP'
        Status = if ($docsResearcherConfig -and $docsResearcherConfig -match '(?s)\[mcp_servers\.openaiDeveloperDocs\].*?https://developers\.openai\.com/mcp') { 'ok' } else { 'missing' }
        Detail = 'docs_researcher local openaiDeveloperDocs MCP'
    }
)

$projectPaths = @(
    'AGENTS.md',
    'memory\PROJECT_CONTEXT.md',
    'memory\DEV_CONTEXT.md',
    'inbox\now.md',
    '.codex\config.toml'
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
Write-Host '=== Codex ===' -ForegroundColor Cyan
@($codexRow) | Format-Table -AutoSize

if ($codexConfig -or $agentFilesPresent -gt 0) {
    Write-Host ''
    Write-Host '=== Subagents ===' -ForegroundColor Cyan
    $subagentRows | Format-Table -AutoSize
}

Write-Host ''
Write-Host "=== Project Context ($resolvedRoot) ===" -ForegroundColor Cyan
$projectRows | Format-Table -AutoSize
