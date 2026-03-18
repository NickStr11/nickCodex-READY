param(
    [switch]$SkipCodex,
    [switch]$SkipOpenClaw,
    [switch]$RunCodexLogin,
    [switch]$RunOpenClawOnboarding,
    [switch]$RunFinalizeWhenAuthReady
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$config = Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot 'openclaw-second-laptop.config.psd1')

function Write-Step {
    param([string]$Message)

    Write-Host ''
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-WarnLine {
    param([string]$Message)

    Write-Host "WARN: $Message" -ForegroundColor Yellow
}

function Test-CommandAvailable {
    param([string]$Name)

    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Ensure-Winget {
    if (-not (Test-CommandAvailable 'winget')) {
        throw 'winget is not available. Install App Installer first, then rerun this script.'
    }
}

function Add-NpmPrefixToPath {
    if (-not (Test-CommandAvailable 'npm')) {
        return
    }

    $prefix = (npm prefix -g).Trim()
    if ([string]::IsNullOrWhiteSpace($prefix)) {
        return
    }

    $parts = $env:Path -split ';'
    if ($parts -notcontains $prefix) {
        $env:Path = "$prefix;$env:Path"
    }
}

function Install-WithWinget {
    param(
        [string]$Id,
        [string]$Label
    )

    Ensure-Winget
    Write-Step "Installing $Label"
    winget install --id $Id --exact --source winget --accept-package-agreements --accept-source-agreements
}

function Ensure-Tool {
    param(
        [string]$Name,
        [string]$WingetId,
        [string]$Label
    )

    if (Test-CommandAvailable $Name) {
        Write-Host "$Label already installed" -ForegroundColor Green
        return
    }

    Install-WithWinget -Id $WingetId -Label $Label
}

$repoRoot = Split-Path -Parent $PSScriptRoot

Write-Host 'OpenClaw second-laptop bootstrap' -ForegroundColor Cyan
Write-Host "Repo root: $repoRoot"
Write-Host "Target model: $($config.OpenClawPrimaryModel)"

Ensure-Tool -Name 'git' -WingetId 'Git.Git' -Label 'Git'
Ensure-Tool -Name 'node' -WingetId 'OpenJS.NodeJS.LTS' -Label 'Node.js LTS'
Ensure-Tool -Name 'npm' -WingetId 'OpenJS.NodeJS.LTS' -Label 'npm'
Add-NpmPrefixToPath

if (-not $SkipCodex) {
    Write-Step 'Installing or updating Codex CLI'
    npm install -g @openai/codex@latest
    Add-NpmPrefixToPath

    if (-not (Test-CommandAvailable 'codex')) {
        throw "Codex CLI is still unavailable in PATH. Open a new terminal and rerun."
    }

    Write-Step 'Adding OpenAI developer docs MCP to Codex CLI'
    try {
        codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp | Out-Null
    }
    catch {
        Write-WarnLine 'Could not add openaiDeveloperDocs MCP automatically. Retry later with: codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp'
    }
}

if (-not $SkipOpenClaw) {
    Write-Step 'Installing or updating OpenClaw via official PowerShell installer'
    $installer = (Invoke-WebRequest -UseBasicParsing https://openclaw.ai/install.ps1).Content
    & ([scriptblock]::Create($installer)) -NoOnboard
    Add-NpmPrefixToPath

    if (-not (Test-CommandAvailable 'openclaw')) {
        Write-WarnLine "OpenClaw is not visible in PATH in this shell. Open a new terminal if the next command cannot find 'openclaw'."
    }
}

$portableBootstrap = Join-Path $repoRoot 'scripts\bootstrap-portable.ps1'
if (Test-Path -LiteralPath $portableBootstrap) {
    Write-Step 'Running local portable bootstrap'
    powershell -ExecutionPolicy Bypass -File $portableBootstrap
}

if ($RunCodexLogin -and -not $SkipCodex) {
    Write-Step 'Running Codex login'
    codex login
}

if ($RunOpenClawOnboarding -and -not $SkipOpenClaw) {
    Write-Step 'Running OpenClaw onboarding for OpenAI Codex subscription'
    openclaw onboard --auth-choice openai-codex --install-daemon
}

$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }
$authCachePath = Join-Path $codexHome 'auth.json'
$finalizeScript = Join-Path $repoRoot 'scripts\finalize-openclaw-laptop.ps1'

if ($RunFinalizeWhenAuthReady -and (Test-Path -LiteralPath $authCachePath) -and (Test-Path -LiteralPath $finalizeScript)) {
    Write-Step 'Codex auth cache already exists, running finalize step'
    powershell -ExecutionPolicy Bypass -File $finalizeScript
}

Write-Host ''
Write-Host 'Next steps:' -ForegroundColor Cyan

if (-not $SkipCodex) {
    Write-Host '1. Run `codex` (or `codex login`) and sign in with the second ChatGPT/Codex account.'
}
else {
    Write-Host '1. Sign in to Codex on this laptop with the second ChatGPT/Codex account.'
}

if (-not $SkipOpenClaw) {
    Write-Host "2. Then run `.\finalize-openclaw-laptop.ps1` to reuse Codex auth and pin `$($config.OpenClawPrimaryModel)`."
    Write-Host '3. Then check `openclaw gateway status`.'
    Write-Host '4. Then open `openclaw dashboard`.'
}
else {
    Write-Host '2. Install OpenClaw later, then run onboarding with the OpenAI Codex auth choice.'
}

Write-Host ''
Write-Host 'Notes:' -ForegroundColor Yellow
Write-Host '- Quick path: native Windows.'
Write-Host '- Stable path per current OpenClaw docs: WSL2.'
Write-Host '- If native Windows becomes flaky, use WSL-MIGRATION.md instead of endlessly patching the host setup.'
