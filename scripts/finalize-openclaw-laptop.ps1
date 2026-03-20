param(
    [switch]$SkipOnboarding,
    [switch]$SkipModelConfig
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

function Get-CodexHome {
    if ($env:CODEX_HOME) {
        return $env:CODEX_HOME
    }

    return Join-Path $env:USERPROFILE '.codex'
}

if (-not (Test-CommandAvailable 'openclaw')) {
    Write-WarnLine 'OpenClaw is not installed or not available in PATH.'
    Write-Host ''
    Write-Host 'Do this first:' -ForegroundColor Cyan
    Write-Host '1. Run .\setup-openclaw-laptop.ps1'
    Write-Host '2. Then rerun .\finalize-openclaw-laptop.ps1'
    exit 0
}

$codexHome = Get-CodexHome
$authCachePath = Join-Path $codexHome 'auth.json'
$configPath = (& openclaw config file).Trim()
$configExists = -not [string]::IsNullOrWhiteSpace($configPath) -and (Test-Path -LiteralPath $configPath)

Write-Host 'OpenClaw second-laptop finalize' -ForegroundColor Cyan
Write-Host "Codex auth cache: $authCachePath"
Write-Host "OpenClaw config path: $configPath"

if (-not (Test-Path -LiteralPath $authCachePath)) {
    Write-WarnLine 'Codex auth cache file was not found.'
    Write-Host ''
    Write-Host 'Do this first:' -ForegroundColor Cyan
    Write-Host '1. Open this repo in Codex.'
    Write-Host '2. Log in with the second ChatGPT/Codex account.'
    Write-Host '3. Rerun .\finalize-openclaw-laptop.ps1'
    exit 0
}

if (-not $SkipOnboarding) {
    if ($configExists) {
        Write-Step 'OpenClaw config already exists, skipping non-interactive onboarding'
    }
    else {
        Write-Step 'Running non-interactive OpenClaw onboarding with Codex auth reuse'
        try {
            openclaw onboard --non-interactive --auth-choice openai-codex --install-daemon --skip-health
        }
        catch {
            Write-WarnLine 'Non-interactive onboarding failed. You can retry manually with: openclaw onboard --auth-choice openai-codex --install-daemon'
        }
    }
}

if (-not $SkipModelConfig) {
    Write-Step "Pinning OpenClaw to $($config.OpenClawPrimaryModel)"
    openclaw config set agents.defaults.model.primary $config.OpenClawPrimaryModel

    $fastModeLiteral = if ($config.OpenClawFastMode) { 'true' } else { 'false' }

    Write-Step "Setting fastMode=$fastModeLiteral for $($config.OpenClawPrimaryModel)"
    openclaw config set "agents.defaults.models[`"$($config.OpenClawPrimaryModel)`"].params.fastMode" $fastModeLiteral --strict-json

    Write-Step 'Validating OpenClaw config'
    openclaw config validate
}

Write-Step 'Checking gateway status'
try {
    openclaw gateway status
}
catch {
    Write-WarnLine 'Gateway status check failed. If onboarding partially succeeded, run openclaw doctor and openclaw gateway install.'
}

Write-Host ''
Write-Host 'Next steps:' -ForegroundColor Cyan
Write-Host '1. Run openclaw dashboard'
Write-Host '2. If you need channels later, add them via openclaw configure or openclaw onboard'
Write-Host '3. If native Windows starts behaving like garbage, move OpenClaw via runbooks/openclaw/WSL-MIGRATION.md'
